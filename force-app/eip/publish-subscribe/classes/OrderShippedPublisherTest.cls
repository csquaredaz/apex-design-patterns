@IsTest
private class OrderShippedPublisherTest {
  private static final String PUBLISHER_PERMSET = 'Order_Event_Publisher';

  // Users first, then data: a permission set assignment after other DML is MIXED_DML_OPERATION.
  private static User minimumAccessUser(String alias, Boolean canPublish) {
    Profile minimum = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce' WITH SYSTEM_MODE LIMIT 1];
    User u = new User(
      Alias = alias,
      Email = alias + '@example.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Shipper ' + alias,
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = minimum.Id,
      TimeZoneSidKey = 'Europe/London',
      Username = alias + '.' + Crypto.getRandomInteger() + '@example.com.adp'
    );
    Database.insert(u, AccessLevel.SYSTEM_MODE);
    if (canPublish) {
      PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :PUBLISHER_PERMSET WITH SYSTEM_MODE];
      Database.insert(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id), AccessLevel.SYSTEM_MODE);
    }
    return u;
  }

  // Arranged in system mode: the running admin has none of this repo's permission sets in CI.
  private static List<Order> orders(Integer count) {
    List<Order> rows = new List<Order>();
    System.runAs(new User(Id = UserInfo.getUserId())) {
      Account customer = new Account(Name = 'Acme Teapots');
      Database.insert(customer, AccessLevel.SYSTEM_MODE);
      for (Integer i = 0; i < count; i++) {
        rows.add(new Order(AccountId = customer.Id, EffectiveDate = Date.today(), Status = 'Draft'));
      }
      Database.insert(rows, AccessLevel.SYSTEM_MODE);
    }
    return rows;
  }

  private static Map<Id, String> tracking(List<Order> rows) {
    Map<Id, String> trackingByOrderId = new Map<Id, String>();
    for (Integer i = 0; i < rows.size(); i++) {
      trackingByOrderId.put(rows[i].Id, 'TRK-' + i);
    }
    return trackingByOrderId;
  }

  private static List<Task> shipmentTasks() {
    return [
      SELECT WhatId, Subject, Status, CreatedById, CreatedBy.UserType
      FROM Task
      WHERE Subject LIKE 'Shipped: %'
      WITH SYSTEM_MODE
    ];
  }

  @IsTest
  static void publish_twoHundredOrdersAsPublisher_subscriberWritesATaskForEach() {
    User publisher = minimumAccessUser('pubok', true);
    List<Order> rows = orders(200);

    System.runAs(publisher) {
      OrderShippedPublisher.publish(tracking(rows));
      Assert.areEqual(0, shipmentTasks().size(), 'after commit: the subscriber has not run yet');
      Test.getEventBus().deliver();
    }

    List<Task> tasks = shipmentTasks();
    Assert.areEqual(200, tasks.size(), 'one Task per shipped order');
    Map<Id, Task> taskByOrder = new Map<Id, Task>();
    for (Task t : tasks) {
      taskByOrder.put(t.WhatId, t);
    }
    Assert.areEqual('Shipped: TRK-0', taskByOrder.get(rows[0].Id).Subject);
    Assert.areEqual('Completed', taskByOrder.get(rows[199].Id).Status);
    Assert.areEqual('AutomatedProcess', tasks[0].CreatedBy.UserType, 'the subscriber runs as Automated Process');
  }

  @IsTest
  static void publish_withoutThePermissionSet_throwsAndNothingIsDelivered() {
    User outsider = minimumAccessUser('pubno', false);
    List<Order> rows = orders(2);

    System.runAs(outsider) {
      try {
        OrderShippedPublisher.publish(tracking(rows));
        Assert.fail('a user without Create on the event must not publish silently');
      } catch (OrderEventPublishException e) {
        Assert.isTrue(e.getMessage().contains(rows[0].Id), e.getMessage());
      }
      Test.getEventBus().deliver();
    }

    Assert.areEqual(0, shipmentTasks().size());
  }

  @IsTest
  static void handle_missingOrderOrBadId_skippedAndTheRestWritten() {
    User publisher = minimumAccessUser('pubbad', true);
    List<Order> rows = orders(2);
    // An Order Id that never existed fails its Task insert. (A Task on a deleted Order, even after
    // emptyRecycleBin, still inserted in a test, so a delete isn't a reliable failure here.)
    Id missing = Id.valueOf(
      Order.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '000000000042'
    );
    Map<Id, String> trackingByOrderId = tracking(rows);
    trackingByOrderId.put(missing, 'TRK-MISSING');

    System.runAs(publisher) {
      OrderShippedPublisher.publish(trackingByOrderId);
      Test.getEventBus().deliver();
    }
    Integer written;
    // A new runAs context: Task DML right after the permission set assignment is MIXED_DML_OPERATION.
    System.runAs(new User(Id = UserInfo.getUserId())) {
      written = OrderShippedSubscriber.handle(
        new List<Order_Shipped_Event__e>{
          new Order_Shipped_Event__e(Order_Id__c = null, Tracking_Number__c = 'TRK-W'),
          new Order_Shipped_Event__e(Order_Id__c = 'not-an-id', Tracking_Number__c = 'TRK-X'),
          new Order_Shipped_Event__e(Order_Id__c = UserInfo.getUserId(), Tracking_Number__c = 'TRK-Y'),
          new Order_Shipped_Event__e(Order_Id__c = rows[1].Id, Tracking_Number__c = 'TRK-Z')
        }
      );
    }

    Set<Id> orderIds = new Set<Id>();
    for (Task t : shipmentTasks()) {
      orderIds.add(t.WhatId);
    }
    Assert.areEqual(new Set<Id>{ rows[0].Id, rows[1].Id }, orderIds, 'the missing order is skipped, the rest written');
    Assert.areEqual(1, written, 'a blank, a non-Id and a non-Order Id are skipped without failing the batch');
  }

  @IsTest
  static void publish_invalidInput_rejectedOrIgnored() {
    OrderShippedPublisher.publish(null);
    OrderShippedPublisher.publish(new Map<Id, String>());
    Integer rejected = 0;
    List<Map<Id, String>> bad = new List<Map<Id, String>>{
      new Map<Id, String>{ null => 'TRK-1' },
      new Map<Id, String>{ UserInfo.getUserId() => ' ' }
    };
    for (Map<Id, String> input : bad) {
      try {
        OrderShippedPublisher.publish(input);
      } catch (IllegalArgumentException e) {
        rejected++;
      }
    }
    Test.getEventBus().deliver();

    Assert.areEqual(2, rejected, 'a null Order Id or a blank tracking number');
    Assert.areEqual(0, shipmentTasks().size(), 'nothing was published');
  }
}
