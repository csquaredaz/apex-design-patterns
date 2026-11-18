/**
 * @description An immutable request to book a shipment with a carrier, built step by step (Builder).
 * The constructor is private, so the only way to get a `ShipmentRequest` is
 * `ShipmentRequest.builder()…build()`, and `build()` rejects a request that is missing a required
 * field or has an out-of-range value, listing every problem at once.
 * @group Creational
 */
public with sharing class ShipmentRequest {
  /** @description Service level used when the caller doesn't choose one. */
  public static final String STANDARD = 'STANDARD';

  /** @description The order this shipment fulfils, for example `ORD-1001`. Required. */
  public final String orderReference;
  /** @description Carrier code, upper-cased, for example `PARCELCO`. Required. */
  public final String carrierCode;
  /** @description Parcel weight in grams. Required, greater than zero. */
  public final Integer weightGrams;
  /** @description Destination postal code, trimmed and upper-cased. Required. */
  public final String destinationPostalCode;
  /** @description Carrier service level. Defaults to `STANDARD`. */
  public final String serviceLevel;
  /** @description Whether the recipient must sign. Defaults to false. */
  public final Boolean signatureRequired;
  /** @description Value declared for insurance, or null for none. Never negative. */
  public final Decimal declaredValue;

  private ShipmentRequest(Builder source) {
    orderReference = source.orderReference;
    carrierCode = source.carrierCode;
    weightGrams = source.weightGrams;
    destinationPostalCode = source.destinationPostalCode;
    serviceLevel = source.serviceLevel;
    signatureRequired = source.signatureRequired;
    declaredValue = source.declaredValue;
  }

  /**
   * @description Starts a new request.
   * @return An empty builder with the defaults applied.
   */
  public static Builder builder() {
    return new Builder();
  }

  /**
   * @description Collects a shipment request's fields; `build()` validates them. Each setter
   * returns the builder so calls chain.
   */
  public class Builder {
    private String orderReference;
    private String carrierCode;
    private Integer weightGrams;
    private String destinationPostalCode;
    private String serviceLevel = STANDARD;
    private Boolean signatureRequired = false;
    private Decimal declaredValue;

    /**
     * @description Sets the order reference.
     * @param value The order reference.
     * @return This builder.
     */
    public Builder forOrder(String value) {
      orderReference = value;
      return this;
    }

    /**
     * @description Sets the carrier; the code is upper-cased.
     * @param value The carrier code.
     * @return This builder.
     */
    public Builder withCarrier(String value) {
      carrierCode = value?.toUpperCase();
      return this;
    }

    /**
     * @description Sets the parcel weight.
     * @param grams The weight in grams.
     * @return This builder.
     */
    public Builder weighing(Integer grams) {
      weightGrams = grams;
      return this;
    }

    /**
     * @description Sets the destination; the postal code is trimmed and upper-cased.
     * @param postalCode The destination postal code.
     * @return This builder.
     */
    public Builder to(String postalCode) {
      destinationPostalCode = postalCode?.trim().toUpperCase();
      return this;
    }

    /**
     * @description Overrides the `STANDARD` service level.
     * @param value The service level, for example `EXPRESS`.
     * @return This builder.
     */
    public Builder withServiceLevel(String value) {
      serviceLevel = value;
      return this;
    }

    /**
     * @description Requires a signature on delivery.
     * @return This builder.
     */
    public Builder requiringSignature() {
      signatureRequired = true;
      return this;
    }

    /**
     * @description Declares a value for insurance.
     * @param value The declared value.
     * @return This builder.
     */
    public Builder declaringValue(Decimal value) {
      declaredValue = value;
      return this;
    }

    /**
     * @description Validates the fields and creates the request. The builder can be reused; later
     * changes to it don't affect requests already built.
     * @return The immutable request.
     * @throws InvalidRequestException Naming every missing or invalid field.
     */
    public ShipmentRequest build() {
      List<String> problems = new List<String>();
      requireText(orderReference, 'orderReference', problems);
      requireText(carrierCode, 'carrierCode', problems);
      requireText(destinationPostalCode, 'destinationPostalCode', problems);
      requireText(serviceLevel, 'serviceLevel', problems);
      if (weightGrams == null || weightGrams <= 0) {
        problems.add('weightGrams must be greater than zero');
      }
      if (declaredValue != null && declaredValue < 0) {
        problems.add('declaredValue must not be negative');
      }
      if (!problems.isEmpty()) {
        throw new InvalidRequestException('Invalid shipment request: ' + String.join(problems, '; '));
      }
      return new ShipmentRequest(this);
    }

    private void requireText(String value, String name, List<String> problems) {
      if (String.isBlank(value)) {
        problems.add(name + ' is required');
      }
    }
  }

  /** @description Thrown by `build()` when the request is incomplete or invalid. */
  public class InvalidRequestException extends Exception {
  }
}
