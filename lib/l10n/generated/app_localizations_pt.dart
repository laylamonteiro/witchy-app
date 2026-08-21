// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Grimório de Bolso';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Sistema / português do Brasil';

  @override
  String get settingsLanguagePortuguese => 'Português (Brasil)';

  @override
  String get settingsLanguageEnglish => 'Inglês';

  @override
  String get settingsLanguageSpanish => 'Espanhol';

  @override
  String settingsLanguageChanged(String language) {
    return 'Idioma alterado para $language';
  }

  @override
  String get homeTitle => 'Início';

  @override
  String get grimoireTitle => 'Grimório';

  @override
  String get diaryTitle => 'Diário';

  @override
  String get authLogin => 'Entrar';

  @override
  String get authSignup => 'Criar conta';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get encyclopediaTitle => 'Enciclopédia';

  @override
  String get toolsTitle => 'Ferramentas';

  @override
  String get errorsGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }

  @override
  String get navEncyclopedia => 'Grimório';

  @override
  String get navGrimoire => 'Ferramentas';

  @override
  String get navDiaries => 'Diários';

  @override
  String get grimoirePageTitle => 'Ferramentas';

  @override
  String get grimoireTabAstrology => 'Astrologia Mística';

  @override
  String get grimoireTabTools => 'Ferramentas Mágicas';

  @override
  String get grimoireTabMyGrimoire => 'Meu Grimório';

  @override
  String get encyMyGrimoireIntro => 'Seus feitiços, reunidos por intenção — crie, guarde e revisite a sua magia';

  @override
  String get diaryPageTitle => 'Diários';

  @override
  String get diaryTabGratitude => 'Gratidão';

  @override
  String get diaryTabAffirmations => 'Afirmações';

  @override
  String get diaryTabDreams => 'Sonhos';

  @override
  String get diaryTabDesires => 'Desejos';

  @override
  String get encyclopediaPageTitle => 'Grimório';

  @override
  String get encyTabMoon => 'Lua';

  @override
  String get encyTabSabbats => 'Sabbats';

  @override
  String get encyTabCrystals => 'Cristais';

  @override
  String get encyTabHerbs => 'Ervas';

  @override
  String get encyTabMetals => 'Metais';

  @override
  String get encyTabColors => 'Cores';

  @override
  String get encyTabGoddesses => 'Deusas';

  @override
  String get encyTabElements => 'Elementos';

  @override
  String get encyTabAltar => 'Altar';

  @override
  String get encyTabRunes => 'Runas';

  @override
  String get encyTabArchetypes => 'Arquétipos';

  @override
  String get encyTabAngels => 'Anjos';

  @override
  String get encyTabDemons => 'Demônios';

  @override
  String get encyTabSymbols => 'Símbolos';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonBackAgainToExit => 'Toque em voltar novamente para sair';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get toolsHeaderTitle => 'Ferramentas Mágicas';

  @override
  String get toolsHeaderSubtitle =>
      'Recursos para auxiliar em suas práticas de magia e manifestação';

  @override
  String get toolMysticAdvisorTitle => 'Conselheiro Místico';

  @override
  String get toolMysticAdvisorDesc =>
      'Sabedoria ancestral para suas dúvidas de bruxaria e magia';

  @override
  String get toolOracleTitle => 'Cartas do Oráculo';

  @override
  String get toolOracleDesc => 'Mensagens e orientação do universo';

  @override
  String get toolSigilsTitle => 'Sigilos';

  @override
  String get toolSigilsDesc => 'Crie símbolos mágicos para suas intenções';

  @override
  String get toolNumerologyTitle => 'Numerologia';

  @override
  String get toolNumerologyDesc =>
      'Seus números-chave, horas espelho e sequências';

  @override
  String get toolRunesTitle => 'Leitura de Runas';

  @override
  String get toolRunesDesc => 'Consulte as antigas runas nórdicas';

  @override
  String get toolPendulumTitle => 'Pêndulo';

  @override
  String get toolPendulumDesc => 'Perguntas de sim ou não';

  @override
  String get toolLivingGrimoireTitle => 'Grimório Vivo';

  @override
  String get toolLivingGrimoireDesc =>
      'Trilhas de aprendizado: cada lição vira uma página sua';

  @override
  String get toolTarotTitle => 'Tarot';

  @override
  String get toolTarotDesc => 'Tiragens, carta do dia e tutor de aprendizado';

  @override
  String get toolArchetypeTitle => 'Teste de Arquétipo';

  @override
  String get toolArchetypeDesc =>
      'Descubra qual arquétipo vibra mais alto em você';

  @override
  String get toolPalmistryTitle => 'Leitura de Mãos';

  @override
  String get toolPalmistryDesc => 'Quiromancia pela palma da sua mão';

  @override
  String get commonClose => 'Fechar';

  @override
  String get premiumBePremium => 'Seja Premium';

  @override
  String get premiumUnlock => 'Desbloquear Premium';

  @override
  String get premiumContentLabel => 'Conteúdo Premium';

  @override
  String get premiumUpgradeAction => 'Upgrade';

  @override
  String get premiumPlansUnavailable =>
      'Os planos estão temporariamente indisponíveis';

  @override
  String get premiumActivated => 'Premium ativado com sucesso!';

  @override
  String get premiumPurchaseFailed => 'Não foi possível concluir a compra';

  @override
  String get premiumHeroAccess => 'ACESSE';

  @override
  String get premiumHeroPower => 'TODO O PODER';

  @override
  String get premiumHeroMagic => 'DA SUA MAGIA';

  @override
  String get premiumHeroTagline1 =>
      'Mais conhecimento, mais orientação e mais ';

  @override
  String get premiumHeroTaglineHighlight => 'conexão';

  @override
  String get premiumHeroTagline2 => ' com o seu caminho';

  @override
  String get premiumCatSemantic => 'Gato mágico do Grimório de Bolso';

  @override
  String get premiumBenefitAdvisor => 'Conselheiro Místico ilimitado';

  @override
  String get premiumBenefitEncyclopedia =>
      'Enciclopédia com conteúdos completos';

  @override
  String get premiumBenefitDailyClimate => 'Clima Mágico Diário personalizado';

  @override
  String get premiumBenefitUnlimitedReadings =>
      'Leituras ilimitadas de Runas, Oráculo e Sigilos';

  @override
  String get premiumBenefitCloudSync => 'Sincronização entre dispositivos';

  @override
  String get premiumPlanMonthly => 'Mensal';

  @override
  String get premiumPlanYearly => 'Anual';

  @override
  String get premiumPerMonth => '/mês';

  @override
  String get premiumPerYear => '/ano';

  @override
  String get premiumSave33 => 'Economize 33%';

  @override
  String get premiumTagSelected => 'SELECIONADO';

  @override
  String get premiumTagPopular => 'POPULAR';

  @override
  String premiumPlanSemantics(String title, String price, String period) {
    return 'Plano $title, $price $period';
  }

  @override
  String get premiumStartNow => 'Começar Agora';

  @override
  String get premiumCancelAnytime => 'Cancele a qualquer momento';

  @override
  String get premiumSecurePayment => 'Pagamento seguro';

  @override
  String get premiumDataProtected => 'Seus dados protegidos';

  @override
  String get authWelcomeBack => 'Bem-vinda de volta!';

  @override
  String get authLoginSubtitle => 'Entre para acessar seu grimório';

  @override
  String get authForgotPassword => 'Esqueci minha senha';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'seu@email.com';

  @override
  String get authEmailRequired => 'Por favor, insira seu email';

  @override
  String get authEmailInvalid => 'Por favor, insira um email válido';

  @override
  String get authPasswordLabel => 'Senha';

  @override
  String get authPasswordRequired => 'Por favor, insira sua senha';

  @override
  String get authPasswordMinLength =>
      'A senha deve ter pelo menos 6 caracteres';

  @override
  String get authOrContinueWith => 'ou continue com';

  @override
  String get authNoAccount => 'Não tem uma conta? ';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authSystemNotConfigured =>
      'Sistema de autenticação não configurado. Entre em contato com o suporte.';

  @override
  String get authLoginError => 'Erro ao fazer login';

  @override
  String get authSocialUnavailable => 'Login social não disponível no momento';

  @override
  String get authGoogleError => 'Erro no login com Google';

  @override
  String get authSignupSubtitle => 'Inicie sua jornada mágica';

  @override
  String get authNameLabel => 'Nome';

  @override
  String get authNameHint => 'Seu nome mágico';

  @override
  String get authNameRequired => 'Por favor, insira seu nome';

  @override
  String get authNameMinLength => 'O nome deve ter pelo menos 2 caracteres';

  @override
  String get authPasswordHintMin => 'Mínimo 6 caracteres';

  @override
  String get authPasswordCreateRequired => 'Por favor, insira uma senha';

  @override
  String get authConfirmPasswordLabel => 'Confirmar Senha';

  @override
  String get authConfirmPasswordHint => 'Digite a senha novamente';

  @override
  String get authConfirmPasswordRequired => 'Por favor, confirme sua senha';

  @override
  String get authPasswordsDontMatch => 'As senhas não coincidem';

  @override
  String get authTermsPrefix => 'Li e aceito os ';

  @override
  String get authTermsOfUse => 'Termos de Uso';

  @override
  String get authTermsAnd => ' e a ';

  @override
  String get authPrivacyPolicy => 'Política de Privacidade';

  @override
  String get authOrSignupWith => 'ou cadastre-se com';

  @override
  String get authHaveAccount => 'Já tem uma conta? ';

  @override
  String get authMustAcceptTerms => 'Você precisa aceitar os termos de uso';

  @override
  String get authSignupError => 'Erro ao criar conta';

  @override
  String get authEmailInUse => 'Este email já está em uso';

  @override
  String get authEmailInvalidShort => 'Email inválido';

  @override
  String get authSignupSuccess =>
      'Conta criada com sucesso! Bem-vinda ao Grimório!';

  @override
  String get authGoogleSignupUnavailable =>
      'Cadastro com Google não disponível no momento';

  @override
  String get authGoogleSignupError => 'Erro no cadastro com Google';

  @override
  String get welcomeSubtitle => 'Sua jornada mágica começa aqui';

  @override
  String get welcomeFeatureLunar => 'Calendário Lunar';

  @override
  String get welcomeFeatureGrimoire => 'Grimório Digital';

  @override
  String get welcomeFeatureDiaries => 'Diários Mágicos';

  @override
  String get welcomeFeatureAstrology => 'Astrologia';

  @override
  String get welcomeHaveAccount => 'Já tenho conta';

  @override
  String get forgotEmailSent => 'Email Enviado!';

  @override
  String forgotEmailSentTo(String email) {
    return 'Enviamos um link de recuperação para\n$email';
  }

  @override
  String get forgotCheckInbox => 'Verifique sua caixa de entrada e spam.';

  @override
  String get forgotBackToLogin => 'Voltar ao Login';

  @override
  String get forgotResend => 'Não recebeu? Enviar novamente';

  @override
  String get forgotTitle => 'Esqueceu a senha?';

  @override
  String get forgotSubtitle =>
      'Sem problemas! Digite seu email e enviaremos um link para criar uma nova senha.';

  @override
  String get forgotSendLink => 'Enviar Link de Recuperação';

  @override
  String get forgotRemembered => 'Lembrou a senha? ';

  @override
  String get forgotBackToLoginLower => 'Voltar ao login';

  @override
  String get forgotSendError => 'Erro ao enviar email';

  @override
  String get forgotResendError => 'Erro ao reenviar email';

  @override
  String get forgotResendSuccess => 'Email reenviado com sucesso!';

  @override
  String get forgotResendErrorPrefix => 'Erro ao reenviar';

  @override
  String get authShowPassword => 'Mostrar senha';

  @override
  String get authHidePassword => 'Ocultar senha';

  @override
  String forgotResendIn(int seconds) {
    return 'Reenviar em ${seconds}s';
  }

  @override
  String get changePasswordTitle => 'Alterar Senha';

  @override
  String get changePasswordHeader => 'Nova Senha';

  @override
  String get changePasswordSubtitle =>
      'Digite sua senha atual e escolha uma nova senha';

  @override
  String get changePasswordCurrentLabel => 'Senha Atual';

  @override
  String get changePasswordCurrentRequired =>
      'Por favor, insira sua senha atual';

  @override
  String get changePasswordNewLabel => 'Nova Senha';

  @override
  String get changePasswordNewRequired => 'Por favor, insira uma nova senha';

  @override
  String get changePasswordMustDiffer =>
      'A nova senha deve ser diferente da atual';

  @override
  String get changePasswordConfirmLabel => 'Confirmar Nova Senha';

  @override
  String get changePasswordConfirmHint => 'Digite a nova senha novamente';

  @override
  String get changePasswordConfirmRequired =>
      'Por favor, confirme sua nova senha';

  @override
  String get changePasswordError => 'Erro ao alterar senha';

  @override
  String get changePasswordSuccess => 'Senha alterada com sucesso!';

  @override
  String get changePasswordWrongCurrent => 'Senha atual incorreta';

  @override
  String get profileTitle => 'Meu Perfil';

  @override
  String get profileAnonymous => 'Bruxa Anônima';

  @override
  String get profileEditName => 'Editar Nome';

  @override
  String get profileFreePlan => 'Plano Gratuito';

  @override
  String get profilePremiumPlan => 'Plano Premium';

  @override
  String get profileFreePlanDesc => 'Algumas funcionalidades são limitadas';

  @override
  String get profilePremiumPlanDesc =>
      'Acesso completo a todas as funcionalidades';

  @override
  String get profileUpgrade => 'Fazer Upgrade';

  @override
  String get profileFreeUsage => 'Uso do Plano Gratuito';

  @override
  String get profileSpells => 'Feitiços';

  @override
  String get profileDiaryEntries => 'Entradas de Diário';

  @override
  String get profileThisMonth => 'este mês';

  @override
  String get profileMysticAdvisor => 'Conselheiro Místico';

  @override
  String get profileToday => 'hoje';

  @override
  String get profileEditProfile => 'Editar Perfil';

  @override
  String get profileManageSubscription => 'Gerenciar Assinatura';

  @override
  String get profileMagicalStats => 'Estatísticas Mágicas';

  @override
  String get profileMagicalJourneys => 'Jornadas Mágicas';

  @override
  String get profileNotifications => 'Notificações';

  @override
  String get profileHelpSupport => 'Ajuda & Suporte';

  @override
  String get profileAboutApp => 'Sobre o App';

  @override
  String get profileLogout => 'Sair da Conta';

  @override
  String get profileLogoutConfirm =>
      'Tem certeza que deseja sair?\nSeus dados locais serão mantidos.';

  @override
  String get profileLogoutAction => 'Sair';

  @override
  String get profileNotificationsSoon =>
      'As configurações de notificações estarão disponíveis em breve!\n\nVocê poderá personalizar alertas para:\n• Lembretes de rituais\n• Fases da lua\n• Datas mágicas especiais';

  @override
  String get profileSupportEmail => 'Email de Suporte';

  @override
  String get profileFaq => 'Perguntas frequentes';

  @override
  String get profilePrivacySafe => 'Seus dados estão seguros';

  @override
  String aboutVersion(String version, String build) {
    return 'Versão $version ($build)';
  }

  @override
  String get aboutDescription =>
      'Seu companheiro para práticas mágicas, rituais e autoconhecimento através da astrologia e bruxaria moderna.';

  @override
  String get aboutMadeWith => 'Desenvolvido com 🔮 e ✨';

  @override
  String get editBasicInfo => 'Informações Básicas';

  @override
  String get editNameUpdated => 'Nome atualizado!';

  @override
  String get editGenderSection => 'Gênero';

  @override
  String get editGenderHelp =>
      'Como o app deve se dirigir a você? Usamos essa escolha nos textos personalizados e nas respostas do Conselheiro Místico.';

  @override
  String get editSecurity => 'Segurança';

  @override
  String get editChangePasswordSubtitle => 'Modificar sua senha de acesso';

  @override
  String get editDataCollection => 'Coleta de Dados';

  @override
  String get editAnalytics => 'Analytics';

  @override
  String get editAnalyticsSubtitle =>
      'Ajude a melhorar o app compartilhando dados de uso anônimos';

  @override
  String get editCrashReports => 'Relatórios de Erro';

  @override
  String get editCrashReportsSubtitle =>
      'Enviar relatórios automáticos quando o app tiver problemas';

  @override
  String get editPersonalizedContent => 'Conteúdo Personalizado';

  @override
  String get editPersonalizedContentSubtitle =>
      'Receber sugestões baseadas no seu uso do app';

  @override
  String get editSyncBackup => 'Sincronização e Backup';

  @override
  String get editSyncBackupCloud => 'Sincronização e Backup na Nuvem';

  @override
  String get editSyncBackupOn =>
      'Manter seus dados protegidos e sincronizados entre dispositivos';

  @override
  String get editSyncPremiumOnly => 'Recurso exclusivo Premium';

  @override
  String get editManageData => 'Gerenciar Seus Dados';

  @override
  String get editExportData => 'Exportar Meus Dados';

  @override
  String get editExportDataSubtitle =>
      'Baixar uma cópia de todos os seus dados';

  @override
  String get editClearLocal => 'Limpar Dados Locais';

  @override
  String get editClearLocalSubtitle => 'Remover dados salvos neste dispositivo';

  @override
  String get editDeleteAccount => 'Excluir Minha Conta';

  @override
  String get editDeleteAccountSubtitle =>
      'Remover permanentemente todos os seus dados';

  @override
  String get genderFeminine => 'Feminino';

  @override
  String get genderMasculine => 'Masculino';

  @override
  String get genderNeutral => 'Neutro';

  @override
  String get editNotInformed => 'Não informado';

  @override
  String get editPrivacyMatters => 'Sua Privacidade Importa';

  @override
  String get editPrivacyNote =>
      'Seus dados mágicos são sagrados. Nunca vendemos suas informações pessoais e você tem controle total sobre o que é coletado e armazenado.';

  @override
  String get editNewPasswordMin =>
      'A nova senha deve ter pelo menos 6 caracteres';

  @override
  String get editErrorPrefix => 'Erro';

  @override
  String get editChangeAction => 'Alterar';

  @override
  String get editExportTitle => 'Exportar Dados';

  @override
  String get editExportConfirm =>
      'Seus dados serão exportados em formato JSON. Isso pode levar alguns segundos.';

  @override
  String get editExportAction => 'Exportar';

  @override
  String get editExporting => 'Exportando dados...';

  @override
  String get editExportSuccess => 'Dados exportados com sucesso!';

  @override
  String get editExportError => 'Erro ao exportar';

  @override
  String get editClearLocalTitle => 'Limpar Dados Locais?';

  @override
  String get editClearLocalConfirm =>
      'Isso removerá todos os dados salvos neste dispositivo. Se você tem sincronização ativada, seus dados na nuvem serão mantidos.';

  @override
  String get editClearAction => 'Limpar';

  @override
  String get editClearSuccess => 'Dados locais removidos com sucesso';

  @override
  String get editClearError => 'Erro ao limpar dados';

  @override
  String get editDeleteTitle => 'Excluir Conta';

  @override
  String get editDeleteWarning =>
      'ATENÇÃO: Esta ação é IRREVERSÍVEL!\n\nTodos os seus dados serão permanentemente excluídos, incluindo:\n- Feitiços e rituais\n- Entradas de diário\n- Mapa astral\n- Configurações\n\nTem certeza absoluta?';

  @override
  String get editDeletePermanently => 'Excluir Permanentemente';

  @override
  String get editDeleting => 'Excluindo conta...';

  @override
  String get editDeleteError => 'Erro ao deletar conta';

  @override
  String get editDeleteSuccess => 'Conta excluída com sucesso';

  @override
  String get editDeleteErrorPrefix => 'Erro ao excluir conta';

  @override
  String get editPremiumFeature => 'Recurso Premium';

  @override
  String get editSyncPremiumPitch =>
      'A sincronização de dados na nuvem é um recurso exclusivo para usuários Premium.\n\nCom o Premium, seus dados ficam sempre seguros e sincronizados entre todos os seus dispositivos.';

  @override
  String get editNotNow => 'Agora Não';

  @override
  String get settingsLifetime => 'Assinatura Vitalícia';

  @override
  String settingsRenewsOn(String date) {
    return 'Renova em: $date';
  }

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsPrivacy => 'Privacidade';

  @override
  String get settingsNotifDesc =>
      'Configure lembretes para eventos mágicos importantes';

  @override
  String get settingsFullMoon => 'Lua Cheia';

  @override
  String get settingsFullMoonDesc => 'Lembrete 1 dia antes da Lua Cheia';

  @override
  String get settingsNewMoon => 'Lua Nova';

  @override
  String get settingsNewMoonDesc => 'Lembrete 1 dia antes da Lua Nova';

  @override
  String get settingsSabbats => 'Sabbats';

  @override
  String get settingsSabbatsDesc => 'Lembrete 3 dias antes de cada Sabbat';

  @override
  String get settingsNotifMobileOnly =>
      'As notificações serão enviadas apenas em dispositivos móveis';

  @override
  String get settingsNotifUpdateError =>
      'Não foi possível atualizar as notificações';

  @override
  String get settingsPaymentsNotConfigured => 'Pagamentos Não Configurados';

  @override
  String get settingsPaymentsNotConfiguredDesc =>
      'O sistema de pagamentos ainda não foi configurado nesta versão do app.\n\nSe você é desenvolvedor, verifique os logs do console para mais detalhes.';

  @override
  String get commonUnderstood => 'Entendi';

  @override
  String get settingsTermsSubtitle => 'As regras do nosso círculo';

  @override
  String get monthJanShort => 'Jan';

  @override
  String get monthFebShort => 'Fev';

  @override
  String get monthMarShort => 'Mar';

  @override
  String get monthAprShort => 'Abr';

  @override
  String get monthMayShort => 'Mai';

  @override
  String get monthJunShort => 'Jun';

  @override
  String get monthJulShort => 'Jul';

  @override
  String get monthAugShort => 'Ago';

  @override
  String get monthSepShort => 'Set';

  @override
  String get monthOctShort => 'Out';

  @override
  String get monthNovShort => 'Nov';

  @override
  String get monthDecShort => 'Dez';

  @override
  String get diaryNewDream => 'Novo Sonho';

  @override
  String get diaryEditDream => 'Editar Sonho';

  @override
  String get diaryTitleLabel => 'Título';

  @override
  String get diaryDreamTitleHint => 'Ex: Sonho com borboletas';

  @override
  String get diaryDreamDate => 'Data do Sonho';

  @override
  String get diaryDreamDescLabel => 'Descrição do Sonho';

  @override
  String get diaryDreamDescHint => 'Descreva seu sonho em detalhes';

  @override
  String get diaryTagsLabel => 'Tags';

  @override
  String get diaryDreamTagsHint => 'Ex: pesadelo, recorrente, lúcido';

  @override
  String get diaryTagsHelper => 'Separe as tags por vírgula';

  @override
  String get diaryDreamFeelingLabel => 'Como você se sentiu ao acordar?';

  @override
  String get diaryDreamFeelingHint => 'Ex: Paz, medo, alegria, confusão';

  @override
  String get diaryInterpretationHeader => '🔮 Interpretação';

  @override
  String get diarySaveDream => 'Salvar Sonho';

  @override
  String get commonUpdate => 'Atualizar';

  @override
  String get diaryFillTitleOrDesc =>
      'Preencha pelo menos o título ou a descrição';

  @override
  String get diaryFillTitleOrContent =>
      'Preencha pelo menos o título ou o conteúdo';

  @override
  String get commonNoTitle => 'Sem título';

  @override
  String get commonConfirmDelete => 'Confirmar exclusão';

  @override
  String get diaryDeleteDreamConfirm => 'Deseja realmente excluir este sonho?';

  @override
  String get diaryNewGratitude => 'Nova Gratidão';

  @override
  String get diaryEditGratitude => 'Editar Gratidão';

  @override
  String get diaryGratitudeTitleHint => 'Ex: Gratidão pelo dia de hoje';

  @override
  String get commonDate => 'Data';

  @override
  String get diaryGratitudeLabel => 'Pelo que você é grato(a) hoje?';

  @override
  String get diaryGratitudeHint => 'Descreva suas gratidões...';

  @override
  String get diaryGratitudeTagsHint => 'Ex: família, saúde, trabalho';

  @override
  String get diarySaveGratitude => 'Salvar Gratidão';

  @override
  String get diaryDeleteGratitudeTitle => 'Excluir Gratidão';

  @override
  String get diaryDeleteGratitudeConfirm =>
      'Tem certeza que deseja excluir esta gratidão?';

  @override
  String get diaryNewDesire => 'Novo Desejo';

  @override
  String get diaryEditDesire => 'Editar Desejo';

  @override
  String get diaryDesireTitleHint => 'Ex: Viajar para o exterior';

  @override
  String get diaryDescLabel => 'Descrição';

  @override
  String get diaryDesireSigilImage => 'Imagem do sigilo';

  @override
  String get diaryDesireSigilTitle => 'Sigilo 🔐';

  @override
  String get diaryDesireDescHint => 'Descreva seu desejo em detalhes';

  @override
  String get diaryStatusLabel => 'Status';

  @override
  String get diaryDesireProgressLabel => 'O que se movimentou?';

  @override
  String get diaryDesireProgressHint => 'Registre a evolução do seu desejo';

  @override
  String get diarySaveDesire => 'Salvar Desejo';

  @override
  String get diaryDeleteDesireConfirm =>
      'Deseja realmente excluir este desejo?';

  @override
  String get diaryNewAffirmation => 'Nova Afirmação';

  @override
  String get diaryEditAffirmation => 'Editar Afirmação';

  @override
  String get diaryPreloadedAffirmationNote =>
      'Afirmações pré-carregadas não podem ser editadas ou excluídas.';

  @override
  String get diaryAdvisorAffirmationPitch =>
      'Deixe o Conselheiro Místico criar uma afirmação poderosa para você';

  @override
  String get diaryContextOptional => 'Contexto (opcional)';

  @override
  String get diaryContextHint => 'Ex: Estou começando um novo emprego...';

  @override
  String get diaryContextHelper =>
      'Descreva sua situação para uma afirmação personalizada';

  @override
  String get diaryConsulting => 'Consultando...';

  @override
  String get diaryGenerateAffirmation => 'Gerar Afirmação';

  @override
  String get diaryWriteOwnAffirmation => 'Ou escreva sua própria afirmação:';

  @override
  String get diaryAffirmationLabel => 'Afirmação';

  @override
  String get diaryAffirmationHint =>
      'Ex: Sou merecedor de abundância e prosperidade';

  @override
  String get diaryAffirmationHelper =>
      'Escreva no presente e de forma positiva';

  @override
  String get diaryCategoryLabel => 'Categoria';

  @override
  String get diarySaveAffirmation => 'Salvar Afirmação';

  @override
  String diaryAffirmationsRemaining(String used) {
    return 'Afirmações restantes hoje: $used';
  }

  @override
  String get diaryAffirmationCreated =>
      'Afirmação criada pelo Conselheiro Místico!';

  @override
  String get diaryAffirmationError => 'Erro ao gerar afirmação';

  @override
  String get diaryTypeOrGenerate => 'Digite ou gere uma afirmação';

  @override
  String get diaryAffirmationLimit =>
      'Você atingiu o limite diário de afirmações. Volte amanhã ou seja Premium!';

  @override
  String get diaryDeleteAffirmationTitle => 'Excluir Afirmação';

  @override
  String get diaryDeleteAffirmationConfirm =>
      'Tem certeza que deseja excluir esta afirmação?';

  @override
  String get diaryLoadingDreams => 'Carregando sonhos...';

  @override
  String get diaryEmptyDreams =>
      'Você ainda não registrou nenhum sonho.\nComece seu diário onírico!';

  @override
  String get diaryRegisterDream => 'Registrar Sonho';

  @override
  String get diaryInterpretDream => 'Interpretar Sonho';

  @override
  String get diaryDreamThemes => 'Temas Oníricos';

  @override
  String get toolDreamsTitle => 'Interpretação de Sonhos';

  @override
  String get toolDreamsDesc =>
      'Desvende as mensagens dos seus sonhos e explore significados';

  @override
  String get dreamToolsIntro =>
      'Os sonhos falam em símbolos. Interprete o seu com o Conselheiro Místico ou explore os significados dos temas mais comuns.';

  @override
  String get dreamInterpretMyDream => 'Interpretar meu Sonho';

  @override
  String get dreamInterpretMyDreamDesc =>
      'Conte seu sonho e receba uma leitura do Conselheiro Místico';

  @override
  String get dreamMeaningsTitle => 'Significados dos Sonhos';

  @override
  String get dreamMeaningsDesc =>
      'Água, queda, voo, dentes e outros temas oníricos — e suas possíveis leituras';

  @override
  String get diaryLoadingGratitudes => 'Carregando gratidões...';

  @override
  String get diaryEmptyGratitudes =>
      'Você ainda não registrou nenhuma gratidão.\nComece a cultivar abundância em sua vida!';

  @override
  String get diaryAddGratitude => 'Adicionar Gratidão';

  @override
  String get diaryLoadingDesires => 'Carregando desejos...';

  @override
  String get diaryEmptyDesires =>
      'Você ainda não registrou nenhum desejo.\nComece a manifestar seus sonhos!';

  @override
  String get diaryAddDesire => 'Adicionar Desejo';

  @override
  String get diaryLoadingAffirmations => 'Carregando afirmações...';

  @override
  String get diaryAllCategories => 'Todas';

  @override
  String get diaryEmptyAffirmationsCategory =>
      'Nenhuma afirmação nesta categoria.\nAdicione suas próprias afirmações!';

  @override
  String get diaryAddAffirmation => 'Adicionar Afirmação';

  @override
  String get commonGoodMorning => 'Bom dia ✨';

  @override
  String get commonGoodAfternoon => 'Boa tarde ✨';

  @override
  String get commonGoodEvening => 'Boa noite ✨';

  @override
  String get diaryPreviousReflections => 'Reflexões anteriores';

  @override
  String get diarySaveReflection => 'Salvar reflexão';

  @override
  String get diaryFreeWritingHint => 'O que está na sua mente hoje?';

  @override
  String get diaryReflections => 'Reflexões';

  @override
  String get diaryLoadingReflections => 'Carregando reflexões...';

  @override
  String get diaryEmptyReflections =>
      'Suas reflexões aparecerão aqui.\nEscreva o que estiver na sua mente. ✨';

  @override
  String get diaryDeleteReflectionTitle => 'Excluir reflexão';

  @override
  String get diaryDeleteReflectionConfirm =>
      'Tem certeza que deseja excluir esta reflexão?';

  @override
  String get diaryDreamThemesIntro =>
      'Cada símbolo carrega muitas leituras possíveis. Explore os temas mais comuns e compare com o que você sentiu no sonho.';

  @override
  String get dreamDescribeFirst => 'Descreva seu sonho primeiro';

  @override
  String get dreamInterpretedTitle => 'Sonho interpretado';

  @override
  String get dreamNotesPrefix => 'Observações';

  @override
  String get dreamSavedToDiary => 'Sonho e interpretação salvos no Diário! 🌙';

  @override
  String get dreamInterpretationTitle => 'Interpretação de Sonhos';

  @override
  String get dreamPremiumOnly =>
      'A interpretação personalizada de sonhos é exclusiva do plano Premium.';

  @override
  String get dreamTellYourDream => 'Conte seu sonho';

  @override
  String get dreamTellHelp =>
      'Descreva com o máximo de detalhes: lugares, pessoas, símbolos, sensações e o que mais lembrar.';

  @override
  String get dreamTextHint => 'Eu estava em uma floresta e…';

  @override
  String get dreamFeelingOptional =>
      'Como você se sentiu ao acordar? (opcional)';

  @override
  String get dreamInterpreting => 'Interpretando…';

  @override
  String get dreamInterpretAgain => 'Interpretar novamente';

  @override
  String get dreamInterpretationLabel => 'Interpretação';

  @override
  String get dreamSaveToDiary => 'Salvar no Diário de Sonhos';

  @override
  String get dreamDateLabel => 'Data do sonho';

  @override
  String get dreamNotesOptional => 'Observações (opcional)';

  @override
  String get dreamSavedShort => 'Salvo no Diário';

  @override
  String get tarotTabDraw => 'Tiragem';

  @override
  String get tarotTabLearn => 'Aprender';

  @override
  String get tarotDailyCard => 'Carta do Dia';

  @override
  String get tarotThreeCards => 'Três Cartas';

  @override
  String get tarotCross => 'Cruz de Cinco';

  @override
  String get tarotDailyDesc => 'A energia que acompanha o seu dia';

  @override
  String get tarotThreeDesc => 'Passado · Presente · Futuro';

  @override
  String get tarotCrossDesc => 'Situação, desafio, raiz, conselho e tendência';

  @override
  String get tarotPosPast => 'Passado';

  @override
  String get tarotPosPresent => 'Presente';

  @override
  String get tarotPosFuture => 'Futuro';

  @override
  String get tarotPosSituation => 'Situação';

  @override
  String get tarotPosChallenge => 'Desafio';

  @override
  String get tarotPosRoot => 'Raiz';

  @override
  String get tarotPosAdvice => 'Conselho';

  @override
  String get tarotPosTendency => 'Tendência';

  @override
  String get tarotFreeLimitReached =>
      'Você já fez sua tiragem gratuita hoje. Assine Premium para tiragens ilimitadas!';

  @override
  String get tarotSpreadLabel => 'Tiragem';

  @override
  String get tarotReversed => 'invertida';

  @override
  String get tarotBreathe =>
      'Respire fundo, pense na sua pergunta e escolha a tiragem.';

  @override
  String get tarotNewSpread => 'Nova tiragem';

  @override
  String get tarotConsultingCards => 'Consultando as cartas…';

  @override
  String get tarotAdvisorInterpretation =>
      'Interpretação do Conselheiro Místico';

  @override
  String get tarotBestCombo => 'Melhor combo';

  @override
  String get tarotDayStreak => 'Dias seguidos';

  @override
  String get tarotAccuracy => 'Precisão';

  @override
  String tarotAnsweredOf(String answered, String total) {
    return '$answered respondidas · $total cartas no baralho';
  }

  @override
  String get tarotQuizTitle => 'Teste o que você sabe';

  @override
  String get tarotQuizDesc =>
      'Uma sessão com perguntas embaralhadas sobre os significados das cartas. Acertos consecutivos formam combo — volte todos os dias para manter a sequência.';

  @override
  String get tarotQuizStart => 'Sessão de 10 perguntas';

  @override
  String get tarotQuizBrilliant => 'Brilhante! ✨';

  @override
  String get tarotQuizDone => 'Sessão concluída 🌙';

  @override
  String tarotQuizScore(String correct, String total) {
    return 'Você acertou $correct de $total.';
  }

  @override
  String get tarotQuizPraise => ' As cartas reconhecem sua dedicação.';

  @override
  String get tarotQuizEncourage =>
      ' Continue praticando — cada sessão aprofunda a leitura.';

  @override
  String get tarotQuizFinish => 'Concluir';

  @override
  String tarotQuizQuestion(String card) {
    return 'O que representa $card?';
  }

  @override
  @override
  String get palmRemainingToday => 'Leituras restantes hoje';

  @override
  String get palmDailyLimitReached =>
      'Você já fez suas leituras de mãos de hoje. Volte amanhã para mais. ✨';

  @override
  String get palmRateLimit =>
      'Muitas leituras em pouco tempo. Aguarde alguns instantes e envie a foto novamente.';

  String get palmImageTooLarge =>
      'A imagem ficou grande demais. Tente com menos zoom ou outra foto.';

  @override
  String get palmImageTooSmall =>
      'A imagem parece pequena ou escura demais para leitura. Fotografe a palma bem iluminada, preenchendo a tela.';

  @override
  String get palmReadingHeader => 'Leitura de Mãos';

  @override
  String get palmSavedToRecords => 'Leitura salva nos seus Registros! ✨';

  @override
  String get palmistryTitle => 'Quiromancia';

  @override
  String get palmPremiumOnly =>
      'A leitura de mãos é exclusiva do plano Premium.';

  @override
  String get palmHowTo => '🖐️ Como fotografar';

  @override
  String get palmTip1 => 'Palma da mão dominante aberta e relaxada';

  @override
  String get palmTip2 => 'Luz natural, sem sombras fortes sobre as linhas';

  @override
  String get palmTip3 => 'A palma deve preencher quase toda a foto';

  @override
  String get palmTip4 => 'Evite fotos tremidas ou desfocadas';

  @override
  String get palmPrivacyNote =>
      'Privacidade: a foto é processada na hora e descartada — não fica salva no aparelho nem em servidores.';

  @override
  String get palmCamera => 'Câmera';

  @override
  String get palmGallery => 'Galeria';

  @override
  String get palmReadingLines => 'Lendo as linhas da sua mão…';

  @override
  String get palmYourReading => '✨ Sua Leitura';

  @override
  String get palmDisclaimer =>
      'Leitura simbólica para reflexão — não substitui orientação médica, psicológica ou profissional.';

  @override
  String get palmSavedShort => 'Salva nas Reflexões';

  @override
  String get palmSaveReading => 'Salvar leitura';

  @override
  String get numMagicOfNumbers => 'A Magia dos Números';

  @override
  String get numIntro =>
      'Explore os números que vibram na sua vida: seu perfil de nascimento, o significado de qualquer número, as horas espelho e as sequências que insistem em aparecer.';

  @override
  String get numPersonalProfile => 'Perfil Pessoal';

  @override
  String get numPersonalProfileDesc =>
      'Seus 5 números-chave a partir do nome e da data de nascimento';

  @override
  String get numLookupTitle => 'Consultar um Número';

  @override
  String get numLookupDesc =>
      'Um número te acompanha? Descubra o que ele vibra';

  @override
  String get numMirrorHours => 'Horas Espelho';

  @override
  String get numMirrorHoursDesc =>
      'O recado das horas duplas: 11:11, 22:22 e além';

  @override
  String get numSequences => 'Sequências Repetidas';

  @override
  String get numSequencesDesc =>
      'O significado de padrões como 333, 1010 e 1234';

  @override
  String get numWhichNumber => 'Que número te acompanha?';

  @override
  String get numLookupHelp =>
      'Placas, datas, portas, recibos… digite o número e veja sua essência numerológica.';

  @override
  String get numLookupHint => 'Ex.: 713';

  @override
  String get numSee => 'Ver';

  @override
  String numReducesTo(String original, String result) {
    return '$original reduz para $result';
  }

  @override
  String get numMirrorIntro =>
      'Olhou o relógio exatamente numa hora dupla? Cada espelho carrega uma vibração numérica. Toque para ver o recado.';

  @override
  String numVibrationOf(String number) {
    return 'Vibração do número $number';
  }

  @override
  String numMirrorMessage(String label) {
    return 'Recado do espelho $label';
  }

  @override
  String get numSequencesIntro =>
      'Aquele número que aparece em todo lugar pode ser um padrão pedindo atenção. Os clássicos:';

  @override
  String numVibratesIn(String number) {
    return 'vibra no $number';
  }

  @override
  String get numFillNameAndDate =>
      'Informe o nome completo e a data de nascimento';

  @override
  String get numDailyLimit =>
      'Limite diário atingido. Assine Premium para consultas ilimitadas.';

  @override
  String get numYourBirthData => 'Seus dados de nascimento';

  @override
  String get numBirthNameHelp =>
      'Use o nome completo de nascimento — é ele que carrega a assinatura numerológica original.';

  @override
  String get numFullName => 'Nome completo';

  @override
  String get numChooseBirthDate => 'Escolher data de nascimento';

  @override
  String get numBirthPrefix => 'Nascimento';

  @override
  String get numCalculate => 'Calcular meus números';

  @override
  String get numSynthesisQuestion =>
      'Quer uma síntese de como esses números conversam entre si?';

  @override
  String get numWeavingSynthesis => 'Tecendo a síntese…';

  @override
  String get numAdvisorExplanation => 'Explicação do Conselheiro Místico';

  @override
  String get sigilCreateTitle => 'Criar Sigilo';

  @override
  String get sigilWhatIs => 'O que é um Sigilo?';

  @override
  String get sigilWhatIsDesc =>
      'Sigilos são símbolos mágicos criados para manifestar intenções. Ao transformar palavras em símbolos abstratos, você cria uma marca energética que carrega o poder da sua vontade, sem revelar sua intenção para outras pessoas.';

  @override
  String get sigilHowIntro =>
      'Defina sua intenção, escolha uma palavra que a represente, e o app criará automaticamente seu sigilo único.';

  @override
  String get sigilSetIntention => 'Defina sua Intenção';

  @override
  String get sigilIntentionWord => 'Sua palavra de intenção';

  @override
  String get sigilTypeWord => 'Digite uma palavra...';

  @override
  String get sigilOneWordWarning => '⚠️ Use apenas UMA palavra, sem espaços';

  @override
  String get sigilExamplesHeader => '💡 Exemplos de palavras';

  @override
  String get sigilExample1 => 'Prosperidade';

  @override
  String get sigilExample2 => 'Proteção';

  @override
  String get sigilExample3 => 'Cura';

  @override
  String get sigilExample4 => 'Confiança';

  @override
  String get sigilExample5 => 'Intuição';

  @override
  String get sigilWordTip =>
      'Dica: Escolha palavras positivas e específicas que ressoem com você.';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get sigilMagicLetters => 'Letras Mágicas';

  @override
  String get sigilYourLetters => 'Letras do seu Sigilo';

  @override
  String get sigilEssence => 'A essência mágica da sua intenção';

  @override
  String get sigilYourIntention => 'Sua intenção:';

  @override
  String get sigilTransformedInto => 'Transformada em:';

  @override
  String get sigilWhatHappened => 'O que aconteceu?';

  @override
  String get sigilSimplified =>
      'Sua palavra foi simplificada seguindo a tradição dos sigilos:';

  @override
  String get sigilStepAccents => '1. Acentos foram normalizados';

  @override
  String get sigilStepSpaces => '2. Espaços e símbolos foram removidos';

  @override
  String get sigilStepDupes =>
      '3. Letras duplicadas foram eliminadas (mantém apenas a primeira ocorrência)';

  @override
  String get sigilWheelNote =>
      'Esta sequência simplificada será conectada na Roda das Bruxas para formar o símbolo mágico do seu sigilo.';

  @override
  String get sigilSeeDrawing => 'Ver Desenho do Sigilo';

  @override
  String get sigilSaveError => 'Não foi possível salvar o sigilo';

  @override
  String get sigilDrawingNotReady => 'Desenho ainda não está pronto';

  @override
  String get sigilImageError => 'Falha ao gerar a imagem';

  @override
  String get sigilSavedToGallery => 'Sigilo salvo na galeria! ✨';

  @override
  String get sigilGalleryPermission =>
      'Permita o acesso à galeria para salvar o sigilo.';

  @override
  String get sigilImageSaveError => 'Não foi possível salvar a imagem.';

  @override
  String get sigilYourSigil => 'Seu Sigilo';

  @override
  String get sigilYourDrawing => 'Desenho do seu Sigilo';

  @override
  String get sigilLegendStart => 'Início';

  @override
  String get sigilLegendLetters => 'Letras';

  @override
  String get sigilLegendEnd => 'Fim';

  @override
  String get sigilWheel => 'Roda';

  @override
  String get sigilPoints => 'Pontos';

  @override
  String get sigilShuffle => 'Embaralhar letras';

  @override
  String get sigilSaveImage => 'Salvar imagem na galeria';

  @override
  String get sigilRestore => 'Restaurar posições';

  @override
  String get sigilHowToUse => 'Como usar seu sigilo';

  @override
  String get sigilUse1Title => '1. Copie este desenho';

  @override
  String get sigilUse1Desc =>
      'Reproduza o traçado em seu caderno, altar, vela, ou papel ritual.';

  @override
  String get sigilUse2Title => '2. Personalize';

  @override
  String get sigilUse2Desc =>
      'Simplifique, gire, ou adicione detalhes. Torná-lo seu faz parte da magia.';

  @override
  String get sigilUse3Title => '3. Ative o sigilo';

  @override
  String get sigilUse3Desc =>
      'Use em meditação, queime em ritual, ou carregue consigo para focar sua intenção.';

  @override
  String get sigilRemember =>
      'Lembre-se: a magia está na sua intenção e no ato de criar, não apenas no desenho final.';

  @override
  String get commonSaving => 'Salvando...';

  @override
  String get commonFinish => 'Finalizar';

  @override
  String get advisorAskFirst => 'Faça sua pergunta primeiro';

  @override
  String get advisorDailyLimit =>
      'Você já consultou o Conselheiro hoje. Volte amanhã ou seja Premium!';

  @override
  String get advisorGenericError =>
      'O conselheiro não pôde responder agora. Tente novamente mais tarde.';

  @override
  String get advisorRateLimited =>
      'O conselheiro precisa de descanso. Muitos pedidos foram feitos. Por favor, aguarde alguns minutos.';

  @override
  String get advisorTempError =>
      'Erro temporário no serviço místico. Tente novamente em instantes.';

  @override
  String get advisorConnectionError =>
      'Erro de conexão. Verifique sua internet e tente novamente.';

  @override
  String get advisorPortalClosed =>
      'O portal místico está temporariamente fechado. Tente novamente em alguns minutos.';

  @override
  String get advisorWisdomTitle => 'Sabedoria do Conselheiro';

  @override
  String get advisorIntro =>
      'Faça uma pergunta sobre bruxaria, magia ou misticismo, e o conselheiro compartilhará sua sabedoria ancestral 🪄';

  @override
  String get advisorQuestionHint =>
      'Ex: Qual a melhor fase da lua para um ritual de proteção?';

  @override
  String get advisorConsultingStars => 'Consultando os astros...';

  @override
  String get advisorConsult => 'Consultar o Conselheiro';

  @override
  String advisorRemainingToday(String used) {
    return 'Consultas restantes hoje: $used';
  }

  @override
  String get advisorAnswers => 'O Conselheiro responde';

  @override
  String get spellGroupProtection => 'Proteção & Limpeza';

  @override
  String get spellGroupProtectionSub => 'Defesa, banimento e purificação';

  @override
  String get spellGroupLove => 'Amor & Laços';

  @override
  String get spellGroupLoveSub => 'Amor, autoestima e amizade';

  @override
  String get spellGroupProsperity => 'Prosperidade & Caminhos';

  @override
  String get spellGroupProsperitySub => 'Abundância, sorte, trabalho e estudos';

  @override
  String get spellGroupDreams => 'Sonhos & Visões';

  @override
  String get spellGroupDreamsSub => 'Adivinhação, sonhos e sabedoria';

  @override
  String get spellGroupEnergy => 'Energia & Cura';

  @override
  String get spellGroupEnergySub => 'Vitalidade, cura e coragem';

  @override
  String get spellGroupCreation => 'Criação & Palavra';

  @override
  String get spellGroupCreationSub => 'Criatividade e comunicação';

  @override
  String get spellGroupHome => 'Lar & Cotidiano';

  @override
  String get spellGroupHomeSub => 'Casa, família e o dia a dia';

  @override
  String get grimoireSearchSpells => 'Buscar feitiços...';

  @override
  String get grimoireMySpells => 'Meus Feitiços';

  @override
  String get grimoireMySpellsSub => 'Criações e registros pessoais';

  @override
  String get grimoireNoSpellsFound => 'Nenhum feitiço encontrado 🔍';

  @override
  String get grimoireAncestral => 'Ancestral';

  @override
  String get spellNew => 'Novo Feitiço';

  @override
  String get spellEdit => 'Editar Feitiço';

  @override
  String get spellNameLabel => 'Nome do Feitiço *';

  @override
  String get spellNameHint => 'Ex: Proteção de Lar';

  @override
  String get commonRequired => 'Campo obrigatório';

  @override
  String get spellPurposeLabel => 'Propósito *';

  @override
  String get spellPurposeHint => 'Ex: Proteção, Amor Próprio, Prosperidade';

  @override
  String get spellTypeLabel => 'Tipo de Feitiço *';

  @override
  String get spellCategoryLabel => 'Categoria *';

  @override
  String get spellMoonPhaseLabel => 'Fase da Lua (Opcional)';

  @override
  String get commonNone => 'Nenhuma';

  @override
  String get spellIngredientsLabel => 'Ingredientes';

  @override
  String get spellIngredientsHint => 'Digite um ingrediente por linha';

  @override
  String get spellHowToLabel => 'Como Realizar *';

  @override
  String get spellHowToHint => 'Descreva os passos do ritual';

  @override
  String get spellDurationLabel => 'Duração (em dias)';

  @override
  String get spellDurationHint => 'Ex: 3';

  @override
  String get spellNotesLabel => 'Observações';

  @override
  String get spellNotesHint => 'Resultados, sensações, anotações...';

  @override
  String get spellAdd => 'Adicionar Feitiço';

  @override
  String get spellFilterByCategory => 'Filtrar por categoria';

  @override
  String get spellAllCategories => 'Todas Categorias';

  @override
  String get spellSourceAll => 'Todos';

  @override
  String get spellSourceMine => 'Meus';

  @override
  String get spellSourceAncestral => 'Ancestrais';

  @override
  String get spellLoading => 'Carregando feitiços...';

  @override
  String get spellNoneFound => 'Nenhum feitiço encontrado';

  @override
  String get spellNoAncestral => 'Nenhum feitiço ancestral disponível';

  @override
  String get spellEmptyGrimoire =>
      'Seu grimório está vazio.\nComece adicionando seu primeiro feitiço!';

  @override
  String get spellMoonPrefix => 'Lua';

  @override
  String get spellSavedToGrimoire => 'Feitiço salvo no seu grimório! ✨';

  @override
  String get spellDetails => 'Detalhes';

  @override
  String get spellSaveToGrimoire => 'Salvar no Grimório';

  @override
  String get spellRecommendedMoon => 'Fase Lunar Recomendada';

  @override
  String get spellHowTo => 'Como Realizar';

  @override
  String spellDurationDays(String duration) {
    return 'Duração: $duration';
  }

  @override
  String get spellDay => 'dia';

  @override
  String get spellDays => 'dias';

  @override
  String spellCreatedAt(String date) {
    return 'Criado em: $date';
  }

  @override
  String spellUpdatedAt(String date) {
    return 'Atualizado em: $date';
  }

  @override
  String spellDeleteConfirm(String name) {
    return 'Deseja realmente excluir o feitiço \"$name\"?';
  }

  @override
  String get recordDetails => 'Registro';

  @override
  String get recordEditTitle => 'Editar Registro';

  @override
  String get recordTitleLabel => 'Título *';

  @override
  String get recordContentLabel => 'Sua página';

  @override
  String get recordTitleRequired => 'Dê um título ao registro';

  @override
  String get recordContentRequired => 'Escreva algo antes de salvar';

  @override
  String get recordUpdated => 'Registro atualizado! ✨';

  @override
  String recordDeleteConfirm(String name) {
    return 'Deseja realmente excluir o registro \"$name\"?';
  }

  @override
  String get aiSpellDescribeFirst => 'Descreva sua intenção primeiro';

  @override
  String get aiSpellDailyLimit =>
      'Você atingiu o limite diário de consultas. Volte amanhã ou seja Premium!';

  @override
  String get aiSpellGenericError =>
      'O conselheiro não pôde manifestar o feitiço. Tente novamente mais tarde.';

  @override
  String get aiSpellDescribeIntention => 'Descreva sua Intenção';

  @override
  String get aiSpellIntentionHelp =>
      'Compartilhe o que você deseja manifestar. Quanto mais detalhes, mais poderoso será o feitiço!';

  @override
  String get aiSpellIntentionHint =>
      'Ex: Quero atrair prosperidade financeira para pagar minhas contas e ter mais tranquilidade';

  @override
  String get aiSpellManifesting => 'Manifestando...';

  @override
  String get aiSpellManifest => 'Manifestar Feitiço ✨';

  @override
  String get aiSpellSeeDetails => 'Ver Detalhes';

  @override
  String get learnUnlockPrevious =>
      'Complete a lição anterior para destravar esta.';

  @override
  String learnLessonN(String number, String title) {
    return 'Lição $number — $title';
  }

  @override
  String learnPageWritten(String title) {
    return 'Página escrita: \"$title\"';
  }

  @override
  String get learnPremiumLesson => 'Lição Premium';

  @override
  String learnCreatesPage(String title) {
    return 'Cria a página: \"$title\"';
  }

  @override
  String get learnToFill => '(a preencher)';

  @override
  String learnPageNote(String trail, String lesson) {
    return 'Página do Grimório Vivo — $trail · $lesson';
  }

  @override
  String get learnTrailBound => 'Trilha Encadernada!';

  @override
  String get learnPageDone => 'Página escrita!';

  @override
  String learnChapterBound(String title) {
    return 'O capítulo \"$title\" agora é um livro encadernado no seu grimório — escrito por você.';
  }

  @override
  String get learnNewTitle => 'Novo título';

  @override
  String get learnSoBeIt => 'Que assim seja ✨';

  @override
  String get learnPracticeGoal => 'Objetivo';

  @override
  String get learnPracticeHow => 'Como fazer';

  @override
  String get learnPracticeThen => 'Depois da prática';

  @override
  String get learnStepTeaching => '📜 Ensino';

  @override
  String get learnStepPractice => '🕯️ Prática';

  @override
  String get learnStepPage => '✍️ A Página';

  @override
  String get learnGoToPractice => 'Ir para a prática';

  @override
  String get learnDidPractice => 'Fiz a prática (ou vou fazer hoje)';

  @override
  String get learnWriteMyPage => 'Escrever minha página';

  @override
  String get learnAnswerHelp =>
      'Responda com as suas palavras — o app monta a página e guarda no Meu Grimório. Ela é sua para sempre.';

  @override
  String get learnPageTitleLabel => 'Título da página';

  @override
  String get learnWriteHere => 'Escreva aqui…';

  @override
  String get learnSealPage => 'Selar página no grimório';

  @override
  String get learnHomeTitle => 'Aprenda escrevendo o seu grimório';

  @override
  String get learnHomeSubtitle =>
      'Cada lição termina com uma página criada por você no Meu Grimório. Ao completar uma trilha, o capítulo é seu — escrito de próprio punho.';

  @override
  String get learnMaxTitle => 'Título máximo alcançado ✨';

  @override
  String learnNextTitle(String pages, String title, String xp) {
    return '$pages páginas escritas · próximo título: $title ($xp XP)';
  }

  @override
  String get learnBoundShort => 'Encadernada!';

  @override
  String learnPagesProgress(String done, String total) {
    return '$done/$total páginas';
  }

  @override
  String learnBoundVolume(String count) {
    return '📕 Volume encadernado — $count páginas escritas por você';
  }

  @override
  String get oracleDailyLimit =>
      'Você atingiu o limite diário de leituras. Volte amanhã ou seja Premium!';

  @override
  String get oracleTitle => 'Cartas do Oráculo';

  @override
  String get oracleSubtitle => 'Receba orientação e mensagens do universo';

  @override
  String get oracleDrawing => 'Tirando cartas...';

  @override
  String get oracleDraw => 'Tirar Cartas';

  @override
  String oracleRemainingToday(String used) {
    return 'Leituras restantes hoje: $used';
  }

  @override
  String get oracleNewReading => 'Nova Leitura';

  @override
  String get oracleYourReading => 'Sua Leitura';

  @override
  String get pendulumUsedAll =>
      'Você já usou suas 3 consultas de hoje. Volte amanhã!';

  @override
  String get pendulumAskFirst => 'Faça uma pergunta primeiro';

  @override
  String get pendulumTitle => 'Pêndulo';

  @override
  String get pendulumConsult => 'Consultar o Pêndulo';

  @override
  String get pendulumIntro =>
      'Faça perguntas de sim ou não. Concentre-se e confie na resposta.';

  @override
  String get pendulumUnlimitedAdmin => 'Consultas ilimitadas (Admin)';

  @override
  String pendulumUsedComeBack(String used, String total) {
    return 'Consultas usadas ($used/$total) - volte amanhã';
  }

  @override
  String get pendulumYourQuestion => 'Sua Pergunta';

  @override
  String get pendulumQuestionHint => 'Ex: Devo aceitar aquele emprego?';

  @override
  String get pendulumAsking => 'Consultando...';

  @override
  String get pendulumAsk => 'Perguntar';

  @override
  String get pendulumNewConsult => 'Nova Consulta';

  @override
  String get pendulumYes => 'SIM';

  @override
  String get pendulumNo => 'NÃO';

  @override
  String get pendulumMaybe => 'TALVEZ';

  @override
  String get runesNoQuestion => 'Sem pergunta';

  @override
  String get runesReadingTitle => 'Leitura de Runas';

  @override
  String get runesReadingIntro =>
      'As runas são símbolos do alfabeto rúnico nórdico usado para adivinhação. Cada runa pode aparecer em posição normal ou invertida (quando aplicável), mudando seu significado.';

  @override
  String get runesReversedNote =>
      'Runas Invertidas: Quando uma runa aparece de cabeça para baixo, geralmente indica bloqueios ou aspectos desafiadores do significado original.';

  @override
  String get runesChooseLayout => 'Escolha um Layout';

  @override
  String get runesQuestionOptional => 'Sua Pergunta (opcional)';

  @override
  String get runesQuestionHint => 'O que as runas devem revelar?';

  @override
  String get runesDrawing => 'Tirando runas...';

  @override
  String get runesDraw => 'Tirar Runas';

  @override
  String get runesReversed => 'Invertida';

  @override
  String get runesListTitle => 'Runas';

  @override
  String get runesAbout => 'Sobre as Runas';

  @override
  String get runesAboutText =>
      'As runas são um alfabeto antigo usado pelos povos germânicos e nórdicos. Além de escrita, cada runa carrega significados simbólicos profundos e pode ser usada para reflexão, autoconhecimento e leitura oracular.';

  @override
  String get runesExplore =>
      'Explore as 24 runas do Futhark Antigo abaixo. Toque em cada uma para conhecer seu significado.';

  @override
  String get runesElderFuthark => 'Futhark Antigo';

  @override
  String get runesKeywords => 'Palavras-chave';

  @override
  String get runesMeaning => 'Significado';

  @override
  String get runesRemember =>
      'Lembre-se: as runas são ferramentas de reflexão e autoconhecimento. Use-as como um ponto de partida para explorar suas próprias percepções e intuições.';

  @override
  String get astroMysticTitle => 'Astrologia Mística';

  @override
  String get astroMysticSubtitle =>
      'Seu mapa astral e perfil mágico personalizado';

  @override
  String get astroZodiacSigns => 'Signos do Zodíaco';

  @override
  String get astroZodiacSignsDesc =>
      'Conheça os 12 signos e seus significados mágicos';

  @override
  String get astroBirthChart => 'Mapa Astral';

  @override
  String get astroSeeChart => 'Ver seu mapa astral completo';

  @override
  String get astroCreateChart => 'Criar seu mapa astral';

  @override
  String get astroMagicMirror => 'Espelho mágico';

  @override
  String get astroMagicalProfile => 'Perfil Mágico';

  @override
  String get astroMagicalProfileDesc =>
      'Interpretação astrológica para bruxaria';

  @override
  String get astroDailyWeather => 'Clima Mágico Diário';

  @override
  String get astroDailyWeatherDesc => 'Trânsitos planetários e energia do dia';

  @override
  String get astroSuggestions => 'Sugestões Personalizadas';

  @override
  String get astroSuggestionsDesc => 'Práticas baseadas nos seus trânsitos';

  @override
  String get astroRecalculate => 'Recalcular Mapa';

  @override
  String get astroRecalculateDesc => 'Criar novo mapa astral';

  @override
  String get astroAbout => 'Sobre a Astrologia';

  @override
  String get astroAboutText =>
      'Seu mapa astral é calculado com base na posição dos planetas no momento e local do seu nascimento. O perfil mágico interpreta essas posições de forma específica para práticas de bruxaria.';

  @override
  String get astroHaveOnHand => 'Para melhores resultados, tenha em mãos:';

  @override
  String get astroBirthDate => 'Data de nascimento';

  @override
  String get astroBirthTime => 'Hora exata de nascimento';

  @override
  String get astroBirthPlace => 'Local de nascimento (cidade e país)';

  @override
  String get astroRecalcTitle => 'Recalcular Mapa Astral?';

  @override
  String get astroRecalcConfirm =>
      'Isso irá substituir seu mapa astral atual. Você tem certeza?';

  @override
  String get chartInvalidDate => 'Data inválida';

  @override
  String get chartInvalidTime => 'Hora inválida';



  @override
  String get chartPlaceNotFound => 'Local não encontrado';

  @override
  String get chartCalcError => 'Erro ao calcular mapa';

  @override
  String get chartCreateTitle => 'Criar Mapa Astral';

  @override
  String get chartYourChart => 'Seu Mapa Astral';

  @override
  String get chartIntro =>
      'Para calcular seu mapa natal preciso, precisamos de sua data, hora e local de nascimento. Quanto mais preciso, melhor!';

  @override
  String get chartBirthDate => 'Data de Nascimento';

  @override
  String get chartDateFormat => 'Digite no formato dd/mm/aaaa';

  @override
  String get chartDateHint => 'dd/mm/aaaa';

  @override
  String get chartBirthTime => 'Hora de Nascimento';

  @override
  String get chartTimeImportant =>
      'A hora exata é importante para calcular o Ascendente e as Casas.';

  @override
  String get chartDontKnowTime => 'Não sei a hora exata';

  @override
  String get chartBirthPlace => 'Local de Nascimento';

  @override
  String get chartTypeToSearch => 'Digite pelo menos 3 caracteres para buscar';

  @override
  String get chartPlaceHint => 'Ex: São Paulo, Brasil';

  @override
  String get chartCalculate => 'Calcular Mapa Astral ✨';

  @override
  String get chartNoonNote =>
      'Sem a hora exata, usaremos meio-dia (12:00) e o sistema de casas iguais.';

  @override
  String get settingsLanguageSubtitle => 'Escolha manualmente o idioma do app';

  @override
  String get quizTitle => 'Teste de Arquétipo';

  @override
  String quizProgress(String current, String total) {
    return '$current de $total';
  }

  @override
  String get quizYourArchetypeIs => 'Seu arquétipo é';

  @override
  String get quizSeeInEncyclopedia => 'Ver na Enciclopédia';

  @override
  String get quizRetake => 'Refazer o teste';

  @override
  String get quizStrongestEnergies => 'Suas energias mais fortes';

  @override
  String get quizMirrorNote =>
      'Arquétipos são espelhos, não gavetas: você carrega vários — este é o que vibra mais alto em você agora. Explore os outros na aba Arquétipos da Enciclopédia.';

  @override
  String quizSavedOn(String date) {
    return 'Resultado do seu último teste ($date)';
  }

  @override
  String get tarotLibraryTitle => 'Biblioteca de Cartas';

  @override
  String get tarotTutorTitle => 'Tutor de Tarot';

  @override
  String get tarotLibraryDesc =>
      'As 78 cartas com imagem, significado e leitura invertida';

  @override
  String get tarotFlipCard => 'Inverter carta';

  @override
  String get tarotUnflipCard => 'Posição normal';

  @override
  String get tarotUprightMeaning => 'Significado';

  @override
  String get tarotReversedMeaning => 'Significado invertido';

  @override
  String get grimoireMyRecords => 'Meus Registros';

  @override
  String get grimoireMyRecordsSub =>
      'Páginas do Grimório Vivo, estudos e reflexões';

  @override
  String get grimoireNoRecords =>
      'Suas páginas do Grimório Vivo e registros aparecerão aqui.';

  @override
  String get learnFillAtLeastOne =>
      'Responda pelo menos uma pergunta antes de selar a página';

  @override
  String learnOpenTool(String tool) {
    return 'Abrir $tool';
  }

  @override
  String get learnToolHint =>
      'Esta lição usa uma ferramenta do app — abra por aqui e depois volte para escrever a página.';

  @override
  String learnSavesTo(String place) {
    return 'Esta página será guardada em: $place';
  }

  @override
  String get learnPlaceDreams => 'Diário de Sonhos';

  @override
  String get learnPlaceGratitude => 'Diário de Gratidão';

  @override
  String get learnPlaceAffirmations => 'Afirmações';

  @override
  String get learnPlaceDesires => 'Diário de Desejos';

  @override
  String get learnSection1 => 'Fundamento';

  @override
  String get learnSection2 => 'Aprofundando';

  @override
  String get learnSection3 => 'Na prática';

  @override
  String get learnSection4 => 'Para levar consigo';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Grimório de Bolso';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Sistema / português do Brasil';

  @override
  String get settingsLanguagePortuguese => 'Português (Brasil)';

  @override
  String get settingsLanguageEnglish => 'Inglês';

  @override
  String get settingsLanguageSpanish => 'Espanhol';

  @override
  String settingsLanguageChanged(String language) {
    return 'Idioma alterado para $language';
  }

  @override
  String get homeTitle => 'Início';

  @override
  String get grimoireTitle => 'Grimório';

  @override
  String get diaryTitle => 'Diário';

  @override
  String get authLogin => 'Entrar';

  @override
  String get authSignup => 'Criar conta';

  @override
  String get premiumTitle => 'Premium';

  @override
  String get encyclopediaTitle => 'Enciclopédia';

  @override
  String get toolsTitle => 'Ferramentas';

  @override
  String get errorsGeneric => 'Algo deu errado. Tente novamente.';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }

  @override
  String get navEncyclopedia => 'Grimório';

  @override
  String get navGrimoire => 'Ferramentas';

  @override
  String get navDiaries => 'Diários';

  @override
  String get grimoirePageTitle => 'Ferramentas';

  @override
  String get grimoireTabAstrology => 'Astrologia Mística';

  @override
  String get grimoireTabTools => 'Ferramentas Mágicas';

  @override
  String get grimoireTabMyGrimoire => 'Meu Grimório';

  @override
  String get encyMyGrimoireIntro => 'Seus feitiços, reunidos por intenção — crie, guarde e revisite a sua magia';

  @override
  String get diaryPageTitle => 'Diários';

  @override
  String get diaryTabGratitude => 'Gratidão';

  @override
  String get diaryTabAffirmations => 'Afirmações';

  @override
  String get diaryTabDreams => 'Sonhos';

  @override
  String get diaryTabDesires => 'Desejos';

  @override
  String get encyclopediaPageTitle => 'Grimório';

  @override
  String get encyTabMoon => 'Lua';

  @override
  String get encyTabSabbats => 'Sabbats';

  @override
  String get encyTabCrystals => 'Cristais';

  @override
  String get encyTabHerbs => 'Ervas';

  @override
  String get encyTabMetals => 'Metais';

  @override
  String get encyTabColors => 'Cores';

  @override
  String get encyTabGoddesses => 'Deusas';

  @override
  String get encyTabElements => 'Elementos';

  @override
  String get encyTabAltar => 'Altar';

  @override
  String get encyTabRunes => 'Runas';

  @override
  String get encyTabArchetypes => 'Arquétipos';

  @override
  String get encyTabAngels => 'Anjos';

  @override
  String get encyTabDemons => 'Demônios';

  @override
  String get encyTabSymbols => 'Símbolos';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonBackAgainToExit => 'Toque em voltar novamente para sair';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get toolsHeaderTitle => 'Ferramentas Mágicas';

  @override
  String get toolsHeaderSubtitle =>
      'Recursos para auxiliar em suas práticas de magia e manifestação';

  @override
  String get toolMysticAdvisorTitle => 'Conselheiro Místico';

  @override
  String get toolMysticAdvisorDesc =>
      'Sabedoria ancestral para suas dúvidas de bruxaria e magia';

  @override
  String get toolOracleTitle => 'Cartas do Oráculo';

  @override
  String get toolOracleDesc => 'Mensagens e orientação do universo';

  @override
  String get toolSigilsTitle => 'Sigilos';

  @override
  String get toolSigilsDesc => 'Crie símbolos mágicos para suas intenções';

  @override
  String get toolNumerologyTitle => 'Numerologia';

  @override
  String get toolNumerologyDesc =>
      'Seus números-chave, horas espelho e sequências';

  @override
  String get toolRunesTitle => 'Leitura de Runas';

  @override
  String get toolRunesDesc => 'Consulte as antigas runas nórdicas';

  @override
  String get toolPendulumTitle => 'Pêndulo';

  @override
  String get toolPendulumDesc => 'Perguntas de sim ou não';

  @override
  String get toolLivingGrimoireTitle => 'Grimório Vivo';

  @override
  String get toolLivingGrimoireDesc =>
      'Trilhas de aprendizado: cada lição vira uma página sua';

  @override
  String get toolTarotTitle => 'Tarot';

  @override
  String get toolTarotDesc => 'Tiragens, carta do dia e tutor de aprendizado';

  @override
  String get toolArchetypeTitle => 'Teste de Arquétipo';

  @override
  String get toolArchetypeDesc =>
      'Descubra qual arquétipo vibra mais alto em você';

  @override
  String get toolPalmistryTitle => 'Leitura de Mãos';

  @override
  String get toolPalmistryDesc => 'Quiromancia pela palma da sua mão';

  @override
  String get commonClose => 'Fechar';

  @override
  String get premiumBePremium => 'Seja Premium';

  @override
  String get premiumUnlock => 'Desbloquear Premium';

  @override
  String get premiumContentLabel => 'Conteúdo Premium';

  @override
  String get premiumUpgradeAction => 'Upgrade';

  @override
  String get premiumPlansUnavailable =>
      'Os planos estão temporariamente indisponíveis';

  @override
  String get premiumActivated => 'Premium ativado com sucesso!';

  @override
  String get premiumPurchaseFailed => 'Não foi possível concluir a compra';

  @override
  String get premiumHeroAccess => 'ACESSE';

  @override
  String get premiumHeroPower => 'TODO O PODER';

  @override
  String get premiumHeroMagic => 'DA SUA MAGIA';

  @override
  String get premiumHeroTagline1 =>
      'Mais conhecimento, mais orientação e mais ';

  @override
  String get premiumHeroTaglineHighlight => 'conexão';

  @override
  String get premiumHeroTagline2 => ' com o seu caminho';

  @override
  String get premiumCatSemantic => 'Gato mágico do Grimório de Bolso';

  @override
  String get premiumBenefitAdvisor => 'Conselheiro Místico ilimitado';

  @override
  String get premiumBenefitEncyclopedia =>
      'Enciclopédia com conteúdos completos';

  @override
  String get premiumBenefitDailyClimate => 'Clima Mágico Diário personalizado';

  @override
  String get premiumBenefitUnlimitedReadings =>
      'Leituras ilimitadas de Runas, Oráculo e Sigilos';

  @override
  String get premiumBenefitCloudSync => 'Sincronização entre dispositivos';

  @override
  String get premiumPlanMonthly => 'Mensal';

  @override
  String get premiumPlanYearly => 'Anual';

  @override
  String get premiumPerMonth => '/mês';

  @override
  String get premiumPerYear => '/ano';

  @override
  String get premiumSave33 => 'Economize 33%';

  @override
  String get premiumTagSelected => 'SELECIONADO';

  @override
  String get premiumTagPopular => 'POPULAR';

  @override
  String premiumPlanSemantics(String title, String price, String period) {
    return 'Plano $title, $price $period';
  }

  @override
  String get premiumStartNow => 'Começar Agora';

  @override
  String get premiumCancelAnytime => 'Cancele a qualquer momento';

  @override
  String get premiumSecurePayment => 'Pagamento seguro';

  @override
  String get premiumDataProtected => 'Seus dados protegidos';

  @override
  String get authWelcomeBack => 'Bem-vinda de volta!';

  @override
  String get authLoginSubtitle => 'Entre para acessar seu grimório';

  @override
  String get authForgotPassword => 'Esqueci minha senha';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'seu@email.com';

  @override
  String get authEmailRequired => 'Por favor, insira seu email';

  @override
  String get authEmailInvalid => 'Por favor, insira um email válido';

  @override
  String get authPasswordLabel => 'Senha';

  @override
  String get authPasswordRequired => 'Por favor, insira sua senha';

  @override
  String get authPasswordMinLength =>
      'A senha deve ter pelo menos 6 caracteres';

  @override
  String get authOrContinueWith => 'ou continue com';

  @override
  String get authNoAccount => 'Não tem uma conta? ';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authSystemNotConfigured =>
      'Sistema de autenticação não configurado. Entre em contato com o suporte.';

  @override
  String get authLoginError => 'Erro ao fazer login';

  @override
  String get authSocialUnavailable => 'Login social não disponível no momento';

  @override
  String get authGoogleError => 'Erro no login com Google';

  @override
  String get authSignupSubtitle => 'Inicie sua jornada mágica';

  @override
  String get authNameLabel => 'Nome';

  @override
  String get authNameHint => 'Seu nome mágico';

  @override
  String get authNameRequired => 'Por favor, insira seu nome';

  @override
  String get authNameMinLength => 'O nome deve ter pelo menos 2 caracteres';

  @override
  String get authPasswordHintMin => 'Mínimo 6 caracteres';

  @override
  String get authPasswordCreateRequired => 'Por favor, insira uma senha';

  @override
  String get authConfirmPasswordLabel => 'Confirmar Senha';

  @override
  String get authConfirmPasswordHint => 'Digite a senha novamente';

  @override
  String get authConfirmPasswordRequired => 'Por favor, confirme sua senha';

  @override
  String get authPasswordsDontMatch => 'As senhas não coincidem';

  @override
  String get authTermsPrefix => 'Li e aceito os ';

  @override
  String get authTermsOfUse => 'Termos de Uso';

  @override
  String get authTermsAnd => ' e a ';

  @override
  String get authPrivacyPolicy => 'Política de Privacidade';

  @override
  String get authOrSignupWith => 'ou cadastre-se com';

  @override
  String get authHaveAccount => 'Já tem uma conta? ';

  @override
  String get authMustAcceptTerms => 'Você precisa aceitar os termos de uso';

  @override
  String get authSignupError => 'Erro ao criar conta';

  @override
  String get authEmailInUse => 'Este email já está em uso';

  @override
  String get authEmailInvalidShort => 'Email inválido';

  @override
  String get authSignupSuccess =>
      'Conta criada com sucesso! Bem-vinda ao Grimório!';

  @override
  String get authGoogleSignupUnavailable =>
      'Cadastro com Google não disponível no momento';

  @override
  String get authGoogleSignupError => 'Erro no cadastro com Google';

  @override
  String get welcomeSubtitle => 'Sua jornada mágica começa aqui';

  @override
  String get welcomeFeatureLunar => 'Calendário Lunar';

  @override
  String get welcomeFeatureGrimoire => 'Grimório Digital';

  @override
  String get welcomeFeatureDiaries => 'Diários Mágicos';

  @override
  String get welcomeFeatureAstrology => 'Astrologia';

  @override
  String get welcomeHaveAccount => 'Já tenho conta';

  @override
  String get forgotEmailSent => 'Email Enviado!';

  @override
  String forgotEmailSentTo(String email) {
    return 'Enviamos um link de recuperação para\n$email';
  }

  @override
  String get forgotCheckInbox => 'Verifique sua caixa de entrada e spam.';

  @override
  String get forgotBackToLogin => 'Voltar ao Login';

  @override
  String get forgotResend => 'Não recebeu? Enviar novamente';

  @override
  String get forgotTitle => 'Esqueceu a senha?';

  @override
  String get forgotSubtitle =>
      'Sem problemas! Digite seu email e enviaremos um link para criar uma nova senha.';

  @override
  String get forgotSendLink => 'Enviar Link de Recuperação';

  @override
  String get forgotRemembered => 'Lembrou a senha? ';

  @override
  String get forgotBackToLoginLower => 'Voltar ao login';

  @override
  String get forgotSendError => 'Erro ao enviar email';

  @override
  String get forgotResendError => 'Erro ao reenviar email';

  @override
  String get forgotResendSuccess => 'Email reenviado com sucesso!';

  @override
  String get forgotResendErrorPrefix => 'Erro ao reenviar';

  @override
  String get authShowPassword => 'Mostrar senha';

  @override
  String get authHidePassword => 'Ocultar senha';

  @override
  String forgotResendIn(int seconds) {
    return 'Reenviar em ${seconds}s';
  }

  @override
  String get changePasswordTitle => 'Alterar Senha';

  @override
  String get changePasswordHeader => 'Nova Senha';

  @override
  String get changePasswordSubtitle =>
      'Digite sua senha atual e escolha uma nova senha';

  @override
  String get changePasswordCurrentLabel => 'Senha Atual';

  @override
  String get changePasswordCurrentRequired =>
      'Por favor, insira sua senha atual';

  @override
  String get changePasswordNewLabel => 'Nova Senha';

  @override
  String get changePasswordNewRequired => 'Por favor, insira uma nova senha';

  @override
  String get changePasswordMustDiffer =>
      'A nova senha deve ser diferente da atual';

  @override
  String get changePasswordConfirmLabel => 'Confirmar Nova Senha';

  @override
  String get changePasswordConfirmHint => 'Digite a nova senha novamente';

  @override
  String get changePasswordConfirmRequired =>
      'Por favor, confirme sua nova senha';

  @override
  String get changePasswordError => 'Erro ao alterar senha';

  @override
  String get changePasswordSuccess => 'Senha alterada com sucesso!';

  @override
  String get changePasswordWrongCurrent => 'Senha atual incorreta';

  @override
  String get profileTitle => 'Meu Perfil';

  @override
  String get profileAnonymous => 'Bruxa Anônima';

  @override
  String get profileEditName => 'Editar Nome';

  @override
  String get profileFreePlan => 'Plano Gratuito';

  @override
  String get profilePremiumPlan => 'Plano Premium';

  @override
  String get profileFreePlanDesc => 'Algumas funcionalidades são limitadas';

  @override
  String get profilePremiumPlanDesc =>
      'Acesso completo a todas as funcionalidades';

  @override
  String get profileUpgrade => 'Fazer Upgrade';

  @override
  String get profileFreeUsage => 'Uso do Plano Gratuito';

  @override
  String get profileSpells => 'Feitiços';

  @override
  String get profileDiaryEntries => 'Entradas de Diário';

  @override
  String get profileThisMonth => 'este mês';

  @override
  String get profileMysticAdvisor => 'Conselheiro Místico';

  @override
  String get profileToday => 'hoje';

  @override
  String get profileEditProfile => 'Editar Perfil';

  @override
  String get profileManageSubscription => 'Gerenciar Assinatura';

  @override
  String get profileMagicalStats => 'Estatísticas Mágicas';

  @override
  String get profileMagicalJourneys => 'Jornadas Mágicas';

  @override
  String get profileNotifications => 'Notificações';

  @override
  String get profileHelpSupport => 'Ajuda & Suporte';

  @override
  String get profileAboutApp => 'Sobre o App';

  @override
  String get profileLogout => 'Sair da Conta';

  @override
  String get profileLogoutConfirm =>
      'Tem certeza que deseja sair?\nSeus dados locais serão mantidos.';

  @override
  String get profileLogoutAction => 'Sair';

  @override
  String get profileNotificationsSoon =>
      'As configurações de notificações estarão disponíveis em breve!\n\nVocê poderá personalizar alertas para:\n• Lembretes de rituais\n• Fases da lua\n• Datas mágicas especiais';

  @override
  String get profileSupportEmail => 'Email de Suporte';

  @override
  String get profileFaq => 'Perguntas frequentes';

  @override
  String get profilePrivacySafe => 'Seus dados estão seguros';

  @override
  String aboutVersion(String version, String build) {
    return 'Versão $version ($build)';
  }

  @override
  String get aboutDescription =>
      'Seu companheiro para práticas mágicas, rituais e autoconhecimento através da astrologia e bruxaria moderna.';

  @override
  String get aboutMadeWith => 'Desenvolvido com 🔮 e ✨';

  @override
  String get editBasicInfo => 'Informações Básicas';

  @override
  String get editNameUpdated => 'Nome atualizado!';

  @override
  String get editGenderSection => 'Gênero';

  @override
  String get editGenderHelp =>
      'Como o app deve se dirigir a você? Usamos essa escolha nos textos personalizados e nas respostas do Conselheiro Místico.';

  @override
  String get editSecurity => 'Segurança';

  @override
  String get editChangePasswordSubtitle => 'Modificar sua senha de acesso';

  @override
  String get editDataCollection => 'Coleta de Dados';

  @override
  String get editAnalytics => 'Analytics';

  @override
  String get editAnalyticsSubtitle =>
      'Ajude a melhorar o app compartilhando dados de uso anônimos';

  @override
  String get editCrashReports => 'Relatórios de Erro';

  @override
  String get editCrashReportsSubtitle =>
      'Enviar relatórios automáticos quando o app tiver problemas';

  @override
  String get editPersonalizedContent => 'Conteúdo Personalizado';

  @override
  String get editPersonalizedContentSubtitle =>
      'Receber sugestões baseadas no seu uso do app';

  @override
  String get editSyncBackup => 'Sincronização e Backup';

  @override
  String get editSyncBackupCloud => 'Sincronização e Backup na Nuvem';

  @override
  String get editSyncBackupOn =>
      'Manter seus dados protegidos e sincronizados entre dispositivos';

  @override
  String get editSyncPremiumOnly => 'Recurso exclusivo Premium';

  @override
  String get editManageData => 'Gerenciar Seus Dados';

  @override
  String get editExportData => 'Exportar Meus Dados';

  @override
  String get editExportDataSubtitle =>
      'Baixar uma cópia de todos os seus dados';

  @override
  String get editClearLocal => 'Limpar Dados Locais';

  @override
  String get editClearLocalSubtitle => 'Remover dados salvos neste dispositivo';

  @override
  String get editDeleteAccount => 'Excluir Minha Conta';

  @override
  String get editDeleteAccountSubtitle =>
      'Remover permanentemente todos os seus dados';

  @override
  String get genderFeminine => 'Feminino';

  @override
  String get genderMasculine => 'Masculino';

  @override
  String get genderNeutral => 'Neutro';

  @override
  String get editNotInformed => 'Não informado';

  @override
  String get editPrivacyMatters => 'Sua Privacidade Importa';

  @override
  String get editPrivacyNote =>
      'Seus dados mágicos são sagrados. Nunca vendemos suas informações pessoais e você tem controle total sobre o que é coletado e armazenado.';

  @override
  String get editNewPasswordMin =>
      'A nova senha deve ter pelo menos 6 caracteres';

  @override
  String get editErrorPrefix => 'Erro';

  @override
  String get editChangeAction => 'Alterar';

  @override
  String get editExportTitle => 'Exportar Dados';

  @override
  String get editExportConfirm =>
      'Seus dados serão exportados em formato JSON. Isso pode levar alguns segundos.';

  @override
  String get editExportAction => 'Exportar';

  @override
  String get editExporting => 'Exportando dados...';

  @override
  String get editExportSuccess => 'Dados exportados com sucesso!';

  @override
  String get editExportError => 'Erro ao exportar';

  @override
  String get editClearLocalTitle => 'Limpar Dados Locais?';

  @override
  String get editClearLocalConfirm =>
      'Isso removerá todos os dados salvos neste dispositivo. Se você tem sincronização ativada, seus dados na nuvem serão mantidos.';

  @override
  String get editClearAction => 'Limpar';

  @override
  String get editClearSuccess => 'Dados locais removidos com sucesso';

  @override
  String get editClearError => 'Erro ao limpar dados';

  @override
  String get editDeleteTitle => 'Excluir Conta';

  @override
  String get editDeleteWarning =>
      'ATENÇÃO: Esta ação é IRREVERSÍVEL!\n\nTodos os seus dados serão permanentemente excluídos, incluindo:\n- Feitiços e rituais\n- Entradas de diário\n- Mapa astral\n- Configurações\n\nTem certeza absoluta?';

  @override
  String get editDeletePermanently => 'Excluir Permanentemente';

  @override
  String get editDeleting => 'Excluindo conta...';

  @override
  String get editDeleteError => 'Erro ao deletar conta';

  @override
  String get editDeleteSuccess => 'Conta excluída com sucesso';

  @override
  String get editDeleteErrorPrefix => 'Erro ao excluir conta';

  @override
  String get editPremiumFeature => 'Recurso Premium';

  @override
  String get editSyncPremiumPitch =>
      'A sincronização de dados na nuvem é um recurso exclusivo para usuários Premium.\n\nCom o Premium, seus dados ficam sempre seguros e sincronizados entre todos os seus dispositivos.';

  @override
  String get editNotNow => 'Agora Não';

  @override
  String get settingsLifetime => 'Assinatura Vitalícia';

  @override
  String settingsRenewsOn(String date) {
    return 'Renova em: $date';
  }

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsPrivacy => 'Privacidade';

  @override
  String get settingsNotifDesc =>
      'Configure lembretes para eventos mágicos importantes';

  @override
  String get settingsFullMoon => 'Lua Cheia';

  @override
  String get settingsFullMoonDesc => 'Lembrete 1 dia antes da Lua Cheia';

  @override
  String get settingsNewMoon => 'Lua Nova';

  @override
  String get settingsNewMoonDesc => 'Lembrete 1 dia antes da Lua Nova';

  @override
  String get settingsSabbats => 'Sabbats';

  @override
  String get settingsSabbatsDesc => 'Lembrete 3 dias antes de cada Sabbat';

  @override
  String get settingsNotifMobileOnly =>
      'As notificações serão enviadas apenas em dispositivos móveis';

  @override
  String get settingsNotifUpdateError =>
      'Não foi possível atualizar as notificações';

  @override
  String get settingsPaymentsNotConfigured => 'Pagamentos Não Configurados';

  @override
  String get settingsPaymentsNotConfiguredDesc =>
      'O sistema de pagamentos ainda não foi configurado nesta versão do app.\n\nSe você é desenvolvedor, verifique os logs do console para mais detalhes.';

  @override
  String get commonUnderstood => 'Entendi';

  @override
  String get settingsTermsSubtitle => 'As regras do nosso círculo';

  @override
  String get monthJanShort => 'Jan';

  @override
  String get monthFebShort => 'Fev';

  @override
  String get monthMarShort => 'Mar';

  @override
  String get monthAprShort => 'Abr';

  @override
  String get monthMayShort => 'Mai';

  @override
  String get monthJunShort => 'Jun';

  @override
  String get monthJulShort => 'Jul';

  @override
  String get monthAugShort => 'Ago';

  @override
  String get monthSepShort => 'Set';

  @override
  String get monthOctShort => 'Out';

  @override
  String get monthNovShort => 'Nov';

  @override
  String get monthDecShort => 'Dez';

  @override
  String get diaryNewDream => 'Novo Sonho';

  @override
  String get diaryEditDream => 'Editar Sonho';

  @override
  String get diaryTitleLabel => 'Título';

  @override
  String get diaryDreamTitleHint => 'Ex: Sonho com borboletas';

  @override
  String get diaryDreamDate => 'Data do Sonho';

  @override
  String get diaryDreamDescLabel => 'Descrição do Sonho';

  @override
  String get diaryDreamDescHint => 'Descreva seu sonho em detalhes';

  @override
  String get diaryTagsLabel => 'Tags';

  @override
  String get diaryDreamTagsHint => 'Ex: pesadelo, recorrente, lúcido';

  @override
  String get diaryTagsHelper => 'Separe as tags por vírgula';

  @override
  String get diaryDreamFeelingLabel => 'Como você se sentiu ao acordar?';

  @override
  String get diaryDreamFeelingHint => 'Ex: Paz, medo, alegria, confusão';

  @override
  String get diaryInterpretationHeader => '🔮 Interpretação';

  @override
  String get diarySaveDream => 'Salvar Sonho';

  @override
  String get commonUpdate => 'Atualizar';

  @override
  String get diaryFillTitleOrDesc =>
      'Preencha pelo menos o título ou a descrição';

  @override
  String get diaryFillTitleOrContent =>
      'Preencha pelo menos o título ou o conteúdo';

  @override
  String get commonNoTitle => 'Sem título';

  @override
  String get commonConfirmDelete => 'Confirmar exclusão';

  @override
  String get diaryDeleteDreamConfirm => 'Deseja realmente excluir este sonho?';

  @override
  String get diaryNewGratitude => 'Nova Gratidão';

  @override
  String get diaryEditGratitude => 'Editar Gratidão';

  @override
  String get diaryGratitudeTitleHint => 'Ex: Gratidão pelo dia de hoje';

  @override
  String get commonDate => 'Data';

  @override
  String get diaryGratitudeLabel => 'Pelo que você é grato(a) hoje?';

  @override
  String get diaryGratitudeHint => 'Descreva suas gratidões...';

  @override
  String get diaryGratitudeTagsHint => 'Ex: família, saúde, trabalho';

  @override
  String get diarySaveGratitude => 'Salvar Gratidão';

  @override
  String get diaryDeleteGratitudeTitle => 'Excluir Gratidão';

  @override
  String get diaryDeleteGratitudeConfirm =>
      'Tem certeza que deseja excluir esta gratidão?';

  @override
  String get diaryNewDesire => 'Novo Desejo';

  @override
  String get diaryEditDesire => 'Editar Desejo';

  @override
  String get diaryDesireTitleHint => 'Ex: Viajar para o exterior';

  @override
  String get diaryDescLabel => 'Descrição';

  @override
  String get diaryDesireSigilImage => 'Imagem do sigilo';

  @override
  String get diaryDesireSigilTitle => 'Sigilo 🔐';

  @override
  String get diaryDesireDescHint => 'Descreva seu desejo em detalhes';

  @override
  String get diaryStatusLabel => 'Status';

  @override
  String get diaryDesireProgressLabel => 'O que se movimentou?';

  @override
  String get diaryDesireProgressHint => 'Registre a evolução do seu desejo';

  @override
  String get diarySaveDesire => 'Salvar Desejo';

  @override
  String get diaryDeleteDesireConfirm =>
      'Deseja realmente excluir este desejo?';

  @override
  String get diaryNewAffirmation => 'Nova Afirmação';

  @override
  String get diaryEditAffirmation => 'Editar Afirmação';

  @override
  String get diaryPreloadedAffirmationNote =>
      'Afirmações pré-carregadas não podem ser editadas ou excluídas.';

  @override
  String get diaryAdvisorAffirmationPitch =>
      'Deixe o Conselheiro Místico criar uma afirmação poderosa para você';

  @override
  String get diaryContextOptional => 'Contexto (opcional)';

  @override
  String get diaryContextHint => 'Ex: Estou começando um novo emprego...';

  @override
  String get diaryContextHelper =>
      'Descreva sua situação para uma afirmação personalizada';

  @override
  String get diaryConsulting => 'Consultando...';

  @override
  String get diaryGenerateAffirmation => 'Gerar Afirmação';

  @override
  String get diaryWriteOwnAffirmation => 'Ou escreva sua própria afirmação:';

  @override
  String get diaryAffirmationLabel => 'Afirmação';

  @override
  String get diaryAffirmationHint =>
      'Ex: Sou merecedor de abundância e prosperidade';

  @override
  String get diaryAffirmationHelper =>
      'Escreva no presente e de forma positiva';

  @override
  String get diaryCategoryLabel => 'Categoria';

  @override
  String get diarySaveAffirmation => 'Salvar Afirmação';

  @override
  String diaryAffirmationsRemaining(String used) {
    return 'Afirmações restantes hoje: $used';
  }

  @override
  String get diaryAffirmationCreated =>
      'Afirmação criada pelo Conselheiro Místico!';

  @override
  String get diaryAffirmationError => 'Erro ao gerar afirmação';

  @override
  String get diaryTypeOrGenerate => 'Digite ou gere uma afirmação';

  @override
  String get diaryAffirmationLimit =>
      'Você atingiu o limite diário de afirmações. Volte amanhã ou seja Premium!';

  @override
  String get diaryDeleteAffirmationTitle => 'Excluir Afirmação';

  @override
  String get diaryDeleteAffirmationConfirm =>
      'Tem certeza que deseja excluir esta afirmação?';

  @override
  String get diaryLoadingDreams => 'Carregando sonhos...';

  @override
  String get diaryEmptyDreams =>
      'Você ainda não registrou nenhum sonho.\nComece seu diário onírico!';

  @override
  String get diaryRegisterDream => 'Registrar Sonho';

  @override
  String get diaryInterpretDream => 'Interpretar Sonho';

  @override
  String get diaryDreamThemes => 'Temas Oníricos';

  @override
  String get toolDreamsTitle => 'Interpretação de Sonhos';

  @override
  String get toolDreamsDesc =>
      'Desvende as mensagens dos seus sonhos e explore significados';

  @override
  String get dreamToolsIntro =>
      'Os sonhos falam em símbolos. Interprete o seu com o Conselheiro Místico ou explore os significados dos temas mais comuns.';

  @override
  String get dreamInterpretMyDream => 'Interpretar meu Sonho';

  @override
  String get dreamInterpretMyDreamDesc =>
      'Conte seu sonho e receba uma leitura do Conselheiro Místico';

  @override
  String get dreamMeaningsTitle => 'Significados dos Sonhos';

  @override
  String get dreamMeaningsDesc =>
      'Água, queda, voo, dentes e outros temas oníricos — e suas possíveis leituras';

  @override
  String get diaryLoadingGratitudes => 'Carregando gratidões...';

  @override
  String get diaryEmptyGratitudes =>
      'Você ainda não registrou nenhuma gratidão.\nComece a cultivar abundância em sua vida!';

  @override
  String get diaryAddGratitude => 'Adicionar Gratidão';

  @override
  String get diaryLoadingDesires => 'Carregando desejos...';

  @override
  String get diaryEmptyDesires =>
      'Você ainda não registrou nenhum desejo.\nComece a manifestar seus sonhos!';

  @override
  String get diaryAddDesire => 'Adicionar Desejo';

  @override
  String get diaryLoadingAffirmations => 'Carregando afirmações...';

  @override
  String get diaryAllCategories => 'Todas';

  @override
  String get diaryEmptyAffirmationsCategory =>
      'Nenhuma afirmação nesta categoria.\nAdicione suas próprias afirmações!';

  @override
  String get diaryAddAffirmation => 'Adicionar Afirmação';

  @override
  String get commonGoodMorning => 'Bom dia ✨';

  @override
  String get commonGoodAfternoon => 'Boa tarde ✨';

  @override
  String get commonGoodEvening => 'Boa noite ✨';

  @override
  String get diaryPreviousReflections => 'Reflexões anteriores';

  @override
  String get diarySaveReflection => 'Salvar reflexão';

  @override
  String get diaryFreeWritingHint => 'O que está na sua mente hoje?';

  @override
  String get diaryReflections => 'Reflexões';

  @override
  String get diaryLoadingReflections => 'Carregando reflexões...';

  @override
  String get diaryEmptyReflections =>
      'Suas reflexões aparecerão aqui.\nEscreva o que estiver na sua mente. ✨';

  @override
  String get diaryDeleteReflectionTitle => 'Excluir reflexão';

  @override
  String get diaryDeleteReflectionConfirm =>
      'Tem certeza que deseja excluir esta reflexão?';

  @override
  String get diaryDreamThemesIntro =>
      'Cada símbolo carrega muitas leituras possíveis. Explore os temas mais comuns e compare com o que você sentiu no sonho.';

  @override
  String get dreamDescribeFirst => 'Descreva seu sonho primeiro';

  @override
  String get dreamInterpretedTitle => 'Sonho interpretado';

  @override
  String get dreamNotesPrefix => 'Observações';

  @override
  String get dreamSavedToDiary => 'Sonho e interpretação salvos no Diário! 🌙';

  @override
  String get dreamInterpretationTitle => 'Interpretação de Sonhos';

  @override
  String get dreamPremiumOnly =>
      'A interpretação personalizada de sonhos é exclusiva do plano Premium.';

  @override
  String get dreamTellYourDream => 'Conte seu sonho';

  @override
  String get dreamTellHelp =>
      'Descreva com o máximo de detalhes: lugares, pessoas, símbolos, sensações e o que mais lembrar.';

  @override
  String get dreamTextHint => 'Eu estava em uma floresta e…';

  @override
  String get dreamFeelingOptional =>
      'Como você se sentiu ao acordar? (opcional)';

  @override
  String get dreamInterpreting => 'Interpretando…';

  @override
  String get dreamInterpretAgain => 'Interpretar novamente';

  @override
  String get dreamInterpretationLabel => 'Interpretação';

  @override
  String get dreamSaveToDiary => 'Salvar no Diário de Sonhos';

  @override
  String get dreamDateLabel => 'Data do sonho';

  @override
  String get dreamNotesOptional => 'Observações (opcional)';

  @override
  String get dreamSavedShort => 'Salvo no Diário';

  @override
  String get tarotTabDraw => 'Tiragem';

  @override
  String get tarotTabLearn => 'Aprender';

  @override
  String get tarotDailyCard => 'Carta do Dia';

  @override
  String get tarotThreeCards => 'Três Cartas';

  @override
  String get tarotCross => 'Cruz de Cinco';

  @override
  String get tarotDailyDesc => 'A energia que acompanha o seu dia';

  @override
  String get tarotThreeDesc => 'Passado · Presente · Futuro';

  @override
  String get tarotCrossDesc => 'Situação, desafio, raiz, conselho e tendência';

  @override
  String get tarotPosPast => 'Passado';

  @override
  String get tarotPosPresent => 'Presente';

  @override
  String get tarotPosFuture => 'Futuro';

  @override
  String get tarotPosSituation => 'Situação';

  @override
  String get tarotPosChallenge => 'Desafio';

  @override
  String get tarotPosRoot => 'Raiz';

  @override
  String get tarotPosAdvice => 'Conselho';

  @override
  String get tarotPosTendency => 'Tendência';

  @override
  String get tarotFreeLimitReached =>
      'Você já fez sua tiragem gratuita hoje. Assine Premium para tiragens ilimitadas!';

  @override
  String get tarotSpreadLabel => 'Tiragem';

  @override
  String get tarotReversed => 'invertida';

  @override
  String get tarotBreathe =>
      'Respire fundo, pense na sua pergunta e escolha a tiragem.';

  @override
  String get tarotNewSpread => 'Nova tiragem';

  @override
  String get tarotConsultingCards => 'Consultando as cartas…';

  @override
  String get tarotAdvisorInterpretation =>
      'Interpretação do Conselheiro Místico';

  @override
  String get tarotBestCombo => 'Melhor combo';

  @override
  String get tarotDayStreak => 'Dias seguidos';

  @override
  String get tarotAccuracy => 'Precisão';

  @override
  String tarotAnsweredOf(String answered, String total) {
    return '$answered respondidas · $total cartas no baralho';
  }

  @override
  String get tarotQuizTitle => 'Teste o que você sabe';

  @override
  String get tarotQuizDesc =>
      'Uma sessão com perguntas embaralhadas sobre os significados das cartas. Acertos consecutivos formam combo — volte todos os dias para manter a sequência.';

  @override
  String get tarotQuizStart => 'Sessão de 10 perguntas';

  @override
  String get tarotQuizBrilliant => 'Brilhante! ✨';

  @override
  String get tarotQuizDone => 'Sessão concluída 🌙';

  @override
  String tarotQuizScore(String correct, String total) {
    return 'Você acertou $correct de $total.';
  }

  @override
  String get tarotQuizPraise => ' As cartas reconhecem sua dedicação.';

  @override
  String get tarotQuizEncourage =>
      ' Continue praticando — cada sessão aprofunda a leitura.';

  @override
  String get tarotQuizFinish => 'Concluir';

  @override
  String tarotQuizQuestion(String card) {
    return 'O que representa $card?';
  }

  @override
  @override
  String get palmRemainingToday => 'Leituras restantes hoje';

  @override
  String get palmDailyLimitReached =>
      'Você já fez suas leituras de mãos de hoje. Volte amanhã para mais. ✨';

  @override
  String get palmRateLimit =>
      'Muitas leituras em pouco tempo. Aguarde alguns instantes e envie a foto novamente.';

  String get palmImageTooLarge =>
      'A imagem ficou grande demais. Tente com menos zoom ou outra foto.';

  @override
  String get palmImageTooSmall =>
      'A imagem parece pequena ou escura demais para leitura. Fotografe a palma bem iluminada, preenchendo a tela.';

  @override
  String get palmReadingHeader => 'Leitura de Mãos';

  @override
  String get palmSavedToRecords => 'Leitura salva nos seus Registros! ✨';

  @override
  String get palmistryTitle => 'Quiromancia';

  @override
  String get palmPremiumOnly =>
      'A leitura de mãos é exclusiva do plano Premium.';

  @override
  String get palmHowTo => '🖐️ Como fotografar';

  @override
  String get palmTip1 => 'Palma da mão dominante aberta e relaxada';

  @override
  String get palmTip2 => 'Luz natural, sem sombras fortes sobre as linhas';

  @override
  String get palmTip3 => 'A palma deve preencher quase toda a foto';

  @override
  String get palmTip4 => 'Evite fotos tremidas ou desfocadas';

  @override
  String get palmPrivacyNote =>
      'Privacidade: a foto é processada na hora e descartada — não fica salva no aparelho nem em servidores.';

  @override
  String get palmCamera => 'Câmera';

  @override
  String get palmGallery => 'Galeria';

  @override
  String get palmReadingLines => 'Lendo as linhas da sua mão…';

  @override
  String get palmYourReading => '✨ Sua Leitura';

  @override
  String get palmDisclaimer =>
      'Leitura simbólica para reflexão — não substitui orientação médica, psicológica ou profissional.';

  @override
  String get palmSavedShort => 'Salva nas Reflexões';

  @override
  String get palmSaveReading => 'Salvar leitura';

  @override
  String get numMagicOfNumbers => 'A Magia dos Números';

  @override
  String get numIntro =>
      'Explore os números que vibram na sua vida: seu perfil de nascimento, o significado de qualquer número, as horas espelho e as sequências que insistem em aparecer.';

  @override
  String get numPersonalProfile => 'Perfil Pessoal';

  @override
  String get numPersonalProfileDesc =>
      'Seus 5 números-chave a partir do nome e da data de nascimento';

  @override
  String get numLookupTitle => 'Consultar um Número';

  @override
  String get numLookupDesc =>
      'Um número te acompanha? Descubra o que ele vibra';

  @override
  String get numMirrorHours => 'Horas Espelho';

  @override
  String get numMirrorHoursDesc =>
      'O recado das horas duplas: 11:11, 22:22 e além';

  @override
  String get numSequences => 'Sequências Repetidas';

  @override
  String get numSequencesDesc =>
      'O significado de padrões como 333, 1010 e 1234';

  @override
  String get numWhichNumber => 'Que número te acompanha?';

  @override
  String get numLookupHelp =>
      'Placas, datas, portas, recibos… digite o número e veja sua essência numerológica.';

  @override
  String get numLookupHint => 'Ex.: 713';

  @override
  String get numSee => 'Ver';

  @override
  String numReducesTo(String original, String result) {
    return '$original reduz para $result';
  }

  @override
  String get numMirrorIntro =>
      'Olhou o relógio exatamente numa hora dupla? Cada espelho carrega uma vibração numérica. Toque para ver o recado.';

  @override
  String numVibrationOf(String number) {
    return 'Vibração do número $number';
  }

  @override
  String numMirrorMessage(String label) {
    return 'Recado do espelho $label';
  }

  @override
  String get numSequencesIntro =>
      'Aquele número que aparece em todo lugar pode ser um padrão pedindo atenção. Os clássicos:';

  @override
  String numVibratesIn(String number) {
    return 'vibra no $number';
  }

  @override
  String get numFillNameAndDate =>
      'Informe o nome completo e a data de nascimento';

  @override
  String get numDailyLimit =>
      'Limite diário atingido. Assine Premium para consultas ilimitadas.';

  @override
  String get numYourBirthData => 'Seus dados de nascimento';

  @override
  String get numBirthNameHelp =>
      'Use o nome completo de nascimento — é ele que carrega a assinatura numerológica original.';

  @override
  String get numFullName => 'Nome completo';

  @override
  String get numChooseBirthDate => 'Escolher data de nascimento';

  @override
  String get numBirthPrefix => 'Nascimento';

  @override
  String get numCalculate => 'Calcular meus números';

  @override
  String get numSynthesisQuestion =>
      'Quer uma síntese de como esses números conversam entre si?';

  @override
  String get numWeavingSynthesis => 'Tecendo a síntese…';

  @override
  String get numAdvisorExplanation => 'Explicação do Conselheiro Místico';

  @override
  String get sigilCreateTitle => 'Criar Sigilo';

  @override
  String get sigilWhatIs => 'O que é um Sigilo?';

  @override
  String get sigilWhatIsDesc =>
      'Sigilos são símbolos mágicos criados para manifestar intenções. Ao transformar palavras em símbolos abstratos, você cria uma marca energética que carrega o poder da sua vontade, sem revelar sua intenção para outras pessoas.';

  @override
  String get sigilHowIntro =>
      'Defina sua intenção, escolha uma palavra que a represente, e o app criará automaticamente seu sigilo único.';

  @override
  String get sigilSetIntention => 'Defina sua Intenção';

  @override
  String get sigilIntentionWord => 'Sua palavra de intenção';

  @override
  String get sigilTypeWord => 'Digite uma palavra...';

  @override
  String get sigilOneWordWarning => '⚠️ Use apenas UMA palavra, sem espaços';

  @override
  String get sigilExamplesHeader => '💡 Exemplos de palavras';

  @override
  String get sigilExample1 => 'Prosperidade';

  @override
  String get sigilExample2 => 'Proteção';

  @override
  String get sigilExample3 => 'Cura';

  @override
  String get sigilExample4 => 'Confiança';

  @override
  String get sigilExample5 => 'Intuição';

  @override
  String get sigilWordTip =>
      'Dica: Escolha palavras positivas e específicas que ressoem com você.';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get sigilMagicLetters => 'Letras Mágicas';

  @override
  String get sigilYourLetters => 'Letras do seu Sigilo';

  @override
  String get sigilEssence => 'A essência mágica da sua intenção';

  @override
  String get sigilYourIntention => 'Sua intenção:';

  @override
  String get sigilTransformedInto => 'Transformada em:';

  @override
  String get sigilWhatHappened => 'O que aconteceu?';

  @override
  String get sigilSimplified =>
      'Sua palavra foi simplificada seguindo a tradição dos sigilos:';

  @override
  String get sigilStepAccents => '1. Acentos foram normalizados';

  @override
  String get sigilStepSpaces => '2. Espaços e símbolos foram removidos';

  @override
  String get sigilStepDupes =>
      '3. Letras duplicadas foram eliminadas (mantém apenas a primeira ocorrência)';

  @override
  String get sigilWheelNote =>
      'Esta sequência simplificada será conectada na Roda das Bruxas para formar o símbolo mágico do seu sigilo.';

  @override
  String get sigilSeeDrawing => 'Ver Desenho do Sigilo';

  @override
  String get sigilSaveError => 'Não foi possível salvar o sigilo';

  @override
  String get sigilDrawingNotReady => 'Desenho ainda não está pronto';

  @override
  String get sigilImageError => 'Falha ao gerar a imagem';

  @override
  String get sigilSavedToGallery => 'Sigilo salvo na galeria! ✨';

  @override
  String get sigilGalleryPermission =>
      'Permita o acesso à galeria para salvar o sigilo.';

  @override
  String get sigilImageSaveError => 'Não foi possível salvar a imagem.';

  @override
  String get sigilYourSigil => 'Seu Sigilo';

  @override
  String get sigilYourDrawing => 'Desenho do seu Sigilo';

  @override
  String get sigilLegendStart => 'Início';

  @override
  String get sigilLegendLetters => 'Letras';

  @override
  String get sigilLegendEnd => 'Fim';

  @override
  String get sigilWheel => 'Roda';

  @override
  String get sigilPoints => 'Pontos';

  @override
  String get sigilShuffle => 'Embaralhar letras';

  @override
  String get sigilSaveImage => 'Salvar imagem na galeria';

  @override
  String get sigilRestore => 'Restaurar posições';

  @override
  String get sigilHowToUse => 'Como usar seu sigilo';

  @override
  String get sigilUse1Title => '1. Copie este desenho';

  @override
  String get sigilUse1Desc =>
      'Reproduza o traçado em seu caderno, altar, vela, ou papel ritual.';

  @override
  String get sigilUse2Title => '2. Personalize';

  @override
  String get sigilUse2Desc =>
      'Simplifique, gire, ou adicione detalhes. Torná-lo seu faz parte da magia.';

  @override
  String get sigilUse3Title => '3. Ative o sigilo';

  @override
  String get sigilUse3Desc =>
      'Use em meditação, queime em ritual, ou carregue consigo para focar sua intenção.';

  @override
  String get sigilRemember =>
      'Lembre-se: a magia está na sua intenção e no ato de criar, não apenas no desenho final.';

  @override
  String get commonSaving => 'Salvando...';

  @override
  String get commonFinish => 'Finalizar';

  @override
  String get advisorAskFirst => 'Faça sua pergunta primeiro';

  @override
  String get advisorDailyLimit =>
      'Você já consultou o Conselheiro hoje. Volte amanhã ou seja Premium!';

  @override
  String get advisorGenericError =>
      'O conselheiro não pôde responder agora. Tente novamente mais tarde.';

  @override
  String get advisorRateLimited =>
      'O conselheiro precisa de descanso. Muitos pedidos foram feitos. Por favor, aguarde alguns minutos.';

  @override
  String get advisorTempError =>
      'Erro temporário no serviço místico. Tente novamente em instantes.';

  @override
  String get advisorConnectionError =>
      'Erro de conexão. Verifique sua internet e tente novamente.';

  @override
  String get advisorPortalClosed =>
      'O portal místico está temporariamente fechado. Tente novamente em alguns minutos.';

  @override
  String get advisorWisdomTitle => 'Sabedoria do Conselheiro';

  @override
  String get advisorIntro =>
      'Faça uma pergunta sobre bruxaria, magia ou misticismo, e o conselheiro compartilhará sua sabedoria ancestral 🪄';

  @override
  String get advisorQuestionHint =>
      'Ex: Qual a melhor fase da lua para um ritual de proteção?';

  @override
  String get advisorConsultingStars => 'Consultando os astros...';

  @override
  String get advisorConsult => 'Consultar o Conselheiro';

  @override
  String advisorRemainingToday(String used) {
    return 'Consultas restantes hoje: $used';
  }

  @override
  String get advisorAnswers => 'O Conselheiro responde';

  @override
  String get spellGroupProtection => 'Proteção & Limpeza';

  @override
  String get spellGroupProtectionSub => 'Defesa, banimento e purificação';

  @override
  String get spellGroupLove => 'Amor & Laços';

  @override
  String get spellGroupLoveSub => 'Amor, autoestima e amizade';

  @override
  String get spellGroupProsperity => 'Prosperidade & Caminhos';

  @override
  String get spellGroupProsperitySub => 'Abundância, sorte, trabalho e estudos';

  @override
  String get spellGroupDreams => 'Sonhos & Visões';

  @override
  String get spellGroupDreamsSub => 'Adivinhação, sonhos e sabedoria';

  @override
  String get spellGroupEnergy => 'Energia & Cura';

  @override
  String get spellGroupEnergySub => 'Vitalidade, cura e coragem';

  @override
  String get spellGroupCreation => 'Criação & Palavra';

  @override
  String get spellGroupCreationSub => 'Criatividade e comunicação';

  @override
  String get spellGroupHome => 'Lar & Cotidiano';

  @override
  String get spellGroupHomeSub => 'Casa, família e o dia a dia';

  @override
  String get grimoireSearchSpells => 'Buscar feitiços...';

  @override
  String get grimoireMySpells => 'Meus Feitiços';

  @override
  String get grimoireMySpellsSub => 'Criações e registros pessoais';

  @override
  String get grimoireNoSpellsFound => 'Nenhum feitiço encontrado 🔍';

  @override
  String get grimoireAncestral => 'Ancestral';

  @override
  String get spellNew => 'Novo Feitiço';

  @override
  String get spellEdit => 'Editar Feitiço';

  @override
  String get spellNameLabel => 'Nome do Feitiço *';

  @override
  String get spellNameHint => 'Ex: Proteção de Lar';

  @override
  String get commonRequired => 'Campo obrigatório';

  @override
  String get spellPurposeLabel => 'Propósito *';

  @override
  String get spellPurposeHint => 'Ex: Proteção, Amor Próprio, Prosperidade';

  @override
  String get spellTypeLabel => 'Tipo de Feitiço *';

  @override
  String get spellCategoryLabel => 'Categoria *';

  @override
  String get spellMoonPhaseLabel => 'Fase da Lua (Opcional)';

  @override
  String get commonNone => 'Nenhuma';

  @override
  String get spellIngredientsLabel => 'Ingredientes';

  @override
  String get spellIngredientsHint => 'Digite um ingrediente por linha';

  @override
  String get spellHowToLabel => 'Como Realizar *';

  @override
  String get spellHowToHint => 'Descreva os passos do ritual';

  @override
  String get spellDurationLabel => 'Duração (em dias)';

  @override
  String get spellDurationHint => 'Ex: 3';

  @override
  String get spellNotesLabel => 'Observações';

  @override
  String get spellNotesHint => 'Resultados, sensações, anotações...';

  @override
  String get spellAdd => 'Adicionar Feitiço';

  @override
  String get spellFilterByCategory => 'Filtrar por categoria';

  @override
  String get spellAllCategories => 'Todas Categorias';

  @override
  String get spellSourceAll => 'Todos';

  @override
  String get spellSourceMine => 'Meus';

  @override
  String get spellSourceAncestral => 'Ancestrais';

  @override
  String get spellLoading => 'Carregando feitiços...';

  @override
  String get spellNoneFound => 'Nenhum feitiço encontrado';

  @override
  String get spellNoAncestral => 'Nenhum feitiço ancestral disponível';

  @override
  String get spellEmptyGrimoire =>
      'Seu grimório está vazio.\nComece adicionando seu primeiro feitiço!';

  @override
  String get spellMoonPrefix => 'Lua';

  @override
  String get spellSavedToGrimoire => 'Feitiço salvo no seu grimório! ✨';

  @override
  String get spellDetails => 'Detalhes';

  @override
  String get spellSaveToGrimoire => 'Salvar no Grimório';

  @override
  String get spellRecommendedMoon => 'Fase Lunar Recomendada';

  @override
  String get spellHowTo => 'Como Realizar';

  @override
  String spellDurationDays(String duration) {
    return 'Duração: $duration';
  }

  @override
  String get spellDay => 'dia';

  @override
  String get spellDays => 'dias';

  @override
  String spellCreatedAt(String date) {
    return 'Criado em: $date';
  }

  @override
  String spellUpdatedAt(String date) {
    return 'Atualizado em: $date';
  }

  @override
  String spellDeleteConfirm(String name) {
    return 'Deseja realmente excluir o feitiço \"$name\"?';
  }

  @override
  String get recordDetails => 'Registro';

  @override
  String get recordEditTitle => 'Editar Registro';

  @override
  String get recordTitleLabel => 'Título *';

  @override
  String get recordContentLabel => 'Sua página';

  @override
  String get recordTitleRequired => 'Dê um título ao registro';

  @override
  String get recordContentRequired => 'Escreva algo antes de salvar';

  @override
  String get recordUpdated => 'Registro atualizado! ✨';

  @override
  String recordDeleteConfirm(String name) {
    return 'Deseja realmente excluir o registro \"$name\"?';
  }

  @override
  String get aiSpellDescribeFirst => 'Descreva sua intenção primeiro';

  @override
  String get aiSpellDailyLimit =>
      'Você atingiu o limite diário de consultas. Volte amanhã ou seja Premium!';

  @override
  String get aiSpellGenericError =>
      'O conselheiro não pôde manifestar o feitiço. Tente novamente mais tarde.';

  @override
  String get aiSpellDescribeIntention => 'Descreva sua Intenção';

  @override
  String get aiSpellIntentionHelp =>
      'Compartilhe o que você deseja manifestar. Quanto mais detalhes, mais poderoso será o feitiço!';

  @override
  String get aiSpellIntentionHint =>
      'Ex: Quero atrair prosperidade financeira para pagar minhas contas e ter mais tranquilidade';

  @override
  String get aiSpellManifesting => 'Manifestando...';

  @override
  String get aiSpellManifest => 'Manifestar Feitiço ✨';

  @override
  String get aiSpellSeeDetails => 'Ver Detalhes';

  @override
  String get learnUnlockPrevious =>
      'Complete a lição anterior para destravar esta.';

  @override
  String learnLessonN(String number, String title) {
    return 'Lição $number — $title';
  }

  @override
  String learnPageWritten(String title) {
    return 'Página escrita: \"$title\"';
  }

  @override
  String get learnPremiumLesson => 'Lição Premium';

  @override
  String learnCreatesPage(String title) {
    return 'Cria a página: \"$title\"';
  }

  @override
  String get learnToFill => '(a preencher)';

  @override
  String learnPageNote(String trail, String lesson) {
    return 'Página do Grimório Vivo — $trail · $lesson';
  }

  @override
  String get learnTrailBound => 'Trilha Encadernada!';

  @override
  String get learnPageDone => 'Página escrita!';

  @override
  String learnChapterBound(String title) {
    return 'O capítulo \"$title\" agora é um livro encadernado no seu grimório — escrito por você.';
  }

  @override
  String get learnNewTitle => 'Novo título';

  @override
  String get learnSoBeIt => 'Que assim seja ✨';

  @override
  String get learnPracticeGoal => 'Objetivo';

  @override
  String get learnPracticeHow => 'Como fazer';

  @override
  String get learnPracticeThen => 'Depois da prática';

  @override
  String get learnStepTeaching => '📜 Ensino';

  @override
  String get learnStepPractice => '🕯️ Prática';

  @override
  String get learnStepPage => '✍️ A Página';

  @override
  String get learnGoToPractice => 'Ir para a prática';

  @override
  String get learnDidPractice => 'Fiz a prática (ou vou fazer hoje)';

  @override
  String get learnWriteMyPage => 'Escrever minha página';

  @override
  String get learnAnswerHelp =>
      'Responda com as suas palavras — o app monta a página e guarda no Meu Grimório. Ela é sua para sempre.';

  @override
  String get learnPageTitleLabel => 'Título da página';

  @override
  String get learnWriteHere => 'Escreva aqui…';

  @override
  String get learnSealPage => 'Selar página no grimório';

  @override
  String get learnHomeTitle => 'Aprenda escrevendo o seu grimório';

  @override
  String get learnHomeSubtitle =>
      'Cada lição termina com uma página criada por você no Meu Grimório. Ao completar uma trilha, o capítulo é seu — escrito de próprio punho.';

  @override
  String get learnMaxTitle => 'Título máximo alcançado ✨';

  @override
  String learnNextTitle(String pages, String title, String xp) {
    return '$pages páginas escritas · próximo título: $title ($xp XP)';
  }

  @override
  String get learnBoundShort => 'Encadernada!';

  @override
  String learnPagesProgress(String done, String total) {
    return '$done/$total páginas';
  }

  @override
  String learnBoundVolume(String count) {
    return '📕 Volume encadernado — $count páginas escritas por você';
  }

  @override
  String get oracleDailyLimit =>
      'Você atingiu o limite diário de leituras. Volte amanhã ou seja Premium!';

  @override
  String get oracleTitle => 'Cartas do Oráculo';

  @override
  String get oracleSubtitle => 'Receba orientação e mensagens do universo';

  @override
  String get oracleDrawing => 'Tirando cartas...';

  @override
  String get oracleDraw => 'Tirar Cartas';

  @override
  String oracleRemainingToday(String used) {
    return 'Leituras restantes hoje: $used';
  }

  @override
  String get oracleNewReading => 'Nova Leitura';

  @override
  String get oracleYourReading => 'Sua Leitura';

  @override
  String get pendulumUsedAll =>
      'Você já usou suas 3 consultas de hoje. Volte amanhã!';

  @override
  String get pendulumAskFirst => 'Faça uma pergunta primeiro';

  @override
  String get pendulumTitle => 'Pêndulo';

  @override
  String get pendulumConsult => 'Consultar o Pêndulo';

  @override
  String get pendulumIntro =>
      'Faça perguntas de sim ou não. Concentre-se e confie na resposta.';

  @override
  String get pendulumUnlimitedAdmin => 'Consultas ilimitadas (Admin)';

  @override
  String pendulumUsedComeBack(String used, String total) {
    return 'Consultas usadas ($used/$total) - volte amanhã';
  }

  @override
  String get pendulumYourQuestion => 'Sua Pergunta';

  @override
  String get pendulumQuestionHint => 'Ex: Devo aceitar aquele emprego?';

  @override
  String get pendulumAsking => 'Consultando...';

  @override
  String get pendulumAsk => 'Perguntar';

  @override
  String get pendulumNewConsult => 'Nova Consulta';

  @override
  String get pendulumYes => 'SIM';

  @override
  String get pendulumNo => 'NÃO';

  @override
  String get pendulumMaybe => 'TALVEZ';

  @override
  String get runesNoQuestion => 'Sem pergunta';

  @override
  String get runesReadingTitle => 'Leitura de Runas';

  @override
  String get runesReadingIntro =>
      'As runas são símbolos do alfabeto rúnico nórdico usado para adivinhação. Cada runa pode aparecer em posição normal ou invertida (quando aplicável), mudando seu significado.';

  @override
  String get runesReversedNote =>
      'Runas Invertidas: Quando uma runa aparece de cabeça para baixo, geralmente indica bloqueios ou aspectos desafiadores do significado original.';

  @override
  String get runesChooseLayout => 'Escolha um Layout';

  @override
  String get runesQuestionOptional => 'Sua Pergunta (opcional)';

  @override
  String get runesQuestionHint => 'O que as runas devem revelar?';

  @override
  String get runesDrawing => 'Tirando runas...';

  @override
  String get runesDraw => 'Tirar Runas';

  @override
  String get runesReversed => 'Invertida';

  @override
  String get runesListTitle => 'Runas';

  @override
  String get runesAbout => 'Sobre as Runas';

  @override
  String get runesAboutText =>
      'As runas são um alfabeto antigo usado pelos povos germânicos e nórdicos. Além de escrita, cada runa carrega significados simbólicos profundos e pode ser usada para reflexão, autoconhecimento e leitura oracular.';

  @override
  String get runesExplore =>
      'Explore as 24 runas do Futhark Antigo abaixo. Toque em cada uma para conhecer seu significado.';

  @override
  String get runesElderFuthark => 'Futhark Antigo';

  @override
  String get runesKeywords => 'Palavras-chave';

  @override
  String get runesMeaning => 'Significado';

  @override
  String get runesRemember =>
      'Lembre-se: as runas são ferramentas de reflexão e autoconhecimento. Use-as como um ponto de partida para explorar suas próprias percepções e intuições.';

  @override
  String get astroMysticTitle => 'Astrologia Mística';

  @override
  String get astroMysticSubtitle =>
      'Seu mapa astral e perfil mágico personalizado';

  @override
  String get astroZodiacSigns => 'Signos do Zodíaco';

  @override
  String get astroZodiacSignsDesc =>
      'Conheça os 12 signos e seus significados mágicos';

  @override
  String get astroBirthChart => 'Mapa Astral';

  @override
  String get astroSeeChart => 'Ver seu mapa astral completo';

  @override
  String get astroCreateChart => 'Criar seu mapa astral';

  @override
  String get astroMagicMirror => 'Espelho mágico';

  @override
  String get astroMagicalProfile => 'Perfil Mágico';

  @override
  String get astroMagicalProfileDesc =>
      'Interpretação astrológica para bruxaria';

  @override
  String get astroDailyWeather => 'Clima Mágico Diário';

  @override
  String get astroDailyWeatherDesc => 'Trânsitos planetários e energia do dia';

  @override
  String get astroSuggestions => 'Sugestões Personalizadas';

  @override
  String get astroSuggestionsDesc => 'Práticas baseadas nos seus trânsitos';

  @override
  String get astroRecalculate => 'Recalcular Mapa';

  @override
  String get astroRecalculateDesc => 'Criar novo mapa astral';

  @override
  String get astroAbout => 'Sobre a Astrologia';

  @override
  String get astroAboutText =>
      'Seu mapa astral é calculado com base na posição dos planetas no momento e local do seu nascimento. O perfil mágico interpreta essas posições de forma específica para práticas de bruxaria.';

  @override
  String get astroHaveOnHand => 'Para melhores resultados, tenha em mãos:';

  @override
  String get astroBirthDate => 'Data de nascimento';

  @override
  String get astroBirthTime => 'Hora exata de nascimento';

  @override
  String get astroBirthPlace => 'Local de nascimento (cidade e país)';

  @override
  String get astroRecalcTitle => 'Recalcular Mapa Astral?';

  @override
  String get astroRecalcConfirm =>
      'Isso irá substituir seu mapa astral atual. Você tem certeza?';

  @override
  String get chartInvalidDate => 'Data inválida';

  @override
  String get chartInvalidTime => 'Hora inválida';

  @override
  String get chartPlaceNotFound => 'Local não encontrado';

  @override
  String get chartCalcError => 'Erro ao calcular mapa';

  @override
  String get chartCreateTitle => 'Criar Mapa Astral';

  @override
  String get chartYourChart => 'Seu Mapa Astral';

  @override
  String get chartIntro =>
      'Para calcular seu mapa natal preciso, precisamos de sua data, hora e local de nascimento. Quanto mais preciso, melhor!';

  @override
  String get chartBirthDate => 'Data de Nascimento';

  @override
  String get chartDateFormat => 'Digite no formato dd/mm/aaaa';

  @override
  String get chartDateHint => 'dd/mm/aaaa';

  @override
  String get chartBirthTime => 'Hora de Nascimento';

  @override
  String get chartTimeImportant =>
      'A hora exata é importante para calcular o Ascendente e as Casas.';

  @override
  String get chartDontKnowTime => 'Não sei a hora exata';

  @override
  String get chartBirthPlace => 'Local de Nascimento';

  @override
  String get chartTypeToSearch => 'Digite pelo menos 3 caracteres para buscar';

  @override
  String get chartPlaceHint => 'Ex: São Paulo, Brasil';

  @override
  String get chartCalculate => 'Calcular Mapa Astral ✨';

  @override
  String get chartNoonNote =>
      'Sem a hora exata, usaremos meio-dia (12:00) e o sistema de casas iguais.';

  @override
  String get settingsLanguageSubtitle => 'Escolha manualmente o idioma do app';

  @override
  String get quizTitle => 'Teste de Arquétipo';

  @override
  String quizProgress(String current, String total) {
    return '$current de $total';
  }

  @override
  String get quizYourArchetypeIs => 'Seu arquétipo é';

  @override
  String get quizSeeInEncyclopedia => 'Ver na Enciclopédia';

  @override
  String get quizRetake => 'Refazer o teste';

  @override
  String get quizStrongestEnergies => 'Suas energias mais fortes';

  @override
  String get quizMirrorNote =>
      'Arquétipos são espelhos, não gavetas: você carrega vários — este é o que vibra mais alto em você agora. Explore os outros na aba Arquétipos da Enciclopédia.';

  @override
  String quizSavedOn(String date) {
    return 'Resultado do seu último teste ($date)';
  }

  @override
  String get tarotLibraryTitle => 'Biblioteca de Cartas';

  @override
  String get tarotTutorTitle => 'Tutor de Tarot';

  @override
  String get tarotLibraryDesc =>
      'As 78 cartas com imagem, significado e leitura invertida';

  @override
  String get tarotFlipCard => 'Inverter carta';

  @override
  String get tarotUnflipCard => 'Posição normal';

  @override
  String get tarotUprightMeaning => 'Significado';

  @override
  String get tarotReversedMeaning => 'Significado invertido';

  @override
  String get grimoireMyRecords => 'Meus Registros';

  @override
  String get grimoireMyRecordsSub =>
      'Páginas do Grimório Vivo, estudos e reflexões';

  @override
  String get grimoireNoRecords =>
      'Suas páginas do Grimório Vivo e registros aparecerão aqui.';

  @override
  String get learnFillAtLeastOne =>
      'Responda pelo menos uma pergunta antes de selar a página';

  @override
  String learnOpenTool(String tool) {
    return 'Abrir $tool';
  }

  @override
  String get learnToolHint =>
      'Esta lição usa uma ferramenta do app — abra por aqui e depois volte para escrever a página.';

  @override
  String learnSavesTo(String place) {
    return 'Esta página será guardada em: $place';
  }

  @override
  String get learnPlaceDreams => 'Diário de Sonhos';

  @override
  String get learnPlaceGratitude => 'Diário de Gratidão';

  @override
  String get learnPlaceAffirmations => 'Afirmações';

  @override
  String get learnPlaceDesires => 'Diário de Desejos';

  @override
  String get learnSection1 => 'Fundamento';

  @override
  String get learnSection2 => 'Aprofundando';

  @override
  String get learnSection3 => 'Na prática';

  @override
  String get learnSection4 => 'Para levar consigo';
}
