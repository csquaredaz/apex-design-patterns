/**
 * @description Our shipment tracking statuses. Carrier adapters map each carrier's own codes onto
 * these; `UNKNOWN` keeps a payload usable when a carrier adds a code we don't know yet.
 * @group Structural
 */
public enum TrackingStatus {
  IN_TRANSIT,
  OUT_FOR_DELIVERY,
  DELIVERED,
  FAILED_ATTEMPT,
  UNKNOWN
}
