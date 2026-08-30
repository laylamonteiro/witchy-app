import 'package:flutter_web_plugins/url_strategy.dart';

/// Na web: URL de caminho (`/enciclopedia` em vez de `/#/enciclopedia`), para o
/// go_router usar `MultiEntriesBrowserHistory` — uma entrada por tela.
void usarUrlDeCaminho() => usePathUrlStrategy();
