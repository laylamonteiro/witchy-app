import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('asset de espelho mágico existe e usa a paleta visual do app', () {
    final asset = File('assets/icons/magic_mirror.svg');

    expect(asset.existsSync(), isTrue);

    final svg = asset.readAsStringSync();
    expect(svg, contains('<title>Espelho mágico</title>'));
    expect(svg, contains('#C9A7FF'));
    expect(svg, contains('#F1A7C5'));
    expect(svg, contains('#A7F0D8'));
    expect(svg, contains('#FFE8A3'));
  });
}
