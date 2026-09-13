# Auditoria das 88 páginas que nunca tinham sido lidas

Três leituras adversariais varreram, em paralelo, as páginas que as
auditorias anteriores não alcançaram — elas tinham parado em 19 das 107.
São **46 achados distintos**: 8 graves, 26 médios, 12 leves. (Eram 48;
dois graves foram à conferência e caíram — ver "O que a conferência
derrubou", no fim.)

**Isto é uma LISTA DE SUSPEITAS, não um laudo.** Os achados saíram de
leitura de código, sem aparelho e sem SDK para rodar nada. Antes de
consertar qualquer um, **leia o código e confirme** — descobrir que o
achado está errado é um resultado legítimo, e nesse caso a linha sai daqui
com o motivo escrito. Foi o que aconteceu com dois deles.

Os dez graves originais já passaram por essa conferência, um a um: oito se
sustentaram e dois caíram. Os médios e os leves ainda não — continuam
sendo suspeita.

**O que já foi corrigido**, e por isso saiu da fila: a exportação que
entregava os dados da outra conta; a exclusão que dizia sucesso e deixava
o cadastro de pé; a senha atual que não era conferida contra nada; e o
nome com dois espaços que derrubava a aba de Configurações. Os graves que
sobram estão marcados abaixo. A decisão de ordem continua sendo da dona.

## Graves (8)

### `lib/core/services/data_export_service.dart:50` — ✅ CORRIGIDO

`buildJson` faz `db.query(table)` sem filtro de `user_id`, ao contrário de todo o resto do app (free_writing_repository.dart:17, menstrual_cycle_repository.dart:138, 152, 239 etc. filtram por conta). O `signOut` preserva o banco local de quem tem e-mail (auth_provider.dart:994) e o `claimLegacyData` só adota linhas de `local_user` (database_helper.dart:1405), então linhas de uma conta anterior permanecem no aparelho.

**Por que importa:** Num aparelho compartilhado — duas pessoas, ou a mesma conta trocada —, quem tocar em "Exportar meus dados" baixa um JSON que inclui as linhas da conta anterior: diários, sonhos, tiragens e a tabela `menstrual_days` inteira, com sintomas e datas. O gesto que existe para a pessoa levar o que é dela entrega o que é de outra.

**Correção proposta:** Passar o `userId` da conta ativa para `buildJson` e usar `where: 'user_id = ?'` em toda tabela que tem a coluna (todas as de `TabelasLocais.conteudo`).

### `lib/features/auth/data/repositories/supabase_auth_repository.dart:772` — ✅ CORRIGIDO

A chamada que apagaria o usuário do Auth está comentada (`// await _supabase.functions.invoke('delete-user');`). `deleteAccount` apaga as linhas de dados e o `profiles`, faz `signOut` e devolve sucesso — e a tela mostra `editDeleteSuccess` ("Conta excluída com sucesso", privacy_settings_page.dart:654). A conta em si, com o e-mail, continua existindo no servidor.

**Por que importa:** A pessoa pede exclusão, lê "excluída" e o cadastro fica. Três consequências que ela encontra sozinha: o e-mail dela permanece guardado depois de um pedido explícito de exclusão; tentar se cadastrar de novo com esse e-mail é recusado com "já está em uso" (signup_page.dart:648); e entrar com a senha antiga recria o perfil (supabase_auth_repository.dart:875) e devolve acesso a uma conta que o app disse não existir mais. É exatamente o defeito que `_deleteUserData` foi escrito para não cometer.

**Correção proposta:** Implantar e chamar a função Edge `delete-user` e só então dizer sucesso; enquanto ela não existir, trocar `editDeleteSuccess` por um texto que diga apenas que os dados foram apagados e que o cadastro será removido (ou abrir a exclusão como pedido a ser confirmado).

### `lib/features/auth/presentation/pages/change_password_page.dart:290` — ✅ CORRIGIDO

A senha atual digitada nunca é conferida contra nada: a tela a lê na linha 290, passa para `SupabaseAuthRepository.updatePassword` (supabase_auth_repository.dart:728-733), e lá o parâmetro `currentPassword` é ignorado — só se chama `auth.updateUser(password: nova)`. O único uso do campo é o validador da linha 212, que apenas exige que a nova senha seja diferente do que foi digitado ali. O doc da classe (linhas 12-16) afirma o contrário: "o backend não exige a senha atual; a checagem é só desta tela".

**Por que importa:** Quem pegar o aparelho desbloqueado troca a senha da conta digitando seis caracteres quaisquer no campo "senha atual", e a dona perde o acesso à própria conta — inclusive à cópia na nuvem do grimório e do registro do ciclo. O tratamento de erro que mapeia para `changePasswordWrongCurrent` (linha 327) nunca pode disparar, o que mascara a ausência da checagem.

**Correção proposta:** Antes de `updateUser`, reautenticar de fato (`signInWithPassword` com o e-mail da sessão e a senha atual) e abortar com `changePasswordWrongCurrent` se falhar — ou, se a decisão for não conferir, remover o campo e corrigir o doc.

### `lib/features/diary/presentation/pages/affirmation_form_page.dart:343` — ✔ confirmado, aberto

Editar uma afirmação própria NUNCA grava. `_saveAffirmation` monta o `AffirmationModel` com o id existente e, logo abaixo, todo o caminho de persistência está dentro de `if (widget.affirmation == null) { ... }`; quando há afirmação, a função cai direto no `Navigator.pop(context)` da linha 361. O `AffirmationProvider` sequer tem um `updateAffirmation` (grep em lib/ inteiro: zero ocorrências) — só `addAffirmation`, `toggleFavorite` e `deleteAffirmation`.

**Por que importa:** A lista de Afirmações abre o formulário ao tocar em qualquer afirmação não pré-carregada (affirmations_list_page.dart:88). A pessoa reescreve o texto, troca a categoria, toca no botão que diz 'Atualizar', a tela fecha sem erro nenhum — e a alteração se perdeu. Não há aviso e não há como perceber antes de reabrir.

**Correção proposta:** Criar `AffirmationProvider.updateAffirmation` (espelhando `updateGratitude`, devolvendo bool) e, no ramo `widget.affirmation != null`, aguardar essa gravação e só sair da tela quando ela devolver sucesso.

**A conferência acrescentou duas coisas.** (1) Seguir esta receita ao pé da
letra troca um bug por dois: o `AffirmationModel` montado na linha 335 usa o
construtor cheio, então `isFavorite` volta ao padrão `false` e `createdAt`
vira `DateTime.now()` — gravar esse objeto DESFAVORITARIA a afirmação e a
jogaria para o topo da lista (`orderBy 'created_at DESC'`). O caminho certo
é `widget.affirmation!.copyWith(...)`, que preserva id, createdAt,
isFavorite e isPreloaded. (2) A lista de Afirmações não é a única porta: a
lição do Grimório Vivo (lesson_page.dart:255) abre o formulário JÁ em modo
edição, logo depois de gravar — qualquer ajuste ali também se perde. E o
molde de retorno `bool` é o `addAffirmation` do próprio provider, não o
`updateGratitude`, que devolve `Future<void>`.

### `lib/features/diary/presentation/pages/free_writing_tab.dart:139` — ✔ confirmado, aberto

O canvas de escrita livre só salva em três gestos: abrir o histórico (linha 98), começar uma reflexão nova (linha 117) e o `PopScope` da linha 142. Mas nos Diários a aba 💭 NÃO é uma rota empilhada — é filha do `TabBarView` de diary_page.dart:114, e `DiaryPage` é `AutomaticKeepAliveClientMixin`. Trocar para a aba Sonhos/Gratidão, abrir Configurações, mudar de aba na bottom bar ou ter o app encerrado em background não dispara pop nenhum; o `dispose` (linha 59) só descarta o controller sem gravar, e não há `WidgetsBindingObserver` para o ciclo de vida.

**Por que importa:** O texto fica só no `TextEditingController`. Quem escreve um desabafo longo e sai da aba (ou tem o app encerrado pelo sistema, o normal em Android) perde tudo — e a docstring da própria classe (linhas 12-15) promete o contrário: 'salvo AUTOMATICAMENTE... ninguém perde o que escreveu por ter esquecido de apertar um botão'. O teste existente (test/free_writing_tab_test.dart) empurra a tela como ROTA, configuração que não é a dos Diários, então o buraco não é coberto.

**Correção proposta:** Tornar `_FreeWritingTabState` um `WidgetsBindingObserver` que chame `_save()` em `AppLifecycleState.inactive/paused`, e salvar também quando a aba perde o foco (listener no `TabController`).

**A conferência acrescentou:** é pior do que está escrito acima. O
`FreeWritingTab` NÃO pede keep-alive, e o próprio repositório já registra
que "o TabBarView desmonta o State fora de cena"
(encyclopedia_index_page.dart:87). Ou seja: trocar para a aba Sonhos ou
Gratidão não é um caso em que o salvamento "não dispara" — é um caso em que
o State é DESMONTADO e o texto digitado some na hora, sem precisar de app
encerrado nem de background.

### `lib/features/encyclopedia/data/data_sources/sacred_symbols_data_pt.dart:127` — ✔ confirmado, aberto

Três verbetes de Símbolos Sagrados têm como `emoji` um caractere de bloco raro do Unicode, e não um emoji: 𓂀 (U+13080, Egyptian Hieroglyphs) no Olho de Hórus (linha 127), ⛤ (U+26E4) no Pentagrama (linha 11) e ☥ (U+2625) no Ankh (linha 69) — idênticos nos três idiomas (_pt/_en/_es). Nenhum celular traz fonte de hieróglifo egípcio, e o ⛤ o próprio repo JÁ declara quebrado: lib/core/tools/tool_identity.dart:45 diz que ⛤, ᚱ e ⟟ mostravam o quadradinho de glifo ausente e por isso viraram desenho. Para sacredSymbols o ArcaneGlyph não tem desenho (arcane_categories.dart:60 devolve null), então o caractere aparece cru em quatro lugares: o título da AppBar (arcane_detail_page.dart:53, '𓂀 Olho de Hórus'), a pílula de origem (arcane_detail_page.dart:152), a linha de referência do card de lista (arcane_list_page.dart:248) e a linha da busca global (encyclopedia_search_page.dart:139).

**Por que importa:** É exatamente o defeito da runa que acabou de ser consertado no commit anterior: onde o aparelho não tem a fonte, o emblema do verbete vira um quadradinho vazio no título da tela, na lista e na busca.

**Correção proposta:** Dar a sacredSymbols uma entrada em ArcaneCategory.glyphIdFor e desenhar os três símbolos no mesmo sistema de ArchetypeGlyphArt (ou, como paliativo, trocar por emojis que existam no piso do app), mantendo o caractere só como reserva.

### `lib/features/learning/presentation/pages/lesson_page.dart:236` — ✔ confirmado, aberto

`_saveRecord` descarta o retorno de todas as gravações: `addDream` (236), `addGratitude` (246), `addAffirmation` (254), `addDesire` (262) e `addSpell` (276) devolvem `Future<bool>` = 'foi persistido?', e nenhum é lido. Os providers engolem a exceção, gravam `_error` e devolvem `false`. Em seguida `_writePage` marca a lição como concluída, mostra o selo com o XP e empilha o formulário do registro. A docstring de `DreamProvider.addDream` (dream_provider.dart:39) diz textualmente 'the caller only records progress for a save that actually happened' — e todas as outras telas honram isso (dream_form_page:239, gratitude_form_page:185, desire_form_page:234, affirmation_form_page:345, spell_form_page:294); só a lição não.

**Por que importa:** Se a gravação falhar, a pessoa escreve a página inteira do Grimório Vivo, vê 'Que assim seja' e o +25 XP, e cai num formulário de um registro que não existe. Pior: `markCompleted` é idempotente e a lição fica marcada como escrita para sempre — reabrir devolve `xpGained: 0` e não há como refazer a página perdida.

**Correção proposta:** Fazer `_saveRecord` devolver também o bool de persistência e, em `_writePage`, abortar com SnackBar de erro (sem `markCompleted`, sem celebração, sem push) quando a gravação falhar.

**A conferência corrigiu um detalhe da alegação:** "todas as outras telas
honram isso" não é verdade — `daily_rites_card.dart:453` e
`cycle_reading_report_page.dart:711` também descartam o bool, e duas das
citadas conferem pelo `provider.error`, não pelo retorno. E `_saveRecord`
tem um SEXTO ramo que a alegação não menciona: `FreeWritingProvider.save`,
que é `Future<void>` e não devolve bool nenhum — para ele o conserto precisa
de outro sinal, ou de mudar a assinatura do provider.

### `lib/features/settings/presentation/pages/settings_page.dart:1020` — ✅ CORRIGIDO

`_getInitials` estoura RangeError em dois nomes possíveis: nome vazio (`''.split(' ')` devolve `['']`, cai no `substring(0, 1)` sobre string de comprimento 0) e nome com dois espaços seguidos (`'Ana  Maria'.split(' ')` devolve `['Ana', '', 'Maria']`, e `parts[1][0]` estoura). O valor vem de `user.displayName` (linha 172), e o próprio diálogo "Editar Perfil" desta tela (linha 1126) salva o texto sem validar nem normalizar espaços.

**Por que importa:** A exceção acontece no `build` do cabeçalho, então a aba Configurações inteira quebra — e é por ela que se chega a Privacidade, Sincronização, Sair da conta e Excluir conta. A pessoa que apagar o próprio nome (ou cujo nome do Google tenha espaço duplo) fica sem nenhum desses caminhos, sem entender por quê.

**Correção proposta:** Fazer `_getInitials` trabalhar sobre `name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty)` e devolver um fallback ('?') quando não sobrar nenhuma parte, e recusar nome vazio no diálogo da linha 1126 como o `_showEditNameDialog` já faz.

## Médios (26)

### `lib/core/services/data_sync_service.dart:1547`

Desligar a sincronização chama `descartarLapidesPendentes`, que apaga a memória das exclusões ainda não avisadas ao servidor — e o interruptor (sync_settings_page.dart:88-97) não pede confirmação nem tem texto que mencione isso; o subtítulo é `editSyncBackupOn`, uma descrição fixa do recurso.

**Por que importa:** A consequência está documentada no código ("um item apagado com a nuvem desligada VOLTA se ela for religada") mas nunca é dita a quem mexe no interruptor: a pessoa desliga, apaga coisas, religa meses depois e vê reaparecer exatamente o que tinha mandado sumir, sem entender a relação entre as duas ações.

**Correção proposta:** Ao DESLIGAR, abrir uma confirmação que explique que o que for apagado com a nuvem desligada pode voltar ao religar (chave de ARB nova — proposta: `syncOffTombstoneWarning`).

### `lib/features/auth/presentation/pages/profile_page.dart:23`

`ProfilePage` não é aberta em lugar nenhum (só é exportada em auth.dart); `EditProfilePage` (944 linhas) só é alcançável a partir dela (profile_page.dart:423), e o `ProfileAvatarPicker` só a partir de ProfilePage:77. São ~1.840 linhas mortas que contêm uma SEGUNDA cópia dos interruptores de privacidade, do exportar, do limpar local e do excluir conta. A política de privacidade manda a pessoa justamente para lá: "Perfil → Gerenciar Seus Dados" (assets/legal/politica_de_privacidade.md:40, 78, 80).

**Por que importa:** Duas coisas ao mesmo tempo: a pessoa que lê a política procura um "Perfil" que não existe (o caminho real é Configurações → Privacidade) e desiste de exercer o direito; e a duplicata continua convidando a divergir — foi exatamente isso que produziu as listas de tabelas incompatíveis descritas em TabelasLocais e no DataExportService.

**Correção proposta:** Apagar ProfilePage/EditProfilePage (e o `export` correspondente) e corrigir os três caminhos citados na política para "Configurações → Privacidade → Gerenciar Seus Dados".

### `lib/features/diary/data/models/affirmation_model.dart:15`

`AffirmationCategory.displayName` devolve português fixo ('Abundância', 'Proteção', 'Amor', 'Cura', 'Poder Pessoal', 'Sabedoria', 'Manifestação', 'Transformação'). Aparece em affirmations_list_page.dart:60 (os chips de filtro no topo da aba), :117 (o subtítulo de cada afirmação) e affirmation_form_page.dart:209 (o dropdown de categoria). O `AffirmationLocalizer` só traduz o campo `text` das pré-carregadas — não toca em categoria. O gate não acusa porque o arquivo INTEIRO está na allowlist (scripts/i18n_allowlist.txt:63), justificado como 'Seeds/campos PT canônicos com overlay ou mapa EN/ES ao lado' — o que vale para as 38 frases semeadas, não para esses oito rótulos de interface, que não têm overlay nenhum.

**Por que importa:** Em inglês e espanhol a aba de Afirmações mostra os oito filtros e o dropdown do formulário em português. E `_generateAffirmation` (affirmation_form_page.dart:266) ainda manda esse `displayName` em PT como categoria no prompt da IA.

**Correção proposta:** Localizar `displayName` via `ContentLocale.instance.select` com mapas por locale e estreitar a linha 63 da allowlist para `lib/features/diary/data/models/affirmation_model\.dart:[0-9]+:.*text:` (só as linhas da semeadura).

### `lib/features/diary/data/models/desire_model.dart:113`

`DesireStatusExtension.displayName` devolve português fixo ('Em Aberto', 'Manifestando', 'Manifestado', 'Liberado') sem passar por ARB nem por `ContentLocale`. É exibido em desires_list_page.dart:100 (o chip de status de cada desejo) e em desire_form_page.dart:118 (o dropdown de status do formulário). O scanner não pega porque nenhuma das quatro tem acento nem está na lista PALAVRAS de scripts/check_hardcoded_pt.sh.

**Por que importa:** Quem usa o app em inglês ou espanhol vê o Diário de Desejos inteiro com os status em português — inclusive no dropdown, que é controle funcional, não só rótulo. O padrão certo já existe ao lado: `SpellType.displayName`/`MoonPhase.displayName` em spell_model.dart:178 usam `ContentLocale.instance.select(pt:, en:, es:)`.

**Correção proposta:** Trocar o switch por `ContentLocale.instance.select` com três mapas `_desireStatusNames{Pt,En,Es}`, como spell_model.dart já faz (não precisa de chave ARB nova).

### `lib/features/diary/presentation/pages/gratitude_form_page.dart:175`

No caminho de EDIÇÃO, `_saveGratitude` faz `provider.updateGratitude(gratitude); Navigator.pop(context);` sem `await` e sem olhar o resultado. O mesmo em dream_form_page.dart:226 (`context.read<DreamProvider>().updateDream(dream); Navigator.pop(context);`). Os dois providers engolem a exceção e só guardam `_error`. O caminho de criação, logo acima nos dois arquivos, faz tudo certo (`_persistNew` espera, checa e mostra SnackBar).

**Por que importa:** Se a gravação falhar, a pessoa vê a tela fechar como se tivesse dado certo e a edição sumiu — sem aviso nenhum. É a mesma incoerência que desire_form_page.dart:233-244 já resolve corretamente para update.

**Correção proposta:** Dar a `updateGratitude`/`updateDream` retorno `Future<bool>` (como `DesireProvider.updateDesire`) e repetir nos dois formulários o padrão de `_persistNew`: aguardar e, em falha, mostrar SnackBar sem sair da tela.

### `lib/features/encyclopedia/data/data_sources/goddesses_data_pt.dart:281`

A Morrigan usa '🐦‍⬛' — sequência ZWJ 🐦 + ZWJ + ⬛, Emoji 15.0 (2023) — nos três idiomas (_pt/_en/_es, todos na linha 281). Onde a fonte de emoji não conhece a sequência, ela se parte nos dois componentes e sai 'pássaro + quadrado preto'. É o mesmo defeito que archetype_glyph.dart:36 documenta ter derrubado A Bruxa (🧙‍♀️) e que motivou os desenhos dos arquétipos. Aparece no card da lista (goddesses_list_page.dart:156 e 172, corpo 32), no cabeçalho do verbete (goddess_detail_page.dart:356) e na busca global.

**Por que importa:** No lugar do corvo da Morrigan a pessoa vê um pássaro genérico seguido de um quadrado preto, que lê como glifo quebrado.

**Correção proposta:** Trocar por um emoji de codepoint único e antigo (🦅 ou 🐦 sozinho) ou dar à deusa um desenho, como foi feito com os arquétipos.

### `lib/features/encyclopedia/presentation/pages/colors_list_page.dart:428`

Os botões de avançar/voltar cor no card de detalhe da roda (_pagerButton) são um InkWell sobre um Container de 34×34 — alvo de toque 10dp abaixo do mínimo de 44, e eles ficam colados um no outro com apenas 6dp de folga (linha 351).

**Por que importa:** São o único jeito de corrigir um toque errado na roda de cores sem re-mirar numa fatia de 18°, e são pequenos demais para acertar com o polegar.

**Correção proposta:** Levar o Container a 44×44 (mantendo o círculo desenhado em 34 com um padding interno) ou trocar por IconButton, que já respeita o alvo mínimo.

### `lib/features/encyclopedia/presentation/pages/crystal_detail_page.dart:111`

O cabeçalho do bloco de segurança é Row(Icon 28 + SizedBox 8 + Text titleLarge) sem Expanded/Flexible, em crystal_detail_page.dart:103-121 e igual em metal_detail_page.dart:121-140. Aqui o card é duplamente recuado (margem 16 do MagicalCard + padding 16 do card + padding 16 do Container de alerta), sobrando ~228dp para o texto; 'Avisos de Segurança' em titleLarge (18sp, w600) mede ~178dp e estoura por volta da escala 1,3 — que é a opção 'Maior' do Android, não um extremo de acessibilidade.

**Por que importa:** É o título do aviso de toxicidade da pedra e do metal; cortado, o bloco perde justamente o rótulo que diz por que ele está lá.

**Correção proposta:** Envolver os dois Text de título (crystal_detail_page.dart:111 e metal_detail_page.dart:129) em Expanded.

### `lib/features/encyclopedia/presentation/pages/crystals_list_page.dart:243`

Mesmo padrão em três listas mais: o Row de referência do card traz emoji + Text sem Expanded/Flexible — crystals_list_page.dart:243-252 (elemento), herbs_list_page.dart:240-249 (elemento) e goddesses_list_page.dart:199-208 (origem, a pior das três porque 'Mesopotâmica' e 'Greco-Romana' são longos). O Row dá restrição de largura infinita ao Text não-flexível, então ele nunca quebra e o excedente é cortado. arcane_list_page.dart:258 é a única das cinco listas que resolve isso.

**Por que importa:** Em fonte grande a linha que classifica o verbete (elemento, origem) fica cortada, e é a informação que faz a pessoa escolher o que abrir.

**Correção proposta:** Envolver os três Text de nome em Expanded com overflow: TextOverflow.ellipsis, copiando a linha de arcane_list_page.dart:258.

### `lib/features/encyclopedia/presentation/pages/encyclopedia_index_page.dart:637`

No sumário do livro (_IndexEntry), o Text do nome da seção não tem Flexible e convive no mesmo Row com um Expanded(_DottedLeader) na linha 646. O Expanded encolhe até zero, mas o Text continua com restrição infinita e é medido no tamanho intrínseco de uma linha só — passando disso, o Row estoura. A página vive dentro de um AspectRatio 3:4 com 21+9 de recuo de papel, então a largura útil do rótulo é bem menor que a da tela (~207dp num aparelho de 360), e 'Símbolos Sagrados' já usa quase tudo na escala 1,0.

**Por que importa:** O sumário é a porta única da Enciclopédia e o único acesso à busca: um nome de seção cortado ali é a primeira coisa quebrada que a pessoa vê ao abrir o livro com fonte grande.

**Correção proposta:** Trocar o Text da linha 637 por Flexible(child: Text(..., maxLines: 1, overflow: TextOverflow.ellipsis)), deixando o pontilhado ceder o espaço.

### `lib/features/encyclopedia/presentation/pages/encyclopedia_index_page.dart:248`

O sumário usa 🗿 (moai da Ilha de Páscoa) como emblema da seção Runas. O app tem identidade própria para runa em dois lugares — ToolDrawing.raidho em lib/core/tools/tool_identity.dart:48 e RuneMark, que a busca já usa (encyclopedia_search_page.dart:132) — e nenhum dos dois é uma estátua polinésia. Na mesma tabela, 😇 e 😈 (carinhas) respondem por Anjos e Demônios, enquanto as páginas dessas seções mostram o SectionEmblem desenhado.

**Por que importa:** O sumário é a superfície que promete o que cada seção é; o desenho do índice não bate com o da seção que ele abre, e a runa é o caso em que o app já decidiu qual é o símbolo certo.

**Correção proposta:** Trocar _emojiFor por um leading opcional que aceite o desenho da seção (ToolDrawing.raidho para runas, SectionEmblem para as demais), mantendo emoji só onde não há desenho.

### `lib/features/encyclopedia/presentation/pages/encyclopedia_search_page.dart:80`

Os estados vazios da Enciclopédia são um Text centralizado e nada mais: encyclopedia_search_page.dart:79-87 ('nada encontrado') e arcane_list_page.dart:149-154 (o mesmo, nas quatro listas arcanas). O app tem estado vazio padrão ilustrado — EmptyStateWidget com MagicalEmptyStateType.search em lib/core/widgets/empty_state_widget.dart — usado por todas as listas dos Diários e pelos feitiços da pessoa. A Enciclopédia é a única seção fora desse padrão. Além disso, o convite de 'ainda digitando' (linha 71) repete literalmente a mesma chave do hint do campo (l10n.encySearchAll), então a frase aparece duas vezes na tela.

**Por que importa:** A busca vazia é o momento de maior dúvida da pessoa, e é o único canto do app onde ela não recebe a cena desenhada que recebe em todos os outros.

**Correção proposta:** Trocar os dois Center(Text(...)) por EmptyStateWidget(type: MagicalEmptyStateType.search, message: l10n.encyNothingFound) e, para o estado 'ainda digitando', usar uma chave diferente da do hint (proposta de ARB no relatório).

### `lib/features/encyclopedia/presentation/pages/metals_list_page.dart:196`

A linha de referência do card de metal é um Row com QUATRO filhos sem Expanded/Flexible: emoji do planeta, nome do planeta, emoji do elemento e nome do elemento (linhas 198–210). É o pior caso da Enciclopédia — todos os outros cards têm dois filhos nessa linha. Numa coluna útil de ~196dp (tela de 360, menos margem do MagicalCard, padding, a miniatura de 60 e o chevron), 'Júpiter' + 'Fogo' com os dois emojis já consome quase tudo na escala 1,0 e estoura nas escalas de fonte grande do sistema.

**Por que importa:** Com fonte aumentada — que é exatamente quem mais precisa dela — a linha que diz planeta e elemento do metal fica cortada na borda do card.

**Correção proposta:** Envolver os dois Text de nome (linhas 200 e 207) em Flexible com overflow: TextOverflow.ellipsis, como arcane_list_page.dart:258 já faz na linha equivalente.

### `lib/features/encyclopedia/presentation/widgets/related_link.dart:204`

O LinkableChip navegável tem padding vertical de 7 sobre bodyMedium (14sp): ~34dp de alvo. O chip gêmeo de 'Veja também' em arcane_detail_page.dart:424 tem padding 6 sobre 13sp: ~30dp. Os dois são InkWell que empilham uma página nova, e os dois ficam abaixo dos 44dp. De quebra, são duas cópias do mesmo chip que já divergiram (raio 16 vs 14, bodyMedium vs fontSize 13).

**Por que importa:** Alvos de 30dp num Wrap denso fazem a pessoa errar de chip e cair no verbete errado; e os dois chips iguais na intenção já não são iguais na tela.

**Correção proposta:** Subir o padding vertical dos dois para 12 (ou envolver em SizedBox de altura mínima 44) e fazer arcane_detail_page._chipSection reusar LinkableChip em vez de manter a cópia.

### `lib/features/encyclopedia/presentation/widgets/user_entry_helpers.dart:63`

MineEmptySpotlight escurece a lista inteira com preto a 55% quando o filtro 'Minhas/Meus' está ligado e não existe nenhuma entrada pessoal (usado em crystals_list_page.dart:279 e herbs_list_page.dart:274). Nesse estado a tela não tem NENHUMA frase: só o véu escuro, o chip de filtro aceso e o FAB com halo. O comentário no código assume que o gesto fica óbvio, mas o que se vê é uma lista apagada sem explicação.

**Por que importa:** É um estado vazio que mostra menos que uma frase; quem ligou o filtro sem saber o que ele fazia fica com a tela escurecida e sem texto que diga o que aconteceu nem o que fazer.

**Correção proposta:** Acrescentar uma linha de texto sobre o véu dizendo que ainda não há entradas pessoais e apontando o botão de adicionar (há chaves candidatas no ARB; se nenhuma servir, é uma chave nova para outra frente).

### `lib/features/journeys/presentation/pages/journeys_page.dart:630`

Duas strings de interface em português direto no código, fora do ARB: `'$completedSteps de ${journey.totalSteps} etapas'` (linha 630, o contador sob a barra de progresso de cada card de jornada) e `'Etapas da Jornada'` (linha 735, o título da seção dentro da folha de detalhe). Escapam do scripts/check_hardcoded_pt.sh porque não têm acento e 'de'/'da'/'etapas' não estão na lista de palavras sem acento.

**Por que importa:** São textos lidos em toda visita à Evolução Mágica, e em inglês/espanhol aparecem em português no meio de uma tela traduzida.

**Correção proposta:** Nenhuma chave existente serve (`learnPagesProgress` é '{done}/{total} páginas'): propor à frente de ARB `journeysStepsProgress` = '{done} de {total} etapas' e `journeysStepsTitle` = 'Etapas da Jornada' (+ EN/ES), e acrescentar 'etapas' à lista PALAVRAS do scanner para ele não deixar passar a próxima.

### `lib/features/journeys/presentation/pages/journeys_page.dart:855`

A tela de Jornadas anuncia XP que não existe. `JourneyStep.xpReward` e `JourneyModel.xpReward` são usados APENAS para desenhar — o selo '+{xp} XP' de cada etapa (linha 855) e a pílula '$earnedXp/${journey.xpReward} XP' do card (linha 654). Grep em lib/ inteiro: nenhum outro consumidor. O XP real vem de `LearningProvider.xp = lessonXp + practiceXp`, calculado por contagem no banco (learning_provider.dart:132-200), e jamais soma nada de jornada. Esses números convivem na MESMA tela com o cabeçalho de XP verdadeiro (linha 240) e com `journeysHowXpBody`, que lista as fontes de XP e não menciona jornadas. Junto disso, a jornada 'Vidente' declara `xpReward: 250` (journey_model.dart:405) mas suas quatro etapas somam 40+40+50+70 = 200: mesmo concluída, o card mostra '200/250 XP' para sempre.

**Por que importa:** A pessoa cumpre uma etapa, lê '+70 XP' e vai conferir o nível — que não mexeu. É a promessa mais explícita da tela e a única que o código não cumpre; a jornada da Divinação ainda por cima nunca fecha a própria conta.

**Correção proposta:** Decidir entre somar as etapas alcançadas (`JourneyStatsRepository.reachedSteps`) ao XP em `LearningProvider._computePracticeXp` ou remover os selos de XP dos cards e etapas — e, se ficarem, corrigir `divinacao_01` para `xpReward: 200`.

### `lib/features/learning/presentation/widgets/lesson_celebration_card.dart:49`

O selo de conclusão da lição é uma `Column` sem rolagem dentro de um `Dialog`, e lesson_page.dart:963 abre esse diálogo com `barrierDismissible: false`. No pior caso a coluna acumula capa do livro (84 px) + título + XP + frase do capítulo + pílula de novo nível + cabeçalho de marcos + até três marcos + pílula de dia completo + botão + botão de compartilhar.

**Por que importa:** Se o conteúdo não couber — tela em paisagem, aparelho baixo, ou fonte do sistema ampliada, que é justamente quem mais precisa — o botão 'Que assim seja' fica fora da área visível e não há barreira para tocar: a pessoa fica presa no diálogo depois de escrever a página. Não dá para confirmar sem rodar; o que dá para afirmar lendo é que a combinação (coluna sem rolagem + barreira não dispensável) não tem saída se estourar.

**Correção proposta:** Envolver a `Column` num `SingleChildScrollView` com `ConstrainedBox(maxHeight: MediaQuery.sizeOf(context).height * 0.8)` e, por garantia, deixar `barrierDismissible: true`.

### `lib/features/menstrual_cycle/presentation/pages/menstrual_cycle_page.dart:166`

`setRecordingAllowed` só é chamado com `true` em todo o app — não existe tela que devolva o primeiro sim. O único lugar que chama `MenstrualConsentStore.forget` na interface é o "apagar meus registros do ciclo" (privacy_settings_page.dart:99), e esse item só aparece quando `_menstrualDays > 0` (linha 222).

**Por que importa:** Quem consentiu e ainda não registrou nenhum dia não tem caminho nenhum para retirar o consentimento: o bloco na Privacidade está escondido e a página do Ciclo já não mostra a tela de consentimento. O doc do `MenstrualConsentStore` promete que "recusar não apaga nada — só fecha a porta da entrada", mas a porta não tem maçaneta do lado de dentro.

**Correção proposta:** Mostrar o bloco de consentimento na Privacidade (ou um "parar de registrar" na página do Ciclo) sempre que `recordingAllowed` for verdadeiro, e não só quando houver dias gravados.

### `lib/features/settings/presentation/pages/privacy_settings_page.dart:165`

Os três interruptores de "Coleta de Dados" (Analytics, Relatórios de Erro, Conteúdo Personalizado) gravam em SharedPreferences e são lidos de volta só pelas duas telas que os desenham — o grep de `privacy_analytics`/`privacy_crash_reporting`/`privacy_personalized` não encontra nenhum outro leitor, e o pubspec não tem nenhum SDK de analytics ou crash (nada de firebase/crashlytics/sentry).

**Por que importa:** Os três nascem LIGADOS e o subtítulo diz "Ajude a melhorar o app compartilhando dados de uso anônimos" — a tela afirma uma coleta que não acontece, e a política de privacidade (assets/legal/politica_de_privacidade.md:51 e 81) promete que dá para desativá-la ali. Se um dia alguém plugar um coletor, ele nascerá ignorando o interruptor, porque não há nada consultando a preferência.

**Correção proposta:** Ou remover a seção enquanto não houver coleta, ou criar um `ColetaDeDados` (um lugar só) que leia essas chaves e por onde qualquer coletor futuro tenha de passar.

### `lib/features/settings/presentation/pages/privacy_settings_page.dart:99`

`_eraseMenstrualRecord` roda `purge`, `forget`, o laço de `FreeWritingRepository().delete` e `MenstrualReportMarks().forget` sem nenhum try/catch, ao contrário de `_clearLocalData` (linha 556) e `_deleteAccount` (linha 664), que mostram o erro. Uma falha em qualquer ponto encerra a função em silêncio: se estourar no laço, as marcas nunca são esquecidas e nenhum aviso aparece.

**Por que importa:** É o gesto mais íntimo da tela. A pessoa toca em "apagar meus registros do ciclo", confirma, e não vê nem sucesso nem erro — fica sem saber se apagou. O comentário de `DatabaseHelper._apagarTabelas` diz literalmente "no gesto mais destrutivo do app, o erro precisa chegar à tela", e aqui ele não chega.

**Correção proposta:** Envolver as linhas 99-107 num try/catch que mostre `l10n.editClearError` (chave já existente) no `catch`, mantendo o snack de sucesso só no caminho que terminou.

### `lib/features/settings/presentation/pages/privacy_settings_page.dart:216`

O item "Limpar Dados Locais" é construído com `isDestructive: false`, enquanto "apagar meus registros do ciclo" e "Excluir conta" usam `true`. Ele apaga todo o conteúdo do aparelho (`limparConteudoDesteAparelho`).

**Por que importa:** É o único gesto destrutivo da tela sem a marca vermelha que os outros dois têm — lido de relance, parece uma limpeza de cache ao lado de dois itens visivelmente perigosos. Numa lista onde a cor é o único sinal de perigo, a inconsistência convida ao toque errado.

**Correção proposta:** Trocar para `isDestructive: true`, ou remover a marca dos três e usar outro sinal — o que não pode é ela existir em dois dos três.

### `lib/features/settings/presentation/pages/settings_page.dart:1126` — ✔ conferido

No diálogo "Editar Perfil", o Salvar chama `authProvider.updateProfile(displayName: nameController.text)` e `setGender` sem `await` e sem validação: o nome vai sem `trim()` e vazio é aceito (`updateProfile` guarda `''`, porque `'' ?? x` é `''`). O diálogo fecha sempre, como se tivesse salvado.

**Por que importa:** É a porta de entrada do estouro do item de gravidade alta acima — nome vazio derruba o cabeçalho das Configurações. Além disso, uma falha na gravação não aparece: a pessoa fecha o diálogo acreditando que o nome mudou.

**Correção proposta:** Validar nome não vazio (como `_showEditNameDialog` na linha 272 já faz), aplicar `trim()`, aguardar as duas gravações e só então fechar, mostrando erro se falharem.

### `lib/features/settings/presentation/pages/sync_settings_page.dart:93`

O `onChanged` faz `setState` e dispara `_saveCloudSync(value)` sem `await` e sem tratamento de erro (mesmo padrão em privacy_settings_page.dart:170-195 com `_saveSetting`). Se a gravação falhar, a tela mostra o estado novo e o armazenamento guarda o antigo.

**Por que importa:** É um interruptor de privacidade: a pessoa vê "desligado" e o app continua sincronizando, ou o contrário. Nenhuma das duas telas tem como perceber, porque ninguém espera pelo resultado.

**Correção proposta:** Tornar o handler `async`, aguardar a gravação e, no `catch`, reverter o `setState` e mostrar o erro.

### `lib/features/your_day/data/daily_checkin_repository.dart:246`

`bestStreak` compara dias com `day.difference(previous).inDays == 1` sobre `DateTime` locais. No dia em que o relógio adianta (horário de verão), a diferença entre duas meias-noites locais consecutivas é 23 h, `inDays` dá 0, e o `run` volta a 1. Mesmo defeito, mesma família, em journey_stats_repository.dart:119 e :127, onde `_calculateStreak` compara `DateTime.parse(dia)` com `todayDate.subtract(const Duration(days: 1))` por igualdade exata — na virada, subtrair 24 h cai às 23:00 do dia anterior e a igualdade falha.

**Por que importa:** O app tem locales en e es (Europa, EUA, Chile, Paraguai têm horário de verão). Uma vez por ano o recorde de sequência das Estatísticas cai para 1 sem motivo, e a sequência de gratidão que alimenta as etapas 'Pratique gratidão por 3/7/21/30 dias seguidos' da jornada Coração Grato se rompe — a pessoa perde o marco por causa do relógio.

**Correção proposta:** Comparar dias por índice de calendário e não por duração: usar `DateTime.utc(y, m, d)` dos dois lados da subtração (ou casar pela chave `dayKey` do dia anterior) em `bestStreak` e em `_calculateStreak`.

### `lib/features/your_day/presentation/widgets/cycle_reading_offer_card.dart:274`

O 'X' que dispensa o convite da Leitura do Ciclo é um `InkWell` com `Padding(all: 4)` sobre um `Icon(size: 18)` — alvo de 26x26, bem abaixo dos 48 do Material — e fica DENTRO de um `MagicalCard.accent` cujo `onTap` inteiro (linha 240) abre o fluxo da leitura. O mesmo desenho aparece no botão de apagar de free_writings_list_page.dart:74-85 (`Padding(all: 4)` + `Icon(size: 20)` = 28x28) colado ao card cujo toque abre a reflexão.

**Por que importa:** Errar o X por dois pixels leva a pessoa para dentro da oferta que ela tentava fechar — e no histórico de reflexões o alvo minúsculo é justamente o de APAGAR, ao lado do alvo grande que abre. Quem tem a mão menos firme não consegue dispensar o convite nem apagar com segurança.

**Correção proposta:** Envolver os dois ícones em `SizedBox(width: 48, height: 48)` (ou trocar por `IconButton`, que já garante o alvo mínimo), ajustando o `borderRadius` do InkWell junto.

## Leves (12)

### `lib/features/auth/presentation/pages/change_password_page.dart:305` — ✔ conferido

Quando `SupabaseConfig.isConfigured` é falso, a tela faz `await Future.delayed(2s)` e mostra `changePasswordSuccess` ("senha alterada") sem ter alterado nada; o mesmo padrão existe em forgot_password_page.dart:390 e 420, que declaram o link de recuperação enviado sem enviar.

**Por que importa:** É a tela dizendo "feito" sobre algo que não aconteceu. Em build de produção a condição não deve ocorrer, mas é um caminho que existe no código e que, se a configuração falhar em runtime, mente para a pessoa exatamente sobre a senha dela.

**Correção proposta:** Trocar a simulação por um erro explícito (`authSystemNotConfigured`, chave já usada em login_page.dart:568) em vez do falso sucesso.

### `lib/features/auth/presentation/pages/welcome_page.dart:20`

O comentário anuncia um guarda que não existe mais: "Sem o guarda, o voltar a tirava do app na única tela em que ela ainda nem entrou" — e logo abaixo vem um `Scaffold` direto. O `GuardaDeVoltarWeb` saiu no commit a90c677, deliberadamente (o PorteiroDoVoltar o tornou redundante), mas o comentário ficou.

**Por que importa:** Não quebra nada hoje, mas é a documentação de uma proteção na tela mais sensível do fluxo de entrada. Quem for mexer aqui vai confiar que existe uma defesa que não existe — ou reintroduzi-la sem necessidade.

**Correção proposta:** Reescrever o comentário dizendo que quem trata o voltar nesta tela é o PorteiroDoVoltar, e não um widget local.

### `lib/features/diary/presentation/pages/gratitude_form_page.dart:85`

A data escolhida é mostrada como `'${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'` — sem zero à esquerda e sem locale. Idêntico em dream_form_page.dart:89. Todo o resto do app usa `DateFormat('dd/MM/yyyy')` (gratitudes_list_page:32, dreams_list_page:153, desires_list_page:161, free_writings_list_page:35).

**Por que importa:** O formulário mostra '3/9/2026' e a lista logo atrás mostra '03/09/2026' para a mesma entrada; para quem usa o app em inglês, '3/9' se lê como 9 de março.

**Correção proposta:** Trocar os dois por `DateFormat.yMd(Localizations.localeOf(context).toString()).format(_selectedDate)` — ou, no mínimo, pelo `DateFormat('dd/MM/yyyy')` que o resto das telas já usa.

### `lib/features/encyclopedia/data/models/herb_model.dart:89`

O getter emoji de Planet mistura dois sistemas: ☀️ 🌙 ♀️ ♂️ pedem apresentação emoji com VS16 (linhas 79-87), enquanto ♃ (U+2643) e ♄ (U+2644) são caracteres de símbolo crus, sem VS16 e sem versão emoji nenhuma — e ☿️ (linha 83) leva VS16 num codepoint que não é emoji, então o seletor não faz nada. Aparecem lado a lado na mesma linha em metals_list_page.dart:198 e herb_detail_page.dart:124.

**Por que importa:** Na mesma lista, cinco planetas saem coloridos e dois saem em traço monocromático (ou em quadradinho, onde a fonte de símbolos não estiver instalada) — a régua de sete planetas não fecha.

**Correção proposta:** Desenhar os sete sigilos planetários no sistema de ToolDrawing/ArchetypeGlyphArt, ou padronizar os sete em emoji de codepoint antigo, em vez de misturar as duas coisas.

### `lib/features/encyclopedia/presentation/pages/elements_page.dart:41`

O card de introdução dos Elementos usa Text('∞', fontSize: 32) como emblema. Todos os cards-irmãos dessa mesma página e da página de Altar usam emoji (⚖️, ✨, 🌟, 🛐) e a seção inteira já tem o LivingEmblem desenhado logo acima, na linha 31. O infinito matemático não pertence a nenhum dos dois vocabulários.

**Por que importa:** Incoerência visível no topo da página: um símbolo de matemática abrindo a seção dos quatro elementos.

**Correção proposta:** Trocar o ∞ por um emoji coerente com o conjunto (🌍 ou ✨, como o resto da página) ou por um desenho pequeno no sistema dos emblemas.

### `lib/features/encyclopedia/presentation/pages/goddess_detail_page.dart:108`

A página das Deusas soma DUAS margens entre cards: o MagicalCard já traz margin vertical de 8 (magical_card.dart:130), o que dá 16 entre dois cards, e o arquivo ainda intercala const SizedBox(height: 16) nas linhas 108, 155, 176, 196, 217, 254 e seguintes — 32dp de respiro. Nenhuma outra página de verbete faz isso: crystal_detail_page, metal_detail_page, herb_detail_page e arcane_detail_page empilham os MagicalCard direto.

**Por que importa:** O verbete de deusa rola com o dobro de espaço em branco de todos os outros, e a Enciclopédia lê como duas páginas feitas por gente diferente.

**Correção proposta:** Remover os SizedBox(height: 16) que ficam ENTRE MagicalCards em goddess_detail_page.dart, deixando a margem do card responder pelo ritmo.

### `lib/features/encyclopedia/presentation/widgets/user_entry_helpers.dart:34`

Sobrou um ramo morto da criação pessoal de Cores: MineFilterButton._label ainda trata UserEntryCategory.color (linha 34-35, consumindo a chave de ARB encyFilterMineColors) e ColorDetailPage ainda aceita userEntry e mostra a lixeira (color_detail_page.dart:17 e 28), mas o recurso foi retirado de propósito — user_entry_model.dart:25 diz 'Cores saíram da criação pessoal', add_entry_page.dart:103 barra a categoria, e colors_list_page.dart nunca instancia MineFilterButton nem AddUserEntryFab nem passa userEntry (linha 396). Nenhuma entrada pessoal de cor pode existir, então nada disso roda.

**Por que importa:** O check_arb_orfas passa (a chave É referenciada), mas encyFilterMineColors está traduzida em quatro ARBs para um botão que a pessoa nunca vê — e o código sugere um caminho que não existe mais.

**Correção proposta:** Remover o ramo color de MineFilterButton._label e o parâmetro userEntry de ColorDetailPage, e propor a baixa de encyFilterMineColors à frente que mexe no ARB.

### `lib/features/learning/presentation/providers/learning_provider.dart:176`

A tela de Jornadas promete, em `journeysHowXpBody`, 'Cada rito do dia: 3'. Mas `_riteXp` conta os ids gravados na coluna `rites` de `daily_checkins`, e gratidão e sonho NUNCA entram lá — o próprio `DailyCheckinProvider.ritesToday` explica isso nas linhas 122-124, e o grep de `completeRite(` confirma: só os seis ritos exploratórios e o `day_complete` são escritos. Na prática 'cada rito do dia' rende 3 XP uma vez por dia, não três.

**Por que importa:** Quem cumpre os três ritos e vai conferir a conta encontra 3 XP onde o texto prometia 9. Gratidão e sonho rendem 5 XP cada por serem criações, mas não é isso que a frase diz.

**Correção proposta:** Reescrever a linha do ARB para 'O rito exploratório do dia: 3' (proposta para a frente de ARB, em `journeysHowXpBody` nos três idiomas) — ou gravar também `gratitude`/`dream` em `rites`, o que mexeria no XP histórico de todo mundo.

### `lib/features/settings/presentation/pages/settings_page.dart:1299` — ✔ conferido

`_getRoleLabel` devolve 'ADMINISTRADOR', 'PREMIUM' e 'GRATUITO' em português cru, fora do ARB; o texto é exibido no crachá sob o nome (linha 230). O `scripts/check_hardcoded_pt.sh` não o pega.

**Por que importa:** Quem está em EN ou ES vê o próprio plano rotulado em português, logo abaixo do nome — no cartão mais visível da tela de conta.

**Correção proposta:** Usar as chaves existentes `profileFreePlan`/`profilePremiumPlan` (já usadas na linha 335 deste mesmo arquivo) e propor uma chave para o admin, em vez das strings literais.

### `lib/features/settings/presentation/pages/theme_picker_page.dart:169`

A prévia de cada tema traz o literal 'Ritual da Lua Nova' em português, dentro do cartão simulado — ao lado de textos que JÁ vêm do ARB no mesmo método (`themePreviewChipProsperity`, `themePreviewButton`).

**Por que importa:** A tela de Aparência mostra uma frase em português a quem escolheu inglês ou espanhol, repetida em todos os cartões de tema da lista.

**Correção proposta:** Criar uma chave (proposta: `themePreviewCardTitle`) ou reaproveitar uma existente de título de ritual, como os outros dois textos da prévia já fazem.

### `lib/features/your_day/presentation/pages/your_day_page.dart:27`

A docstring descreve uma ordem que o `build` não segue: ela diz 'ganhos rápidos (ritos do dia, afirmação) → retomar (trilha) → contexto (lua, momento, clima) → consulta (recolhida) → atalhos', mas a lista de filhos (linhas 112-131) põe o contexto lunar (`MoonDayCarousel`, `NextMoonPhasesCard`) e a consulta recolhida (`SpellRecommendationsCard`) ANTES dos ritos, e a afirmação depois do clima. Na mesma tela, `_refresh` (linha 67) afirma que 'o resto da tela é derivado e se reconstrói junto' recarregando só o `DailyCheckinProvider` — mas `DailyAffirmationCard` e `ContinueTrailCard` leem providers que o puxar-para-atualizar não toca.

**Por que importa:** Não afeta quem usa o app hoje, mas é a explicação que a próxima pessoa vai ler antes de reordenar a tela — e os dois comentários estão errados em relação ao que o código faz.

**Correção proposta:** Atualizar a docstring para a ordem real (ou reordenar os filhos para a ordem declarada) e, em `_refresh`, recarregar também `LearningProvider` e `AffirmationProvider`, que é o que o comentário já afirma acontecer.

### `lib/features/your_day/presentation/widgets/daily_rites_card.dart:455`

O título da gratidão escrita no card é cortado com `text.substring(0, 40)`, que corta por unidade UTF-16. Um emoji (ou qualquer caractere fora do BMP) exatamente na fronteira dos 40 é partido ao meio e vira meio par substituto.

**Por que importa:** O título aparece na lista do Diário de Gratidão com um caractere quebrado no fim, e o campo também é o que sobe para a nuvem.

**Correção proposta:** Cortar por `runes` (`String.fromCharCodes(text.runes.take(40))`) em vez de `substring`.

## O que a conferência derrubou

Dois achados foram lidos no código, um a um, por um conferente e por dois
céticos encarregados de derrubá-lo. Os dois não sobreviveram, e saem da
lista — o motivo fica aqui para ninguém reabri-los.

### `arcane_detail_page.dart:435` — o chip de "Veja também" (era grave)

**Alegava:** que o `Text` do rótulo não tinha `Flexible` nem `Expanded`, e
que por isso o rótulo comprido do verbete Tríplice Lua saía cortado.

**Por que caiu:** o `Flexible` já está lá. Entrou no commit 332bda7, que é
ANTERIOR ao commit deste documento (c4309d2) — a leitura que gerou o achado
foi feita sobre uma árvore mais velha. Hoje arcane_detail_page.dart:439
envolve o `Text` exatamente como a correção proposta pedia, com um
comentário descrevendo o mesmo defeito, e o chip gêmeo de related_link.dart
(linha 216) recebeu o mesmo conserto no mesmo commit. O dado citado é
verdadeiro — sacred_symbols_data_en.dart:65 traz mesmo o rótulo de 54
caracteres —, mas com o `Flexible` no lugar ele quebra em duas linhas
dentro do chip em vez de estourar a linha do `Wrap`.

### `daily_rites_card.dart:181` — gratidão e sonho desmarcados (era grave)

**Alegava:** que o card lê `gratidoes.gratitudes` e `sonhos.dreams` sem
nunca disparar a carga, e que ninguém mais dispara no boot — então ao
reabrir o app os dois ritos apareceriam desmarcados e o selo do dia nunca
fecharia.

**Por que caiu:** quem dispara a carga é o `ChangeNotifierProxyProvider` de
main.dart (linhas 657-663 e 671-677). O `update` de cada um chama
`setUserId(auth.currentUser.id)`, e o `setUserId` dos dois providers
(gratitude_provider.dart:17, dream_provider.dart:17) chama
`loadGratitudes()`/`loadDreams()` sempre que o id muda. O grep da auditoria
procurou os chamadores EXTERNOS de `loadGratitudes()` e não viu o caminho
interno.

A guarda `if (_currentUserId == userId) return;` também não cala a carga:
ela só curto-circuitaria se a conta tivesse o id `'local_user'`, e quem
chega ao Seu Dia tem sessão — `decidirRedirect` (app_router.dart:257)
manda qualquer rota de conteúdo sem sessão para `/welcome`, e
`isAuthenticated` exige e-mail, que só existe com conta real e uuid
próprio. E o card lê os dois com `context.watch`, então ele se reconstrói
quando a carga termina: não fica com a lista vazia do primeiro quadro.

## O que só o aparelho responde

As leituras separaram, por conta própria, o que não dá para decidir
sem ver a tela num telefone de verdade:

- Se 𓂀 (U+13080), ⛤ (U+26E4) e ☥ (U+2625) realmente viram quadradinho: o raciocínio é firme (nenhum sistema móvel traz fonte de Egyptian Hieroglyphs, e o próprio tool_identity.dart:45 registra que ⛤ mostrava o glifo ausente NESTE app), mas a confirmação por aparelho depende de qual fonte de símbolos cada Android/iOS carrega. Precisa de um print em aparelho real, de preferência num Android antigo.
- Se 🐦‍⬛ se parte em 🐦 + ⬛: depende da versão da fonte de emoji do aparelho (Emoji 15.0, set/2023). Em Android recente sai o corvo; em aparelhos anteriores, não. Só um print em aparelho antigo fecha a questão.
- O ponto exato de escala de fonte em que cada Row sem Expanded estoura: as contas acima são estimativas de largura de glifo em Nunito/Cinzel a partir do texto real dos ARBs e das larguras de card. Quem confirma é rodar as telas com textScaleFactor 1,3 e 2,0 — ou um teste de golden/overflow, que esta frente não pode escrever.
- Se o alvo de 34dp de _pagerButton e de ~30dp dos chips causa erro de toque na prática: o número é objetivo e está abaixo do mínimo, mas o impacto real se mede usando.
- Se o selo de conclusão da lição (lesson_celebration_card) realmente estoura a tela: depende da altura do aparelho e da fonte do sistema. O que dá para afirmar lendo é que a Column não rola e o diálogo não é dispensável pela barreira — se estourar, não há saída.
- Se o DiaryPage/TabBarView constrói mesmo só a aba corrente (índice 2) no preload do shell: a leitura de app_router.dart:136-200 (`preload: true`) e do TabBarView sustenta a conclusão de que gratitudes/dreams não carregam no boot, e o comentário de daily_rites_card.dart:84-87 a confirma, mas a contagem exata de abas construídas só se vê rodando.
- Se os alvos de toque de 26/28 px (X do convite do Ciclo, apagar do histórico de reflexões) causam toque errado na prática: a medida vem do código; a taxa de erro, só de uso real.
- Se existe algum registro com data no FUTURO no banco: os dois seletores usam `lastDate: DateTime.now()`, então pelo app não dá para criar um. Se um chegar pelo sync (relógio errado do outro aparelho), `showDatePicker` receberia `initialDate` depois de `lastDate` — em debug isso quebra num assert; o comportamento em release eu não consigo determinar sem rodar.
- Se algum provider dos Diários fica com dado velho na tela depois do logout de conta anônima: `signOut` limpa o banco (auth_provider.dart:1000) e devolve o id 'local_user', e o `setUserId` de todos os providers de diário retorna cedo quando o id não muda. Se a HomePage for remontada na volta ao portal de entrada, os initState recarregam e o efeito não aparece — isso só se decide rodando.
- Estouro de Row com fonte do sistema ampliada em journeys_page.dart:322 ('ver níveis ✦' sem Flexible depois de um Expanded) e continue_trail_card.dart:295 (rótulo do CTA sem restrição de largura): a conta dá folga em escala normal e aperta muito acima de 2x, mas a largura real do texto só se mede no aparelho.
- Se entrar de novo com a senha antiga depois de "excluir a conta" realmente devolve acesso depende da configuração do Supabase (confirmação de e-mail, RLS de profiles). O que é certo pela leitura: o usuário do Auth não é apagado e o e-mail continua ocupado; o comportamento exato do re-login precisa de teste contra o servidor.
- O vazamento na exportação depende de o aparelho ter tido duas contas. O código confirma as duas metades (o signOut preserva o banco de quem tem e-mail; o export não filtra user_id), mas a reprodução de ponta a ponta precisa do app rodando com duas contas.
- O estouro de `_getInitials` foi deduzido da semântica de `String.split` em Dart (`''.split(' ') == ['']`, `'a  b'.split(' ') == ['a','','b']`) — sem SDK local não pude executar nem rodar `flutter analyze`/`flutter test` para confirmar.
- Alvo de toque e estouro de layout: só olhei o código. Os ListTile das telas de Configurações e Privacidade usam altura padrão do Material, e não achei nada gritante, mas medida de verdade só com o app na tela.
- Não rodei `flutter analyze`: as observações sobre imports e elementos não usados vieram de grep, não do analisador.

