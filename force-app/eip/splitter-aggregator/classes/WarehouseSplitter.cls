/**
 * @description Splits an order into one pick per warehouse (Splitter). Every pick carries the order
 * reference as its correlation id and the number of picks the order became, so `PickAggregator`
 * can tell when all of them are confirmed without asking the splitter.
 * @group EIP
 */
public with sharing class WarehouseSplitter {
  private final Map<String, String> warehouseBySku;

  /**
   * @description Creates a splitter over a stocking table.
   * @param warehouseBySku The warehouse that ships each SKU.
   * @throws IllegalArgumentException If the table is null or empty.
   */
  public WarehouseSplitter(Map<String, String> warehouseBySku) {
    if (warehouseBySku == null || warehouseBySku.isEmpty()) {
      throw new IllegalArgumentException('A splitter needs a warehouse for at least one SKU');
    }
    this.warehouseBySku = warehouseBySku.clone();
  }

  /**
   * @description Splits one order. Picks come out sorted by warehouse (a Map's key order
   * isn't a documented contract), and each pick holds only that warehouse's lines.
   * @param orderRef The order reference; becomes each pick's correlation id.
   * @param quantityBySku The order's lines.
   * @return One pick per warehouse.
   * @throws IllegalArgumentException If the reference is blank, there are no lines, a quantity is
   * not positive, or any SKU has no warehouse (all of them are named). A splitter never drops lines.
   */
  public List<WarehousePick> split(String orderRef, Map<String, Integer> quantityBySku) {
    if (String.isBlank(orderRef) || quantityBySku == null || quantityBySku.isEmpty()) {
      throw new IllegalArgumentException('An order needs a reference and at least one line');
    }
    checkLines(quantityBySku);
    Map<String, Map<String, Integer>> linesByWarehouse = new Map<String, Map<String, Integer>>();
    for (String sku : quantityBySku.keySet()) {
      String warehouse = warehouseBySku.get(sku);
      if (!linesByWarehouse.containsKey(warehouse)) {
        linesByWarehouse.put(warehouse, new Map<String, Integer>());
      }
      linesByWarehouse.get(warehouse).put(sku, quantityBySku.get(sku));
    }
    List<String> warehouses = new List<String>(linesByWarehouse.keySet());
    warehouses.sort();
    List<WarehousePick> picks = new List<WarehousePick>();
    for (String warehouse : warehouses) {
      picks.add(new WarehousePick(orderRef, warehouse, warehouses.size(), linesByWarehouse.get(warehouse)));
    }
    return picks;
  }

  // Every line must have a positive quantity and a warehouse; name all unmapped SKUs at once.
  private void checkLines(Map<String, Integer> quantityBySku) {
    List<String> unmapped = new List<String>();
    for (String sku : quantityBySku.keySet()) {
      Integer quantity = quantityBySku.get(sku);
      if (quantity == null || quantity <= 0) {
        throw new IllegalArgumentException('SKU ' + sku + ' needs a positive quantity');
      }
      if (String.isBlank(warehouseBySku.get(sku))) {
        unmapped.add(sku);
      }
    }
    if (!unmapped.isEmpty()) {
      unmapped.sort();
      throw new IllegalArgumentException('No warehouse stocks: ' + String.join(unmapped, ', '));
    }
  }
}
