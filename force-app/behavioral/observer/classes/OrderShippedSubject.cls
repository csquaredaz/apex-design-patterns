/**
 * @description Tells every subscribed listener when orders ship (Observer's subject). The shipping
 * code calls `publish` and doesn't know who is listening: a customer notifier, a loyalty-points
 * service, an analytics feed. Everything runs in the caller's transaction, so if a listener throws,
 * the later listeners don't run and the caller sees the exception. For listeners that must be
 * isolated from each other, publish a Platform Event instead (see `eip/publish-subscribe`).
 * @group Behavioral
 */
public with sharing class OrderShippedSubject {
  private final List<IOrderShippedListener> listeners = new List<IOrderShippedListener>();

  /**
   * @description Adds a listener. A listener already subscribed isn't added twice.
   * @param listener The listener.
   * @throws IllegalArgumentException If the listener is null.
   */
  public void subscribe(IOrderShippedListener listener) {
    if (listener == null) {
      throw new IllegalArgumentException('Cannot subscribe a null listener');
    }
    if (indexOf(listener) < 0) {
      listeners.add(listener);
    }
  }

  /**
   * @description Removes a listener. Removing one that isn't subscribed does nothing.
   * @param listener The listener.
   */
  public void unsubscribe(IOrderShippedListener listener) {
    Integer index = indexOf(listener);
    if (index >= 0) {
      listeners.remove(index);
    }
  }

  /**
   * @description Sends a batch to every listener once, in subscribe order. An empty or null batch
   * notifies nobody. A listener's exception stops the remaining listeners and reaches the caller.
   * @param events The orders that shipped.
   */
  public void publish(List<OrderShipped> events) {
    if (events == null || events.isEmpty()) {
      return;
    }
    // Iterate over a copy, so a listener that unsubscribes itself doesn't skip its neighbour.
    for (IOrderShippedListener listener : new List<IOrderShippedListener>(listeners)) {
      listener.onShipped(events);
    }
  }

  // Identity, not equals(): two listeners of the same class are different subscribers.
  private Integer indexOf(IOrderShippedListener listener) {
    for (Integer i = 0; i < listeners.size(); i++) {
      if (listeners[i] === listener) {
        return i;
      }
    }
    return -1;
  }
}
