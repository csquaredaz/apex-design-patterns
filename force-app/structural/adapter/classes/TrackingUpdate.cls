/**
 * @description One tracking event in our own model, whichever carrier reported it.
 * @group Structural
 */
public with sharing class TrackingUpdate {
  /** @description The carrier's tracking number. */
  public final String trackingNumber;
  /** @description Our status for the event. */
  public final TrackingStatus status;
  /** @description The carrier's own status code, kept for support and for `UNKNOWN` statuses. */
  public final String carrierStatusCode;
  /** @description When the event happened, in GMT. */
  public final Datetime occurredAt;

  // A value object's constructor takes exactly its fields. If they grow, use a Builder (creational/builder).
  /**
   * @description Creates a tracking update.
   * @param trackingNumber The tracking number.
   * @param status Our status.
   * @param carrierStatusCode The carrier's code.
   * @param occurredAt When it happened.
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  public TrackingUpdate(String trackingNumber, TrackingStatus status, String carrierStatusCode, Datetime occurredAt) {
    this.trackingNumber = trackingNumber;
    this.status = status;
    this.carrierStatusCode = carrierStatusCode;
    this.occurredAt = occurredAt;
  }
}
