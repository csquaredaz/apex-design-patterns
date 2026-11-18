/**
 * @description Subscribes to `Order_Shipped_Event__e`. It runs as the Automated Process user, in
 * its own transaction, after the publisher's transaction commits. All logic is in
 * `OrderShippedSubscriber`.
 */
trigger OrderShippedEventTrigger on Order_Shipped_Event__e(after insert) {
  OrderShippedSubscriber.handle(Trigger.new);
}
