/**
 * @description Exports orders as a JSON array, one object per line. Only `formatRow`, `header`,
 * `footer` and `separator` differ from CSV; the steps are the base class's.
 * @group Behavioral
 */
public with sharing class JsonOrderExport extends OrderExport {
  protected override String header() {
    return '[';
  }

  protected override String footer() {
    return ']';
  }

  protected override String separator() {
    return ',\n';
  }

  protected override String formatRow(ExportOrder row) {
    return JSON.serialize(
      new Map<String, Object>{
        'reference' => row.reference,
        'customer' => row.customerName,
        'total' => row.total?.setScale(2)
      }
    );
  }
}
