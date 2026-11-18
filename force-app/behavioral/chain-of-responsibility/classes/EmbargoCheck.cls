/**
 * @description Rejects orders to countries the business can't ship to.
 * @group Behavioral
 */
public with sharing class EmbargoCheck extends OrderCheck {
  private final Set<String> embargoed = new Set<String>();

  /**
   * @description Creates the check.
   * @param embargoedCountries Country codes, in any case.
   */
  public EmbargoCheck(Set<String> embargoedCountries) {
    for (String code : embargoedCountries ?? new Set<String>()) {
      if (code != null) {
        embargoed.add(code.toUpperCase());
      }
    }
  }

  protected override String failureFor(OrderCandidate candidate) {
    return embargoed.contains(candidate.countryCode?.toUpperCase())
      ? 'Shipping to ' + candidate.countryCode + ' is not allowed'
      : null;
  }

  protected override String name() {
    return 'Embargo';
  }
}
