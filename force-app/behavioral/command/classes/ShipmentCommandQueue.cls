/**
 * @description Runs queued shipment commands in order, all or nothing (the Command's invoker). If a
 * command fails, the commands that already ran are undone newest first, and the failure is
 * reported with the original exception as its cause. The queue knows nothing about booking or
 * labels; it only knows `IShipmentCommand`.
 * @group Behavioral
 */
public with sharing class ShipmentCommandQueue {
  private final List<IShipmentCommand> pending = new List<IShipmentCommand>();

  /**
   * @description Adds a command to the end of the queue.
   * @param command The command.
   * @return This queue, so calls chain.
   * @throws IllegalArgumentException If the command is null.
   */
  public ShipmentCommandQueue enqueue(IShipmentCommand command) {
    if (command == null) {
      throw new IllegalArgumentException('Cannot queue a null command');
    }
    pending.add(command);
    return this;
  }

  /**
   * @description Runs every queued command, then empties the queue.
   * @return The descriptions of the commands that ran, in order.
   * @throws CommandFailedException If a command fails. Every command that ran before it is undone,
   * newest first; if an undo also fails, the others still run and the message lists it.
   */
  public List<String> runAll() {
    List<IShipmentCommand> executed = new List<IShipmentCommand>();
    List<IShipmentCommand> batch = new List<IShipmentCommand>(pending);
    pending.clear();
    for (IShipmentCommand command : batch) {
      try {
        command.execute();
      } catch (Exception e) {
        List<String> undoFailures = undoNewestFirst(executed);
        String message =
          '"' +
          command.describe() +
          '" failed; undid ' +
          (executed.size() - undoFailures.size()) +
          ' earlier command(s): ' +
          e.getMessage();
        if (!undoFailures.isEmpty()) {
          message += '. Undo also failed for: ' + String.join(undoFailures, '; ');
        }
        throw new CommandFailedException(message, e);
      }
      executed.add(command);
    }
    List<String> log = new List<String>();
    for (IShipmentCommand command : executed) {
      log.add(command.describe());
    }
    return log;
  }

  // Undo every executed command even if one undo fails, so one broken undo can't leave the others
  // in place or hide the original failure. Returns the undo failures for the error message.
  private static List<String> undoNewestFirst(List<IShipmentCommand> executed) {
    List<String> failures = new List<String>();
    for (Integer i = executed.size() - 1; i >= 0; i--) {
      try {
        executed[i].undo();
      } catch (Exception e) {
        failures.add(executed[i].describe() + ' (' + e.getMessage() + ')');
      }
    }
    return failures;
  }

  /** @description Thrown when a queued command fails, after the earlier ones are undone. */
  public class CommandFailedException extends Exception {
  }
}
