/**
 * @description Chooses the shortest transit time; ties go to the cheaper quote, then to the carrier
 * code in alphabetical order.
 * @group Behavioral
 */
public with sharing class FastestRate implements IRateStrategy {
  /**
   * @description Chooses the fastest quote.
   * @param quotes The quotes.
   * @return The fastest quote.
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
    if (candidate.transitDays != best.transitDays) {
      return candidate.transitDays < best.transitDays;
    }
    if (candidate.price != best.price) {
      return candidate.price < best.price;
    }
    return candidate.carrierCode < best.carrierCode;
  }
}
