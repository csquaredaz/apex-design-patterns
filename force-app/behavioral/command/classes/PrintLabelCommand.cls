/**
 * @description Prints the label for a booked shipment; undo voids it.
 * @group Behavioral
 */
public with sharing class PrintLabelCommand implements IShipmentCommand {
  private final ShipmentLedger ledger;
  private final String orderReference;

  /**
   * @description Creates the command; nothing happens until `execute()`.
   * @param ledger The receiver.
   * @param orderReference The order.
   */
  public PrintLabelCommand(ShipmentLedger ledger, String orderReference) {
    this.ledger = ledger;
    this.orderReference = orderReference;
  }

  /** @description Prints the label. */
  public void execute() {
    ledger.printLabel(orderReference);
  }

  /** @description Voids the label. */
  public void undo() {
    ledger.voidLabel(orderReference);
  }

  /**
   * @description Describes the command.
   * @return The description.
   */
  public String describe() {
    return 'Print label for ' + orderReference;
  }
}
