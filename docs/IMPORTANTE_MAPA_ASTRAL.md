# ⚠️ IMPORTANTE: Sobre o Cálculo de Mapa Astral

## Horário de Nascimento - Como Informar Corretamente

Para que o mapa astral seja calculado com PRECISÃO, é **extremamente importante** informar:

### ✅ Hora CORRETA
- **Informe a hora LOCAL do local onde você nasceu**
- Exemplo: Se você nasceu em São Paulo às HH:MM (horário de São Paulo), informe **HH:MM**
- **NÃO** converta para UTC ou outro fuso horário
- **NÃO** considere horário de verão - informe a hora que estava no relógio naquele dia

### 📍 Local EXATO
- Use o autocomplete para selecionar o local preciso
- Quanto mais específico, melhor (cidade exata, não apenas estado/país)
- As coordenadas são usadas para determinar automaticamente o fuso horário

### 🕐 Como Funciona Internamente

1. Você informa: **dd/mm/aaaa às HH:MM em São Paulo, Brazil**
2. O app envia para a API:
   - Datetime: `1994-03-31THH:MM:00` (horário local, SEM timezone)
   - Coordenadas: `-23.5505, -46.6333`
3. A API Prokerala:
   - Detecta que São Paulo está em UTC-3
   - Calcula as posições planetárias considerando o fuso horário correto
   - Retorna o mapa astral preciso

### ❌ Erros Comuns

**ERRADO**: "Nasci em São Paulo às HH:MM, mas agora estou em Lisboa, então vou converter para horário de Lisboa"
- ❌ Isso vai gerar um mapa incorreto!

**CERTO**: "Nasci em São Paulo às HH:MM, então informo HH:MM e seleciono São Paulo como local"
- ✅ Isso vai gerar um mapa correto!

### 🔍 Como Verificar se Está Correto

Compare o mapa gerado com:
- **astro.com** (https://www.astro.com/cgi/chart.cgi)
- Informe os mesmos dados (data, hora local, cidade)
- Os planetas devem estar nas mesmas posições (máximo ±1° de diferença)

### 📝 Correções Recentes

**Commit atual**: Corrigido problema de fuso horário
- Antes: O app enviava o datetime no timezone do dispositivo
- Agora: O app envia o datetime como horário local + coordenadas
- Resultado: A API calcula corretamente o timezone do local de nascimento

---

**Data da correção**: 20/11/2025
**Versão**: Fase 4 - Correção de timezone
