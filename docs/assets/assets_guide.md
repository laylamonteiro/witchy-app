# Guia de Assets - Grimório de Bolso

## Paleta de Cores Oficial

### Dark Mode (Principal)
- Background: `#0B0A16` (quase preto roxo profundo)
- Surface: `#171425` (roxo bem escuro)
- Border: `#26213A` (roxo mais claro)
- Lilac: `#C9A7FF` (magia, espiritualidade)
- Pink: `#F1A7C5` (amor próprio, afeto)
- Mint: `#A7F0D8` (cura, natureza)
- Star Yellow: `#FFE8A3` (brilho, feedback positivo)
- Text Primary: `#F6F4FF` (branquinho suave)
- Text Secondary: `#B7B2D6` (texto secundário)

### Light Mode (Adaptação)
- Background: `#F6F4FF` (branquinho suave)
- Surface: `#FFFFFF` (branco puro)
- Border: `#E5E0F5` (lilás bem claro)
- Lilac: `#8B5FD6` (versão mais escura)
- Pink: `#D668A0` (versão mais escura)
- Mint: `#4EC49E` (versão mais escura)
- Star Yellow: `#D4B14F` (versão mais escura)
- Text Primary: `#0B0A16` (quase preto)
- Text Secondary: `#524D6B` (roxo acinzentado)

## Elementos Visuais Selecionados

### Navegação Principal (Bottom Navigation)
1. **Lua** - Calendário Lunar (lua crescente com estrelas)
2. **Livro Grimório** - Grimório Digital (livro com pentagramas)
3. **Diário** - Diários (caderno com lua)
4. **Cristal** - Enciclopédia (cluster de cristais)

### Ícones Funcionais
- **Adicionar**: Varinha mágica com sparkles
- **Editar**: Pena de escrever
- **Deletar**: Caldeirão com fumaça
- **Buscar**: Bola de cristal
- **Filtrar**: Poção
- **Configurações**: Pentagramas

### Elementos Decorativos
- Velas (diferentes tamanhos)
- Estrelas (animadas)
- Lua em diferentes fases
- Cristais variados
- Gato preto (mascote)
- Plantas/ervas
- Cartas de tarô
- Mãos místicas

## Especificações Técnicas

### Tamanhos
- Ícones de navegação: 24x24px (com área de toque de 48x48px)
- Ícones funcionais: 20x20px
- Elementos decorativos: variados (16x16 até 64x64px)
- Ilustrações grandes: 128x128px ou 256x256px

### Formato
- SVG para ícones (escalabilidade)
- PNG para elementos complexos com transparência
- Pixel art com anti-aliasing suave nas bordas

### Estrutura de Arquivos
```
assets/
├── icons/
│   ├── navigation/
│   │   ├── moon_active_dark.svg
│   │   ├── moon_inactive_dark.svg
│   │   ├── moon_active_light.svg
│   │   ├── moon_inactive_light.svg
│   │   └── ...
│   └── functional/
│       ├── add_dark.svg
│       ├── add_light.svg
│       └── ...
├── decorative/
│   ├── crystals/
│   ├── candles/
│   ├── stars/
│   └── ...
└── illustrations/
    ├── empty_states/
    ├── onboarding/
    └── splash/
```
