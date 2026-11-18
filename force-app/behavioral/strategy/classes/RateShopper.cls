/**
 * @description Picks a carrier quote using whichever `IRateStrategy` it was given (the Strategy's
 * context). The caller chooses the rule, for example cheapest for standard orders and fastest for
 * express ones, and the shopper stays the same.
 * @group Behavioral
 */
public with sharing class RateShopper {
  private final IRateStrategy strategy;

  /**
   * @description Creates a shopper with a rule.
   * @param strategy The rule; must not be null.
   * @throws IllegalArgumentException If the strategy is null.
   */
  public RateShopper(IRateStrategy strategy) {
    if (strategy == null) {
      throw new IllegalArgumentException('RateShopper needs a rate strategy');
    }
    this.strategy = strategy;
  }

  /**
   * @description Picks the best quote under the shopper's rule.
   * @param quotes The quotes to choose from.
   * @return The chosen quote.
   * @throws NoQuoteException If there are no quotes.
   */
  public CarrierQuote bestQuote(List<CarrierQuote> quotes) {
    if (quotes == null || quotes.isEmpty()) {
      throw new NoQuoteException('No carrier quoted for this shipment');
    }
    return strategy.choose(quotes);
  }

  /** @description Thrown when there is nothing to choose from. */
  public class NoQuoteException extends Exception {
  }
}
