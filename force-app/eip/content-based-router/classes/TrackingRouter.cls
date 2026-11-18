/**
 * @description Sends each tracking scan to the channel registered for its carrier (Content-Based
 * Router): the router reads the message's content, and the senders don't know the channels. Scans
 * whose carrier has no route, or no carrier at all, go to the required unroutable channel (EIP's
 * Invalid Message Channel) instead of failing the batch or vanishing.
 * @group EIP
 */
public with sharing class TrackingRouter {
  private final ITrackingChannel unroutable;
  // Keyed by lower-cased carrier code, so `ParcelCo` and `parcelco` share a route.
  private final Map<String, ITrackingChannel> channelByCarrier = new Map<String, ITrackingChannel>();

  /**
   * @description Creates a router with no routes yet.
   * @param unroutable Receives scans that no route matches.
   * @throws IllegalArgumentException If the unroutable channel is null.
   */
  public TrackingRouter(ITrackingChannel unroutable) {
    if (unroutable == null) {
      throw new IllegalArgumentException('A router needs a channel for unroutable scans');
    }
    this.unroutable = unroutable;
  }

  /**
   * @description Registers the channel for one carrier, matched case-insensitively.
   * @param carrierCode The carrier code.
   * @param channel The channel for that carrier's scans.
   * @return This router, so routes can be chained.
   * @throws IllegalArgumentException If the code is blank, the channel is null or the carrier
   * already has a route.
   */
  public TrackingRouter route(String carrierCode, ITrackingChannel channel) {
    if (String.isBlank(carrierCode) || channel == null) {
      throw new IllegalArgumentException('A route needs a carrier code and a channel');
    }
    String key = carrierCode.trim().toLowerCase();
    if (channelByCarrier.containsKey(key)) {
      throw new IllegalArgumentException('Carrier ' + carrierCode + ' already has a route');
    }
    channelByCarrier.put(key, channel);
    return this;
  }

  /**
   * @description Routes a batch. Each channel is called once, with its scans in arrival order;
   * channels are called in the order their first scan arrived. An empty or null batch calls nothing.
   * @param scans The scans to route.
   */
  public void dispatch(List<TrackingScan> scans) {
    if (scans == null || scans.isEmpty()) {
      return;
    }
    // Lists keep first-seen order; a Map's iteration order isn't a documented contract.
    List<ITrackingChannel> channels = new List<ITrackingChannel>();
    List<List<TrackingScan>> batches = new List<List<TrackingScan>>();
    for (TrackingScan scan : scans) {
      ITrackingChannel channel = channelFor(scan);
      Integer index = indexOf(channels, channel);
      if (index < 0) {
        channels.add(channel);
        batches.add(new List<TrackingScan>());
        index = channels.size() - 1;
      }
      batches[index].add(scan);
    }
    for (Integer i = 0; i < channels.size(); i++) {
      channels[i].receive(batches[i]);
    }
  }

  private ITrackingChannel channelFor(TrackingScan scan) {
    String key = scan == null || String.isBlank(scan.carrierCode) ? null : scan.carrierCode.trim().toLowerCase();
    ITrackingChannel channel = key == null ? null : channelByCarrier.get(key);
    return channel == null ? unroutable : channel;
  }

  // Identity, not equals(): two channels of the same class are different destinations.
  private static Integer indexOf(List<ITrackingChannel> channels, ITrackingChannel channel) {
    for (Integer i = 0; i < channels.size(); i++) {
      if (channels[i] === channel) {
        return i;
      }
    }
    return -1;
  }
}
