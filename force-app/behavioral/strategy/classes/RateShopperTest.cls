@IsTest
private class RateShopperTest {
  private static final List<CarrierQuote> QUOTES = new List<CarrierQuote>{
    new CarrierQuote('PARCELCO', 6.50, 3),
    new CarrierQuote('SWIFTSHIP', 9.00, 1),
    new CarrierQuote('ROADRUNNER', 4.75, 5)
  };

  /** A rule written by the caller, to show the shopper accepts any strategy. */
  private class PreferredCarrier implements IRateStrategy {
    public CarrierQuote choose(List<CarrierQuote> quotes) {
      for (CarrierQuote quote : quotes) {
        if (quote.carrierCode == 'PARCELCO') {
          return quote;
        }
      }
      return quotes[0];
    }
  }

  @IsTest
  static void bestQuote_strategyChanged_answerChanges() {
    Assert.areEqual('ROADRUNNER', new RateShopper(new CheapestRate()).bestQuote(QUOTES).carrierCode);
    Assert.areEqual('SWIFTSHIP', new RateShopper(new FastestRate()).bestQuote(QUOTES).carrierCode);
    Assert.areEqual('PARCELCO', new RateShopper(new PreferredCarrier()).bestQuote(QUOTES).carrierCode);
  }

  @IsTest
  static void cheapest_tiedOnPrice_fasterThenAlphabeticalWins() {
    List<CarrierQuote> tied = new List<CarrierQuote>{
      new CarrierQuote('ZED', 5, 2),
      new CarrierQuote('BETA', 5, 4),
      new CarrierQuote('ALPHA', 5, 2)
    };

    Assert.areEqual('ALPHA', new CheapestRate().choose(tied).carrierCode, 'faster first, then A before Z');
  }

  @IsTest
  static void fastest_tiedOnTransit_cheaperThenAlphabeticalWins() {
    List<CarrierQuote> tied = new List<CarrierQuote>{
      new CarrierQuote('ZED', 7, 1),
      new CarrierQuote('BETA', 9, 1),
      new CarrierQuote('ALPHA', 7, 1)
    };

    Assert.areEqual('ALPHA', new FastestRate().choose(tied).carrierCode, 'cheaper first, then A before Z');
  }

  @IsTest
  static void bestQuote_orderOfQuotes_doesNotMatter() {
    List<CarrierQuote> reversed = new List<CarrierQuote>{ QUOTES[2], QUOTES[1], QUOTES[0] };

    Assert.areEqual(
      new CheapestRate().choose(QUOTES).carrierCode,
      new CheapestRate().choose(reversed).carrierCode,
      'deterministic whatever order the carriers answered in'
    );
  }

  @IsTest
  static void bestQuote_noQuotesOrBadInput_rejected() {
    RateShopper shopper = new RateShopper(new CheapestRate());
    Integer rejected = 0;
    for (List<CarrierQuote> quotes : new List<List<CarrierQuote>>{ null, new List<CarrierQuote>() }) {
      try {
        shopper.bestQuote(quotes);
      } catch (RateShopper.NoQuoteException e) {
        rejected++;
      }
    }
    Assert.areEqual(2, rejected, 'null and empty both throw NoQuoteException');

    try {
      new RateShopper(null);
      Assert.fail('a shopper needs a strategy');
    } catch (IllegalArgumentException e) {
      Assert.isTrue(e.getMessage().contains('rate strategy'));
    }
    try {
      new CarrierQuote('PARCELCO', -1, 1);
      Assert.fail('a negative price is rejected');
    } catch (IllegalArgumentException e) {
      Assert.isTrue(e.getMessage().contains('zero or more'));
    }
  }

  @IsTest
  static void bestQuote_twoHundredQuotes_findsTheCheapest() {
    List<CarrierQuote> quotes = new List<CarrierQuote>();
    for (Integer i = 0; i < 200; i++) {
      quotes.add(new CarrierQuote('C' + String.valueOf(i).leftPad(3, '0'), 100 - Math.mod(i * 7, 97), Math.mod(i, 5)));
    }

    CarrierQuote cheapest = new RateShopper(new CheapestRate()).bestQuote(quotes);

    for (CarrierQuote quote : quotes) {
      Assert.isTrue(cheapest.price <= quote.price, 'no quote is cheaper than the chosen one');
    }
  }
}
