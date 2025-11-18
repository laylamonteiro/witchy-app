# Integração dos Assets no Projeto Flutter

## 1. Copiar os arquivos para o projeto

Copie a pasta `app_assets` para dentro da pasta `assets` do seu projeto Flutter:

```bash
cp -r /home/claude/app_assets/* /caminho/do/seu/projeto/grimorio_de_bolso/assets/
```

## 2. Atualizar o pubspec.yaml

Adicione a dependência para trabalhar com SVG e atualize a seção de assets:

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... outras dependências existentes
  flutter_svg: ^2.0.9  # Adicionar esta linha

flutter:
  uses-material-design: true
  
  assets:
    - assets/icons/navigation/
    - assets/icons/functional/
    - assets/decorative/
    - assets/illustrations/
```

## 3. Copiar o arquivo de configuração

Copie o arquivo `app_assets_config.dart` para o projeto:

```bash
cp /home/claude/app_assets_config.dart /caminho/do/seu/projeto/lib/core/theme/app_assets.dart
```

## 4. Exemplo de uso nos widgets

### Usando ícones SVG na navegação:

```dart
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_assets.dart';

class HomePage extends StatefulWidget {
  // ... código existente
}

// No BottomNavigationBar:
BottomNavigationBarItem(
  icon: SvgPicture.asset(
    AppAssets.moonDark,
    width: 24,
    height: 24,
    colorFilter: ColorFilter.mode(
      _selectedIndex == 0 ? AppColors.lilac : AppColors.textSecondary,
      BlendMode.srcIn,
    ),
  ),
  label: 'Lua',
),
```

### Usando o mascote em empty states:

```dart
class EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.blackCatMascot,
            width: 128,
            height: 128,
          ),
          const SizedBox(height: 24),
          Text(
            'Nenhum feitiço encontrado',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Que tal criar seu primeiro feitiço?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
```

### Usando estrelas animadas para loading:

```dart
class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            AppAssets.animatedStars,
            width: 48,
            height: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Carregando magia...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
```

## 5. Adaptação para Light/Dark Mode

Para alternar automaticamente entre versões light e dark:

```dart
class ThemedIcon extends StatelessWidget {
  final String iconName;
  final double size;
  
  const ThemedIcon({
    Key? key,
    required this.iconName,
    this.size = 24,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return SvgPicture.asset(
      AppAssets.getThemedIcon(iconName, isDarkMode),
      width: size,
      height: size,
    );
  }
}
```

## 6. Otimizações de Performance

### Pré-carregar assets importantes:

```dart
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _preloadAssets();
  }
  
  Future<void> _preloadAssets() async {
    // Pré-carrega os ícones de navegação
    await Future.wait([
      precachePicture(
        ExactAssetPicture(SvgPicture.svgStringDecoderBuilder,
          AppAssets.moonDark),
        null,
      ),
      precachePicture(
        ExactAssetPicture(SvgPicture.svgStringDecoderBuilder,
          AppAssets.grimoireDark),
        null,
      ),
      // ... outros assets importantes
    ]);
    
    // Navega para home após carregar
    Navigator.pushReplacementNamed(context, '/home');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset(
          AppAssets.animatedStars,
          width: 100,
          height: 100,
        ),
      ),
    );
  }
}
```

## 7. Criar mais assets conforme necessário

Para criar novos assets seguindo o mesmo padrão:

1. Use as cores definidas em `AssetColors`
2. Mantenha o estilo pixel art com bordas de 1-2 pixels
3. Use opacidade para criar profundidade
4. Sempre crie versões light e dark quando aplicável
5. Mantenha tamanhos consistentes:
   - Ícones de navegação: 24x24
   - Ícones funcionais: 20x20
   - Elementos decorativos: variados
   - Ilustrações: 128x128 ou 256x256

## Exemplo de estrutura final no projeto:

```
grimorio_de_bolso/
├── assets/
│   ├── icons/
│   │   ├── navigation/
│   │   │   ├── moon_dark.svg
│   │   │   ├── moon_light.svg
│   │   │   └── ...
│   │   └── functional/
│   │       ├── add_dark.svg
│   │       ├── add_light.svg
│   │       └── ...
│   ├── decorative/
│   │   ├── black_cat_mascot.svg
│   │   ├── animated_stars.svg
│   │   └── ...
│   └── illustrations/
│       └── ...
└── lib/
    └── core/
        └── theme/
            ├── app_theme.dart (existente)
            └── app_assets.dart (novo)
```

## Notas de Design

- **Pixel Art**: Todos os elementos são criados com retângulos de 1x1 ou 2x2 pixels
- **Anti-aliasing**: Use opacidade para suavizar bordas quando necessário
- **Consistência**: Mantenha a mesma densidade de pixels em todos os assets
- **Animações**: Use animações CSS/SVG nativas para melhor performance
- **Acessibilidade**: Sempre forneça labels apropriadas para leitores de tela