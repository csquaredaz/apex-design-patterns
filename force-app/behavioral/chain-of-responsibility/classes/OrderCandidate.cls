/**
 * @description An order waiting for its pre-acceptance checks.
 * @group Behavioral
 */
public with sharing class OrderCandidate {
  /** @description The order total. */
  public final Decimal total;
  /** @description The destination's ISO 3166 country code, for example `GB`. */
  public final String countryCode;
  /** @description The destination postal code. */
  public final String postalCode;

  /**
   * @description Creates a candidate.
   * @param total The order total.
   * @param countryCode The destination country code.
   * @param postalCode The destination postal code.
   */
  public OrderCandidate(Decimal total, String countryCode, String postalCode) {
    this.total = total;
    this.countryCode = countryCode;
    this.postalCode = postalCode;
  }
}
