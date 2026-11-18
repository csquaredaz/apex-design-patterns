/**
 * @description Anything that can sit in an order: a single line or a bundle of items (Composite).
 * Callers price an order without knowing how deeply its bundles nest.
 * @group Structural
 */
public interface IOrderItem {
  /**
   * @description The item's price, including everything it contains.
   * @return The price, rounded to 2 decimal places.
   */
  Decimal price();

  /**
   * @description How many physical units the item ships as.
   * @return The unit count.
   */
  Integer unitCount();
}
