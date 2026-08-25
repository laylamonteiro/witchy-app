/// Recomeçar o app na raiz do site, descartando o documento atual — o
/// conserto do histórico depois da volta do login social (ver o chamador no
/// AuthWrapper). Fora da web é um no-op: lá não existe documento.
export 'recomeco_stub.dart'
    if (dart.library.js_interop) 'recomeco_web.dart';
