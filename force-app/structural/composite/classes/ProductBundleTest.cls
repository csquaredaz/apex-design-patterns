@IsTest
private class ProductBundleTest {
  @IsTest
  static void price_lineAndBundle_treatedAlike() {
    List<IOrderItem> order = new List<IOrderItem>{
      new OrderLine('MUG', 8.50, 2),
      new ProductBundle('Coffee set', 10).add(new OrderLine('BEANS', 12, 1)).add(new OrderLine('FILTER', 3, 2))
    };

    Decimal total = 0;
    Integer units = 0;
    for (IOrderItem item : order) {
      total += item.price();
      units += item.unitCount();
    }

    Assert.areEqual(17.00 + 16.20, total, 'the caller never asks which kind of item it has');
    Assert.areEqual(5, units);
  }

  @IsTest
  static void price_nestedBundles_applyEachDiscount() {
    ProductBundle refills = new ProductBundle('Refills', 50).add(new OrderLine('BEANS', 10, 2));
    ProductBundle giftBox = new ProductBundle('Gift box', 10).add(refills).add(new OrderLine('MUG', 10, 1));

    Assert.areEqual(18.00, giftBox.price(), '((20 x 50%) + 10) x 90%');
    Assert.areEqual(3, giftBox.unitCount());
  }

  @IsTest
  static void price_emptyBundle_isZero() {
    ProductBundle empty = new ProductBundle('Empty', 0);

    Assert.areEqual(0, empty.price());
    Assert.areEqual(0, empty.unitCount());
  }

  @IsTest
  static void build_invalidItems_rejected() {
    ProductBundle bundle = new ProductBundle('Kit', 5);
    Integer rejected = 0;
    List<Object> attempts = new List<Object>{ 'self', 'null', 'discount', 'quantity', 'price' };
    for (Object attempt : attempts) {
      try {
        switch on (String) attempt {
          when 'self' {
            bundle.add(bundle);
          }
          when 'null' {
            bundle.add(null);
          }
          when 'discount' {
            new ProductBundle('Too generous', 101);
          }
          when 'quantity' {
            new OrderLine('MUG', 1, 0);
          }
          when else {
            new OrderLine('MUG', -1, 1);
          }
        }
      } catch (IllegalArgumentException e) {
        rejected++;
      }
    }
    Assert.areEqual(attempts.size(), rejected, 'every invalid item is rejected');
    Assert.areEqual(0, bundle.unitCount(), 'a rejected add leaves the bundle unchanged');
  }

  @IsTest
  static void price_twoHundredLines_summed() {
    ProductBundle bundle = new ProductBundle('Bulk', 0);
    for (Integer i = 0; i < 200; i++) {
      bundle.add(new OrderLine('SKU-' + i, 1.25, 1));
    }

    Assert.areEqual(250.00, bundle.price());
    Assert.areEqual(200, bundle.unitCount());
  }
}
