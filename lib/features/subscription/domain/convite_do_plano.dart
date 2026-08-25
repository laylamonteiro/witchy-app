import '../../auth/data/models/feature_access.dart';
import '../../auth/data/models/user_model.dart';

/// Um limite que a pessoa Free pode encostar, já com o rótulo que ela lê.
///
/// O card antigo montava linhas à mão, e foi assim que nasceu o defeito: a
/// linha "Conselheiro Místico" lia `aiConsultationsToday` contra
/// `freeAiConsultationsLimit`, que são de OUTRA cota. Os dois limites valem
/// 1, então o denominador batia por coincidência e ninguém percebeu — mas a
/// barra errava nos dois sentidos: consultar o Conselheiro não a movia, e
/// analisar um sonho movia.
///
/// Por isso os números vêm de [FeatureAccessService.limits], o mesmo mapa que
/// DECIDE o bloqueio. Ler de outro lugar é o que permite a tela e a regra
/// discordarem.
class LimiteVisivel {
  const LimiteVisivel({
    required this.chave,
    required this.rotulo,
    required this.usado,
    required this.limite,
    required this.janela,
  });

  /// Identifica a cota para a tela escolher o texto de "do outro lado".
  final BalcaoDoLimite chave;

  /// Já traduzido.
  final String rotulo;

  final int usado;
  final int limite;
  final LimitWindow janela;

  int get restante {
    final r = limite - usado;
    return r < 0 ? 0 : r;
  }

  bool get esgotado => usado >= limite;

  /// Encostou, mas ainda dá para uma.
  ///
  /// `usado > 0` não é detalhe: numa cota de 1, quem não usou nada também
  /// tem "resta 1" — e anunciar isso como aviso seria transformar o começo
  /// do dia em contagem regressiva.
  bool get naUltima => usado > 0 && restante == 1;

  double get fracao => limite <= 0 ? 1 : usado / limite;
}

/// As cotas do plano Free, uma por BALCÃO — não uma por feature.
///
/// Três features de IA (analisar sonho, sugerir feitiço, clima mágico)
/// dividem `aiConsultationsToday`, e o Tarô consome a leitura do Oráculo do
/// dia. Mostrar uma linha por feature faria a mesma cota aparecer várias
/// vezes, cada uma andando quando a pessoa usou "outra coisa" — que é
/// exatamente a confusão que este trabalho veio desfazer.
enum BalcaoDoLimite {
  feiticos,
  diario,
  conselheiro,
  ia,
  runas,
  pendulo,
  oraculo,
  afirmacoes,
}

/// Em que ponto a pessoa está — e é isto que o cartão obedece.
///
/// O card antigo mostrava "0/10 · 0/30 · 0/1" para quem acabou de chegar.
/// Zero usado é justamente quando o limite parece generoso e distante: o
/// melhor espaço da tela gasto para dizer "você tem muito ainda". E quando
/// ela de fato esbarrava, mostrava a mesma coisa, do mesmo tamanho.
enum EstadoDoConvite {
  /// Ninguém está perto de nada: números somem, entra a curiosidade.
  longe,

  /// Uma cota está na última: aparece ESSA, e só ela.
  perto,

  /// Alguma acabou: o cartão cresce e diz o que havia do outro lado.
  noLimite,
}

/// A leitura do momento: o estado e a cota que o justifica.
class MomentoDoConvite {
  const MomentoDoConvite({required this.estado, this.emFoco});

  final EstadoDoConvite estado;

  /// A cota que decidiu o estado — nula apenas em [EstadoDoConvite.longe].
  final LimiteVisivel? emFoco;
}

/// Decide o estado a partir das cotas. Puro de propósito: é a regra que o
/// teste tranca, e ela não precisa de tela para existir.
MomentoDoConvite lerOMomento(List<LimiteVisivel> limites) {
  final esgotadas = limites.where((l) => l.esgotado).toList();
  if (esgotadas.isNotEmpty) {
    // A mais "cara" primeiro: entre duas cotas acabadas, a de limite menor é
    // a que a pessoa sente mais (perder a única consulta do dia dói mais do
    // que a décima entrada do diário).
    esgotadas.sort((a, b) => a.limite.compareTo(b.limite));
    return MomentoDoConvite(
      estado: EstadoDoConvite.noLimite,
      emFoco: esgotadas.first,
    );
  }

  final naUltima = limites.where((l) => l.naUltima).toList();
  if (naUltima.isNotEmpty) {
    // Desempate pela fração: com o mesmo "resta 1", quem gastou mais do
    // total está mais perto do fim.
    naUltima.sort((a, b) => b.fracao.compareTo(a.fracao));
    return MomentoDoConvite(
      estado: EstadoDoConvite.perto,
      emFoco: naUltima.first,
    );
  }

  return const MomentoDoConvite(estado: EstadoDoConvite.longe);
}

/// De onde cada balcão tira número: a chave no mapa que decide o bloqueio.
///
/// [BalcaoDoLimite.afirmacoes] não aparece aqui porque não está no mapa: a
/// afirmação tem DOIS limites, o mensal do diário (via
/// `diaryAffirmationsCreate`) e um diário de 3 que vive só em
/// `UserModel.canUseAffirmations`, sem entrada no registro. Achado fora
/// deste escopo — unificar os dois é mexer em bloqueio, não em tela —, mas
/// o limite existe e a pessoa esbarra nele, então ele é mostrado.
const Map<BalcaoDoLimite, AppFeature> _featureDoBalcao = {
  BalcaoDoLimite.feiticos: AppFeature.grimoireCreate,
  BalcaoDoLimite.diario: AppFeature.diaryDreamsCreate,
  BalcaoDoLimite.conselheiro: AppFeature.aiMysticCounselor,
  BalcaoDoLimite.ia: AppFeature.aiDreamAnalysis,
  BalcaoDoLimite.runas: AppFeature.runesReadings,
  BalcaoDoLimite.pendulo: AppFeature.divinationPendulum,
  BalcaoDoLimite.oraculo: AppFeature.divinationOracle,
};

/// Monta as cotas de [user] com os rótulos já traduzidos.
///
/// [rotulos] entra de fora para esta função continuar pura: quem chama é a
/// tela, que tem o l10n na mão.
List<LimiteVisivel> limitesDoPlanoGratuito(
  UserModel user,
  Map<BalcaoDoLimite, String> rotulos,
) {
  final registro = FeatureAccessService.limits;
  final lista = <LimiteVisivel>[];

  for (final balcao in BalcaoDoLimite.values) {
    final rotulo = rotulos[balcao];
    if (rotulo == null) continue;

    if (balcao == BalcaoDoLimite.afirmacoes) {
      lista.add(LimiteVisivel(
        chave: balcao,
        rotulo: rotulo,
        usado: user.affirmationsToday,
        limite: UserModel.freeAffirmationsLimit,
        janela: LimitWindow.daily,
      ));
      continue;
    }

    final limite = registro[_featureDoBalcao[balcao]];
    if (limite == null) continue;
    lista.add(LimiteVisivel(
      chave: balcao,
      rotulo: rotulo,
      usado: limite.used(user),
      limite: limite.limit,
      janela: limite.window,
    ));
  }

  return lista;
}

/// Qual vislumbre mostrar hoje, quando ninguém está perto de limite nenhum.
///
/// Roda por DIA, e não por abertura de tela: um vislumbre que troca a cada
/// vez que a pessoa entra nas Configurações vira ruído, e ela nunca termina
/// de ler o mesmo. Determinístico de propósito — sem timer, sem aleatório,
/// e por isso testável.
int indiceDoVislumbre(DateTime agora, int total) {
  if (total <= 0) return 0;
  final dias = DateTime.utc(agora.year, agora.month, agora.day)
      .difference(DateTime.utc(2020))
      .inDays;
  return dias.remainder(total).abs();
}
