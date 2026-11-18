@IsTest
private class CarrierClientFactoryTest {
  private static Carrier_Setting__mdt row(String carrier, String className, Boolean active) {
    return new Carrier_Setting__mdt(DeveloperName = carrier, Client_Class__c = className, Active__c = active);
  }

  private static void useRows(List<Carrier_Setting__mdt> settings) {
    Map<String, Carrier_Setting__mdt> byName = new Map<String, Carrier_Setting__mdt>();
    for (Carrier_Setting__mdt setting : settings) {
      byName.put(setting.DeveloperName, setting);
    }
    CarrierClientFactory.rows = byName;
  }

  private static String failureFor(String carrier) {
    try {
      CarrierClientFactory.forCarrier(carrier);
      return null;
    } catch (CarrierClientFactory.UnknownCarrierException e) {
      return e.getMessage();
    }
  }

  @IsTest
  static void forCarrier_shippedRows_resolveBothCarriers() {
    ICarrierClient parcelCo = CarrierClientFactory.forCarrier('ParcelCo');
    ICarrierClient swiftShip = CarrierClientFactory.forCarrier('SwiftShip');

    Assert.isInstanceOfType(parcelCo, ParcelCoClient.class);
    Assert.areEqual('PARCELCO', parcelCo.carrierCode());
    Assert.areEqual('https://track.parcelco.example/parcels/PC%2F9', parcelCo.trackingUrl('PC/9'));
    Assert.areEqual('SWIFTSHIP', swiftShip.carrierCode());
  }

  @IsTest
  static void forCarrier_codeInAnyCase_resolvesConfiguredClass() {
    useRows(new List<Carrier_Setting__mdt>{ row('ParcelCo', 'SwiftShipClient', true) });

    ICarrierClient client = CarrierClientFactory.forCarrier('PARCELCO');

    Assert.areEqual('SWIFTSHIP', client.carrierCode(), 'the row, not the code, decides the class');
    Assert.areEqual('https://swiftship.example/track?ref=A+1', client.trackingUrl('A 1'));
  }

  @IsTest
  static void forCarrier_unresolvable_explainsWhy() {
    useRows(
      new List<Carrier_Setting__mdt>{
        row('Retired', 'ParcelCoClient', false),
        row('Typo', 'ParcelCoClientt', true),
        row('Wrong', 'CarrierClientFactory', true)
      }
    );

    Assert.isTrue(failureFor('Missing').contains('No active'), failureFor('Missing'));
    Assert.isTrue(failureFor('Retired').contains('No active'), 'an inactive row is not resolved');
    Assert.isTrue(failureFor('Typo').contains('does not exist'), failureFor('Typo'));
    Assert.isTrue(failureFor('Wrong').contains('does not implement ICarrierClient'), failureFor('Wrong'));
    Assert.isTrue(failureFor(null).contains('No active'), failureFor(null));
  }

  @IsTest
  static void forCarrier_twoHundredCalls_noQueriesAndNewInstances() {
    Integer queriesBefore = Limits.getQueries();
    List<ICarrierClient> clients = new List<ICarrierClient>();
    for (Integer i = 0; i < 200; i++) {
      clients.add(CarrierClientFactory.forCarrier(Math.mod(i, 2) == 0 ? 'ParcelCo' : 'SwiftShip'));
    }

    Assert.areEqual(queriesBefore, Limits.getQueries(), 'getAll() reads custom metadata without SOQL');
    Assert.areEqual(200, clients.size());
    Assert.isTrue(clients[0] !== clients[2], 'each call creates a new client, not a shared one');
    Assert.areEqual('SWIFTSHIP', clients[199].carrierCode());
  }
}
