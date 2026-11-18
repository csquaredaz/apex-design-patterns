/**
 * @description One product at a quantity: the Composite's leaf.
 * @group Structural
 */
public with sharing class OrderLine implements IOrderItem {
  /** @description The product's stock-keeping unit. */
  public final String sku;
  private final Decimal unitPrice;
  private final Integer quantity;

  /**
   * @description Creates an order line.
   * @param sku The product SKU.
   * @param unitPrice The price of one unit; zero or more.
   * @param quantity The quantity; at least 1.
   * @throws IllegalArgumentException If the price is negative or the quantity is below 1.
   */
  public OrderLine(String sku, Decimal unitPrice, Integer quantity) {
    if (unitPrice == null || unitPrice < 0 || quantity == null || quantity < 1) {
      throw new IllegalArgumentException(
        'Order line ' + sku + ' needs a price of zero or more and a quantity of at least 1'
      );
    }
    this.sku = sku;
    this.unitPrice = unitPrice;
    this.quantity = quantity;
  }

  /**
   * @description The unit price times the quantity.
   * @return The price.
   */
  public Decimal price() {
    return (unitPrice * quantity).setScale(2, RoundingMode.HALF_UP);
  }

  /**
   * @description The quantity.
   * @return The unit count.
   */
  public Integer unitCount() {
    return quantity;
  }
}
