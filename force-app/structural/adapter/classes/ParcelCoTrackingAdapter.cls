/**
 * @description Adapts ParcelCo's tracking webhook to `ITrackingParser` (Adapter). ParcelCo sends
 * `{"parcels":[{"ref":"PC123","events":[{"code":"DLV","ts":1763459400000}]}]}`: its own status codes
 * and epoch milliseconds. This class is the only place that knows that shape. An unknown code maps
 * to `UNKNOWN` rather than failing the payload (Tolerant Reader).
 * @group Structural
 */
public with sharing class ParcelCoTrackingAdapter implements ITrackingParser {
  private static final Map<String, TrackingStatus> STATUS_BY_CODE = new Map<String, TrackingStatus>{
    'TRN' => TrackingStatus.IN_TRANSIT,
    'OFD' => TrackingStatus.OUT_FOR_DELIVERY,
    'DLV' => TrackingStatus.DELIVERED,
    'ATT' => TrackingStatus.FAILED_ATTEMPT
  };

  /**
   * @description Parses a ParcelCo webhook body.
   * @param body The JSON body.
   * @return One update per event, parcel by parcel, in payload order.
   * @throws TrackingFormatException If the body is blank, isn't JSON, or has no `parcels` list.
   */
  public List<TrackingUpdate> parse(String body) {
    Payload payload = read(body);
    List<TrackingUpdate> updates = new List<TrackingUpdate>();
    for (Parcel parcel : payload.parcels) {
      for (ParcelEvent event : parcel.events ?? new List<ParcelEvent>()) {
        updates.add(
          new TrackingUpdate(
            parcel.ref,
            STATUS_BY_CODE.get(event.code) ?? TrackingStatus.UNKNOWN,
            event.code,
            toDatetime(event.ts)
          )
        );
      }
    }
    return updates;
  }

  private static Payload read(String body) {
    if (String.isBlank(body)) {
      throw new TrackingFormatException('ParcelCo tracking payload is empty');
    }
    Payload payload;
    try {
      payload = (Payload) JSON.deserialize(body, Payload.class);
    } catch (JSONException e) {
      throw new TrackingFormatException('ParcelCo tracking payload is not valid JSON: ' + e.getMessage(), e);
    }
    if (payload?.parcels == null) {
      throw new TrackingFormatException('ParcelCo tracking payload has no parcels list');
    }
    return payload;
  }

  private static Datetime toDatetime(Long epochMillis) {
    return epochMillis == null ? null : Datetime.newInstance(epochMillis);
  }

  // ParcelCo's wire format (the adaptee). Field names match their JSON.
  private class Payload {
    public List<Parcel> parcels;
  }

  private class Parcel {
    public String ref;
    public List<ParcelEvent> events;
  }

  private class ParcelEvent {
    public String code;
    public Long ts;
  }
}
