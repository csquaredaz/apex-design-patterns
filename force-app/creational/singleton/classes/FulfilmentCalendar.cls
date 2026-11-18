/**
 * @description The org's default business hours, loaded once per transaction (Singleton). Every
 * caller in a transaction shares one instance, so 200 orders in a trigger cost one SOQL query, not
 * 200. "Once" means once per Apex transaction: a static field doesn't survive into the next
 * transaction, a Queueable, a batch `execute` or a Platform Event trigger run.
 * @group Creational
 */
public with sharing class FulfilmentCalendar {
  private static FulfilmentCalendar instance;

  private final Id businessHoursId;

  private FulfilmentCalendar(Id businessHoursId) {
    this.businessHoursId = businessHoursId;
  }

  /**
   * @description Returns the shared calendar, loading the default business hours on first use.
   * @return The transaction's calendar.
   * @throws QueryException If the org has no default business hours (every org has one).
   */
  public static FulfilmentCalendar getInstance() {
    if (instance == null) {
      BusinessHours defaultHours = [SELECT Id FROM BusinessHours WHERE IsDefault = TRUE WITH USER_MODE LIMIT 1];
      instance = new FulfilmentCalendar(defaultHours.Id);
    }
    return instance;
  }

  /**
   * @description The default business hours record.
   * @return Its Id.
   */
  public Id businessHoursId() {
    return businessHoursId;
  }

  /**
   * @description The first working moment at or after a time, for example when a warehouse can
   * start on an order placed overnight.
   * @param fromTime The time to start from.
   * @return `fromTime` if it is within business hours, otherwise the next start of business hours.
   */
  public Datetime nextWorkingTime(Datetime fromTime) {
    return BusinessHours.nextStartDate(businessHoursId, fromTime);
  }

  @TestVisible
  private static void reset() {
    instance = null;
  }
}
