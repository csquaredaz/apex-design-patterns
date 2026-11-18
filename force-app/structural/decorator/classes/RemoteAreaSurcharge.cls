/**
 * @description Adds a flat fee for remote delivery areas.
 * @group Structural
 */
public with sharing class RemoteAreaSurcharge extends ShippingCostDecorator {
  private final Decimal flatFee;

  /**
   * @description Wraps a cost with a flat remote-area fee.
   * @param wrapped The cost to wrap.
   * @param flatFee The fee; must be zero or more.
   * @throws IllegalArgumentException If `wrapped` is null or the fee is null or negative.
   */
  public RemoteAreaSurcharge(IShippingCost wrapped, Decimal flatFee) {
    super(wrapped);
    if (flatFee == null || flatFee < 0) {
      throw new IllegalArgumentException('Remote area fee must be zero or more, not ' + flatFee);
    }
    this.flatFee = flatFee.setScale(2, RoundingMode.HALF_UP);
  }

  /**
   * @description The wrapped amount plus the flat fee.
   * @return The amount.
   */
  public override Decimal amount() {
    return wrapped.amount() + flatFee;
  }

  protected override String describe() {
    return 'Remote area: +' + flatFee;
  }
}
