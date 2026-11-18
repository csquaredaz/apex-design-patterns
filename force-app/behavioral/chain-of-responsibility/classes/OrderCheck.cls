/**
 * @description One link in a chain of order checks (Chain of Responsibility). Each link either
 * rejects the order, which ends the chain, or hands it to the next link. Callers hold only the first
 * link, so checks can be added, removed or reordered where the chain is built.
 * @group Behavioral
 */
public abstract with sharing class OrderCheck {
  private OrderCheck next;

  /**
   * @description Links the next check. Returns that check, so a chain reads left to right:
   * `first.andThen(second).andThen(third)`. Keep a reference to `first`.
   * @param nextCheck The check to run after this one passes.
   * @return `nextCheck`.
   * @throws IllegalArgumentException If `nextCheck` is null or is this check.
   */
  public OrderCheck andThen(OrderCheck nextCheck) {
    if (nextCheck == null || nextCheck === this) {
      throw new IllegalArgumentException('A check must link to a different, non-null check');
    }
    next = nextCheck;
    return nextCheck;
  }

  /**
   * @description Runs this check and, if it passes, the rest of the chain.
   * @param candidate The order to check.
   * @return The first failure, or a pass if every check passed.
   */
  public CheckOutcome check(OrderCandidate candidate) {
    String failure = failureFor(candidate);
    if (failure != null) {
      return CheckOutcome.fail(name(), failure);
    }
    return next == null ? CheckOutcome.pass() : next.check(candidate);
  }

  /**
   * @description This link's rule.
   * @param candidate The order.
   * @return Why the order fails, or null if it passes.
   */
  protected abstract String failureFor(OrderCandidate candidate);

  /**
   * @description This link's name, reported when it fails.
   * @return The name.
   */
  protected abstract String name();
}
