@IsTest
private class PickAggregatorTest {
  private static List<WarehousePick> picksFor(String orderRef) {
    return new WarehouseSplitter(
        new Map<String, String>{ 'MUG' => 'LEEDS', 'KETTLE' => 'BRISTOL', 'TRAY' => 'GLASGOW' }
      )
      .split(orderRef, new Map<String, Integer>{ 'MUG' => 1, 'KETTLE' => 1, 'TRAY' => 1 });
  }

  @IsTest
  static void add_allPartsInAnyOrder_releasesTheOrderOnceWithEveryTrackingNumber() {
    List<WarehousePick> picks = picksFor('ORD-1');
    PickAggregator aggregator = new PickAggregator();

    List<AssembledOrder> first = aggregator.add(
      new List<PickConfirmation>{ picks[2].confirm('TRK-L'), picks[0].confirm('TRK-B') }
    );
    Assert.areEqual(0, first.size(), 'two of three parts: still waiting');
    Assert.areEqual(1, aggregator.pendingCount());

    List<AssembledOrder> second = aggregator.add(new List<PickConfirmation>{ picks[1].confirm('TRK-G') });

    Assert.areEqual(1, second.size());
    Assert.areEqual('ORD-1', second[0].orderRef);
    Assert.areEqual(
      new Map<String, String>{ 'BRISTOL' => 'TRK-B', 'GLASGOW' => 'TRK-G', 'LEEDS' => 'TRK-L' },
      second[0].trackingByWarehouse
    );
    Assert.areEqual(0, aggregator.pendingCount(), 'a released order holds no state');
  }

  @IsTest
  static void add_repeatedConfirmations_ignored() {
    List<WarehousePick> picks = picksFor('ORD-2');
    PickAggregator aggregator = new PickAggregator();

    aggregator.add(new List<PickConfirmation>{ picks[0].confirm('TRK-1'), picks[0].confirm('TRK-1-again') });
    aggregator.add(new List<PickConfirmation>{ picks[1].confirm('TRK-2') });
    Assert.areEqual(1, aggregator.pendingCount(), 'a repeat is not a new part');

    List<AssembledOrder> done = aggregator.add(new List<PickConfirmation>{ picks[2].confirm('TRK-3') });
    Assert.areEqual('TRK-1', done[0].trackingByWarehouse.get(picks[0].warehouse), 'the first copy wins');

    List<AssembledOrder> late = aggregator.add(new List<PickConfirmation>{ picks[1].confirm('TRK-2-late') });
    Assert.areEqual(0, late.size(), 'a released order is never released twice');
    Assert.areEqual(0, aggregator.pendingCount(), 'and a late copy does not reopen it');
  }

  @IsTest
  static void add_conflictingPartCount_rejectsTheWholeBatch() {
    List<WarehousePick> picks = picksFor('ORD-3');
    WarehousePick impostor = new WarehousePick('ORD-3', 'CARDIFF', 2, new Map<String, Integer>{ 'MUG' => 1 });
    PickAggregator aggregator = new PickAggregator();
    aggregator.add(new List<PickConfirmation>{ picks[0].confirm('TRK-1') });

    try {
      aggregator.add(new List<PickConfirmation>{ picks[1].confirm('TRK-2'), impostor.confirm('TRK-X') });
      Assert.fail('a part count that disagrees must be rejected');
    } catch (IllegalArgumentException e) {
      Assert.areEqual('Order ORD-3 was split into 3 picks, not 2', e.getMessage());
    }
    List<AssembledOrder> done = aggregator.add(
      new List<PickConfirmation>{ picks[1].confirm('TRK-2'), picks[2].confirm('TRK-3') }
    );
    Assert.areEqual(1, done.size(), 'the rejected batch applied nothing, so these two complete the order');
  }

  @IsTest
  static void add_invalidInput_handled() {
    PickAggregator aggregator = new PickAggregator();
    Assert.areEqual(0, aggregator.add(null).size(), 'a null batch completes nothing');
    Integer rejected = 0;
    try {
      aggregator.add(new List<PickConfirmation>{ null });
    } catch (IllegalArgumentException e) {
      rejected++;
    }
    try {
      new PickConfirmation(null, 'TRK-1');
    } catch (IllegalArgumentException e) {
      rejected++;
    }
    try {
      picksFor('ORD-4')[0].confirm(' ');
    } catch (IllegalArgumentException e) {
      rejected++;
    }
    Assert.areEqual(3, rejected, 'a null confirmation, a confirmation without a pick or without tracking');
  }

  @IsTest
  static void add_twoHundredOrdersInterleaved_eachReleasedOnce() {
    List<PickConfirmation> partOne = new List<PickConfirmation>();
    List<PickConfirmation> partTwo = new List<PickConfirmation>();
    for (Integer i = 0; i < 200; i++) {
      List<WarehousePick> picks = picksFor('ORD-' + i);
      partOne.add(picks[0].confirm('A-' + i));
      partOne.add(picks[1].confirm('B-' + i));
      partTwo.add(picks[2].confirm('C-' + i));
    }
    PickAggregator aggregator = new PickAggregator();

    Assert.areEqual(0, aggregator.add(partOne).size());
    Assert.areEqual(200, aggregator.pendingCount());
    List<AssembledOrder> done = aggregator.add(partTwo);

    Assert.areEqual(200, done.size());
    Assert.areEqual('ORD-0', done[0].orderRef, 'released in completion order');
    Assert.areEqual(3, done[199].trackingByWarehouse.size());
    Assert.areEqual(0, aggregator.pendingCount());
  }
}
