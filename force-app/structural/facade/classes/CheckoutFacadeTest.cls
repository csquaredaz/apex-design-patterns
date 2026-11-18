@IsTest
private class CheckoutFacadeTest {
  private static final Map<String, Integer> BASKET = new Map<String, Integer>{ 'MUG' => 2 };

  /** One stub provider for all three subsystems; it records every call in order. */
  private class Subsystems implements System.StubProvider {
    Boolean stockAvailable = true;
    Boolean carrierDown = false;
    final List<String> calls = new List<String>();

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
      calls.add(methodName);
      switch on methodName {
        when 'priceOf' {
          return 17.00;
        }
        when 'reserve' {
          return stockAvailable;
        }
        when 'book' {
          if (carrierDown) {
            throw new ShipmentBookingException('carrier timeout');
          }
          return 'TRK-' + args[0];
        }
        when else {
          return null;
        }
      }
    }

    CheckoutFacade facade() {
      return new CheckoutFacade(
        (ICheckoutPricing) Test.createStub(ICheckoutPricing.class, this),
        (IStockReservation) Test.createStub(IStockReservation.class, this),
        (IShipmentBooking) Test.createStub(IShipmentBooking.class, this)
      );
    }
  }

  @IsTest
  static void checkout_allSubsystemsSucceed_pricesReservesThenBooks() {
    Subsystems subsystems = new Subsystems();

    CheckoutResult result = subsystems.facade().checkout('ORD-1', BASKET, 'SW1A 1AA');

    Assert.isTrue(result.success);
    Assert.areEqual(17.00, result.total);
    Assert.areEqual('TRK-ORD-1', result.trackingNumber);
    Assert.isNull(result.failureReason);
    Assert.areEqual(new List<String>{ 'priceOf', 'reserve', 'book' }, subsystems.calls);
  }

  @IsTest
  static void checkout_noStock_neverBooks() {
    Subsystems subsystems = new Subsystems();
    subsystems.stockAvailable = false;

    CheckoutResult result = subsystems.facade().checkout('ORD-2', BASKET, 'SW1A 1AA');

    Assert.isFalse(result.success);
    Assert.isTrue(result.failureReason.contains('Not enough stock'), result.failureReason);
    Assert.areEqual(new List<String>{ 'priceOf', 'reserve' }, subsystems.calls, 'no booking without stock');
  }

  @IsTest
  static void checkout_bookingFails_releasesTheReservedStock() {
    Subsystems subsystems = new Subsystems();
    subsystems.carrierDown = true;

    CheckoutResult result = subsystems.facade().checkout('ORD-3', BASKET, 'SW1A 1AA');

    Assert.isFalse(result.success);
    Assert.isNull(result.trackingNumber);
    Assert.areEqual(17.00, result.total, 'the total is still reported');
    Assert.isTrue(result.failureReason.contains('carrier timeout'), result.failureReason);
    Assert.areEqual(new List<String>{ 'priceOf', 'reserve', 'book', 'release' }, subsystems.calls);
  }

  @IsTest
  static void checkout_invalidInput_callsNoSubsystem() {
    Subsystems subsystems = new Subsystems();
    CheckoutFacade facade = subsystems.facade();

    Assert.isFalse(facade.checkout(' ', BASKET, 'SW1A 1AA').success);
    Assert.isFalse(facade.checkout('ORD-4', new Map<String, Integer>(), 'SW1A 1AA').success);
    Assert.isFalse(facade.checkout('ORD-4', null, 'SW1A 1AA').success);
    Assert.areEqual(0, subsystems.calls.size());
  }

  @IsTest
  static void constructor_missingSubsystem_rejected() {
    try {
      new CheckoutFacade(null, null, null);
      Assert.fail('a facade needs every subsystem');
    } catch (IllegalArgumentException e) {
      Assert.isTrue(e.getMessage().contains('pricing, stock and booking'));
    }
  }

  @IsTest
  static void checkout_twoHundredOrders_eachCompleted() {
    Subsystems subsystems = new Subsystems();
    CheckoutFacade facade = subsystems.facade();
    Integer completed = 0;

    for (Integer i = 0; i < 200; i++) {
      if (facade.checkout('ORD-' + i, BASKET, 'SW1A 1AA').success) {
        completed++;
      }
    }

    Assert.areEqual(200, completed);
    Assert.areEqual(600, subsystems.calls.size(), 'three subsystem calls per order');
  }
}
