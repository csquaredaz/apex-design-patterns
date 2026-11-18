/**
 * @description A rule for choosing one quote from several (Strategy). `RateShopper` is given one
 * and doesn't know which.
 * @group Behavioral
 */
public interface IRateStrategy {
  /**
   * @description Chooses the best quote under this rule. Ties must be broken deterministically, so
   * the same quotes always give the same answer.
   * @param quotes The quotes; never null or empty.
   * @return The chosen quote.
   */
  CarrierQuote choose(List<CarrierQuote> quotes);
}
