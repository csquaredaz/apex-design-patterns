/**
 * @description Rejects orders above a credit limit.
 * @group Behavioral
 */
public with sharing class CreditLimitCheck extends OrderCheck {
  private final Decimal limitAmount;

  /**
   * @description Creates the check.
   * @param limitAmount The highest order total accepted.
   */
  public CreditLimitCheck(Decimal limitAmount) {
    this.limitAmount = limitAmount;
  }

  protected override String failureFor(OrderCandidate candidate) {
    return candidate.total > limitAmount ? 'Total ' + candidate.total + ' is over the limit of ' + limitAmount : null;
  }

  protected override String name() {
    return 'Credit limit';
  }
}
