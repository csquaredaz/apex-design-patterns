/**
 * @description Base class for order exports (Template Method). `render` fixes the steps: an
 * optional header, one row per order, an optional footer, all joined by a separator. A subclass
 * fills in `formatRow` and may override the other hooks, but it can't reorder or skip the steps,
 * because Apex methods are non-virtual unless declared otherwise.
 * @group Behavioral
 */
public abstract with sharing class OrderExport {
  /**
   * @description Renders the orders. This is the template method; subclasses can't override it.
   * @param orders The orders, in output order; must not be null or empty.
   * @return The export text.
   * @throws IllegalArgumentException If there are no orders to export.
   */
  public String render(List<ExportOrder> orders) {
    if (orders == null || orders.isEmpty()) {
      throw new IllegalArgumentException('Nothing to export');
    }
    List<String> parts = new List<String>();
    String headerText = header();
    if (headerText != null) {
      parts.add(headerText);
    }
    List<String> rows = new List<String>();
    for (ExportOrder row : orders) {
      rows.add(formatRow(row));
    }
    parts.add(String.join(rows, separator()));
    String footerText = footer();
    if (footerText != null) {
      parts.add(footerText);
    }
    return String.join(parts, '\n');
  }

  /**
   * @description Formats one order. Required.
   * @param row The order.
   * @return The row text.
   */
  protected abstract String formatRow(ExportOrder row);

  /**
   * @description The first line, if any.
   * @return The header, or null for none (the default).
   */
  protected virtual String header() {
    return null;
  }

  /**
   * @description The last line, if any.
   * @return The footer, or null for none (the default).
   */
  protected virtual String footer() {
    return null;
  }

  /**
   * @description What goes between rows.
   * @return The separator; a newline by default.
   */
  protected virtual String separator() {
    return '\n';
  }
}
