/// The brief action a card performs when it is the one in focus.
enum OracleScene { none, candle, cauldron, cat, seed, key, door }

/// Visual entry for one catalog ID: an optional static front asset and the
/// scene type. Every ID resolves; an unknown one gets the common frame.
class OracleArt {
  const OracleArt({required this.id, this.assetPath, this.scene = OracleScene.none});

  final int id;

  /// Static front, when the illustrated catalog ships. Null draws the
  /// vector frame with the card's emoji as its figure; that fallback is
  /// also the reduced-motion, error and export state.
  final String? assetPath;
  final OracleScene scene;

  bool get hasScene => scene != OracleScene.none;
}

/// Maps the 44 catalog IDs to their art. Names and texts stay in the
/// localized data sources; nothing here is user-facing text.
abstract final class OracleArtRegistry {
  static const catalogVersion = 'oracle-44-v1';
  static const cardCount = 44;

  /// First animated batch: candle, cauldron, black cat, seed, key and door.
  static const scenes = <int, OracleScene>{
    6: OracleScene.candle,
    3: OracleScene.cauldron,
    16: OracleScene.cat,
    42: OracleScene.seed,
    26: OracleScene.key,
    27: OracleScene.door,
  };

  static bool covers(int id) => id >= 1 && id <= cardCount;

  static OracleArt of(int id) =>
      OracleArt(id: id, scene: covers(id) ? scenes[id] ?? OracleScene.none : OracleScene.none);
}
