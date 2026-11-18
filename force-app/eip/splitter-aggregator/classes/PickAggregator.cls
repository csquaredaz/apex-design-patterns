/**
 * @description Collects pick confirmations by order and releases an order once every pick has
 * been confirmed (Aggregator). The completeness rule is the part count each confirmation carries.
 * A repeated confirmation (same order and warehouse) is ignored, so redelivery is harmless.
 * State lives in this instance, so it lasts one transaction; a production aggregator stores it and
 * needs a timeout for picks that never come back (see this pattern's card).
 * @group EIP
 */
public with sharing class PickAggregator {
  private final Map<String, Integer> partCountByOrder = new Map<String, Integer>();
  private final Map<String, Map<String, String>> trackingByOrder = new Map<String, Map<String, String>>();

  /**
   * @description Adds a batch of confirmations.
   * @param confirmations The confirmations, in any order and from any mix of orders.
   * @return The orders this batch completed, in the order they completed. An order is released
   * once; later confirmations for it are ignored.
   * @throws IllegalArgumentException If a confirmation is null, or its part count disagrees with an
   * earlier one for the same order. Nothing in the batch is applied then.
   */
  public List<AssembledOrder> add(List<PickConfirmation> confirmations) {
    List<AssembledOrder> completed = new List<AssembledOrder>();
    if (confirmations == null) {
      return completed;
    }
    validate(confirmations);
    for (PickConfirmation confirmation : confirmations) {
      if (!partCountByOrder.containsKey(confirmation.orderRef)) {
        partCountByOrder.put(confirmation.orderRef, confirmation.partCount);
        trackingByOrder.put(confirmation.orderRef, new Map<String, String>());
      }
      Map<String, String> tracking = trackingByOrder.get(confirmation.orderRef);
      if (tracking == null || tracking.containsKey(confirmation.warehouse)) {
        continue; // already released, or a repeat of a part we hold
      }
      tracking.put(confirmation.warehouse, confirmation.trackingNumber);
      if (tracking.size() == confirmation.partCount) {
        completed.add(new AssembledOrder(confirmation.orderRef, tracking));
        trackingByOrder.put(confirmation.orderRef, null); // released: remember it, hold nothing
      }
    }
    return completed;
  }

  /**
   * @description How many orders have some, but not all, of their picks confirmed.
   * @return The number of orders still waiting.
   */
  public Integer pendingCount() {
    Integer pending = 0;
    for (Map<String, String> tracking : trackingByOrder.values()) {
      if (tracking != null) {
        pending++;
      }
    }
    return pending;
  }

  // Check the whole batch first, so a bad confirmation can't leave it half applied.
  private void validate(List<PickConfirmation> confirmations) {
    Map<String, Integer> seen = partCountByOrder.clone();
    for (PickConfirmation confirmation : confirmations) {
      if (confirmation == null) {
        throw new IllegalArgumentException('A batch cannot contain a null confirmation');
      }
      Integer known = seen.get(confirmation.orderRef);
      if (known != null && known != confirmation.partCount) {
        throw new IllegalArgumentException(
          'Order ' + confirmation.orderRef + ' was split into ' + known + ' picks, not ' + confirmation.partCount
        );
      }
      seen.put(confirmation.orderRef, confirmation.partCount);
    }
  }
}
