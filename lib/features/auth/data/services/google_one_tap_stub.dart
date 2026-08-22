/// Fora da web não existe Google Identity Services: no celular a entrada com
/// o Google é nativa (`google_sign_in`), que já devolve o ID token sem sair
/// do app.
Future<String?> pedirIdTokenDoGoogle({
  required String clientId,
  required String nonceHash,
  required Duration limite,
}) async =>
    null;
