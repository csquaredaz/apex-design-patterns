/**
 * @description A shipping cost and how it was built up. The base cost and every surcharge implement
 * it, so surcharges wrap each other in any combination (Decorator).
 * @group Structural
 */
public interface IShippingCost {
  /**
   * @description The cost, including every layer below this one.
   * @return The amount, rounded to 2 decimal places.
   */
  Decimal amount();

  /**
   * @description One line per layer, innermost first, for an invoice or a support agent.
   * @return The breakdown lines.
   */
  List<String> breakdown();
}
