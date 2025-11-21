/// Credentials for the Groq API.
///
/// The API key is loaded from a compile-time environment variable to avoid
/// hardcoding secrets in the codebase. Set `--dart-define=GROQ_API_KEY=...`
/// when building or set `GROQ_API_KEY` in your CI/CD workflow to provide the
/// key at runtime. If not provided, the value defaults to an empty string.
class GroqCredentials {
  static const apiKey = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
}
