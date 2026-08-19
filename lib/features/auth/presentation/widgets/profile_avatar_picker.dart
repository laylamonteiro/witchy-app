import 'dart:io';
import 'package:grimorio_de_bolso/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../../../core/theme/grimoire_colors.dart';
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
  final ImagePicker _picker = ImagePicker();
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
                'Foto de Perfil',
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
                title: const Text('Tirar Foto'),
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
                title: const Text('Escolher da Galeria'),
                subtitle: const Text('Selecione uma foto existente'),
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
                  title: const Text('Remover Foto'),
                  subtitle: Text(AppLocalizations.of(context).avatarResetDefault),
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Na web não há arquivo: o recorte (image_cropper) e a compressão por
      // caminho não se aplicam. Trabalha com os bytes e envia ao Storage.
      if (kIsWeb) {
        await _uploadPickedImage(pickedFile);
        return;
      }

      // Fazer crop da imagem
      final croppedFile = await _cropImage(pickedFile.path);

      if (croppedFile != null) {
        // Comprimir imagem para evitar crashes por arquivos grandes
        final compressedFile = await _compressImage(croppedFile.path);

        // Salvar no diretório do app
        final savedPath = await _saveImage(compressedFile);

        setState(() {
          _currentPhotoPath = savedPath;
          _isLoading = false;
        });

        // Notificar mudança
        widget.onPhotoChanged?.call(savedPath);

        // Salvar referência
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_photo_path', savedPath);
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: $e'),
            backgroundColor: context.gc.alert,
          ),
        );
      }
    }
  }

  /// Caminho da web: bytes → compressão (API de bytes, a única que funciona no
  /// navegador) → Supabase Storage. O banco guarda a referência do Storage.
  Future<void> _uploadPickedImage(XFile pickedFile) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final original = await pickedFile.readAsBytes();
      final compressed = await FlutterImageCompress.compressWithList(
        original,
        minWidth: 800,
        minHeight: 800,
        quality: 75,
        format: CompressFormat.jpeg,
      );

      final reference = await ImageStorageService.instance.uploadJpeg(
        compressed,
        folder: 'avatar',
      );

      if (!mounted) return;
      setState(() {
        _currentPhotoPath = reference;
        _isLoading = false;
      });

      widget.onPhotoChanged?.call(reference);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_photo_path', reference);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar foto: $e'),
          backgroundColor: context.gc.alert,
        ),
      );
    }
  }

  Future<CroppedFile?> _cropImage(String sourcePath) async {
    return await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar Foto',
          toolbarColor: context.gc.surface,
          toolbarWidgetColor: context.gc.lilac,
          backgroundColor: context.gc.background,
          activeControlsWidgetColor: context.gc.lilac,
          cropFrameColor: context.gc.lilac,
          cropGridColor: context.gc.surfaceBorder,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Ajustar Foto',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
  }

  Future<File> _compressImage(String sourcePath) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/profile_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final XFile? compressed = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      targetPath,
      quality: 75,
      minWidth: 800,
      minHeight: 800,
      format: CompressFormat.jpeg,
    );

    return File(compressed?.path ?? sourcePath);
  }

  Future<String> _saveImage(File file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${appDir.path}/$fileName';

    // Copiar arquivo para o diretório do app
    final bytes = await file.readAsBytes();
    final savedFile = File(savedPath);
    await savedFile.writeAsBytes(bytes);

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
