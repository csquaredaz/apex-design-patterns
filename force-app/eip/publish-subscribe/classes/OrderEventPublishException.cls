/**
 * @description `OrderShippedPublisher` couldn't publish some events, for example because the running
 * user has no Create access on `Order_Shipped_Event__e` (permission set `Order_Event_Publisher`).
 * @group EIP
 */
public with sharing class OrderEventPublishException extends Exception {
}
