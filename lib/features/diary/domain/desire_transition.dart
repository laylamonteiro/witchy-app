import '../../journeys/domain/action_outcome.dart';
import '../data/models/desire_model.dart';

/// Which feedback a status change of a wish deserves, if any. Only the
/// transition into `manifested` (the "Fulfilled" seal) or into `released`
/// (the thread of light) counts; editing a wish that already had that
/// status, or moving between other states, is silent.
ActionOrigin? desireTransitionOrigin(DesireStatus? previous, DesireStatus next) {
  if (previous == next) return null;
  return switch (next) {
    DesireStatus.manifested => ActionOrigin.desireManifested,
    DesireStatus.released => ActionOrigin.desireReleased,
    _ => null,
  };
}
