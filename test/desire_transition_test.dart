import 'package:flutter_test/flutter_test.dart';
import 'package:grimorio_de_bolso/features/diary/data/models/desire_model.dart';
import 'package:grimorio_de_bolso/features/diary/domain/desire_transition.dart';
import 'package:grimorio_de_bolso/features/journeys/domain/action_outcome.dart';

void main() {
  test('only entering fulfilled or released earns a scene', () {
    expect(desireTransitionOrigin(DesireStatus.open, DesireStatus.manifested),
        ActionOrigin.desireManifested);
    expect(desireTransitionOrigin(DesireStatus.manifesting, DesireStatus.released),
        ActionOrigin.desireReleased);
    expect(desireTransitionOrigin(DesireStatus.open, DesireStatus.manifesting), isNull);
    expect(desireTransitionOrigin(DesireStatus.manifested, DesireStatus.open), isNull);
  });

  test('editing a wish that already had the status is silent', () {
    expect(desireTransitionOrigin(DesireStatus.manifested, DesireStatus.manifested), isNull);
    expect(desireTransitionOrigin(DesireStatus.released, DesireStatus.released), isNull);
  });
}
