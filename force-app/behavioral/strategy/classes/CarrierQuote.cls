/**
 * @description One carrier's offer for a shipment: a price and a transit time.
 * @group Behavioral
 */
public with sharing class CarrierQuote {
  /** @description The carrier code, for example `PARCELCO`. */
  public final String carrierCode;
  /** @description The quoted price. */
  public final Decimal price;
  /** @description Working days in transit. */
  public final Integer transitDays;

  /**
   * @description Creates a quote.
   * @param carrierCode The carrier code.
   * @param price The price; zero or more.
   * @param transitDays Days in transit; zero or more.
   * @throws IllegalArgumentException If the carrier is blank or a number is null or negative.
   */
  public CarrierQuote(String carrierCode, Decimal price, Integer transitDays) {
    if (String.isBlank(carrierCode) || price == null || price < 0 || transitDays == null || transitDays < 0) {
      throw new IllegalArgumentException('A quote needs a carrier, a price and transit days of zero or more');
    }
    this.carrierCode = carrierCode;
    this.price = price;
    this.transitDays = transitDays;
  }
}
