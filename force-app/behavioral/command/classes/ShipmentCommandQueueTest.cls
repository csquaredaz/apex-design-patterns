@IsTest
private class ShipmentCommandQueueTest {
  private static List<String> undone = new List<String>();

  /** Wraps a real command and records undo calls, to check the undo order. */
  private class TrackedCommand implements IShipmentCommand {
    final IShipmentCommand real;

    TrackedCommand(IShipmentCommand real) {
      this.real = real;
    }

    public void execute() {
      real.execute();
    }

    public void undo() {
      undone.add(real.describe());
      real.undo();
    }

    public String describe() {
      return real.describe();
    }
  }

  @IsTest
  static void runAll_bookThenLabel_bothApplied() {
    ShipmentLedger ledger = new ShipmentLedger();

    List<String> log = new ShipmentCommandQueue()
      .enqueue(new BookShipmentCommand(ledger, 'ORD-1', 'PARCELCO'))
      .enqueue(new PrintLabelCommand(ledger, 'ORD-1'))
      .runAll();

    Assert.areEqual(new List<String>{ 'Book ORD-1 with PARCELCO', 'Print label for ORD-1' }, log);
    Assert.isTrue(ledger.isBooked('ORD-1'));
    Assert.isTrue(ledger.hasLabel('ORD-1'));
  }

  @IsTest
  static void runAll_commandFails_earlierOnesUndoneNewestFirst() {
    ShipmentLedger ledger = new ShipmentLedger();
    ShipmentCommandQueue queue = new ShipmentCommandQueue()
      .enqueue(new TrackedCommand(new BookShipmentCommand(ledger, 'ORD-1', 'PARCELCO')))
      .enqueue(new TrackedCommand(new PrintLabelCommand(ledger, 'ORD-1')))
      .enqueue(new TrackedCommand(new PrintLabelCommand(ledger, 'ORD-2')));

    try {
      queue.runAll();
      Assert.fail('labelling an unbooked order must fail the batch');
    } catch (ShipmentCommandQueue.CommandFailedException e) {
      Assert.isTrue(e.getMessage().contains('"Print label for ORD-2" failed; undid 2'), e.getMessage());
      Assert.isInstanceOfType(e.getCause(), IllegalArgumentException.class, 'the original failure is the cause');
    }
    Assert.areEqual(new List<String>{ 'Print label for ORD-1', 'Book ORD-1 with PARCELCO' }, undone, 'newest first');
    Assert.isFalse(ledger.isBooked('ORD-1'), 'nothing from the failed batch is left behind');
    Assert.isFalse(ledger.hasLabel('ORD-1'));
  }

  /** A command that runs but can't be undone. */
  private class StickyCommand implements IShipmentCommand {
    public void execute() {
      undone.add('sticky ran');
    }

    public void undo() {
      throw new IllegalArgumentException('carrier refused the cancellation');
    }

    public String describe() {
      return 'Sticky';
    }
  }

  @IsTest
  static void runAll_undoAlsoFails_otherUndosStillRunAndBothReported() {
    ShipmentLedger ledger = new ShipmentLedger();
    ShipmentCommandQueue queue = new ShipmentCommandQueue()
      .enqueue(new BookShipmentCommand(ledger, 'ORD-1', 'PARCELCO'))
      .enqueue(new StickyCommand())
      .enqueue(new PrintLabelCommand(ledger, 'ORD-2'));

    try {
      queue.runAll();
      Assert.fail('the batch must fail');
    } catch (ShipmentCommandQueue.CommandFailedException e) {
      Assert.isTrue(e.getMessage().contains('undid 1 earlier command(s)'), e.getMessage());
      Assert.isTrue(e.getMessage().contains('Undo also failed for: Sticky (carrier refused'), e.getMessage());
      Assert.isTrue(e.getCause().getMessage().contains('no shipment is booked'), 'the original failure is kept');
    }
    Assert.isFalse(ledger.isBooked('ORD-1'), 'the booking is still undone after the sticky undo failed');
  }

  @IsTest
  static void runAll_queueEmptiedAfterRun_secondRunDoesNothing() {
    ShipmentLedger ledger = new ShipmentLedger();
    ShipmentCommandQueue queue = new ShipmentCommandQueue()
      .enqueue(new BookShipmentCommand(ledger, 'ORD-1', 'SWIFTSHIP'));

    queue.runAll();

    Assert.areEqual(0, queue.runAll().size(), 'a command runs once; booking twice would have thrown');
  }

  @IsTest
  static void commands_createdButNotRun_changeNothing() {
    ShipmentLedger ledger = new ShipmentLedger();
    IShipmentCommand book = new BookShipmentCommand(ledger, 'ORD-1', 'PARCELCO');

    Assert.isFalse(ledger.isBooked('ORD-1'), 'creating a command does not execute it');
    book.execute();
    try {
      book.execute();
      Assert.fail('the receiver refuses a second booking');
    } catch (IllegalArgumentException e) {
      Assert.isTrue(e.getMessage().contains('already booked with PARCELCO'), e.getMessage());
    }
    book.undo();
    Assert.isFalse(ledger.isBooked('ORD-1'), 'undo reverses execute');
    try {
      new ShipmentCommandQueue().enqueue(null);
      Assert.fail('null commands are rejected');
    } catch (IllegalArgumentException e) {
      Assert.isTrue(e.getMessage().contains('null command'));
    }
  }

  @IsTest
  static void runAll_twoHundredOrders_allBookedAndLabelled() {
    ShipmentLedger ledger = new ShipmentLedger();
    ShipmentCommandQueue queue = new ShipmentCommandQueue();
    for (Integer i = 0; i < 200; i++) {
      queue.enqueue(new BookShipmentCommand(ledger, 'ORD-' + i, 'PARCELCO'))
        .enqueue(new PrintLabelCommand(ledger, 'ORD-' + i));
    }

    Assert.areEqual(400, queue.runAll().size());
    Assert.isTrue(ledger.hasLabel('ORD-199'));
  }
}
