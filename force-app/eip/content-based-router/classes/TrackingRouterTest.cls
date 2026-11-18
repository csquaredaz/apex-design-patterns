@IsTest
private class TrackingRouterTest {
  private static List<String> calls = new List<String>();

  /** A channel that records what it receives. */
  private class RecordingChannel implements ITrackingChannel {
    final String name;
    final List<TrackingScan> received = new List<TrackingScan>();
    Integer batches = 0;

    RecordingChannel(String name) {
      this.name = name;
    }

    public void receive(List<TrackingScan> scans) {
      calls.add(name);
      batches++;
      received.addAll(scans);
    }
  }

  private static TrackingScan scan(String carrierCode, Integer i) {
    return new TrackingScan(carrierCode, 'TRK-' + i, 'IN_TRANSIT');
  }

  @IsTest
  static void dispatch_twoHundredMixedScans_eachChannelOnceInArrivalOrder() {
    RecordingChannel parcelCo = new RecordingChannel('parcelco');
    RecordingChannel swiftShip = new RecordingChannel('swiftship');
    RecordingChannel unroutable = new RecordingChannel('unroutable');
    TrackingRouter router = new TrackingRouter(unroutable).route('parcelco', parcelCo).route('swiftship', swiftShip);
    List<TrackingScan> scans = new List<TrackingScan>();
    for (Integer i = 0; i < 200; i++) {
      scans.add(scan(Math.mod(i, 2) == 0 ? 'swiftship' : 'parcelco', i));
    }

    router.dispatch(scans);

    Assert.areEqual(new List<String>{ 'swiftship', 'parcelco' }, calls, 'one call per channel, first-seen order');
    Assert.areEqual(100, parcelCo.received.size());
    Assert.areEqual(100, swiftShip.received.size());
    Assert.areEqual('TRK-1', parcelCo.received[0].trackingNumber, 'arrival order kept within a channel');
    Assert.areEqual('TRK-199', parcelCo.received[99].trackingNumber);
    Assert.areEqual(0, unroutable.batches, 'every scan had a route');
  }

  @IsTest
  static void dispatch_carrierCodeInAnyCase_matchesItsRoute() {
    RecordingChannel parcelCo = new RecordingChannel('parcelco');
    RecordingChannel unroutable = new RecordingChannel('unroutable');
    TrackingRouter router = new TrackingRouter(unroutable).route('ParcelCo', parcelCo);

    router.dispatch(new List<TrackingScan>{ scan('PARCELCO', 1), scan(' parcelco ', 2) });

    Assert.areEqual(2, parcelCo.received.size(), 'carrier codes match case-insensitively and trimmed');
    Assert.areEqual(0, unroutable.batches);
  }

  @IsTest
  static void dispatch_unknownOrMissingCarrier_goesToUnroutableChannel() {
    RecordingChannel parcelCo = new RecordingChannel('parcelco');
    RecordingChannel unroutable = new RecordingChannel('unroutable');
    TrackingRouter router = new TrackingRouter(unroutable).route('parcelco', parcelCo);

    router.dispatch(
      new List<TrackingScan>{ scan('parcelco', 1), scan('oceanfreight', 2), scan(null, 3), scan(' ', 4), null }
    );

    Assert.areEqual(1, parcelCo.received.size());
    Assert.areEqual(1, unroutable.batches, 'all unroutable scans in one call');
    Assert.areEqual(4, unroutable.received.size(), 'unknown, null, blank and missing scans are kept, not dropped');
    Assert.areEqual('TRK-2', unroutable.received[0].trackingNumber);
  }

  @IsTest
  static void dispatch_emptyOrNullBatch_callsNoChannel() {
    RecordingChannel unroutable = new RecordingChannel('unroutable');
    TrackingRouter router = new TrackingRouter(unroutable).route('parcelco', new RecordingChannel('parcelco'));

    router.dispatch(new List<TrackingScan>());
    router.dispatch(null);

    Assert.areEqual(0, calls.size(), 'nothing to route, nothing called');
  }

  @IsTest
  static void construction_invalidRoutes_rejected() {
    RecordingChannel channel = new RecordingChannel('parcelco');
    TrackingRouter router = new TrackingRouter(new RecordingChannel('unroutable')).route('parcelco', channel);
    List<String> failures = new List<String>();
    for (Integer i = 0; i < 4; i++) {
      try {
        if (i == 0) {
          new TrackingRouter(null);
        } else if (i == 1) {
          router.route(' ', channel);
        } else if (i == 2) {
          router.route('swiftship', null);
        } else {
          router.route('PARCELCO', channel);
        }
      } catch (IllegalArgumentException e) {
        failures.add(e.getMessage());
      }
    }

    Assert.areEqual(4, failures.size(), String.join(failures, ' | '));
    Assert.isTrue(failures[3].contains('already has a route'), 'a second route for the same carrier, in any case');
  }
}
