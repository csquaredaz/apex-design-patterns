/**
 * @description Pricing subsystem behind `CheckoutFacade`.
 * @group Structural
 */
public interface ICheckoutPricing {
  /**
   * @description Prices a basket.
   * @param quantitiesBySku Quantity per SKU.
   * @return The basket total.
   */
  Decimal priceOf(Map<String, Integer> quantitiesBySku);
}
