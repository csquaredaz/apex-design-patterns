/**
 * @description The carrier's base rate: the innermost `IShippingCost` that surcharges wrap.
 * @group Structural
 */
public with sharing class BaseShippingCost implements IShippingCost {
  private final Decimal baseAmount;

  /**
   * @description Creates the base cost.
   * @param amount The base rate; must not be null or negative.
   * @throws IllegalArgumentException If the amount is null or negative.
   */
  public BaseShippingCost(Decimal amount) {
    if (amount == null || amount < 0) {
      throw new IllegalArgumentException('Base shipping cost must be zero or more, not ' + amount);
    }
    baseAmount = amount.setScale(2, RoundingMode.HALF_UP);
  }

  /**
   * @description The base rate.
   * @return The amount.
   */
  public Decimal amount() {
    return baseAmount;
  }

  /**
   * @description The base rate's breakdown line.
   * @return One line.
   */
  public List<String> breakdown() {
    return new List<String>{ 'Base rate: ' + baseAmount };
  }
}
