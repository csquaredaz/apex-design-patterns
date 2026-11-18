/**
 * @description What every carrier integration offers, whichever carrier it is. `CarrierClientFactory`
 * creates the implementation that `Carrier_Setting__mdt` names for a carrier code.
 * @group Creational
 */
public interface ICarrierClient {
  /**
   * @description The carrier this client talks to.
   * @return The upper-case carrier code, for example `PARCELCO`.
   */
  String carrierCode();

  /**
   * @description The public page where a recipient can follow a parcel.
   * @param trackingNumber The carrier's tracking number.
   * @return The tracking page URL.
   */
  String trackingUrl(String trackingNumber);
}
