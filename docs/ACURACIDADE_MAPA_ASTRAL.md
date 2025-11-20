# 🎯 Acuracidade do Mapa Astral - O Que Afeta e Como Testar

## ✅ Correções que MELHORAM a Acuracidade

### 1. Correção de Timezone (Commit: 31055d3)
**Arquivo**: `lib/features/astrology/data/services/external_chart_api.dart`

**O que foi corrigido**:
- Datetime agora é enviado sem sufixo de timezone: `YYYY-MM-DDTHH:mm:ss`
- API Prokerala recebe hora LOCAL do nascimento + coordenadas
- API usa coordenadas para determinar timezone correto do local de nascimento

**Antes (ERRADO)**:
```dart
birthDate.toIso8601String()
// Resultado: "1994-03-31T19:39:00-03:00"
// ❌ Enviava timezone do dispositivo, não do local de nascimento
```

**Depois (CORRETO)**:
```dart
'${birthDate.year}-${birthDate.month}-${birthDate.day}T${birthDate.hour}:${birthDate.minute}:${birthDate.second}'
// Resultado: "1994-03-31T19:39:00"
// ✅ Envia hora local, API calcula timezone pelas coordenadas
```

**Impacto**: 🌟🌟🌟🌟🌟 (Crítico para acuracidade)

---

## ❌ Correções que NÃO Afetam Acuracidade

### 1. Correção de Crashes (Commits: 7d0e88f, 32a9e2c)
**Arquivo**: `lib/features/astrology/data/services/transit_interpreter.dart`

**O que foi corrigido**:
- Clima Mágico Diário não crasheava mais
- Sugestões Personalizadas não ficavam em branco
- Trânsitos estimados quando cálculos falham

**Impacto na acuracidade do MAPA NATAL**: ⭐ (Zero)
**Impacto na acuracidade dos TRÂNSITOS**: 🌟🌟 (Médio - usa estimativas se cálculo falhar)

---

## 🔍 Como Verificar se a Acuracidade Melhorou

### Dados de Teste Conhecidos

Use estes dados para testar (comparar com astro.com):

**Exemplo 1: São Paulo**
- Data: 31/03/1994
- Hora: 19:39 (hora LOCAL de São Paulo)
- Local: São Paulo, SP, Brasil
- Coordenadas: -23.5505, -46.6333
- Timezone esperado: UTC-3 (ou UTC-2 se horário de verão)

**Posições esperadas** (aproximadas):
- Sol: ~10-11° Áries
- Lua: ~16-17° Escorpião
- Ascendente: ~23-24° Virgem

---

### Passo a Passo para Testar

1. **Limpar completamente o app**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Criar novo mapa astral** com os dados de teste acima

3. **Verificar nos logs**:
   ```
   📡 Tentando usar API externa (Prokerala)...
   📅 DateTime LOCAL (sem TZ): 1994-03-31T19:39:00
   📍 Coordenadas: -23.5505,-46.6333
   ✅ API externa funcionou! Usando cálculos precisos.
   ```

4. **Se ver este log**, a API **NÃO está sendo usada**:
   ```
   ❌ Erro na API externa: [erro]
   ⚠️ Usando cálculos locais como fallback (±2° precisão)
   ```

5. **Comparar resultados**:
   - Acesse https://www.astro.com/cgi/chart.cgi
   - Use EXATAMENTE os mesmos dados
   - Compare as posições planetárias

---

## 🎯 O Que Pode Ainda Estar Afetando Acuracidade

### 1. API Não Está Sendo Chamada
**Sintomas**:
- Logs mostram "Usando cálculos locais como fallback"
- Erro de autenticação OAuth

**Soluções**:
- Verificar se credenciais estão corretas em `prokerala_credentials.dart`
- Verificar conexão com internet
- Verificar se API Prokerala está funcionando

### 2. Credenciais Inválidas
**Sintomas**:
- Erro 401 ou 403 nos logs
- "Credenciais inválidas"

**Solução**:
- Revogar credenciais antigas em https://api.prokerala.com/
- Criar novas credenciais
- Atualizar `prokerala_credentials.dart`

### 3. Horário de Verão
**Sintomas**:
- Posições planetárias com ~1 hora de diferença
- Ascendente muito diferente

**Observação**:
- A API Prokerala DEVE calcular automaticamente horário de verão
- Se não estiver calculando, pode ser bug da API

### 4. Cálculos Locais (Fallback)
**Sintomas**:
- Logs mostram "±2° precisão"
- Posições com 1-3° de diferença

**Nota**:
- Cálculos locais são aproximações matemáticas
- Não incluem nutação, precessão precisa, etc.
- SEMPRE tente usar a API externa para acuracidade máxima

---

## 📊 Níveis de Acuracidade

### 🌟🌟🌟🌟🌟 Excelente (API Externa)
- Diferença: ±0.1° nas posições planetárias
- Swiss Ephemeris (biblioteca profissional)
- Considera: nutação, precessão, timezone automático

### 🌟🌟🌟 Boa (Cálculos Locais)
- Diferença: ±2° nas posições planetárias
- Cálculos matemáticos simplificados
- Não considera: nutação fina, alguns asteroides

### ⭐ Ruim (Sem Hora de Nascimento)
- Usa meio-dia (12:00) como padrão
- Ascendente e Casas INCORRETOS
- Lua pode ter ±7° de erro

---

## 🚀 Próximos Passos

1. **TESTE** com os dados acima e compare com astro.com
2. **VERIFIQUE** os logs para ver se API está sendo usada
3. **RELATE** os resultados:
   - A API foi chamada com sucesso?
   - As posições estão próximas do astro.com?
   - Qual a diferença em graus?

---

## 📝 Resumo Rápido

| Correção | Arquivo | Afeta Mapa Natal? | Afeta Trânsitos? |
|----------|---------|-------------------|------------------|
| Timezone fix | `external_chart_api.dart` | ✅ SIM (Crítico) | ❌ NÃO |
| Crash fixes | `transit_interpreter.dart` | ❌ NÃO | ✅ SIM (Médio) |
| Essential transits | `transit_interpreter.dart` | ❌ NÃO | ✅ SIM (Médio) |

**Para melhorar acuracidade do MAPA NATAL**: A correção de timezone (commit 31055d3) é a chave!
**Para evitar crashes**: As correções recentes (commits 7d0e88f, 32a9e2c) resolvem!
