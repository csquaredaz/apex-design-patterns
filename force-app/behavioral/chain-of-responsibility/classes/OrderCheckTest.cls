@IsTest
private class OrderCheckTest {
  /** A check that always passes and counts how often it runs. */
  private class CountingCheck extends OrderCheck {
    Integer runs = 0;

    protected override String failureFor(OrderCandidate candidate) {
      runs++;
      return null;
    }

    protected override String name() {
      return 'Counting';
    }
  }

  private static OrderCheck standardChain() {
    OrderCheck first = new CreditLimitCheck(1000);
    first.andThen(new AddressCheck()).andThen(new EmbargoCheck(new Set<String>{ 'xx', null }));
    return first;
  }

  @IsTest
  static void check_validOrder_passesEveryLink() {
    CheckOutcome outcome = standardChain().check(new OrderCandidate(250, 'GB', 'SW1A 1AA'));

    Assert.isTrue(outcome.passed);
    Assert.isNull(outcome.failedCheck);
    Assert.isNull(outcome.reason);
  }

  @IsTest
  static void check_eachRuleBroken_namesTheFailingCheck() {
    OrderCheck chain = standardChain();

    Assert.areEqual('Credit limit', chain.check(new OrderCandidate(1500, 'GB', 'SW1A 1AA')).failedCheck);
    Assert.areEqual('Address', chain.check(new OrderCandidate(10, 'GB', ' ')).failedCheck);
    Assert.areEqual('Embargo', chain.check(new OrderCandidate(10, 'XX', '123')).failedCheck, 'codes match in any case');
    Assert.isTrue(chain.check(new OrderCandidate(1500, 'GB', 'X')).reason.contains('over the limit of 1000'));
  }

  @IsTest
  static void check_earlyFailure_laterLinksNeverRun() {
    CountingCheck later = new CountingCheck();
    OrderCheck first = new CreditLimitCheck(100);
    first.andThen(later);

    first.check(new OrderCandidate(500, 'GB', 'X'));
    Assert.areEqual(0, later.runs, 'the chain stops at the first failure');

    first.check(new OrderCandidate(50, 'GB', 'X'));
    Assert.areEqual(1, later.runs, 'a pass hands the order on');
  }

  @IsTest
  static void check_linkOrder_decidesWhichFailureIsReported() {
    OrderCandidate badEverywhere = new OrderCandidate(5000, 'XX', null);
    OrderCheck embargoFirst = new EmbargoCheck(new Set<String>{ 'XX' });
    embargoFirst.andThen(new CreditLimitCheck(100));

    Assert.areEqual('Credit limit', standardChain().check(badEverywhere).failedCheck);
    Assert.areEqual('Embargo', embargoFirst.check(badEverywhere).failedCheck);
  }

  @IsTest
  static void andThen_nullOrSelf_rejected() {
    OrderCheck check = new AddressCheck();
    Integer rejected = 0;
    for (OrderCheck nextCheck : new List<OrderCheck>{ null, check }) {
      try {
        check.andThen(nextCheck);
      } catch (IllegalArgumentException e) {
        rejected++;
      }
    }
    Assert.areEqual(2, rejected);
  }

  @IsTest
  static void check_twoHundredOrders_eachJudgedAlone() {
    OrderCheck chain = standardChain();
    Integer passed = 0;
    for (Integer i = 0; i < 200; i++) {
      if (chain.check(new OrderCandidate(i * 10, 'GB', 'SW1A 1AA')).passed) {
        passed++;
      }
    }

    Assert.areEqual(101, passed, 'totals 0 to 1000 pass, 1010 and above fail');
  }
}
