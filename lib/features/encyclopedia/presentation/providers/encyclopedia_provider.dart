import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/services/data_sync_service.dart';
import '../../../../core/services/debug_log_service.dart';
import '../../data/models/crystal_model.dart';
import '../../data/models/color_model.dart';
import '../../data/models/herb_model.dart';
import '../../data/models/metal_model.dart';
import '../../data/models/user_entry_model.dart';
import '../../data/data_sources/crystals_data.dart';
import '../../data/data_sources/colors_data.dart';
import '../../data/data_sources/herbs_data.dart';
import '../../data/data_sources/metals_data.dart';
import '../../data/repositories/user_encyclopedia_repository.dart';

class EncyclopediaProvider with ChangeNotifier {
  EncyclopediaProvider({
    UserEncyclopediaRepository? userRepository,
    Stream<SyncStatus>? statusDoSync,
  }) : _userRepository = userRepository ?? UserEncyclopediaRepository() {
    // Fotos guardadas como arquivo local (antigas, ou sem rede na hora)
    // sobem DEPOIS de um sync completo: aí as lápides remotas já foram
    // aplicadas, e um verbete apagado em outro aparelho não ressuscita aqui
    // com a foto migrada por cima.
    _syncSub = (statusDoSync ?? DataSyncService().statusStream).listen(
      (status) {
        if (status == SyncStatus.success) _migrarFotosPendentes();
      },
    );
  }

  StreamSubscription<SyncStatus>? _syncSub;
  bool _migrandoFotos = false;

  // Getters diretos (não campos) para que a troca de idioma em runtime
  // reflita imediatamente o conteúdo do locale atual via ContentLocale.
  List<CrystalModel> get _crystals => crystalsData;
  List<ColorModel> get _colors => colorsData;
  List<HerbModel> get _herbs => herbsData;
  List<MetalModel> get _metals => metalsData;

  List<CrystalModel> get crystals => _crystals;
  List<ColorModel> get colors => _colors;
  List<HerbModel> get herbs => _herbs;
  List<MetalModel> get metals => _metals;

  // ---- Entradas pessoais (foto + IA, Premium) ----

  final UserEncyclopediaRepository _userRepository;

  String _userId = 'local_user';
  String? _loadedForUserId;
  Map<UserEntryCategory, List<UserEncyclopediaEntry>> _userEntries = {};

  List<UserEncyclopediaEntry> userEntries(UserEntryCategory category) =>
      _userEntries[category] ?? const [];

  /// Carrega as entradas pessoais da conta atual (no-op se já carregadas
  /// para o mesmo usuário — o update do ProxyProvider dispara a cada notify
  /// do AuthProvider).
  Future<void> loadUserEntries(String userId) async {
    if (_loadedForUserId == userId) return;
    _loadedForUserId = userId;
    _userId = userId;
    final loaded = <UserEntryCategory, List<UserEncyclopediaEntry>>{};
    for (final category in UserEntryCategory.values) {
      loaded[category] = await _userRepository.entriesFor(userId, category);
    }
    _userEntries = loaded;
    notifyListeners();
  }

  /// Cria a entrada com a foto comprimida ([photoBytes]); onde a foto vai
  /// parar é decisão do repositório (nuvem + espelho local, ou só local).
  Future<UserEncyclopediaEntry> addUserEntry({
    required UserEntryCategory category,
    required String name,
    Uint8List? photoBytes,
    required Map<String, dynamic> data,
  }) async {
    final entry = await _userRepository.create(
      userId: _userId,
      category: category,
      name: name,
      photo: photoBytes,
      data: data,
    );
    _userEntries[category] = [entry, ...userEntries(category)];
    notifyListeners();
    return entry;
  }

  Future<void> deleteUserEntry(UserEncyclopediaEntry entry) async {
    await _userRepository.delete(entry);
    _userEntries[entry.category] =
        userEntries(entry.category).where((e) => e.id != entry.id).toList();
    notifyListeners();
  }

  Future<int> userEntriesCreatedToday() =>
      _userRepository.countCreatedToday(_userId);

  /// Sobe as fotos pendentes da conta atual e recarrega a lista se alguma
  /// subiu (a referência nova muda o que as telas mostram).
  Future<void> _migrarFotosPendentes() async {
    if (_migrandoFotos || _userId == 'local_user') return;
    _migrandoFotos = true;
    try {
      final enviadas = await _userRepository.uploadPendingPhotos(_userId);
      if (enviadas > 0) {
        _loadedForUserId = null;
        await loadUserEntries(_userId);
      }
    } catch (e) {
      unawaited(debugLog('STORAGE', 'migração de fotos falhou: $e'));
    } finally {
      _migrandoFotos = false;
    }
  }

  @override
  void dispose() {
    _syncSub?.cancel();
    super.dispose();
  }

  List<CrystalModel> searchCrystals(String query) {
    final lowerQuery = query.toLowerCase();
    return _crystals.where((crystal) {
      return crystal.name.toLowerCase().contains(lowerQuery) ||
          crystal.description.toLowerCase().contains(lowerQuery) ||
          crystal.intentions.any((i) => i.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<ColorModel> searchColors(String query) {
    final lowerQuery = query.toLowerCase();
    return _colors.where((color) {
      return color.name.toLowerCase().contains(lowerQuery) ||
          color.meaning.toLowerCase().contains(lowerQuery) ||
          color.intentions.any((i) => i.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<CrystalModel> getCrystalsByElement(Element element) {
    return _crystals.where((crystal) => crystal.element == element).toList();
  }

  List<CrystalModel> getCrystalsByIntention(String intention) {
    return _crystals.where((crystal) {
      return crystal.intentions
          .any((i) => i.toLowerCase().contains(intention.toLowerCase()));
    }).toList();
  }

  List<ColorModel> getColorsByIntention(String intention) {
    return _colors.where((color) {
      return color.intentions
          .any((i) => i.toLowerCase().contains(intention.toLowerCase()));
    }).toList();
  }

  List<HerbModel> searchHerbs(String query) {
    final lowerQuery = query.toLowerCase();
    return _herbs.where((herb) {
      return herb.name.toLowerCase().contains(lowerQuery) ||
          herb.description.toLowerCase().contains(lowerQuery) ||
          herb.magicalProperties
              .any((p) => p.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<HerbModel> getHerbsByElement(HerbElement element) {
    return _herbs.where((herb) => herb.element == element).toList();
  }

  List<HerbModel> getHerbsByPlanet(Planet planet) {
    return _herbs.where((herb) => herb.planet == planet).toList();
  }

  List<HerbModel> getHerbsByProperty(String property) {
    return _herbs.where((herb) {
      return herb.magicalProperties
          .any((p) => p.toLowerCase().contains(property.toLowerCase()));
    }).toList();
  }

  List<HerbModel> getSafeHerbs() {
    return _herbs.where((herb) => !herb.toxic).toList();
  }

  List<HerbModel> getEdibleHerbs() {
    return _herbs.where((herb) => herb.edible).toList();
  }

  // Métodos para Metais
  List<MetalModel> searchMetals(String query) {
    final lowerQuery = query.toLowerCase();
    return _metals.where((metal) {
      return metal.name.toLowerCase().contains(lowerQuery) ||
          metal.description.toLowerCase().contains(lowerQuery) ||
          metal.magicalProperties
              .any((p) => p.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  List<MetalModel> getMetalsByElement(Element element) {
    return _metals.where((metal) => metal.element == element).toList();
  }

  List<MetalModel> getMetalsByPlanet(Planet planet) {
    return _metals.where((metal) => metal.planet == planet).toList();
  }

  List<MetalModel> getMetalsByProperty(String property) {
    return _metals.where((metal) {
      return metal.magicalProperties
          .any((p) => p.toLowerCase().contains(property.toLowerCase()));
    }).toList();
  }

  List<MetalModel> getConductiveMetals() {
    return _metals.where((metal) => metal.conductsPower).toList();
  }
}
