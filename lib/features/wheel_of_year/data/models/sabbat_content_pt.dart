import 'sabbat_model.dart';

/// Textos dos Sabbats — conteúdo em português (idioma-base). Nomes dos
/// Sabbats (Samhain, Yule...) são nomes próprios invariantes.
/// Paridade verificada em test/content_models_parity_test.dart.
const Map<SabbatType, String> sabbatDescriptionsPt = {
  SabbatType.samhain: 'Ano Novo Bruxo. Véu entre mundos está fino. Honre ancestrais e entes queridos. Início do outono/inverno, período de recolhimento',
  SabbatType.yule: 'Solstício de Inverno. A noite mais longa do ano. Renascimento da luz. Coincide com festas juninas que mantêm a tradição do fogo sagrado',
  SabbatType.imbolc: 'Festival da luz crescente. Despertar da Terra, primeiros sinais da primavera. Tempo de limpeza, purificação e preparação para o novo crescimento',
  SabbatType.ostara: 'Equinócio de Primavera. Equilíbrio perfeito entre luz e escuridão. A natureza desperta plenamente. Tempo de novos começos',
  SabbatType.beltane: 'Festival do fogo e fertilidade. Celebração da vida em plenitude. Coincide com Finados, mas energeticamente é sobre celebrar a vida e o amor',
  SabbatType.litha: 'Solstício de Verão. O dia mais longo, pico do poder solar. Coincide com festas de fim de ano. Momento de celebração e gratidão',
  SabbatType.lammas: 'Primeira colheita. Após o verão abundante, é tempo de agradecer e compartilhar. Reconhecemos o sacrifício necessário para a abundância',
  SabbatType.mabon: 'Equinócio de Outono. Segunda colheita e segundo equilíbrio do ano. Preparação para o outono. Tempo de gratidão e equilíbrio',
};

const Map<SabbatType, String> sabbatSouthDatesPt = {
  SabbatType.samhain: '1 de maio',
  SabbatType.yule: '21 de junho',
  SabbatType.imbolc: '1 de agosto',
  SabbatType.ostara: '21 de setembro',
  SabbatType.beltane: '31 de outubro',
  SabbatType.litha: '21 de dezembro',
  SabbatType.lammas: '2 de fevereiro',
  SabbatType.mabon: '20 de março',
};

const Map<SabbatType, String> sabbatNorthDatesPt = {
  SabbatType.samhain: '31 de outubro',
  SabbatType.yule: '21 de dezembro',
  SabbatType.imbolc: '1 de fevereiro',
  SabbatType.ostara: '21 de março',
  SabbatType.beltane: '1 de maio',
  SabbatType.litha: '21 de junho',
  SabbatType.lammas: '1 de agosto',
  SabbatType.mabon: '21 de setembro',
};

const Map<SabbatType, List<String>> sabbatCrystalsPt = {
  SabbatType.samhain: ['Obsidiana', 'Ônix', 'Turmalina negra', 'Ametista'],
  SabbatType.yule: ['Quartzo transparente', 'Citrino', 'Granada', 'Rubi'],
  SabbatType.imbolc: ['Ametista', 'Quartzo rosa', 'Selenita', 'Pedra da lua'],
  SabbatType.ostara: ['Quartzo rosa', 'Aventurina', 'Água-marinha', 'Jaspe'],
  SabbatType.beltane: ['Quartzo rosa', 'Esmeralda', 'Malaquita', 'Carnélia'],
  SabbatType.litha: ['Citrino', 'Olho de tigre', 'Quartzo transparente', 'Âmbar'],
  SabbatType.lammas: ['Citrino', 'Cornalina', 'Ágata', 'Peridoto'],
  SabbatType.mabon: ['Âmbar', 'Topázio', 'Citrino', 'Ágata'],
};

const Map<SabbatType, List<String>> sabbatHerbsPt = {
  SabbatType.samhain: ['Artemísia', 'Alecrim', 'Sálvia', 'Rosa (pétalas)', 'Hortelã'],
  SabbatType.yule: ['Alecrim', 'Canela', 'Gengibre', 'Pinheiro', 'Louro'],
  SabbatType.imbolc: ['Lavanda', 'Camomila', 'Angélica', 'Manjericão'],
  SabbatType.ostara: ['Rosa', 'Lavanda', 'Hortelã', 'Manjericão'],
  SabbatType.beltane: ['Rosa', 'Lavanda', 'Hortelã', 'Manjericão'],
  SabbatType.litha: ['Camomila', 'Hortelã', 'Rosa', 'Lavanda'],
  SabbatType.lammas: ['Manjericão', 'Camomila', 'Alecrim'],
  SabbatType.mabon: ['Sálvia', 'Alecrim', 'Camomila'],
};

const Map<SabbatType, List<String>> sabbatColorsPt = {
  SabbatType.samhain: ['Preto', 'Laranja', 'Roxo escuro', 'Dourado escuro'],
  SabbatType.yule: ['Vermelho', 'Verde', 'Dourado', 'Branco'],
  SabbatType.imbolc: ['Branco', 'Rosa claro', 'Amarelo claro', 'Verde claro'],
  SabbatType.ostara: ['Verde', 'Amarelo', 'Rosa', 'Lilás'],
  SabbatType.beltane: ['Vermelho', 'Verde vibrante', 'Dourado', 'Rosa'],
  SabbatType.litha: ['Amarelo', 'Laranja', 'Dourado', 'Vermelho'],
  SabbatType.lammas: ['Dourado', 'Marrom', 'Laranja', 'Verde escuro'],
  SabbatType.mabon: ['Laranja', 'Vermelho', 'Marrom', 'Dourado escuro'],
};

const Map<SabbatType, List<String>> sabbatFoodsPt = {
  SabbatType.samhain: ['Abóbora', 'Maçãs', 'Pães caseiros', 'Sopas', 'Castanhas', 'Romã'],
  SabbatType.yule: ['Quentão', 'Pães de gengibre', 'Frutas secas', 'Milho', 'Laranja'],
  SabbatType.imbolc: ['Leite e derivados', 'Pães com sementes', 'Mel', 'Chás'],
  SabbatType.ostara: ['Ovos', 'Saladas verdes', 'Pães com ervas', 'Mel', 'Sementes'],
  SabbatType.beltane: ['Morangos', 'Frutas vermelhas', 'Vinho', 'Bolos de mel'],
  SabbatType.litha: ['Frutas frescas', 'Saladas', 'Sucos', 'Girassol (sementes)'],
  SabbatType.lammas: ['Pães', 'Milho', 'Cerveja', 'Frutas da estação', 'Grãos'],
  SabbatType.mabon: ['Maçãs', 'Uvas', 'Vinho', 'Abóboras', 'Nozes', 'Cogumelos'],
};

const Map<SabbatType, List<String>> sabbatRitualsPt = {
  SabbatType.samhain: ['Crie um altar para ancestrais com fotos e oferendas', 'Faça uma ceia silenciosa em honra aos que partiram', 'Pratique divinação (tarô, runas, pêndulo)', 'Acenda velas pretas e laranja'],
  SabbatType.yule: ['Decore sua casa com elementos naturais', 'Acenda velas para trazer a luz de volta', 'Faça um banho de ervas purificador', 'Medite sobre o ciclo de morte e renascimento'],
  SabbatType.imbolc: ['Limpe e purifique sua casa', 'Acenda velas brancas ou amarelas', 'Plante sementes (literais ou simbólicas)', 'Faça um ritual de banho com leite e mel'],
  SabbatType.ostara: ['Pinte ovos com símbolos mágicos', 'Plante flores e ervas', 'Faça um ritual de equilíbrio e harmonia', 'Crie sachês de prosperidade'],
  SabbatType.beltane: ['Acenda uma fogueira ou velas vermelhas', 'Dance e celebre a vida', 'Faça oferendas às fadas e elementais', 'Crie um altar de flores'],
  SabbatType.litha: ['Assista ao nascer ou pôr do sol', 'Colha ervas mágicas (estão no auge)', 'Faça um círculo de proteção ao redor de sua casa', 'Celebre com frutas e flores amarelas/douradas'],
  SabbatType.lammas: ['Asse pão como oferenda', 'Agradeça pelas conquistas do ano', 'Faça bonecas de milho (corn dolly)', 'Doe alimentos para quem precisa'],
  SabbatType.mabon: ['Crie uma cornucópia de gratidão', 'Faça um ritual de equilíbrio', 'Preserve alimentos (geleias, chás)', 'Medite sobre o que precisa ser liberado'],
};
