@IsTest
private class ShipmentRequestTest {
  private static ShipmentRequest.Builder complete() {
    return ShipmentRequest.builder().forOrder('ORD-1001').withCarrier('parcelco').weighing(1200).to(' sw1a 1aa ');
  }

  @IsTest
  static void build_allRequiredFields_appliesDefaultsAndNormalises() {
    ShipmentRequest request = complete().build();

    Assert.areEqual('ORD-1001', request.orderReference);
    Assert.areEqual('PARCELCO', request.carrierCode, 'carrier code is upper-cased');
    Assert.areEqual(1200, request.weightGrams);
    Assert.areEqual('SW1A 1AA', request.destinationPostalCode, 'postal code is trimmed and upper-cased');
    Assert.areEqual(ShipmentRequest.STANDARD, request.serviceLevel);
    Assert.isFalse(request.signatureRequired);
    Assert.isNull(request.declaredValue);
  }

  @IsTest
  static void build_optionalFields_overridesDefaults() {
    ShipmentRequest request = complete()
      .withServiceLevel('EXPRESS')
      .requiringSignature()
      .declaringValue(250.00)
      .build();

    Assert.areEqual('EXPRESS', request.serviceLevel);
    Assert.isTrue(request.signatureRequired);
    Assert.areEqual(250.00, request.declaredValue);
  }

  @IsTest
  static void build_emptyBuilder_listsEveryMissingField() {
    try {
      ShipmentRequest.builder().build();
      Assert.fail('an empty builder must not build');
    } catch (ShipmentRequest.InvalidRequestException e) {
      for (String field : new List<String>{ 'orderReference', 'carrierCode', 'destinationPostalCode', 'weightGrams' }) {
        Assert.isTrue(e.getMessage().contains(field), 'message names ' + field + ': ' + e.getMessage());
      }
    }
  }

  @IsTest
  static void build_outOfRangeValues_rejected() {
    List<ShipmentRequest.Builder> invalid = new List<ShipmentRequest.Builder>{
      complete().weighing(0),
      complete().weighing(-5),
      complete().declaringValue(-0.01),
      complete().withServiceLevel(' ')
    };
    Integer rejected = 0;
    for (ShipmentRequest.Builder candidate : invalid) {
      try {
        candidate.build();
      } catch (ShipmentRequest.InvalidRequestException e) {
        rejected++;
      }
    }
    Assert.areEqual(invalid.size(), rejected, 'every out-of-range value is rejected');
  }

  @IsTest
  static void build_builderReusedAfterBuild_earlierRequestUnchanged() {
    ShipmentRequest.Builder builder = complete();
    ShipmentRequest first = builder.build();

    ShipmentRequest second = builder.forOrder('ORD-1002').weighing(900).build();

    Assert.areEqual('ORD-1001', first.orderReference, 'the first request is immutable');
    Assert.areEqual(1200, first.weightGrams);
    Assert.areEqual('ORD-1002', second.orderReference);
    Assert.areEqual(900, second.weightGrams);
  }

  @IsTest
  static void build_twoHundredRequests_eachIndependent() {
    ShipmentRequest.Builder builder = complete();
    List<ShipmentRequest> requests = new List<ShipmentRequest>();
    for (Integer i = 0; i < 200; i++) {
      requests.add(builder.forOrder('ORD-' + i).build());
    }

    Assert.areEqual(200, requests.size());
    Assert.areEqual('ORD-0', requests[0].orderReference);
    Assert.areEqual('ORD-199', requests[199].orderReference);
  }
}
