/**
 * @description Carrier booking subsystem behind `CheckoutFacade`.
 * @group Structural
 */
public interface IShipmentBooking {
  /**
   * @description Books a shipment for an order.
   * @param orderReference The order.
   * @param postalCode The destination postal code.
   * @return The carrier's tracking number.
   * @throws ShipmentBookingException If the carrier refuses or can't be reached.
   */
  String book(String orderReference, String postalCode);
}
