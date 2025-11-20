# Prompt para Claude Opus: Corrigir Página de Sigilos

## Contexto do Projeto
Você está trabalhando em um aplicativo Flutter chamado "Grimório de Bolso" (witchy-app), um app mágico/espiritual com funcionalidades de feitiços, diário, runas, sigilos, etc.

## Problema Atual
As alterações feitas na página de criação de Sigilos (`lib/features/sigils/presentation/screens/sigil_creation_screen.dart`) **NÃO estão aparecendo no APK compilado**, mesmo após:
- Fazer `flutter clean`
- Deletar pasta `build/`
- Deletar `android/.gradle` e `android/app/build`
- Fazer `flutter pub get`
- Compilar novo APK com `flutter build apk --release`
- Desinstalar app antigo e instalar novo APK

O código está CORRETO no repositório, mas as mudanças não refletem no app instalado.

## O que Foi Alterado (e deveria estar aparecendo)

### 1. Estrutura da Página
A página deve ter esta sequência EXATA:

```
AppBar: "Criar Sigilo"
  ↓
Caixa Introdutória "O que é um Sigilo?" (MagicalCard com emoji 🃏)
  ↓
Título centralizado "Defina sua Intenção" (headlineMedium)
  ↓
Card com campos de texto (intenção e frase)
  ↓
Card "Roda de Sigilo"
  ↓
Card de Informações (condicional)
  ↓
Card de Controles (Salvar/Compartilhar/Limpar)
```

### 2. Alterações Específicas no Código

#### A. Imports
O arquivo DEVE ter este import (linha 9):
```dart
import 'package:grimorio_de_bolso/core/widgets/magical_card.dart';
```

#### B. Estrutura do Body (linhas 148-194)
```dart
body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Introdução - O que é um Sigilo
        _buildIntroductionCard(),

        const SizedBox(height: 24),

        // Título da seção
        Text(
          'Defina sua Intenção',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Card de Intenção
        _buildIntentionCard(),

        const SizedBox(height: 16),

        // Card da Roda
        _buildWheelCard(),
        // ... resto dos cards
      ],
    ),
  ),
),
```

#### C. Função _buildIntroductionCard() (linhas 646-693)
```dart
Widget _buildIntroductionCard() {
  // DEBUG: Confirmação de build
  debugPrint('🃏 Building Introduction Card with MagicalCard');

  return MagicalCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🃏', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Text(
              'O que é um Sigilo?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Sigilos são símbolos mágicos criados para manifestar intenções. '
          'Ao transformar palavras em símbolos abstratos, você cria uma marca energética '
          'que carrega o poder da sua vontade, sem revelar sua intenção para outras pessoas.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Defina sua intenção, escolha uma palavra ou frase que a represente, '
          'e o app criará automaticamente seu sigilo único na Roda Mágica.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
        ),
      ],
    ),
  );
}
```

#### D. Card de Intenção (linhas 197-288)
O card `_buildIntentionCard()` NÃO deve ter o título "Defina sua Intenção" dentro dele (isso foi movido para fora como Text centralizado). Deve começar DIRETAMENTE com o campo de texto:

```dart
Widget _buildIntentionCard() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de intenção (SEM Row com ícone e título antes)
          TextFormField(
            controller: _intentionController,
            // ...
          ),
          // ... resto do card
        ],
      ),
    ),
  );
}
```

## O que Você Precisa Fazer

1. **Verificar o arquivo atual**: Leia o arquivo `lib/features/sigils/presentation/screens/sigil_creation_screen.dart` COMPLETAMENTE

2. **Comparar com o esperado**: Verifique se:
   - O import de `MagicalCard` está presente (linha 9)
   - A função `_buildIntroductionCard()` existe e retorna um `MagicalCard` (não `Card`)
   - O emoji é 🃏 (carta de jogar), não ✨ (brilho)
   - A ordem dos elementos no body está correta (introdução → título → card de campos)
   - O título "Defina sua Intenção" está FORA do card, como Text separado

3. **Se o código estiver CORRETO mas não funcionar**:
   - Adicione mais logs de debug (debugPrint) em pontos estratégicos
   - Verifique se há algum problema de cache do Flutter/Dart
   - Sugira forçar uma rebuild completa do projeto
   - Verifique se há arquivos `.dart_tool` que precisam ser deletados

4. **Se o código estiver INCORRETO**:
   - Faça as correções necessárias
   - Explique EXATAMENTE o que estava errado
   - Force uma mudança adicional (como adicionar um comentário) para garantir que o Flutter detecte a alteração

## Arquivo de Referência (Padrão Correto)
Para comparar, veja como as outras páginas de encyclopedia (Runas, Altar, Elementos) implementam a caixa introdutória:

**Exemplo de Runas** (`lib/features/runes/presentation/pages/runes_list_page.dart`):
```dart
MagicalCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Text('🔮', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Text(
            'Sobre as Runas',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
      // ... texto descritivo
    ],
  ),
),
```

A página de Sigilos deve seguir EXATAMENTE este padrão.

## Informações Adicionais
- Branch: `claude/fix-sigil-wheel-layers-01Y1e5xiy2dDcNHyq4Ap7aYU`
- Último commit relevante: `0c34dfc - Debug: adicionar log para confirmar build da página de Sigilos`
- O código está CORRETO no Git, mas NÃO reflete no APK compilado
- Já tentamos `flutter clean`, rebuild completo, reinstalação do app
- Outras páginas (Altar, Elementos, Runas) funcionam corretamente com o mesmo padrão

## Objetivo Final
Fazer com que a página de Sigilos mostre:
1. Caixa "O que é um Sigilo?" com emoji 🃏 (usando MagicalCard)
2. Título "Defina sua Intenção" centralizado FORA do card
3. Card com os campos de input (sem repetir o título)

**POR FAVOR, INVESTIGUE PROFUNDAMENTE E RESOLVA ESTE PROBLEMA DE CACHE/BUILD DO FLUTTER.**
