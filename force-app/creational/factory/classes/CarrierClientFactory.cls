/**
 * @description Creates the `ICarrierClient` for a carrier code from configuration (Factory). Each
 * `Carrier_Setting__mdt` row maps a carrier code (its DeveloperName) to an Apex class name, which is
 * created with `Type.forName`. Adding a carrier is a new class plus a new row; callers don't change.
 * Reading rows with `getAll()` costs no SOQL query.
 * @group Creational
 */
public with sharing class CarrierClientFactory {
  @TestVisible
  private static Map<String, Carrier_Setting__mdt> rows {
    get {
      if (rows == null) {
        rows = Carrier_Setting__mdt.getAll();
      }
      return rows;
    }
    set;
  }

  /**
   * @description Creates the client for a carrier.
   * @param carrierCode The carrier code, case-insensitive, for example `parcelco`.
   * @return A new client for that carrier.
   * @throws UnknownCarrierException If no active row names the carrier, or its class is missing or
   * doesn't implement `ICarrierClient`. A client class without a public no-argument constructor
   * fails with the platform's `TypeException`, which is a programming error, not configuration.
   */
  public static ICarrierClient forCarrier(String carrierCode) {
    Carrier_Setting__mdt row = findRow(carrierCode);
    if (row == null || !row.Active__c) {
      throw new UnknownCarrierException('No active Carrier_Setting__mdt row for carrier ' + carrierCode);
    }
    Type clientType = Type.forName(row.Client_Class__c);
    if (clientType == null) {
      throw new UnknownCarrierException(
        'Carrier ' + carrierCode + ' names class ' + row.Client_Class__c + ', which does not exist'
      );
    }
    // Check the type before creating it, so a row that names the wrong class never runs that
    // class's constructor.
    if (!ICarrierClient.class.isAssignableFrom(clientType)) {
      throw new UnknownCarrierException(
        'Carrier ' + carrierCode + ' names class ' + row.Client_Class__c + ', which does not implement ICarrierClient'
      );
    }
    return (ICarrierClient) clientType.newInstance();
  }

  // getAll() keys rows by DeveloperName as stored, so match case-insensitively.
  private static Carrier_Setting__mdt findRow(String carrierCode) {
    if (String.isBlank(carrierCode)) {
      return null;
    }
    for (Carrier_Setting__mdt row : rows.values()) {
      if (row.DeveloperName.equalsIgnoreCase(carrierCode)) {
        return row;
      }
    }
    return null;
  }

  /** @description Thrown when a carrier code can't be resolved to a working client. */
  public class UnknownCarrierException extends Exception {
  }
}
