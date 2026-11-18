/**
 * @description The outcome of `CheckoutFacade.checkout`: either a priced, booked order or the
 * reason it wasn't completed.
 * @group Structural
 */
public with sharing class CheckoutResult {
  /** @description True if stock is reserved and a shipment is booked. */
  public final Boolean success;
  /** @description The basket total; null if pricing wasn't reached. */
  public final Decimal total;
  /** @description The carrier's tracking number; null unless `success`. */
  public final String trackingNumber;
  /** @description Why checkout failed; null on success. */
  public final String failureReason;

  // A value object's constructor takes exactly its fields; callers use completed() or failed().
  @SuppressWarnings('PMD.ExcessiveParameterList')
  private CheckoutResult(Boolean success, Decimal total, String trackingNumber, String failureReason) {
    this.success = success;
    this.total = total;
    this.trackingNumber = trackingNumber;
    this.failureReason = failureReason;
  }

  /**
   * @description A completed checkout.
   * @param total The basket total.
   * @param trackingNumber The tracking number.
   * @return The result.
   */
  public static CheckoutResult completed(Decimal total, String trackingNumber) {
    return new CheckoutResult(true, total, trackingNumber, null);
  }

  /**
   * @description A checkout that stopped.
   * @param total The basket total, if pricing ran.
   * @param reason Why it stopped.
   * @return The result.
   */
  public static CheckoutResult failed(Decimal total, String reason) {
    return new CheckoutResult(false, total, null, reason);
  }
}
