/**
 * @description One tracking scan as it arrives from a carrier: the message `TrackingRouter` routes.
 * @group EIP
 */
public with sharing class TrackingScan {
  /** @description The carrier that sent the scan, for example `parcelco`; the router's key. */
  public final String carrierCode;
  /** @description The carrier's tracking number. */
  public final String trackingNumber;
  /** @description The carrier's status text, as sent. */
  public final String status;

  /**
   * @description Creates a scan.
   * @param carrierCode The carrier code.
   * @param trackingNumber The tracking number.
   * @param status The carrier's status text.
   */
  public TrackingScan(String carrierCode, String trackingNumber, String status) {
    this.carrierCode = carrierCode;
    this.trackingNumber = trackingNumber;
    this.status = status;
  }
}
