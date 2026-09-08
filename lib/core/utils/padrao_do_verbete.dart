/// O PADRÃO DE ESCRITA dos verbetes, tirado do catálogo do app.
///
/// Os cristais e as ervas pré-carregados (`crystals_data_*.dart`,
/// `herbs_data_*.dart`) seguem uma regra que ninguém tinha escrito em lugar
/// nenhum, mas que vale nos três idiomas, sem uma exceção: **todo item de
/// lista começa com letra maiúscula e nunca termina em ponto final**. As
/// descrições podem ter ponto entre as frases, nunca no fim.
///
/// O verbete gerado pela IA vinha em minúscula ("aumentar a autoconfiança",
/// "lavar com água corrente") e a tela — que é a mesma para o catálogo e para
/// o verbete pessoal — mostrava o texto exatamente como veio. Daí a diferença
/// que salta aos olhos ao lado de um cristal do catálogo.
///
/// Isto aqui é a parte MECÂNICA da régua, e roda em dois lugares: quando o
/// verbete é gerado (para nascer certo) e quando ele é lido (para os que já
/// foram criados aparecerem certos, sem migração de banco). Por isso é
/// idempotente: aplicar duas vezes dá o mesmo resultado.
///
/// A parte de ESTILO — chip substantivado ("Autoconfiança") em vez de frase
/// com verbo ("Aumentar a autoconfiança"), uso no imperativo — não dá para
/// fazer por programa: essa mora no prompt (`encyGenerateSystemPrompt`).
library;

/// Uma frase do verbete no padrão do catálogo.
///
/// - apara espaços nas pontas;
/// - tira UM ponto final (reticências, `!` e `?` ficam — são intenção de quem
///   escreveu, não pontuação de sobra);
/// - põe a primeira letra em maiúscula.
///
/// Não mexe quando o primeiro caractere não é letra (número, aspas, emoji) nem
/// quando a segunda letra é maiúscula — `pH neutro` e `mL de água` viram
/// `PH neutro` e `ML de água` se a gente não tomar cuidado.
String fraseDoVerbete(String texto) {
  var t = texto.trim();
  if (t.isEmpty) return t;

  if (t.endsWith('.') && !t.endsWith('..')) {
    t = t.substring(0, t.length - 1).trimRight();
    if (t.isEmpty) return t;
  }

  final primeira = t[0];
  final maiuscula = primeira.toUpperCase();
  // Já é maiúscula, ou não é letra nenhuma (o toUpperCase de '1' é '1').
  if (primeira == maiuscula) return t;
  if (t.length > 1 && _ehMaiuscula(t[1])) return t;

  return '$maiuscula${t.substring(1)}';
}

bool _ehMaiuscula(String caractere) =>
    caractere == caractere.toUpperCase() &&
    caractere != caractere.toLowerCase();

/// Os campos de TEXTO do verbete gerado, no padrão do catálogo.
///
/// Fica de fora, de propósito: `name` (é o nome que a pessoa escolheu ou
/// confirmou), os enums (`element`, `planet`) e os booleanos — mexer neles
/// quebraria a leitura do modelo.
Map<String, dynamic> verbeteNoPadrao(Map<String, dynamic> dados) {
  final saida = Map<String, dynamic>.from(dados);

  for (final chave in const ['description', 'scientificName', 'folkNames']) {
    final valor = saida[chave];
    if (valor is String) saida[chave] = fraseDoVerbete(valor);
  }

  for (final chave in const [
    'intentions',
    'usageTips',
    'magicalProperties',
    'ritualUses',
    'safetyWarnings',
  ]) {
    final valor = saida[chave];
    if (valor is List) {
      saida[chave] = valor
          .map((item) => item is String ? fraseDoVerbete(item) : item)
          .toList();
    }
  }

  for (final chave in const ['cleaningMethods', 'chargingMethods']) {
    final valor = saida[chave];
    if (valor is List) {
      saida[chave] = valor.map((item) {
        if (item is! Map) return item;
        final metodo = Map<String, dynamic>.from(item);
        final nome = metodo['method'];
        if (nome is String) metodo['method'] = fraseDoVerbete(nome);
        final aviso = metodo['warning'];
        if (aviso is String) metodo['warning'] = fraseDoVerbete(aviso);
        return metodo;
      }).toList();
    }
  }

  return saida;
}
