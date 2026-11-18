@IsTest
private class ShippingCostDecoratorTest {
  /** A stubbed wrapped cost that records how often each method is called. */
  private class InnerCostStub implements System.StubProvider {
    private final Decimal amount;
    private final Map<String, Integer> calls = new Map<String, Integer>();

    InnerCostStub(Decimal amount) {
      this.amount = amount;
    }

    /**
     * @description Answers every stubbed call. The six parameters are fixed by System.StubProvider.
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public Object handleMethodCall(
      Object stubbedObject,
      String methodName,
      Type returnType,
      List<Type> paramTypes,
      List<String> paramNames,
      List<Object> args
    ) {
      calls.put(methodName, (calls.get(methodName) ?? 0) + 1);
      return methodName == 'amount' ? (Object) amount : (Object) new List<String>{ 'Stub rate: ' + amount };
    }

    Integer callCount(String methodName) {
      return calls.get(methodName) ?? 0;
    }
  }

  @IsTest
  static void amount_stackedSurcharges_addEachLayer() {
    IShippingCost cost = new FragileSurcharge(new RemoteAreaSurcharge(new BaseShippingCost(10), 5), 10);

    Assert.areEqual(16.50, cost.amount(), '(10 + 5) + 10%');
    Assert.areEqual(
      new List<String>{ 'Base rate: 10.00', 'Remote area: +5.00', 'Fragile handling: +10%' },
      cost.breakdown(),
      'one line per layer, innermost first'
    );
  }

  @IsTest
  static void amount_stackOrderChanged_totalChanges() {
    IShippingCost fragileFirst = new RemoteAreaSurcharge(new FragileSurcharge(new BaseShippingCost(10), 10), 5);
    IShippingCost remoteFirst = new FragileSurcharge(new RemoteAreaSurcharge(new BaseShippingCost(10), 5), 10);

    Assert.areEqual(16.00, fragileFirst.amount(), '10 + 10% + 5');
    Assert.areEqual(16.50, remoteFirst.amount(), 'the percentage now applies to the remote fee too');
  }

  @IsTest
  static void decorator_wrapsAnyCost_delegatesToInner() {
    InnerCostStub stub = new InnerCostStub(20);
    IShippingCost stubbedCost = (IShippingCost) Test.createStub(IShippingCost.class, stub);

    IShippingCost cost = new RemoteAreaSurcharge(stubbedCost, 2.5);

    Assert.areEqual(22.50, cost.amount());
    Assert.areEqual(new List<String>{ 'Stub rate: 20', 'Remote area: +2.50' }, cost.breakdown());
    Assert.areEqual(1, stub.callCount('amount'), 'a decorator calls its wrapped cost once per call');
    Assert.areEqual(1, stub.callCount('breakdown'));
  }

  @IsTest
  static void constructors_invalidArguments_rejected() {
    List<String> rejected = new List<String>();
    List<String> cases = new List<String>{ 'null wrapped', 'negative fee', 'percent over 100', 'negative base' };
    for (String c : cases) {
      try {
        switch on c {
          when 'null wrapped' {
            new RemoteAreaSurcharge(null, 1);
          }
          when 'negative fee' {
            new RemoteAreaSurcharge(new BaseShippingCost(1), -1);
          }
          when 'percent over 100' {
            new FragileSurcharge(new BaseShippingCost(1), 101);
          }
          when else {
            new BaseShippingCost(-0.01);
          }
        }
      } catch (IllegalArgumentException e) {
        rejected.add(c);
      }
    }
    Assert.areEqual(cases, rejected, 'every invalid argument is rejected');
  }

  @IsTest
  static void amount_twoHundredLayers_staysExact() {
    IShippingCost cost = new BaseShippingCost(0);
    for (Integer i = 0; i < 200; i++) {
      cost = new RemoteAreaSurcharge(cost, 0.01);
    }

    Assert.areEqual(2.00, cost.amount());
    Assert.areEqual(201, cost.breakdown().size());
  }
}
