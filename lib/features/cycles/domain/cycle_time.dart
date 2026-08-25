/// Conversões de tempo do ciclo de 120 anos.
///
/// O sistema usa o **ano de 365,25 dias** (ano juliano) como unidade — é o que
/// faz as fronteiras das Eras baterem com as tabelas de referência.
library;

/// Dias em um ano, na convenção do sistema.
const double kAnoEmDias = 365.25;

/// Milissegundos em um dia.
const int kDiaEmMilissegundos = 86400000;

/// Um nakshatra (termo técnico, nunca exibido) = 360/27 = 13°20'.
const double kNakshatraGraus = 360.0 / 27.0;

/// Quantidade de nakshatras no zodíaco.
const int kTotalNakshatras = 27;

/// Versão do algoritmo. Subir este número invalida os caches gravados por
/// versões anteriores, forçando o recálculo.
///
/// O carimbo do cache é só das ENTRADAS (longitude da Lua, instante do
/// nascimento, esta versão): mudar o CÁLCULO sem subir daqui deixa cache
/// velho na máquina de quem já abriu a tela, e ele nunca cai sozinho.
///
/// Quem cobra isso é test/life_eras_calculator_test.dart, no caso de
/// referência: os valores congelados lá são o contrato do algoritmo, e o
/// teste prende esta constante a eles. Não é boa memória — é trava.
const int kLifeErasAlgoVersion = 1;

/// Converte anos fracionários em [Duration].
///
/// Usa **milissegundos**, não microssegundos: o app compila para web, onde
/// `int` é um `double` de 53 bits (~9×10¹⁵). Os 120 anos do ciclo em
/// microssegundos dão 3,8×10¹⁵ — perto demais do limite para ficar confortável.
/// Em milissegundos são 3,8×10¹², com folga de sobra.
Duration anosParaDuracao(double anos) =>
    Duration(milliseconds: (anos * kAnoEmDias * kDiaEmMilissegundos).round());

/// Converte uma [Duration] de volta para anos fracionários.
double duracaoParaAnos(Duration duracao) =>
    duracao.inMilliseconds / (kAnoEmDias * kDiaEmMilissegundos);
