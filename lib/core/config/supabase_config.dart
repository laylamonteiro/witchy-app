/// Configuração do Supabase
///
/// As credenciais são carregadas via variáveis de ambiente no build.
/// Configure os secrets no GitHub Actions ou passe via --dart-define.
class SupabaseConfig {
  /// URL do projeto Supabase
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Anon Key (chave pública) do Supabase
  /// Esta é a publishable key - segura para usar no cliente
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Verifica se o Supabase está configurado
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  /// Schema do banco de dados
  static const String schema = 'public';

  /// Deep link scheme para OAuth callbacks
  static const String deepLinkScheme = 'io.supabase.grimorio'; // Usado para callbacks nativos em mobile

  /// Redirect URL para OAuth (deve ser HTTPS para provedores como Google)
  /// Formato padrão do Supabase: https://<SUA_URL_SUPABASE>/auth/v1/callback
  static String get redirectUrl => '$url/auth/v1/callback';
}

/// Tabelas do Supabase
class SupabaseTables {
  static const String profiles = 'profiles';
  static const String spells = 'spells';
  static const String dreams = 'dreams';
  static const String desires = 'desires';
  static const String gratitudes = 'gratitudes';
  static const String affirmations = 'affirmations';
  static const String freeWritings = 'free_writings';
  static const String dailyRituals = 'daily_rituals';
  static const String ritualLogs = 'ritual_logs';
  static const String sigils = 'sigils';
  static const String birthCharts = 'birth_charts';
  static const String magicalProfiles = 'magical_profiles';
  static const String runeReadings = 'rune_readings';
  static const String pendulumConsultations = 'pendulum_consultations';
  static const String oracleReadings = 'oracle_readings';
  static const String tarotReadings = 'tarot_readings';
  static const String dailyMagicalWeather = 'daily_magical_weather';
  static const String dailyCheckins = 'daily_checkins';
  static const String learningProgress = 'learning_progress';
  static const String userEncyclopediaEntries =
      'user_encyclopedia_entries';
  static const String cycleReadings = 'cycle_readings';
  static const String betaCodes = 'beta_codes';
}
