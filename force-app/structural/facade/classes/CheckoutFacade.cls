/**
 * @description One `checkout` call over three subsystems: pricing, stock and carrier booking
 * (Facade). Callers such as an LWC controller or an invocable action don't learn the order of the
 * steps or how to undo them: if booking fails after stock was reserved, the facade releases the
 * stock before it returns. The subsystems are injected, so each can be replaced or stubbed.
 * @group Structural
 */
public with sharing class CheckoutFacade {
  private final ICheckoutPricing pricing;
  private final IStockReservation stock;
  private final IShipmentBooking booking;

  /**
   * @description Creates the facade over its subsystems.
   * @param pricing The pricing subsystem.
   * @param stock The stock subsystem.
   * @param booking The carrier booking subsystem.
   * @throws IllegalArgumentException If any subsystem is null.
   */
  public CheckoutFacade(ICheckoutPricing pricing, IStockReservation stock, IShipmentBooking booking) {
    if (pricing == null || stock == null || booking == null) {
      throw new IllegalArgumentException('CheckoutFacade needs pricing, stock and booking');
    }
    this.pricing = pricing;
    this.stock = stock;
    this.booking = booking;
  }

  /**
   * @description Prices the basket, reserves stock, then books the shipment. Stops at the first
   * step that fails; never books without stock, and never leaves stock held for a failed booking.
   * @param orderReference The order.
   * @param quantitiesBySku Quantity per SKU; must not be empty.
   * @param postalCode The destination postal code.
   * @return A completed result with the total and tracking number, or a failed one with the reason.
   */
  public CheckoutResult checkout(String orderReference, Map<String, Integer> quantitiesBySku, String postalCode) {
    if (String.isBlank(orderReference) || quantitiesBySku == null || quantitiesBySku.isEmpty()) {
      return CheckoutResult.failed(null, 'An order reference and at least one item are required');
    }
    Decimal total = pricing.priceOf(quantitiesBySku);
    if (!stock.reserve(orderReference, quantitiesBySku)) {
      return CheckoutResult.failed(total, 'Not enough stock for order ' + orderReference);
    }
    try {
      return CheckoutResult.completed(total, booking.book(orderReference, postalCode));
    } catch (ShipmentBookingException e) {
      stock.release(orderReference);
      return CheckoutResult.failed(total, 'Shipment booking failed: ' + e.getMessage());
    }
  }
}
