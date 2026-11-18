/**
 * @description One shipment operation as an object (Command): it can be queued, run later, described
 * in a log, and undone.
 * @group Behavioral
 */
public interface IShipmentCommand {
  /** @description Performs the operation. */
  void execute();

  /** @description Reverses a completed `execute()`. Only called after `execute()` succeeded. */
  void undo();

  /**
   * @description A line for logs and error messages.
   * @return What the command does, for example `Book ORD-1 with PARCELCO`.
   */
  String describe();
}
