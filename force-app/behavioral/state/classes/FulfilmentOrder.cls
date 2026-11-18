/**
 * @description An order's fulfilment lifecycle (State). Each status is an object that knows its own
 * legal moves, so the rules live in one place per status instead of in `if (status == …)` checks
 * spread across triggers, flows and services:
 *
 * PENDING → PAID → SHIPPED → DELIVERED, and PENDING or PAID → CANCELLED.
 *
 * Every other move throws `IllegalTransitionException` and leaves the order unchanged. The states
 * are private, so callers can only ask the order to move, never set its status.
 * @group Behavioral
 */
public with sharing class FulfilmentOrder {
  /** @description The order reference. */
  public final String reference;

  private FulfilmentState state = new Pending();
  private String trackingNumber;
  private final List<String> transitions = new List<String>();

  /**
   * @description Creates an order in `PENDING`.
   * @param reference The order reference.
   */
  public FulfilmentOrder(String reference) {
    this.reference = reference;
    transitions.add(state.name());
  }

  /**
   * @description Records payment.
   * @return This order.
   * @throws IllegalTransitionException Unless the order is `PENDING`.
   */
  public FulfilmentOrder pay() {
    return moveTo(state.pay(this));
  }

  /**
   * @description Hands the order to the carrier.
   * @param trackingNumber The carrier's tracking number; required.
   * @return This order.
   * @throws IllegalTransitionException Unless the order is `PAID`.
   * @throws IllegalArgumentException If the tracking number is blank.
   */
  public FulfilmentOrder ship(String trackingNumber) {
    return moveTo(state.ship(this, trackingNumber));
  }

  /**
   * @description Records delivery.
   * @return This order.
   * @throws IllegalTransitionException Unless the order is `SHIPPED`.
   */
  public FulfilmentOrder deliver() {
    return moveTo(state.deliver(this));
  }

  /**
   * @description Cancels the order.
   * @return This order.
   * @throws IllegalTransitionException Unless the order is `PENDING` or `PAID`.
   */
  public FulfilmentOrder cancel() {
    return moveTo(state.cancel(this));
  }

  /**
   * @description The current status.
   * @return `PENDING`, `PAID`, `SHIPPED`, `DELIVERED` or `CANCELLED`.
   */
  public String status() {
    return state.name();
  }

  /**
   * @description The carrier's tracking number, once shipped.
   * @return The tracking number, or null.
   */
  public String trackingNumber() {
    return trackingNumber;
  }

  /**
   * @description Every status the order has been in, oldest first.
   * @return A copy of the history.
   */
  public List<String> history() {
    return new List<String>(transitions);
  }

  private FulfilmentOrder moveTo(FulfilmentState nextState) {
    state = nextState;
    transitions.add(state.name());
    return this;
  }

  /** @description Thrown when an order is asked to make a move its status doesn't allow. */
  public class IllegalTransitionException extends Exception {
  }

  // The base state rejects every move; each state overrides only the moves it allows.
  private abstract class FulfilmentState {
    public abstract String name();

    public virtual FulfilmentState pay(FulfilmentOrder owner) {
      throw rejected('pay');
    }

    public virtual FulfilmentState ship(FulfilmentOrder owner, String trackingNumber) {
      throw rejected('ship');
    }

    public virtual FulfilmentState deliver(FulfilmentOrder owner) {
      throw rejected('deliver');
    }

    public virtual FulfilmentState cancel(FulfilmentOrder owner) {
      throw rejected('cancel');
    }

    IllegalTransitionException rejected(String action) {
      return new IllegalTransitionException('Cannot ' + action + ' an order that is ' + name());
    }
  }

  private class Pending extends FulfilmentState {
    public override String name() {
      return 'PENDING';
    }

    public override FulfilmentState pay(FulfilmentOrder owner) {
      return new Paid();
    }

    public override FulfilmentState cancel(FulfilmentOrder owner) {
      return new Cancelled();
    }
  }

  private class Paid extends FulfilmentState {
    public override String name() {
      return 'PAID';
    }

    public override FulfilmentState ship(FulfilmentOrder owner, String trackingNumber) {
      if (String.isBlank(trackingNumber)) {
        throw new IllegalArgumentException('Shipping needs a tracking number');
      }
      owner.trackingNumber = trackingNumber;
      return new Shipped();
    }

    public override FulfilmentState cancel(FulfilmentOrder owner) {
      return new Cancelled();
    }
  }

  private class Shipped extends FulfilmentState {
    public override String name() {
      return 'SHIPPED';
    }

    public override FulfilmentState deliver(FulfilmentOrder owner) {
      return new Delivered();
    }
  }

  private class Delivered extends FulfilmentState {
    public override String name() {
      return 'DELIVERED';
    }
  }

  private class Cancelled extends FulfilmentState {
    public override String name() {
      return 'CANCELLED';
    }
  }
}
