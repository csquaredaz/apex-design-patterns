/**
 * @description The interface our tracking code depends on (the Adapter's target). Each carrier
 * gets an adapter that implements it, so nothing past the adapter knows a carrier's wire format.
 * @group Structural
 */
public interface ITrackingParser {
  /**
   * @description Parses a carrier's tracking payload.
   * @param body The raw payload, for example a webhook body.
   * @return The events in our model, in payload order.
   * @throws TrackingFormatException If the payload isn't in the carrier's format.
   */
  List<TrackingUpdate> parse(String body);
}
