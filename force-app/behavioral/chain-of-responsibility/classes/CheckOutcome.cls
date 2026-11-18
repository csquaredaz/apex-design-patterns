/**
 * @description The result of running a chain of `OrderCheck`s: passed, or the first check that failed
 * and why.
 * @group Behavioral
 */
public with sharing class CheckOutcome {
  /** @description True if every check in the chain passed. */
  public final Boolean passed;
  /** @description The name of the check that failed; null if passed. */
  public final String failedCheck;
  /** @description Why it failed; null if passed. */
  public final String reason;

  private CheckOutcome(Boolean passed, String failedCheck, String reason) {
    this.passed = passed;
    this.failedCheck = failedCheck;
    this.reason = reason;
  }

  /**
   * @description Every check passed.
   * @return The outcome.
   */
  public static CheckOutcome pass() {
    return new CheckOutcome(true, null, null);
  }

  /**
   * @description A check failed.
   * @param failedCheck The check's name.
   * @param reason Why.
   * @return The outcome.
   */
  public static CheckOutcome fail(String failedCheck, String reason) {
    return new CheckOutcome(false, failedCheck, reason);
  }
}
