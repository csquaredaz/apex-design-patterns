/**
 * @description One order as an export sees it.
 * @group Behavioral
 */
public with sharing class ExportOrder {
  /** @description The order reference. */
  public final String reference;
  /** @description The customer's name, which may contain commas or quotes. */
  public final String customerName;
  /** @description The order total. */
  public final Decimal total;

  /**
   * @description Creates an export row's source.
   * @param reference The order reference.
   * @param customerName The customer name.
   * @param total The order total.
   */
  public ExportOrder(String reference, String customerName, Decimal total) {
    this.reference = reference;
    this.customerName = customerName;
    this.total = total;
  }
}
