@IsTest
private class ParcelCoTrackingAdapterTest {
  private static final Long DELIVERED_AT = 1763459400000L;

  private static String failureFor(String body) {
    try {
      new ParcelCoTrackingAdapter().parse(body);
      return null;
    } catch (TrackingFormatException e) {
      return e.getMessage();
    }
  }

  @IsTest
  static void parse_knownCodes_mapToOurStatuses() {
    String body =
      '{"parcels":[{"ref":"PC1","events":[' +
      '{"code":"TRN","ts":1},{"code":"OFD","ts":2},{"code":"ATT","ts":3},{"code":"DLV","ts":' +
      DELIVERED_AT +
      '}]}]}';

    ITrackingParser parser = new ParcelCoTrackingAdapter();
    List<TrackingUpdate> updates = parser.parse(body);

    Assert.areEqual(4, updates.size());
    Assert.areEqual(TrackingStatus.IN_TRANSIT, updates[0].status);
    Assert.areEqual(TrackingStatus.OUT_FOR_DELIVERY, updates[1].status);
    Assert.areEqual(TrackingStatus.FAILED_ATTEMPT, updates[2].status);
    Assert.areEqual(TrackingStatus.DELIVERED, updates[3].status);
    Assert.areEqual('PC1', updates[3].trackingNumber);
    Assert.areEqual('DLV', updates[3].carrierStatusCode);
    Assert.areEqual(Datetime.newInstance(DELIVERED_AT), updates[3].occurredAt, 'epoch millis become a Datetime');
  }

  @IsTest
  static void parse_unknownCodeAndMissingFields_tolerated() {
    String body = '{"parcels":[{"ref":"PC2","events":[{"code":"HELD"}]},{"ref":"PC3"}],"version":7}';

    List<TrackingUpdate> updates = new ParcelCoTrackingAdapter().parse(body);

    Assert.areEqual(1, updates.size(), 'a parcel with no events adds nothing; extra fields are ignored');
    Assert.areEqual(TrackingStatus.UNKNOWN, updates[0].status);
    Assert.areEqual('HELD', updates[0].carrierStatusCode, 'the raw code is kept for support');
    Assert.isNull(updates[0].occurredAt);
  }

  @IsTest
  static void parse_notTheCarrierFormat_rejected() {
    Assert.isTrue(failureFor('').contains('empty'), failureFor(''));
    Assert.isTrue(failureFor('{not json').contains('not valid JSON'), failureFor('{not json'));
    Assert.isTrue(failureFor('{"shipments":[]}').contains('no parcels'), failureFor('{"shipments":[]}'));
    Assert.isTrue(failureFor('null').contains('no parcels'), failureFor('null'));
  }

  @IsTest
  static void parse_twoHundredParcels_allMapped() {
    List<String> parcels = new List<String>();
    for (Integer i = 0; i < 200; i++) {
      parcels.add('{"ref":"PC' + i + '","events":[{"code":"TRN","ts":' + i + '}]}');
    }

    List<TrackingUpdate> updates = new ParcelCoTrackingAdapter()
      .parse('{"parcels":[' + String.join(parcels, ',') + ']}');

    Assert.areEqual(200, updates.size());
    Assert.areEqual('PC199', updates[199].trackingNumber, 'payload order is kept');
  }
}
