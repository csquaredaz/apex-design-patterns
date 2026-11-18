/**
 * @description Exports orders as CSV with a header row. Every text field is quoted, and quotes
 * inside it are doubled (RFC 4180), so a customer called `Smith, "Jo"` stays in one column.
 * @group Behavioral
 */
public with sharing class CsvOrderExport extends OrderExport {
  protected override String header() {
    return 'reference,customer,total';
  }

  protected override String formatRow(ExportOrder row) {
    return quote(row.reference) + ',' + quote(row.customerName) + ',' + row.total?.setScale(2);
  }

  private static String quote(String value) {
    return '"' + (value ?? '').replace('"', '""') + '"';
  }
}
