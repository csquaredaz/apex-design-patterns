/**
 * @description Base class for surcharges (Decorator). It holds the wrapped cost and appends this
 * layer's line to the wrapped breakdown; a subclass only says how it changes the amount and how it
 * describes itself.
 * @group Structural
 */
public abstract with sharing class ShippingCostDecorator implements IShippingCost {
  protected final IShippingCost wrapped;

  /**
   * @description Wraps a cost.
   * @param wrapped The cost to wrap; must not be null.
   * @throws IllegalArgumentException If `wrapped` is null.
   */
  protected ShippingCostDecorator(IShippingCost wrapped) {
    if (wrapped == null) {
      throw new IllegalArgumentException('A surcharge must wrap a shipping cost');
    }
    this.wrapped = wrapped;
  }

  /**
   * @description The wrapped cost's lines, then this layer's.
   * @return The breakdown lines, innermost first.
   */
  public List<String> breakdown() {
    List<String> lines = new List<String>(wrapped.breakdown());
    lines.add(describe());
    return lines;
  }

  /**
   * @description The wrapped amount plus this layer's surcharge.
   * @return The amount, rounded to 2 decimal places.
   */
  public abstract Decimal amount();

  /**
   * @description This layer's breakdown line.
   * @return The line.
   */
  protected abstract String describe();
}
