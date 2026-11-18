/**
 * @description One warehouse's part of a split order, as `WarehouseSplitter` produces it.
 * @group EIP
 */
public with sharing class WarehousePick {
  /** @description The order reference: the correlation id the aggregator groups by. */
  public final String orderRef;
  /** @description The warehouse that picks these lines. */
  public final String warehouse;
  /** @description How many picks the order was split into. */
  public final Integer partCount;
  /** @description The lines this warehouse picks. */
  public final Map<String, Integer> quantityBySku;

  // A value object's constructor takes exactly its fields. If they grow, use a Builder (creational/builder).
  /**
   * @description Creates a pick. The lines are copied.
   * @param orderRef The order reference.
   * @param warehouse The warehouse.
   * @param partCount How many picks the order became.
   * @param quantityBySku The lines.
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public WarehousePick(String orderRef, String warehouse, Integer partCount, Map<String, Integer> quantityBySku) {
    this.orderRef = orderRef;
    this.warehouse = warehouse;
    this.partCount = partCount;
    this.quantityBySku = quantityBySku == null ? new Map<String, Integer>() : quantityBySku.clone();
  }

  /**
   * @description The warehouse's confirmation for this pick, carrying the pick's correlation data.
   * @param trackingNumber The tracking number of the parcel the warehouse sent.
   * @return The confirmation.
   */
  public PickConfirmation confirm(String trackingNumber) {
    return new PickConfirmation(this, trackingNumber);
  }
}
