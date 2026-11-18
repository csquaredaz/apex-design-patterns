/**
 * @description An order whose every pick is confirmed: what `PickAggregator` releases.
 * @group EIP
 */
public with sharing class AssembledOrder {
  /** @description The order reference. */
  public final String orderRef;
  /** @description Each warehouse's tracking number. */
  public final Map<String, String> trackingByWarehouse;

  /**
   * @description Creates the assembled order. The map is copied.
   * @param orderRef The order reference.
   * @param trackingByWarehouse Each warehouse's tracking number.
   */
  public AssembledOrder(String orderRef, Map<String, String> trackingByWarehouse) {
    this.orderRef = orderRef;
    this.trackingByWarehouse = trackingByWarehouse.clone();
  }
}
