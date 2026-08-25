/// Fora da web não existe documento nem histórico de navegador: o voltar do
/// sistema chega como `popRoute` e é o `SystemNavigator.pop()` que responde.
void instalarVigiaDoCorrimao() {}

/// Sem corrimão, nenhum `pushRoute` é voltar — e fora da web o
/// `PorteiroDoVoltar` nem chega a perguntar.
bool oUltimoVoltarVeioDoCorrimao() => false;

/// Diagnóstico: quantos `popstate` este documento viu. Fora da web, nenhum.
int voltaresVistosPeloDocumento() => 0;

/// Fora da web não há janelinha de diagnóstico para alimentar.
void anotarVoltarTratadoPeloApp(int quantos) {}
