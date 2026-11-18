/**
 * @description Announces shipped orders on `Order_Shipped_Event__e` (Publish-Subscribe Channel). The
 * publisher knows the channel, not the subscribers: each subscriber runs in its own transaction,
 * with its own retries, so one subscriber's failure can't undo the shipment or another subscriber.
 * The event is Publish After Commit, so nobody hears about a shipment that rolled back.
 * @group EIP
 */
public with sharing class OrderShippedPublisher {
  /**
   * @description Publishes one event per order, in one `EventBus.publish` call.
   * @param trackingNumberByOrderId Each shipped Order's tracking number. Empty or null publishes
   * nothing.
   * @throws IllegalArgumentException If an Order Id is null or a tracking number is blank; nothing
   * is published then.
   * @throws OrderEventPublishException If any event fails to publish, naming each error. The
   * running user needs the `Order_Event_Publisher` permission set.
   */
  public static void publish(Map<Id, String> trackingNumberByOrderId) {
    if (trackingNumberByOrderId == null || trackingNumberByOrderId.isEmpty()) {
      return;
    }
    List<Order_Shipped_Event__e> events = eventsFor(trackingNumberByOrderId);
    List<String> failures = failuresOf(events, EventBus.publish(events));
    if (!failures.isEmpty()) {
      throw new OrderEventPublishException('Could not publish order shipped events: ' + String.join(failures, '; '));
    }
  }

  private static List<Order_Shipped_Event__e> eventsFor(Map<Id, String> trackingNumberByOrderId) {
    List<Order_Shipped_Event__e> events = new List<Order_Shipped_Event__e>();
    for (Id orderId : trackingNumberByOrderId.keySet()) {
      String trackingNumber = trackingNumberByOrderId.get(orderId);
      if (orderId == null || String.isBlank(trackingNumber)) {
        throw new IllegalArgumentException('Every shipped order needs an Order Id and a tracking number');
      }
      events.add(new Order_Shipped_Event__e(Order_Id__c = orderId, Tracking_Number__c = trackingNumber));
    }
    return events;
  }

  private static List<String> failuresOf(List<Order_Shipped_Event__e> events, List<Database.SaveResult> results) {
    List<String> failures = new List<String>();
    for (Integer i = 0; i < results.size(); i++) {
      // A successful publish can list an OPERATION_ENQUEUED "error"; only failed results count.
      if (results[i].isSuccess()) {
        continue;
      }
      for (Database.Error error : results[i].getErrors()) {
        failures.add(events[i].Order_Id__c + ': ' + error.getStatusCode() + ' ' + error.getMessage());
      }
    }
    return failures;
  }
}
