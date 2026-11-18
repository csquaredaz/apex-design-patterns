/**
 * @description A warehouse's reply that a pick has shipped: the message `PickAggregator` collects.
 * It's built from its pick (`WarehousePick.confirm`), so it always carries that pick's correlation id
 * and part count.
 * @group EIP
 */
public with sharing class PickConfirmation {
  /** @description The order reference (correlation id). */
  public final String orderRef;
  /** @description The warehouse that shipped. */
  public final String warehouse;
  /** @description How many picks the order was split into. */
  public final Integer partCount;
  /** @description The parcel's tracking number. */
  public final String trackingNumber;

  /**
   * @description Creates a confirmation for a pick.
   * @param pick The pick being confirmed.
   * @param trackingNumber The parcel's tracking number.
   * @throws IllegalArgumentException If the pick is null or the tracking number is blank.
   */
  public PickConfirmation(WarehousePick pick, String trackingNumber) {
    if (pick == null || String.isBlank(trackingNumber)) {
      throw new IllegalArgumentException('A confirmation needs its pick and a tracking number');
    }
    this.orderRef = pick.orderRef;
    this.warehouse = pick.warehouse;
    this.partCount = pick.partCount;
    this.trackingNumber = trackingNumber;
  }
}
