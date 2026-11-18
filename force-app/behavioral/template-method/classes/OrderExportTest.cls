@IsTest
private class OrderExportTest {
  private static final List<ExportOrder> ORDERS = new List<ExportOrder>{
    new ExportOrder('ORD-1', 'Ada Lovelace', 12.5),
    new ExportOrder('ORD-2', 'Smith, "Jo"', 7)
  };

  /** The smallest possible subclass: only the required hook, every default kept. */
  private class ReferenceOnlyExport extends OrderExport {
    protected override String formatRow(ExportOrder row) {
      return row.reference;
    }
  }

  @IsTest
  static void render_csv_quotesAndEscapes() {
    String csv = new CsvOrderExport().render(ORDERS);

    Assert.areEqual(
      'reference,customer,total\n"ORD-1","Ada Lovelace",12.50\n"ORD-2","Smith, ""Jo""",7.00',
      csv,
      'header first, then one escaped row per order'
    );
  }

  @IsTest
  static void render_json_isAValidArray() {
    String body = new JsonOrderExport().render(ORDERS);

    List<Object> parsed = (List<Object>) JSON.deserializeUntyped(body);
    Assert.areEqual(2, parsed.size());
    Map<String, Object> second = (Map<String, Object>) parsed[1];
    Assert.areEqual('Smith, "Jo"', second.get('customer'), 'JSON escaping keeps the name intact');
    Assert.areEqual(7.00, (Decimal) second.get('total'));
  }

  @IsTest
  static void render_defaultsOnly_noHeaderOrFooter() {
    Assert.areEqual('ORD-1\nORD-2', new ReferenceOnlyExport().render(ORDERS), 'the defaults add nothing around rows');
  }

  @IsTest
  static void render_nothingToExport_rejectedForEveryFormat() {
    Integer rejected = 0;
    for (OrderExport format : new List<OrderExport>{ new CsvOrderExport(), new JsonOrderExport() }) {
      for (List<ExportOrder> orders : new List<List<ExportOrder>>{ null, new List<ExportOrder>() }) {
        try {
          format.render(orders);
        } catch (IllegalArgumentException e) {
          rejected++;
        }
      }
    }
    Assert.areEqual(4, rejected, 'the guard lives in the template, so every subclass gets it');
  }

  @IsTest
  static void render_twoHundredOrders_oneRowEach() {
    List<ExportOrder> orders = new List<ExportOrder>();
    for (Integer i = 0; i < 200; i++) {
      orders.add(new ExportOrder('ORD-' + i, 'Customer ' + i, i));
    }

    List<String> lines = new CsvOrderExport().render(orders).split('\n');

    Assert.areEqual(201, lines.size(), 'one header plus 200 rows');
    Assert.areEqual('"ORD-199","Customer 199",199.00', lines[200]);
  }
}
