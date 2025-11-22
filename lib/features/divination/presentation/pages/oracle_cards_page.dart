import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../core/widgets/magical_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/oracle_card_model.dart';
import '../../data/data_sources/oracle_cards_data.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/premium_blur_widget.dart';
import '../../../auth/data/models/user_model.dart';

class OracleCardsPage extends StatefulWidget {
  const OracleCardsPage({super.key});

  @override
  State<OracleCardsPage> createState() => _OracleCardsPageState();
}

class _OracleCardsPageState extends State<OracleCardsPage>
    with SingleTickerProviderStateMixin {
  OracleSpreadType _selectedSpread = OracleSpreadType.daily;
  List<OracleCardPosition>? _drawnCards;
  late AnimationController _animController;
  bool _isDrawing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _drawCards() async {
    // Verificar limite diário para usuários free
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.canUseOracle) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você atingiu o limite diário de leituras. Volte amanhã ou seja Premium!'),
          backgroundColor: AppColors.alert,
          duration: Duration(seconds: 4),
        ),
      );
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const PremiumUpgradeSheet(),
      );
      return;
    }

    setState(() {
      _isDrawing = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    // Embaralhar cartas
    final allCards = List<OracleCard>.from(oracleCardsData)..shuffle();

    // Tirar cartas
    final count = _selectedSpread.cardCount;
    final drawn = <OracleCardPosition>[];

    for (int i = 0; i < count; i++) {
      drawn.add(OracleCardPosition(
        position: i,
        card: allCards[i],
        positionMeaning: _selectedSpread.getPositionMeaning(i),
      ));
    }

    // Incrementar uso de oracle
    await authProvider.incrementOracleReadings();

    setState(() {
      _drawnCards = drawn;
      _isDrawing = false;
    });

    _animController.forward(from: 0);

    // Salvar leitura
    await _saveReading(drawn);
  }

  Future<void> _saveReading(List<OracleCardPosition> positions) async {
    final db = await DatabaseHelper.instance.database;
    final reading = OracleReading(
      id: const Uuid().v4(),
      spreadType: _selectedSpread,
      positions: positions,
      date: DateTime.now(),
    );

    await db.insert(
      'oracle_readings',
      {
        'id': reading.id,
        'spread_type': reading.spreadType.name,
        'reading_data': reading.toJsonString(),
        'date': reading.date.millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartas do Oráculo'),
        backgroundColor: AppColors.darkBackground,
      ),
      backgroundColor: AppColors.darkBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_drawnCards == null) ...[
              MagicalCard(
                child: Column(
                  children: [
                    const Text('🔮', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      'Cartas do Oráculo',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.lilac,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Receba orientação e mensagens do universo',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.softWhite.withOpacity(0.8),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _buildSpreadOption(OracleSpreadType.daily),
              const SizedBox(height: 12),
              _buildSpreadOption(OracleSpreadType.threeCard),
              const SizedBox(height: 12),
              _buildSpreadOption(OracleSpreadType.weeklyGuidance),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isDrawing ? null : _drawCards,
                icon: _isDrawing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.darkBackground,
                          ),
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isDrawing ? 'Tirando cartas...' : 'Tirar Cartas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lilac,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  disabledBackgroundColor: AppColors.lilac.withOpacity(0.3),
                ),
              ),

              // Exibir usos restantes para usuários free
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  if (authProvider.isPremium) return const SizedBox.shrink();
                  final remaining = authProvider.currentUser.remainingOracleReadings;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Leituras restantes hoje: $remaining/${UserModel.freeOracleReadingsLimit}',
                      style: TextStyle(
                        color: remaining > 0
                            ? AppColors.softWhite.withOpacity(0.6)
                            : AppColors.alert,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],

            if (_drawnCards != null) ...[
              _buildReadingResult(_drawnCards!),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _drawnCards = null;
                    _animController.reset();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Nova Leitura'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.lilac,
                  side: const BorderSide(color: AppColors.lilac),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpreadOption(OracleSpreadType spread) {
    final isSelected = _selectedSpread == spread;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSpread = spread;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lilac.withOpacity(0.2)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.lilac : AppColors.surfaceBorder,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.style,
              color: AppColors.lilac,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spread.displayName,
                    style: TextStyle(
                      color: isSelected ? AppColors.lilac : AppColors.softWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    spread.description,
                    style: TextStyle(
                      color: AppColors.softWhite.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.lilac,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingResult(List<OracleCardPosition> positions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MagicalCard(
          child: Column(
            children: [
              const Text('✨', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'Sua Leitura',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.lilac,
                    ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ...positions.map((position) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _animController,
                      curve: Interval(
                        position.position * 0.15,
                        (position.position * 0.15) + 0.4,
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: child,
                );
              },
              child: MagicalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.lilac,
                                AppColors.lilac.withOpacity(0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              position.card.emoji,
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                position.positionMeaning,
                                style: TextStyle(
                                  color: AppColors.softWhite.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                position.card.name,
                                style: const TextStyle(
                                  color: AppColors.lilac,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                position.card.message,
                                style: TextStyle(
                                  color: AppColors.softWhite.withOpacity(0.8),
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.lilac),
                    const SizedBox(height: 8),
                    Text(
                      position.card.guidance,
                      style: const TextStyle(
                        color: AppColors.softWhite,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: position.card.keywords.map((keyword) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lilac.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.lilac.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            keyword,
                            style: const TextStyle(
                              color: AppColors.lilac,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
