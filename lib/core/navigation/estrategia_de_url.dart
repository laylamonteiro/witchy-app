/// URL de caminho (sem `#`) na web, para o histórico do navegador crescer uma
/// entrada por tela — ver [criarAppRouter].
///
/// `package:flutter_web_plugins` é SÓ da web e quebra a compilação nativa
/// (Android/iOS), então a implementação real fica atrás de importação
/// condicional. Fora da web, o stub é um no-op.
export 'estrategia_de_url_stub.dart'
    if (dart.library.js_interop) 'estrategia_de_url_web.dart';
