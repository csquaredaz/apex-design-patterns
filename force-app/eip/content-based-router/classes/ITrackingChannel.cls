/**
 * @description A destination for tracking scans, such as one carrier's status processor. A channel
 * receives all of its scans from a batch in one call, so it can query and write once per batch.
 * @group EIP
 */
public interface ITrackingChannel {
  /**
   * @description Receives the scans routed to this channel.
   * @param scans The scans, in arrival order; never empty. The unroutable channel also receives
   * any null entries from the batch, so nothing is dropped silently.
   */
  void receive(List<TrackingScan> scans);
}
