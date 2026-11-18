/**
 * @description Adds a percentage of everything it wraps, for fragile handling. Because it is a
 * percentage, where it sits in the stack changes the total.
 * @group Structural
 */
public with sharing class FragileSurcharge extends ShippingCostDecorator {
  private final Decimal percent;

  /**
   * @description Wraps a cost with a fragile-handling percentage.
   * @param wrapped The cost to wrap.
   * @param percent The percentage, from 0 to 100.
   * @throws IllegalArgumentException If `wrapped` is null or the percentage is outside 0–100.
   */
  public FragileSurcharge(IShippingCost wrapped, Decimal percent) {
    super(wrapped);
    if (percent == null || percent < 0 || percent > 100) {
      throw new IllegalArgumentException('Fragile surcharge must be 0-100%, not ' + percent);
    }
    this.percent = percent;
  }

  /**
   * @description The wrapped amount plus the percentage of it.
   * @return The amount, rounded to 2 decimal places.
   */
  public override Decimal amount() {
    Decimal wrappedAmount = wrapped.amount();
    return (wrappedAmount + wrappedAmount * percent / 100).setScale(2, RoundingMode.HALF_UP);
  }

  protected override String describe() {
    return 'Fragile handling: +' + percent + '%';
  }
}
