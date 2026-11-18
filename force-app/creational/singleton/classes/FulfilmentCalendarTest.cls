@IsTest
private class FulfilmentCalendarTest {
  @IsTest
  static void getInstance_calledTwice_returnsSameInstance() {
    Assert.isTrue(FulfilmentCalendar.getInstance() === FulfilmentCalendar.getInstance());
  }

  @IsTest
  static void getInstance_twoHundredCallers_queryOnce() {
    Integer before = Limits.getQueries();

    for (Integer i = 0; i < 200; i++) {
      FulfilmentCalendar.getInstance().businessHoursId();
    }

    Assert.areEqual(before + 1, Limits.getQueries(), 'loaded lazily, exactly once');
  }

  @IsTest
  static void getInstance_loadsTheDefaultBusinessHours() {
    BusinessHours expected = [SELECT Id FROM BusinessHours WHERE IsDefault = TRUE LIMIT 1];

    Assert.areEqual(expected.Id, FulfilmentCalendar.getInstance().businessHoursId());
  }

  @IsTest
  static void nextWorkingTime_matchesThePlatformCalculation() {
    FulfilmentCalendar calendar = FulfilmentCalendar.getInstance();
    Datetime sundayNight = Datetime.newInstanceGmt(2026, 11, 22, 23, 30, 0);

    Datetime next = calendar.nextWorkingTime(sundayNight);

    Assert.isTrue(next >= sundayNight, 'never earlier than the start time');
    Assert.isTrue(BusinessHours.isWithin(calendar.businessHoursId(), next), 'the result is working time');
  }

  @IsTest
  static void reset_nextCaller_reloads() {
    FulfilmentCalendar first = FulfilmentCalendar.getInstance();
    Integer before = Limits.getQueries();

    FulfilmentCalendar.reset();
    FulfilmentCalendar second = FulfilmentCalendar.getInstance();

    Assert.isTrue(first !== second, 'a reset (like a new transaction) gives a new instance');
    Assert.areEqual(before + 1, Limits.getQueries());
  }
}
