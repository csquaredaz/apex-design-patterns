/**
 * @description The `Order_Shipped_Event__e` subscriber: records each shipment as a completed Task
 * on its Order. It runs as the Automated Process user, which owns the Tasks (proven in a scratch
 * org: that user may insert Tasks on Orders in user mode with no permission set). Other subscribers,
 * such as a Flow or an external CometD client, can listen to the same channel without any change here.
 * @group EIP
 */
public with sharing class OrderShippedSubscriber {
  /**
   * @description Writes one Task per event in one partial-success insert, so an event whose
   * Order Id is blank, isn't an Order's, or names no Order (or a Task that a validation rule refuses)
   * doesn't block the rest of the batch. A deleted Order doesn't fail: its Task still inserts. Production
   * code would log or dead-letter those (see this pattern's card); here they're skipped.
   * @param events The delivered events.
   * @return How many Tasks were written.
   */
  public static Integer handle(List<Order_Shipped_Event__e> events) {
    List<Task> tasks = new List<Task>();
    for (Order_Shipped_Event__e shipped : events) {
      Id orderId = orderIdOf(shipped.Order_Id__c);
      if (orderId != null) {
        tasks.add(
          new Task(
            WhatId = orderId,
            Subject = 'Shipped: ' + shipped.Tracking_Number__c,
            Status = 'Completed',
            Priority = 'Normal'
          )
        );
      }
    }
    Integer written = 0;
    for (Database.SaveResult result : Database.insert(tasks, false, AccessLevel.USER_MODE)) {
      if (result.isSuccess()) {
        written++;
      }
    }
    return written;
  }

  // Any publisher can reach the channel (Apex, Flow, the APIs), so don't trust the field to hold an Order Id.
  private static Id orderIdOf(String value) {
    if (String.isBlank(value)) {
      return null;
    }
    try {
      Id candidate = Id.valueOf(value);
      return candidate.getSObjectType() == Order.SObjectType ? candidate : null;
    } catch (StringException e) {
      return null;
    }
  }
}
