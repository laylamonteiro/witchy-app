/// Configuração do Supabase
///
/// IMPORTANTE: Em produção, considere usar variáveis de ambiente
/// para não expor as chaves no código fonte público.
class SupabaseConfig {
  /// URL do projeto Supabase
  static const String url = 'https://jdncobtussylzfabrebe.supabase.co';

  /// Anon Key (chave pública) do Supabase
  /// Esta é a publishable key - segura para usar no cliente
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_79SfND3aYJcqveRfKd7ljw_vTkXNVLb',
  );

  /// Verifica se o Supabase está configurado
  static bool get isConfigured => anonKey.isNotEmpty;

  /// Schema do banco de dados
  static const String schema = 'public';

  /// Deep link scheme para OAuth callbacks
  static const String deepLinkScheme = 'io.supabase.grimorio';

  /// Redirect URL para OAuth
  static String get redirectUrl => '$deepLinkScheme://callback';
}

/// Tabelas do Supabase
class SupabaseTables {
  static const String profiles = 'profiles';
  static const String spells = 'spells';
  static const String dreams = 'dreams';
  static const String desires = 'desires';
  static const String gratitudes = 'gratitudes';
  static const String affirmations = 'affirmations';
  static const String dailyRituals = 'daily_rituals';
  static const String ritualLogs = 'ritual_logs';
  static const String sigils = 'sigils';
  static const String birthCharts = 'birth_charts';
  static const String magicalProfiles = 'magical_profiles';
  static const String runeReadings = 'rune_readings';
  static const String pendulumConsultations = 'pendulum_consultations';
  static const String oracleReadings = 'oracle_readings';
  static const String dailyMagicalWeather = 'daily_magical_weather';
}
