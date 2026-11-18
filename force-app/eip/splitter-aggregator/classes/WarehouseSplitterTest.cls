@IsTest
private class WarehouseSplitterTest {
  private static final Map<String, String> STOCKING = new Map<String, String>{
    'MUG' => 'LEEDS',
    'TEAPOT' => 'LEEDS',
    'KETTLE' => 'BRISTOL',
    'TRAY' => 'GLASGOW'
  };

  @IsTest
  static void split_linesAcrossThreeWarehouses_onePickEachWithItsLines() {
    List<WarehousePick> picks = new WarehouseSplitter(STOCKING)
      .split('ORD-1', new Map<String, Integer>{ 'MUG' => 2, 'KETTLE' => 1, 'TEAPOT' => 1, 'TRAY' => 3 });

    Assert.areEqual(3, picks.size(), 'one pick per warehouse');
    Assert.areEqual('BRISTOL', picks[0].warehouse, 'sorted by warehouse');
    Assert.areEqual('GLASGOW', picks[1].warehouse);
    Assert.areEqual('LEEDS', picks[2].warehouse);
    Assert.areEqual(new Map<String, Integer>{ 'MUG' => 2, 'TEAPOT' => 1 }, picks[2].quantityBySku);
    for (WarehousePick pick : picks) {
      Assert.areEqual('ORD-1', pick.orderRef, 'every pick carries the correlation id');
      Assert.areEqual(3, pick.partCount, 'and how many parts the order became');
    }
  }

  @IsTest
  static void split_oneWarehouse_onePickOfOne() {
    List<WarehousePick> picks = new WarehouseSplitter(STOCKING)
      .split('ORD-2', new Map<String, Integer>{ 'MUG' => 1, 'TEAPOT' => 1 });

    Assert.areEqual(1, picks.size());
    Assert.areEqual(1, picks[0].partCount);
  }

  @IsTest
  static void split_skusWithNoWarehouse_rejectedNamingEveryOne() {
    Map<String, String> withBlank = STOCKING.clone();
    withBlank.put('SPOON', ' ');
    try {
      new WarehouseSplitter(withBlank)
        .split('ORD-3', new Map<String, Integer>{ 'MUG' => 1, 'SPOON' => 2, 'FORK' => 1 });
      Assert.fail('a line with no warehouse must not be dropped');
    } catch (IllegalArgumentException e) {
      Assert.areEqual('No warehouse stocks: FORK, SPOON', e.getMessage());
    }
  }

  @IsTest
  static void split_invalidInput_rejected() {
    WarehouseSplitter splitter = new WarehouseSplitter(STOCKING);
    List<Map<String, Integer>> badLines = new List<Map<String, Integer>>{
      null,
      new Map<String, Integer>(),
      new Map<String, Integer>{ 'MUG' => 0 },
      new Map<String, Integer>{ 'MUG' => null }
    };
    Integer rejected = 0;
    for (Map<String, Integer> lines : badLines) {
      try {
        splitter.split('ORD-4', lines);
      } catch (IllegalArgumentException e) {
        rejected++;
      }
    }
    try {
      splitter.split(' ', new Map<String, Integer>{ 'MUG' => 1 });
    } catch (IllegalArgumentException e) {
      rejected++;
    }
    try {
      new WarehouseSplitter(new Map<String, String>());
    } catch (IllegalArgumentException e) {
      rejected++;
    }

    Assert.areEqual(6, rejected, 'no lines, a non-positive quantity, a blank reference or no stocking table');
  }

  @IsTest
  static void split_twoHundredLines_eachOnItsWarehousesPick() {
    Map<String, String> stocking = new Map<String, String>();
    Map<String, Integer> lines = new Map<String, Integer>();
    for (Integer i = 0; i < 200; i++) {
      stocking.put('SKU-' + i, 'WH-' + Math.mod(i, 4));
      lines.put('SKU-' + i, 1);
    }

    List<WarehousePick> picks = new WarehouseSplitter(stocking).split('ORD-5', lines);

    Assert.areEqual(4, picks.size());
    Integer total = 0;
    for (WarehousePick pick : picks) {
      Assert.areEqual(50, pick.quantityBySku.size(), pick.warehouse);
      total += pick.quantityBySku.size();
    }
    Assert.areEqual(200, total, 'no line lost or duplicated');
  }
}
