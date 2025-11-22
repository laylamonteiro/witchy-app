import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';

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
    if (savedPath != null && File(savedPath).existsSync()) {
      setState(() {
        _currentPhotoPath = savedPath;
      });
    }
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
                            AppColors.lilac.withValues(alpha: 0.5),
                            AppColors.pink.withValues(alpha: 0.5),
                          ],
                    )
                  : null,
              color: widget.backgroundColor ?? AppColors.surface,
              border: Border.all(
                color: AppColors.lilac.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lilac.withValues(alpha: 0.3),
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
                  color: AppColors.lilac,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.background,
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
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.lilac),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent() {
    if (_currentPhotoPath != null) {
      // Verificar se é arquivo local ou URL
      if (_currentPhotoPath!.startsWith('http')) {
        return Image.network(
          _currentPhotoPath!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
        );
      } else {
        final file = File(_currentPhotoPath!);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
          );
        }
      }
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        size: widget.size * 0.5,
        color: AppColors.textPrimary.withValues(alpha: 0.8),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
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
                  color: AppColors.surfaceBorder,
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
                    color: AppColors.lilac.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.lilac),
                ),
                title: const Text('Tirar Foto'),
                subtitle: const Text('Use a câmera do dispositivo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.mint.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.mint),
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
                      color: AppColors.alert.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete, color: AppColors.alert),
                  ),
                  title: const Text('Remover Foto'),
                  subtitle: const Text('Voltar ao avatar padrão'),
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

      // Fazer crop da imagem
      final croppedFile = await _cropImage(pickedFile.path);

      if (croppedFile != null) {
        // Salvar no diretório do app
        final savedPath = await _saveImage(croppedFile);

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
            backgroundColor: AppColors.alert,
          ),
        );
      }
    }
  }

  Future<CroppedFile?> _cropImage(String sourcePath) async {
    return await ImageCropper().cropImage(
      sourcePath: sourcePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar Foto',
          toolbarColor: AppColors.surface,
          toolbarWidgetColor: AppColors.lilac,
          backgroundColor: AppColors.background,
          activeControlsWidgetColor: AppColors.lilac,
          cropFrameColor: AppColors.lilac,
          cropGridColor: AppColors.surfaceBorder,
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

  Future<String> _saveImage(CroppedFile croppedFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPath = '${appDir.path}/$fileName';

    // Copiar arquivo para o diretório do app
    final bytes = await croppedFile.readAsBytes();
    final file = File(savedPath);
    await file.writeAsBytes(bytes);

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
    // Remover arquivo se existir
    if (_currentPhotoPath != null && !_currentPhotoPath!.startsWith('http')) {
      try {
        final file = File(_currentPhotoPath!);
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
