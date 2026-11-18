@IsTest
private class FulfilmentOrderTest {
  private static final List<String> ACTIONS = new List<String>{ 'pay', 'ship', 'deliver', 'cancel' };

  private static FulfilmentOrder orderIn(String status) {
    FulfilmentOrder fulfilment = new FulfilmentOrder('ORD-1');
    switch on status {
      when 'PAID' {
        fulfilment.pay();
      }
      when 'SHIPPED' {
        fulfilment.pay().ship('TRK-1');
      }
      when 'DELIVERED' {
        fulfilment.pay().ship('TRK-1').deliver();
      }
      when 'CANCELLED' {
        fulfilment.cancel();
      }
    }
    return fulfilment;
  }

  private static Boolean tryAction(FulfilmentOrder fulfilment, String action) {
    try {
      switch on action {
        when 'pay' {
          fulfilment.pay();
        }
        when 'ship' {
          fulfilment.ship('TRK-2');
        }
        when 'deliver' {
          fulfilment.deliver();
        }
        when else {
          fulfilment.cancel();
        }
      }
      return true;
    } catch (FulfilmentOrder.IllegalTransitionException e) {
      Assert.isTrue(e.getMessage().startsWith('Cannot ' + action), e.getMessage());
      return false;
    }
  }

  @IsTest
  static void lifecycle_happyPath_recordsEveryStatus() {
    FulfilmentOrder fulfilment = new FulfilmentOrder('ORD-1').pay().ship('TRK-9').deliver();

    Assert.areEqual('DELIVERED', fulfilment.status());
    Assert.areEqual('TRK-9', fulfilment.trackingNumber());
    Assert.areEqual(new List<String>{ 'PENDING', 'PAID', 'SHIPPED', 'DELIVERED' }, fulfilment.history());
  }

  @IsTest
  static void everyStatusAndAction_onlyTheLegalMovesSucceed() {
    // status → the actions it allows; everything else must throw.
    Map<String, Set<String>> legal = new Map<String, Set<String>>{
      'PENDING' => new Set<String>{ 'pay', 'cancel' },
      'PAID' => new Set<String>{ 'ship', 'cancel' },
      'SHIPPED' => new Set<String>{ 'deliver' },
      'DELIVERED' => new Set<String>(),
      'CANCELLED' => new Set<String>()
    };
    for (String status : legal.keySet()) {
      for (String action : ACTIONS) {
        FulfilmentOrder fulfilment = orderIn(status);
        Boolean moved = tryAction(fulfilment, action);

        Assert.areEqual(legal.get(status).contains(action), moved, status + ' + ' + action);
        if (!moved) {
          Assert.areEqual(status, fulfilment.status(), 'a rejected move leaves ' + status + ' unchanged');
        }
      }
    }
  }

  @IsTest
  static void ship_withoutTrackingNumber_rejectedAndStaysPaid() {
    FulfilmentOrder fulfilment = new FulfilmentOrder('ORD-1').pay();

    try {
      fulfilment.ship(' ');
      Assert.fail('shipping needs a tracking number');
    } catch (IllegalArgumentException e) {
      Assert.isTrue(e.getMessage().contains('tracking number'));
    }
    Assert.areEqual('PAID', fulfilment.status());
    Assert.isNull(fulfilment.trackingNumber());
  }

  @IsTest
  static void history_returnsACopy() {
    FulfilmentOrder fulfilment = new FulfilmentOrder('ORD-1');
    fulfilment.history().add('SHIPPED');

    Assert.areEqual(new List<String>{ 'PENDING' }, fulfilment.history(), 'callers cannot rewrite the history');
  }

  @IsTest
  static void twoHundredOrders_eachHasItsOwnState() {
    List<FulfilmentOrder> fulfilments = new List<FulfilmentOrder>();
    for (Integer i = 0; i < 200; i++) {
      FulfilmentOrder fulfilment = new FulfilmentOrder('ORD-' + i).pay();
      fulfilments.add(Math.mod(i, 2) == 0 ? fulfilment.ship('TRK-' + i) : fulfilment.cancel());
    }

    Assert.areEqual('SHIPPED', fulfilments[0].status());
    Assert.areEqual('CANCELLED', fulfilments[199].status());
    Assert.areEqual('TRK-198', fulfilments[198].trackingNumber());
  }
}
