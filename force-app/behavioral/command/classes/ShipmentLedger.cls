/**
 * @description The receiver the commands act on: which orders have a booked shipment and which have
 * a printed label. In memory here; in an org it would be records written through a Unit of Work.
 * @group Behavioral
 */
public with sharing class ShipmentLedger {
  private final Map<String, String> carrierByOrder = new Map<String, String>();
  private final Set<String> labelled = new Set<String>();

  /**
   * @description Books a shipment.
   * @param orderReference The order.
   * @param carrierCode The carrier.
   * @throws IllegalArgumentException If the order is already booked.
   */
  public void book(String orderReference, String carrierCode) {
    if (carrierByOrder.containsKey(orderReference)) {
      throw new IllegalArgumentException(
        orderReference + ' is already booked with ' + carrierByOrder.get(orderReference)
      );
    }
    carrierByOrder.put(orderReference, carrierCode);
  }

  /**
   * @description Cancels a booking.
   * @param orderReference The order.
   */
  public void cancelBooking(String orderReference) {
    carrierByOrder.remove(orderReference);
  }

  /**
   * @description Prints a label for a booked shipment.
   * @param orderReference The order.
   * @throws IllegalArgumentException If the order isn't booked.
   */
  public void printLabel(String orderReference) {
    if (!carrierByOrder.containsKey(orderReference)) {
      throw new IllegalArgumentException('Cannot label ' + orderReference + ': no shipment is booked');
    }
    labelled.add(orderReference);
  }

  /**
   * @description Voids a printed label.
   * @param orderReference The order.
   */
  public void voidLabel(String orderReference) {
    labelled.remove(orderReference);
  }

  /**
   * @description Whether a shipment is booked.
   * @param orderReference The order.
   * @return True if booked.
   */
  public Boolean isBooked(String orderReference) {
    return carrierByOrder.containsKey(orderReference);
  }

  /**
   * @description Whether a label is printed.
   * @param orderReference The order.
   * @return True if labelled.
   */
  public Boolean hasLabel(String orderReference) {
    return labelled.contains(orderReference);
  }
}
