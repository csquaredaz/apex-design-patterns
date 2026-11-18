@IsTest
private class OrderShippedSubjectTest {
  private static List<String> calls = new List<String>();

  /** A listener that records each call it receives. */
  private class RecordingListener implements IOrderShippedListener {
    final String name;
    Integer batches = 0;
    Integer events = 0;

    RecordingListener(String name) {
      this.name = name;
    }

    public void onShipped(List<OrderShipped> shipped) {
      calls.add(name);
      batches++;
      events += shipped.size();
    }
  }

  /** A listener that fails. */
  private class FailingListener implements IOrderShippedListener {
    public void onShipped(List<OrderShipped> shipped) {
      calls.add('failing');
      throw new IllegalArgumentException('notifier down');
    }
  }

  private static List<OrderShipped> shipped(Integer count) {
    List<OrderShipped> events = new List<OrderShipped>();
    for (Integer i = 0; i < count; i++) {
      events.add(new OrderShipped('ORD-' + i, 'TRK-' + i));
    }
    return events;
  }

  @IsTest
  static void publish_twoHundredOrders_eachListenerCalledOnceInOrder() {
    OrderShippedSubject subject = new OrderShippedSubject();
    RecordingListener notifier = new RecordingListener('notifier');
    RecordingListener loyalty = new RecordingListener('loyalty');
    subject.subscribe(notifier);
    subject.subscribe(loyalty);

    subject.publish(shipped(200));

    Assert.areEqual(new List<String>{ 'notifier', 'loyalty' }, calls, 'subscribe order');
    Assert.areEqual(1, notifier.batches, 'one call for the whole batch, not one per order');
    Assert.areEqual(200, loyalty.events);
  }

  @IsTest
  static void subscribe_twiceOrUnsubscribed_handledByIdentity() {
    OrderShippedSubject subject = new OrderShippedSubject();
    RecordingListener first = new RecordingListener('first');
    RecordingListener twin = new RecordingListener('first');
    subject.subscribe(first);
    subject.subscribe(first);
    subject.subscribe(twin);

    subject.publish(shipped(1));
    Assert.areEqual(1, first.batches, 'subscribing the same listener twice adds it once');
    Assert.areEqual(1, twin.batches, 'a look-alike listener is a separate subscriber');

    subject.unsubscribe(first);
    subject.unsubscribe(new RecordingListener('never subscribed'));
    subject.publish(shipped(1));
    Assert.areEqual(1, first.batches, 'an unsubscribed listener hears nothing');
    Assert.areEqual(2, twin.batches);
  }

  @IsTest
  static void publish_listenerThrows_laterListenersSkippedAndCallerSeesIt() {
    OrderShippedSubject subject = new OrderShippedSubject();
    RecordingListener later = new RecordingListener('later');
    subject.subscribe(new FailingListener());
    subject.subscribe(later);

    try {
      subject.publish(shipped(3));
      Assert.fail('a listener failure must reach the caller');
    } catch (IllegalArgumentException e) {
      Assert.areEqual('notifier down', e.getMessage());
    }
    Assert.areEqual(new List<String>{ 'failing' }, calls);
    Assert.areEqual(0, later.batches, 'in-transaction observers are not isolated from each other');
  }

  @IsTest
  static void publish_nothingOrNoListeners_isANoOp() {
    OrderShippedSubject subject = new OrderShippedSubject();
    subject.publish(shipped(5));
    RecordingListener listener = new RecordingListener('listener');
    subject.subscribe(listener);

    subject.publish(new List<OrderShipped>());
    subject.publish(null);

    Assert.areEqual(0, listener.batches);
    try {
      subject.subscribe(null);
      Assert.fail('null listeners are rejected');
    } catch (IllegalArgumentException e) {
      Assert.isTrue(e.getMessage().contains('null listener'));
    }
  }
}
