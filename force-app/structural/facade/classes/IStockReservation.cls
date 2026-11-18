/**
 * @description Stock subsystem behind `CheckoutFacade`.
 * @group Structural
 */
public interface IStockReservation {
  /**
   * @description Reserves stock for an order, all or nothing.
   * @param orderReference The order the stock is held for.
   * @param quantitiesBySku Quantity per SKU.
   * @return True if every SKU was reserved; false (and nothing held) otherwise.
   */
  Boolean reserve(String orderReference, Map<String, Integer> quantitiesBySku);

  /**
   * @description Releases everything held for an order. Safe to call when nothing is held.
   * @param orderReference The order.
   */
  void release(String orderReference);
}
