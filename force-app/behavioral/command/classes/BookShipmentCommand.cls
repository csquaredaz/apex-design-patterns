/**
 * @description Books an order's shipment with a carrier; undo cancels the booking.
 * @group Behavioral
 */
public with sharing class BookShipmentCommand implements IShipmentCommand {
  private final ShipmentLedger ledger;
  private final String orderReference;
  private final String carrierCode;

  /**
   * @description Creates the command; nothing happens until `execute()`.
   * @param ledger The receiver.
   * @param orderReference The order.
   * @param carrierCode The carrier.
   */
  public BookShipmentCommand(ShipmentLedger ledger, String orderReference, String carrierCode) {
    this.ledger = ledger;
    this.orderReference = orderReference;
    this.carrierCode = carrierCode;
  }

  /** @description Books the shipment. */
  public void execute() {
    ledger.book(orderReference, carrierCode);
  }

  /** @description Cancels the booking. */
  public void undo() {
    ledger.cancelBooking(orderReference);
  }

  /**
   * @description Describes the command.
   * @return The description.
   */
  public String describe() {
    return 'Book ' + orderReference + ' with ' + carrierCode;
  }
}
