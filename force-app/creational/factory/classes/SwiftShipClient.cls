/**
 * @description `ICarrierClient` for the fictional carrier SwiftShip. Created by
 * `CarrierClientFactory` through `Type.forName`, so it needs a public no-argument constructor.
 * @group Creational
 */
public with sharing class SwiftShipClient implements ICarrierClient {
  /**
   * @description The carrier this client talks to.
   * @return `SWIFTSHIP`.
   */
  public String carrierCode() {
    return 'SWIFTSHIP';
  }

  /**
   * @description SwiftShip's tracking page, which takes the number as a query parameter.
   * @param trackingNumber The tracking number.
   * @return The tracking page URL.
   */
  public String trackingUrl(String trackingNumber) {
    return 'https://swiftship.example/track?ref=' + EncodingUtil.urlEncode(trackingNumber, 'UTF-8');
  }
}
