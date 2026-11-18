/**
 * @description `ICarrierClient` for the fictional carrier ParcelCo. Created by `CarrierClientFactory`
 * through `Type.forName`, so it needs a public no-argument constructor (the default one).
 * @group Creational
 */
public with sharing class ParcelCoClient implements ICarrierClient {
  /**
   * @description The carrier this client talks to.
   * @return `PARCELCO`.
   */
  public String carrierCode() {
    return 'PARCELCO';
  }

  /**
   * @description ParcelCo's tracking page.
   * @param trackingNumber The tracking number.
   * @return The tracking page URL.
   */
  public String trackingUrl(String trackingNumber) {
    return 'https://track.parcelco.example/parcels/' + EncodingUtil.urlEncode(trackingNumber, 'UTF-8');
  }
}
