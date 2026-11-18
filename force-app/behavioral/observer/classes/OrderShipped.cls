/**
 * @description An order left the warehouse: the in-transaction event `OrderShippedSubject` sends.
 * @group Behavioral
 */
public with sharing class OrderShipped {
  /** @description The order reference. */
  public final String orderReference;
  /** @description The carrier's tracking number. */
  public final String trackingNumber;

  /**
   * @description Creates the event.
   * @param orderReference The order reference.
   * @param trackingNumber The tracking number.
   */
  public OrderShipped(String orderReference, String trackingNumber) {
    this.orderReference = orderReference;
    this.trackingNumber = trackingNumber;
  }
}
