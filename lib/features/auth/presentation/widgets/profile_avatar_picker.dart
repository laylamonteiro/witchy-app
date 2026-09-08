import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/images/seletor_de_foto.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../../../core/theme/grimoire_colors.dart';
import '../../../../core/utils/reducao_de_imagem.dart';
import '../../../../core/widgets/stored_image.dart';

/// Widget para selecionar e exibir foto de perfil
class ProfileAvatarPicker extends StatefulWidget {
  /// URL da foto atual (pode ser null)
  final String? currentPhotoUrl;

  /// Tamanho do avatar
  final double size;

  /// Callback quando uma nova foto é selecionada
  final Function(String? photoPath)? onPhotoChanged;

  /// Se permite edição
  final bool editable;

  /// Cor de fundo padrão (quando não há foto)
  final Color? backgroundColor;

  /// Gradiente para o ícone padrão
  final List<Color>? gradientColors;

  const ProfileAvatarPicker({
    super.key,
    this.currentPhotoUrl,
    this.size = 100,
    this.onPhotoChanged,
    this.editable = true,
    this.backgroundColor,
    this.gradientColors,
  });

  @override
  State<ProfileAvatarPicker> createState() => _ProfileAvatarPickerState();
}

class _ProfileAvatarPickerState extends State<ProfileAvatarPicker> {
  /// Lado da foto guardada: um avatar não precisa dos 1600 px do verbete.
  static const int _ladoDoAvatar = 800;

  String? _currentPhotoPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentPhotoPath = widget.currentPhotoUrl;
    _loadSavedPhoto();
  }

  Future<void> _loadSavedPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_photo_path');
    if (savedPath == null || savedPath.isEmpty) return;

    // Referência do Storage ou URL: vale em qualquer plataforma. Caminho de
    // arquivo só existe no celular — e checar existência na web estoura.
    final isFilePath = !ImageStorageService.isRemote(savedPath) &&
        !savedPath.startsWith('http');
    if (isFilePath && (kIsWeb || !File(savedPath).existsSync())) return;

    setState(() {
      _currentPhotoPath = savedPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.editable ? _showPhotoOptions : null,
      child: Stack(
        children: [
          // Avatar
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _currentPhotoPath == null
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.gradientColors ??
                          [
                            context.gc.lilac.withValues(alpha: 0.5),
                            context.gc.pink.withValues(alpha: 0.5),
                          ],
                    )
                  : null,
              color: widget.backgroundColor ?? context.gc.surface,
              border: Border.all(
                color: context.gc.lilac.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.gc.lilac.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: _buildAvatarContent(),
            ),
          ),
          // Indicador de edição
          if (widget.editable)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.gc.lilac,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.gc.background,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: const Color(0xFF2B2143),
                  size: widget.size * 0.18,
                ),
              ),
            ),
          // Indicador de carregamento
          if (_isLoading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(context.gc.lilac),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    final photo = _currentPhotoPath;
    if (photo == null || photo.isEmpty) return _buildDefaultAvatar();

    // Storage, URL do login social ou arquivo local antigo — o StoredImage
    // resolve cada origem e cai no avatar padrão quando não dá para exibir.
    return StoredImage(
      reference: photo,
      fit: BoxFit.cover,
      placeholderBuilder: (_) => _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        size: widget.size * 0.5,
        color: context.gc.textPrimary.withValues(alpha: 0.8),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.gc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.gc.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Título
              Text(
                AppLocalizations.of(context).avatarSheetTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              // Opções
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.gc.lilac.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt, color: context.gc.lilac),
                ),
                title: Text(AppLocalizations.of(context).avatarTakePhoto),
                subtitle: Text(AppLocalizations.of(context).avatarUseCamera),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.gc.mint.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library, color: context.gc.mint),
                ),
                title: Text(AppLocalizations.of(context).avatarFromGallery),
                subtitle: Text(
                  AppLocalizations.of(context).avatarFromGallerySubtitle,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_currentPhotoPath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.gc.alert.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.delete, color: context.gc.alert),
                  ),
                  title: Text(
                    AppLocalizations.of(context).avatarRemovePhoto,
                  ),
                  subtitle: Text(
                    AppLocalizations.of(context).avatarResetDefault,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pegar → converter → recortar em quadrado → reduzir: o mesmo caminho do
  /// verbete ([SeletorDeFoto]). Antes o avatar tinha pipeline próprio, sem
  /// HEIC na web e com recorte só no celular.
  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isLoading = true);

    final Uint8List? bytes;
    try {
      bytes = await const SeletorDeFoto().escolher(
        context,
        origem: source,
        ladoMaximo: _ladoDoAvatar,
      );
    } on FotoNaoSuportadaException catch (e) {
      debugPrint('Foto de perfil: formato não suportado: ${e.formato}');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _avisar(messenger, l10n.encyAddPhotoUnsupported(e.formato));
      return;
    } catch (e) {
      debugPrint('Foto de perfil: falha ao selecionar: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _avisar(messenger, l10n.profileErrPickPhoto);
      return;
    }
    if (!mounted) return;
    if (bytes == null) {
      // Desistiu no seletor ou no recorte: nada a dizer.
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Na web não há arquivo: a foto vai direto ao Storage e o banco guarda
      // a referência. No celular fica no diretório do app.
      final String novo = kIsWeb
          ? await ImageStorageService.instance.uploadJpeg(
              bytes,
              folder: 'avatar',
            )
          : await _saveImage(bytes);
      if (!mounted) return;
      setState(() {
        _currentPhotoPath = novo;
        _isLoading = false;
      });
      widget.onPhotoChanged?.call(novo);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_photo_path', novo);
    } catch (e) {
      debugPrint('Foto de perfil: falha ao guardar: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      _avisar(messenger, l10n.profileErrUploadPhoto);
    }
  }

  void _avisar(ScaffoldMessengerState messenger, String texto) {
    messenger.showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: context.gc.alert),
    );
  }

  Future<String> _saveImage(Uint8List bytes) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${appDir.path}/$fileName';
    await File(savedPath).writeAsBytes(bytes);

    // Remover foto antiga se existir
    if (_currentPhotoPath != null &&
        !_currentPhotoPath!.startsWith('http') &&
        _currentPhotoPath != savedPath) {
      try {
        final oldFile = File(_currentPhotoPath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (e) {
        // Ignora erro ao deletar arquivo antigo
      }
    }

    return savedPath;
  }

  Future<void> _removePhoto() async {
    final photo = _currentPhotoPath;

    if (photo != null && ImageStorageService.isRemote(photo)) {
      await ImageStorageService.instance.delete(photo);
    } else if (photo != null && !kIsWeb && !photo.startsWith('http')) {
      // Arquivo local (celular): apaga junto para não deixar lixo no aparelho.
      try {
        final file = File(photo);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // Ignora erro ao deletar
      }
    }

    // Limpar referência
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_photo_path');

    setState(() {
      _currentPhotoPath = null;
    });

    widget.onPhotoChanged?.call(null);
  }
}
