/**
 * @description A named group of items sold together at a discount: the Composite. A bundle can
 * hold lines and other bundles, and prices itself by asking its children.
 * @group Structural
 */
public with sharing class ProductBundle implements IOrderItem {
  /** @description The bundle's name, for example `Starter kit`. */
  public final String name;
  private final Decimal discountPercent;
  private final List<IOrderItem> items = new List<IOrderItem>();

  /**
   * @description Creates an empty bundle.
   * @param name The bundle name.
   * @param discountPercent The discount on the bundle's contents, from 0 to 100.
   * @throws IllegalArgumentException If the discount is outside 0–100.
   */
  public ProductBundle(String name, Decimal discountPercent) {
    if (discountPercent == null || discountPercent < 0 || discountPercent > 100) {
      throw new IllegalArgumentException('Bundle ' + name + ' discount must be 0-100%, not ' + discountPercent);
    }
    this.name = name;
    this.discountPercent = discountPercent;
  }

  /**
   * @description Adds an item (a line or another bundle).
   * @param item The item to add.
   * @return This bundle, so calls chain.
   * @throws IllegalArgumentException If the item is null or is this bundle.
   */
  public ProductBundle add(IOrderItem item) {
    if (item == null || item === this) {
      throw new IllegalArgumentException('Bundle ' + name + ' cannot contain null or itself');
    }
    items.add(item);
    return this;
  }

  /**
   * @description The children's total, less this bundle's discount. Nested bundles apply their own
   * discount first.
   * @return The price, rounded to 2 decimal places.
   */
  public Decimal price() {
    Decimal total = 0;
    for (IOrderItem item : items) {
      total += item.price();
    }
    return (total * (100 - discountPercent) / 100).setScale(2, RoundingMode.HALF_UP);
  }

  /**
   * @description The children's unit count.
   * @return The unit count.
   */
  public Integer unitCount() {
    Integer units = 0;
    for (IOrderItem item : items) {
      units += item.unitCount();
    }
    return units;
  }
}
