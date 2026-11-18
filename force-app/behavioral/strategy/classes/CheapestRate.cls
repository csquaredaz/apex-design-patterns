/**
 * @description Chooses the lowest price; ties go to the faster quote, then to the carrier code
 * in alphabetical order.
 * @group Behavioral
 */
public with sharing class CheapestRate implements IRateStrategy {
  /**
   * @description Chooses the cheapest quote.
   * @param quotes The quotes.
   * @return The cheapest quote.
   */
  public CarrierQuote choose(List<CarrierQuote> quotes) {
    CarrierQuote best = quotes[0];
    for (CarrierQuote candidate : quotes) {
      if (isBetter(candidate, best)) {
        best = candidate;
      }
    }
    return best;
  }

  private static Boolean isBetter(CarrierQuote candidate, CarrierQuote best) {
    if (candidate.price != best.price) {
      return candidate.price < best.price;
    }
    if (candidate.transitDays != best.transitDays) {
      return candidate.transitDays < best.transitDays;
    }
    return candidate.carrierCode < best.carrierCode;
  }
}
