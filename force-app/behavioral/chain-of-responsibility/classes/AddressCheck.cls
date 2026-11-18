/**
 * @description Rejects orders without a country and postal code to ship to.
 * @group Behavioral
 */
public with sharing class AddressCheck extends OrderCheck {
  protected override String failureFor(OrderCandidate candidate) {
    return String.isBlank(candidate.countryCode) || String.isBlank(candidate.postalCode)
      ? 'A destination country and postal code are required'
      : null;
  }

  protected override String name() {
    return 'Address';
  }
}
