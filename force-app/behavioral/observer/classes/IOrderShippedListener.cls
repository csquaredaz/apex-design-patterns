/**
 * @description Something that reacts when orders ship (Observer). Listeners get the whole batch in
 * one call, so a listener that queries or writes does it once per batch, not once per order.
 * @group Behavioral
 */
public interface IOrderShippedListener {
  /**
   * @description Handles a batch of shipped orders.
   * @param events The orders that shipped, in publish order; never empty.
   */
  void onShipped(List<OrderShipped> events);
}
