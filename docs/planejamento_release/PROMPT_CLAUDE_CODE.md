# 🎯 PROMPT PARA CLAUDE CODE - Grimório de Bolso
## Ajustes Finais Fase 1: Autenticação, Premium e Sincronização

---

## 📋 CONTEXTO DO PROJETO

Você está trabalhando no **Grimório de Bolso**, um app Flutter para bruxas/bruxos iniciantes no Brasil. O projeto está na **transição da Fase 1 (MVP Local-First) para Fase 2 (Backend + Premium)**.

### Stack Tecnológico
- **Framework**: Flutter 3.x + Dart 3.x
- **Estado**: Provider (flutter_riverpod)
- **Banco Local**: SQLite (sqflite)
- **Autenticação**: Firebase Auth (Google Sign-In + Email/Password)
- **Backend**: (A definir - FastAPI ou Supabase)
- **Pagamentos**: Google Play Billing / App Store In-App Purchases
- **Tema**: Pastel Goth / Whimsigoth (cores místicas, dark mode)

### Arquitetura Atual
```
lib/
├── core/
│   ├── database/           # DatabaseHelper (SQLite)
│   ├── theme/              # AppTheme, cores, tipografia
│   ├── widgets/            # Componentes reutilizáveis
│   ├── providers/          # Providers globais (Auth, Settings)
│   ├── services/           # Serviços (notificações, etc)
│   └── models/             # Modelos compartilhados
│
├── features/
│   ├── auth/               # Autenticação (login, cadastro)
│   ├── home/               # Tela principal + navegação
│   ├── lunar/              # Calendário lunar
│   ├── grimoire/           # Grimório de feitiços
│   ├── diary/              # Diários (sonhos, desejos)
│   ├── encyclopedia/       # Cristais, cores, ervas
│   ├── settings/           # Configurações do usuário
│   └── premium/            # Paywall, upgrade, gestão
│
└── main.dart
```

---

## 🎯 OBJETIVO GERAL

Resolver **11 ajustes críticos** antes do lançamento beta, organizados em **3 sprints por prioridade**:

**Sprint 1 (P0 - Crítico)**: Bloqueadores que impedem lançamento
**Sprint 2 (P1 - Importante)**: UX e conversão Premium
**Sprint 3 (P2 - Melhorias)**: Polimento e consistência

---

## 🔴 SPRINT 1: FUNDAÇÃO CRÍTICA (P0)

### ✅ AJUSTE #1: Sistema de Autenticação Obrigatório
**Problema**: Após desinstalar e reinstalar, o app abre direto sem pedir login.

**Causa Raiz**: Estado de autenticação sendo persistido incorretamente (SharedPreferences ou Firebase persistence).

**Solução Técnica**:

1. **Criar SplashPage com verificação robusta**
   - Localização: `lib/features/auth/presentation/pages/splash_page.dart`
   - Lógica:
     ```dart
     class SplashPage extends StatefulWidget {
       @override
       _SplashPageState createState() => _SplashPageState();
     }
     
     class _SplashPageState extends State<SplashPage> {
       @override
       void initState() {
         super.initState();
         _checkAuthStatus();
       }
       
       Future<void> _checkAuthStatus() async {
         // 1. Verificar token Firebase
         User? firebaseUser = FirebaseAuth.instance.currentUser;
         
         if (firebaseUser != null) {
           // 2. Verificar token expirado
           final isTokenValid = await _verifyTokenWithBackend(firebaseUser.uid);
           
           if (isTokenValid) {
             // 3. Carregar dados do usuário
             await Provider.of<AuthProvider>(context, listen: false).loadUser();
             Navigator.pushReplacementNamed(context, '/home');
           } else {
             // Token inválido, forçar logout
             await FirebaseAuth.instance.signOut();
             Navigator.pushReplacementNamed(context, '/auth');
           }
         } else {
           // Nenhum usuário, ir para login
           Navigator.pushReplacementNamed(context, '/auth');
         }
       }
       
       Future<bool> _verifyTokenWithBackend(String uid) async {
         // TODO: Chamar backend /auth/verify-token
         // Por enquanto, apenas verificar se token existe
         return true;
       }
       
       @override
       Widget build(BuildContext context) {
         return Scaffold(
           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
           body: Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 // Logo pixel art
                 Image.asset('assets/images/logo_pixel.png', width: 120),
                 SizedBox(height: 24),
                 CircularProgressIndicator(
                   valueColor: AlwaysStoppedAnimation<Color>(
                     Theme.of(context).colorScheme.primary,
                   ),
                 ),
               ],
             ),
           ),
         );
       }
     }
     ```

2. **Atualizar main.dart para usar SplashPage**
   - Localização: `lib/main.dart`
   - Mudança:
     ```dart
     MaterialApp(
       initialRoute: '/splash',  // ← Mudar de '/' ou '/auth'
       routes: {
         '/splash': (context) => SplashPage(),
         '/auth': (context) => AuthPage(),
         '/home': (context) => HomePage(),
         // ...
       },
     );
     ```

3. **Refatorar AuthProvider para não persistir sessão local**
   - Localização: `lib/core/providers/auth_provider.dart`
   - Remover qualquer `SharedPreferences.setBool('isLoggedIn', true)`
   - Confiar apenas em `FirebaseAuth.instance.currentUser`

4. **Implementar logout completo**
   ```dart
   Future<void> logout() async {
     // 1. Firebase
     await FirebaseAuth.instance.signOut();
     
     // 2. Google Sign In (se usado)
     final googleSignIn = GoogleSignIn();
     if (await googleSignIn.isSignedIn()) {
       await googleSignIn.signOut();
     }
     
     // 3. Limpar SharedPreferences (exceto settings de app)
     final prefs = await SharedPreferences.getInstance();
     final keysToKeep = ['theme_mode', 'locale', 'first_launch'];
     final allKeys = prefs.getKeys();
     for (final key in allKeys) {
       if (!keysToKeep.contains(key)) {
         await prefs.remove(key);
       }
     }
     
     // 4. Navegar para splash (que vai para /auth)
     Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
   }
   ```

**Testes Necessários**:
- [ ] Instalar app → Login → Fechar app → Reabrir (deve manter sessão)
- [ ] Instalar app → Login → Logout → Reabrir (deve pedir login)
- [ ] Instalar app → Login → Desinstalar → Reinstalar (deve pedir login)
- [ ] App em background por 24h → Reabrir (verificar token expirando)

---

### ✅ AJUSTE #5: Revogação de Acesso Premium
**Problema**: Usuário mantém Premium após refund ou cancelamento de assinatura.

**Causa Raiz**: Falta integração com webhooks de pagamento e verificação periódica.

**Solução Técnica**:

1. **Criar SubscriptionService**
   - Localização: `lib/core/services/subscription_service.dart`
   - Responsabilidades:
     - Verificar status no Google Play Billing
     - Sincronizar com backend
     - Gerenciar estado local de Premium
   
   ```dart
   class SubscriptionService {
     final InAppPurchase _iap = InAppPurchase.instance;
     final Dio _dio = Dio(); // HTTP client
     
     // IDs dos produtos (usar do Google Play Console)
     static const String premiumMonthly = 'grimorio_premium_monthly';
     static const String premiumYearly = 'grimorio_premium_yearly';
     
     /// Verifica status da assinatura no Google Play
     Future<bool> checkSubscriptionStatus() async {
       try {
         // 1. Buscar compras do Google Play
         final QueryPurchaseDetailsResponse response = 
             await _iap.queryPastPurchases();
         
         if (response.error != null) {
           print('Erro ao buscar compras: ${response.error}');
           return false;
         }
         
         // 2. Verificar se há assinatura ativa
         final activeSubs = response.pastPurchases.where((purchase) {
           return (purchase.productID == premiumMonthly || 
                   purchase.productID == premiumYearly) &&
                  purchase.status == PurchaseStatus.purchased;
         });
         
         if (activeSubs.isEmpty) {
           return false;
         }
         
         // 3. Verificar com backend (autoridade final)
         final backendStatus = await _verifyWithBackend(activeSubs.first);
         
         return backendStatus;
       } catch (e) {
         print('Erro ao verificar assinatura: $e');
         return false;
       }
     }
     
     /// Verifica com backend (que recebe webhooks do Google)
     Future<bool> _verifyWithBackend(PurchaseDetails purchase) async {
       try {
         final response = await _dio.post(
           'https://api.grimoriodebolso.com/subscription/verify',
           data: {
             'user_id': FirebaseAuth.instance.currentUser?.uid,
             'purchase_token': purchase.verificationData.serverVerificationData,
             'product_id': purchase.productID,
           },
         );
         
         return response.data['is_active'] == true;
       } catch (e) {
         print('Erro ao verificar com backend: $e');
         // Em caso de erro de rede, confiar no status local por até 24h
         return _checkLocalCache();
       }
     }
     
     /// Sincroniza status periodicamente (rodar a cada 6h)
     Future<void> syncSubscriptionStatus() async {
       final isActive = await checkSubscriptionStatus();
       
       // Atualizar estado global
       final prefs = await SharedPreferences.getInstance();
       await prefs.setBool('is_premium', isActive);
       
       // Notificar listeners (se usando Provider/Riverpod)
       // subscriptionNotifier.value = isActive;
     }
     
     /// Forçar verificação (chamar ao abrir telas Premium)
     Future<bool> verifyAccessToFeature(String featureId) async {
       final prefs = await SharedPreferences.getInstance();
       final cachedStatus = prefs.getBool('is_premium') ?? false;
       
       // Se cache diz que é Premium, verificar online
       if (cachedStatus) {
         final onlineStatus = await checkSubscriptionStatus();
         if (!onlineStatus) {
           // Remover acesso imediatamente
           await prefs.setBool('is_premium', false);
           return false;
         }
         return true;
       }
       
       return false;
     }
   }
   ```

2. **Integrar no app startup**
   - No `SplashPage`, após login, verificar Premium:
     ```dart
     if (firebaseUser != null) {
       await Provider.of<AuthProvider>(context, listen: false).loadUser();
       
       // Verificar status Premium
       final subscriptionService = SubscriptionService();
       await subscriptionService.syncSubscriptionStatus();
       
       Navigator.pushReplacementNamed(context, '/home');
     }
     ```

3. **Criar job periódico de sincronização**
   - Usar `workmanager` package para rodar a cada 6h:
   ```dart
   void callbackDispatcher() {
     Workmanager().executeTask((task, inputData) async {
       if (task == 'syncSubscription') {
         final subscriptionService = SubscriptionService();
         await subscriptionService.syncSubscriptionStatus();
       }
       return Future.value(true);
     });
   }
   
   void main() {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Registrar job periódico
     Workmanager().initialize(callbackDispatcher);
     Workmanager().registerPeriodicTask(
       "subscription-sync",
       "syncSubscription",
       frequency: Duration(hours: 6),
     );
     
     runApp(MyApp());
   }
   ```

4. **Backend: Webhook Endpoint** (pseudocódigo)
   ```python
   # Backend FastAPI
   @app.post("/webhook/google-play")
   async def handle_google_play_webhook(notification: GooglePlayNotification):
       """
       Recebe notificações do Google Play sobre mudanças em assinaturas.
       Tipos: SUBSCRIPTION_PURCHASED, SUBSCRIPTION_CANCELED, SUBSCRIPTION_RENEWED, etc.
       """
       if notification.notification_type == "SUBSCRIPTION_CANCELED":
           user_id = get_user_id_from_purchase_token(notification.purchase_token)
           
           # Remover acesso Premium
           await db.execute(
               "UPDATE users SET is_premium = false, premium_expires_at = NOW() WHERE id = ?",
               (user_id,)
           )
           
           # Enviar push notification
           await send_push_notification(
               user_id,
               "Sua assinatura Premium foi cancelada"
           )
       
       return {"status": "ok"}
   ```

**Testes Necessários**:
- [ ] Comprar Premium → Verificar acesso concedido
- [ ] Cancelar no Google Play → Verificar acesso removido (após sync)
- [ ] Pedir refund → Verificar acesso removido imediatamente
- [ ] Testar sync periódica (forçar após 6h)
- [ ] Testar offline → Online (verificar cache vs real)

---

### ✅ AJUSTE #8: Bug do Grimório Vazio
**Problema**: Página do grimório carrega vazia aleatoriamente.

**Causa Raiz**: Race condition no carregamento ou estado inconsistente do Provider.

**Solução Técnica**:

1. **Adicionar logs detalhados**
   - Localização: `lib/features/grimoire/presentation/providers/grimoire_provider.dart`
   - Adicionar print statements em cada etapa:
   ```dart
   class GrimoireProvider with ChangeNotifier {
     List<Spell> _spells = [];
     bool _isLoading = false;
     String? _error;
     
     Future<void> loadSpells() async {
       print('[GrimoireProvider] Iniciando carregamento...');
       _isLoading = true;
       _error = null;
       notifyListeners();
       
       try {
         print('[GrimoireProvider] Buscando do repositório...');
         final repository = GrimoireRepository();
         _spells = await repository.getAllSpells();
         
         print('[GrimoireProvider] Carregados ${_spells.length} feitiços');
         
         if (_spells.isEmpty) {
           print('[GrimoireProvider] WARNING: Lista vazia! Verificando DB...');
           final dbHelper = DatabaseHelper.instance;
           final count = await dbHelper.database.then((db) {
             return db.rawQuery('SELECT COUNT(*) as count FROM spells');
           });
           print('[GrimoireProvider] DB tem ${count.first['count']} feitiços');
         }
         
         _isLoading = false;
         notifyListeners();
       } catch (e, stackTrace) {
         print('[GrimoireProvider] ERRO ao carregar: $e');
         print('[GrimoireProvider] StackTrace: $stackTrace');
         _error = e.toString();
         _isLoading = false;
         notifyListeners();
       }
     }
   }
   ```

2. **Adicionar retry logic**
   ```dart
   Future<void> loadSpells({int retryCount = 0}) async {
     const maxRetries = 3;
     
     try {
       // ... código de carregamento ...
     } catch (e) {
       if (retryCount < maxRetries) {
         print('[GrimoireProvider] Tentativa ${retryCount + 1} falhou, tentando novamente em 1s...');
         await Future.delayed(Duration(seconds: 1));
         return loadSpells(retryCount: retryCount + 1);
       } else {
         print('[GrimoireProvider] Todas as tentativas falharam');
         _error = 'Não foi possível carregar feitiços. Verifique sua conexão.';
         _isLoading = false;
         notifyListeners();
       }
     }
   }
   ```

3. **Garantir inicialização do DB antes de carregar**
   - No `main.dart`:
   ```dart
   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     
     // Garantir DB inicializado
     await DatabaseHelper.instance.database;
     print('[Main] Database inicializado');
     
     // Seed inicial (se vazio)
     await DatabaseHelper.instance.seedDefaultSpells();
     
     runApp(MyApp());
   }
   ```

4. **Na UI, mostrar estados intermediários**
   - Localização: `lib/features/grimoire/presentation/pages/grimoire_page.dart`
   ```dart
   @override
   Widget build(BuildContext context) {
     return Consumer<GrimoireProvider>(
       builder: (context, provider, child) {
         // Estado: Carregando
         if (provider.isLoading) {
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 CircularProgressIndicator(),
                 SizedBox(height: 16),
                 Text('Carregando feitiços...'),
               ],
             ),
           );
         }
         
         // Estado: Erro
         if (provider.error != null) {
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.error_outline, size: 64, color: Colors.red),
                 SizedBox(height: 16),
                 Text('Ops! ${provider.error}'),
                 SizedBox(height: 16),
                 ElevatedButton(
                   onPressed: () => provider.loadSpells(),
                   child: Text('Tentar novamente'),
                 ),
               ],
             ),
           );
         }
         
         // Estado: Vazio (após carregamento bem-sucedido)
         if (provider.spells.isEmpty) {
           return Center(
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Icon(Icons.auto_stories, size: 64),
                 SizedBox(height: 16),
                 Text('Seu grimório está vazio'),
                 Text('Adicione seu primeiro feitiço!'),
                 SizedBox(height: 16),
                 ElevatedButton(
                   onPressed: () => Navigator.pushNamed(context, '/grimoire/add'),
                   child: Text('Criar Feitiço'),
                 ),
               ],
             ),
           );
         }
         
         // Estado: Lista com itens
         return ListView.builder(
           itemCount: provider.spells.length,
           itemBuilder: (context, index) {
             return SpellCard(spell: provider.spells[index]);
           },
         );
       },
     );
   }
   ```

**Testes Necessários**:
- [ ] Abrir app 50x seguidas (stress test)
- [ ] Alternar entre abas rapidamente
- [ ] Adicionar/Remover feitiço → Reabrir grimório
- [ ] Desativar dados → Abrir grimório (modo offline)
- [ ] Limpar cache do app → Reabrir

---

### ✅ AJUSTE #10: Sincronização na Nuvem
**Problema**: Dados não sincronizam com backend (feature faltando).

**Causa Raiz**: Feature não implementada ainda (MVP era local-first).

**Solução Técnica**:

1. **Definir estratégia de sincronização**
   - **Modelo**: Last-Write-Wins (mais simples para MVP)
   - **Conflitos**: Timestamp do backend sempre ganha
   - **Granularidade**: Por entidade (spell, dream, desire)
   - **Offline-first**: Fila local de mudanças

2. **Criar SyncService**
   - Localização: `lib/core/services/sync_service.dart`
   ```dart
   class SyncService {
     final Dio _dio = Dio();
     final DatabaseHelper _db = DatabaseHelper.instance;
     
     /// Sincroniza todos os dados do usuário
     Future<SyncResult> syncAll() async {
       try {
         // 1. Upload de mudanças locais
         await _uploadLocalChanges();
         
         // 2. Download de mudanças remotas
         await _downloadRemoteChanges();
         
         // 3. Atualizar timestamp de última sync
         final prefs = await SharedPreferences.getInstance();
         await prefs.setString('last_sync', DateTime.now().toIso8601String());
         
         return SyncResult.success();
       } catch (e) {
         print('[SyncService] Erro na sincronização: $e');
         return SyncResult.error(e.toString());
       }
     }
     
     /// Faz upload das mudanças locais para o backend
     Future<void> _uploadLocalChanges() async {
       final prefs = await SharedPreferences.getInstance();
       final lastSync = prefs.getString('last_sync');
       
       // Buscar entidades modificadas desde última sync
       final spells = await _db.getModifiedSpells(since: lastSync);
       final dreams = await _db.getModifiedDreams(since: lastSync);
       final desires = await _db.getModifiedDesires(since: lastSync);
       
       // Enviar para backend
       if (spells.isNotEmpty) {
         await _dio.post('/sync/spells', data: {'spells': spells.map((s) => s.toJson()).toList()});
       }
       
       if (dreams.isNotEmpty) {
         await _dio.post('/sync/dreams', data: {'dreams': dreams.map((d) => d.toJson()).toList()});
       }
       
       if (desires.isNotEmpty) {
         await _dio.post('/sync/desires', data: {'desires': desires.map((d) => d.toJson()).toList()});
       }
     }
     
     /// Faz download das mudanças remotas do backend
     Future<void> _downloadRemoteChanges() async {
       final prefs = await SharedPreferences.getInstance();
       final lastSync = prefs.getString('last_sync');
       
       // Buscar mudanças do backend
       final response = await _dio.get('/sync/changes', queryParameters: {
         'since': lastSync ?? '1970-01-01T00:00:00Z',
       });
       
       final changes = response.data;
       
       // Aplicar mudanças localmente
       if (changes['spells'] != null) {
         for (final spell in changes['spells']) {
           await _db.upsertSpell(Spell.fromJson(spell));
         }
       }
       
       if (changes['dreams'] != null) {
         for (final dream in changes['dreams']) {
           await _db.upsertDream(Dream.fromJson(dream));
         }
       }
       
       if (changes['desires'] != null) {
         for (final desire in changes['desires']) {
           await _db.upsertDesire(Desire.fromJson(desire));
         }
       }
     }
     
     /// Adiciona operação à fila de sincronização (para offline)
     Future<void> queueOperation(String type, String entityId, Map<String, dynamic> data) async {
       final db = await _db.database;
       await db.insert('sync_queue', {
         'id': Uuid().v4(),
         'type': type, // 'create', 'update', 'delete'
         'entity_type': data['entity_type'], // 'spell', 'dream', 'desire'
         'entity_id': entityId,
         'data': jsonEncode(data),
         'created_at': DateTime.now().toIso8601String(),
         'status': 'pending',
       });
     }
     
     /// Processa fila de operações pendentes
     Future<void> processQueue() async {
       final db = await _db.database;
       final pending = await db.query('sync_queue', where: 'status = ?', whereArgs: ['pending']);
       
       for (final op in pending) {
         try {
           await _processOperation(op);
           
           // Marcar como processado
           await db.update('sync_queue', 
             {'status': 'processed', 'processed_at': DateTime.now().toIso8601String()},
             where: 'id = ?', whereArgs: [op['id']],
           );
         } catch (e) {
           print('[SyncService] Erro ao processar operação ${op['id']}: $e');
           
           // Marcar como erro
           await db.update('sync_queue', 
             {'status': 'error', 'error': e.toString()},
             where: 'id = ?', whereArgs: [op['id']],
           );
         }
       }
     }
   }
   ```

3. **Adicionar campos de sincronização aos modelos**
   - Todos os modelos precisam de:
     ```dart
     class Spell {
       final String id;
       final String userId;
       final DateTime createdAt;
       final DateTime updatedAt;
       final DateTime? syncedAt;  // ← Novo
       final bool isSynced;        // ← Novo
       
       // ...
     }
     ```

4. **Integrar no app**
   - Sincronizar ao fazer login:
     ```dart
     // Em AuthProvider.login()
     await _syncService.syncAll();
     ```
   
   - Sincronizar periodicamente (a cada 30min):
     ```dart
     // Em main.dart
     Timer.periodic(Duration(minutes: 30), (timer) async {
       if (await Connectivity().checkConnectivity() != ConnectivityResult.none) {
         final authProvider = Provider.of<AuthProvider>(context, listen: false);
         if (authProvider.isAuthenticated) {
           await SyncService().syncAll();
         }
       }
     });
     ```
   
   - Sincronizar ao voltar online:
     ```dart
     Connectivity().onConnectivityChanged.listen((result) async {
       if (result != ConnectivityResult.none) {
         await SyncService().processQueue();
         await SyncService().syncAll();
       }
     });
     ```

5. **Adicionar indicador visual de sync**
   - Widget no AppBar:
   ```dart
   Consumer<SyncProvider>(
     builder: (context, sync, child) {
       if (sync.isSyncing) {
         return Row(
           children: [
             SizedBox(
               width: 16,
               height: 16,
               child: CircularProgressIndicator(strokeWidth: 2),
             ),
             SizedBox(width: 8),
             Text('Sincronizando...', style: TextStyle(fontSize: 12)),
           ],
         );
       }
       
       if (sync.lastSyncError != null) {
         return IconButton(
           icon: Icon(Icons.sync_problem, color: Colors.red),
           onPressed: () => sync.retrySync(),
           tooltip: 'Erro na sincronização. Toque para tentar novamente.',
         );
       }
       
       return Row(
         children: [
           Icon(Icons.cloud_done, size: 16, color: Colors.green),
           SizedBox(width: 4),
           Text('Sincronizado', style: TextStyle(fontSize: 12)),
         ],
       );
     },
   );
   ```

**Testes Necessários**:
- [ ] Criar feitiço offline → Conectar → Verificar sync
- [ ] Editar em 2 dispositivos simultaneamente → Resolver conflito
- [ ] Sincronizar 100+ itens → Verificar performance
- [ ] Desconectar no meio da sync → Verificar recovery
- [ ] Login em novo dispositivo → Baixar todos os dados

---

## 🟠 SPRINT 2: EXPERIÊNCIA PREMIUM (P1)

### ✅ AJUSTE #2: UI Condicional para OAuth
**Problema**: Opção "Alterar senha" aparece para usuários que entraram com Google.

**Solução Técnica**:

1. **Adicionar campo authMethod ao User**
   ```dart
   // lib/core/models/user.dart
   class User {
     final String id;
     final String email;
     final String? displayName;
     final String? photoURL;
     final AuthMethod authMethod; // ← Novo
     
     User({...});
   }
   
   enum AuthMethod {
     emailPassword,
     google,
     apple, // futuro
   }
   ```

2. **Detectar método no login**
   ```dart
   // lib/features/auth/presentation/providers/auth_provider.dart
   Future<void> signInWithGoogle() async {
     final googleUser = await _googleSignIn.signIn();
     // ...
     _currentUser = User(
       id: firebaseUser.uid,
       email: firebaseUser.email!,
       authMethod: AuthMethod.google, // ← Detectar
     );
   }
   ```

3. **Widget condicional em Settings**
   ```dart
   // lib/features/settings/presentation/widgets/password_section.dart
   class PasswordSection extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       final user = Provider.of<AuthProvider>(context).currentUser;
       
       // Não mostrar para OAuth
       if (user?.authMethod != AuthMethod.emailPassword) {
         return SizedBox.shrink();
       }
       
       return Card(
         child: ListTile(
           leading: Icon(Icons.lock_outline),
           title: Text('Alterar senha'),
           trailing: Icon(Icons.chevron_right),
           onTap: () => Navigator.pushNamed(context, '/settings/change-password'),
         ),
       );
     }
   }
   ```

---

### ✅ AJUSTE #3: Status Premium na UI
**Problema**: Botão "Virar Premium" aparece para quem já é Premium.

**Solução Técnica**:

1. **Criar PremiumStatusCard**
   ```dart
   // lib/features/settings/presentation/widgets/premium_status_card.dart
   class PremiumStatusCard extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return Consumer<SubscriptionProvider>(
         builder: (context, subscription, child) {
           if (!subscription.isPremium) {
             // Mostrar CTA para upgrade
             return _buildUpgradeCard(context);
           }
           
           // Mostrar status Premium
           return Card(
             color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
             child: Padding(
               padding: EdgeInsets.all(16),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       Icon(Icons.stars, color: Colors.amber, size: 32),
                       SizedBox(width: 12),
                       Text(
                         'Premium Ativo',
                         style: TextStyle(
                           fontSize: 20,
                           fontWeight: FontWeight.bold,
                           color: Theme.of(context).colorScheme.primary,
                         ),
                       ),
                     ],
                   ),
                   SizedBox(height: 12),
                   Text('Tipo: ${subscription.subscriptionType}'),
                   Text('Renova em: ${subscription.renewalDate?.format('dd/MM/yyyy')}'),
                   if (subscription.willCancelAtPeriodEnd)
                     Text(
                       'Cancelado (acesso até ${subscription.renewalDate?.format('dd/MM/yyyy')})',
                       style: TextStyle(color: Colors.orange),
                     ),
                   SizedBox(height: 16),
                   Row(
                     children: [
                       Expanded(
                         child: OutlinedButton(
                           onPressed: () => _manageSubscription(context),
                           child: Text('Gerenciar'),
                         ),
                       ),
                       if (!subscription.willCancelAtPeriodEnd) ...[
                         SizedBox(width: 12),
                         Expanded(
                           child: OutlinedButton(
                             onPressed: () => _cancelSubscription(context, subscription),
                             style: OutlinedButton.styleFrom(
                               foregroundColor: Colors.red,
                             ),
                             child: Text('Cancelar'),
                           ),
                         ),
                       ],
                     ],
                   ),
                 ],
               ),
             ),
           );
         },
       );
     }
     
     void _manageSubscription(BuildContext context) async {
       // Deep link para Google Play / App Store
       if (Platform.isAndroid) {
         final url = 'https://play.google.com/store/account/subscriptions?sku=grimorio_premium_monthly&package=com.grimoriodebolso.app';
         await launchUrl(Uri.parse(url));
       } else if (Platform.isIOS) {
         final url = 'https://apps.apple.com/account/subscriptions';
         await launchUrl(Uri.parse(url));
       }
     }
     
     void _cancelSubscription(BuildContext context, SubscriptionProvider subscription) async {
       final confirm = await showDialog<bool>(
         context: context,
         builder: (context) => AlertDialog(
           title: Text('Cancelar assinatura?'),
           content: Text(
             'Você terá acesso até ${subscription.renewalDate?.format('dd/MM/yyyy')}. '
             'Depois disso, perderá acesso a:\n\n'
             '• Grimório ilimitado\n'
             '• Mapa astral completo\n'
             '• Clima mágico diário\n'
             '• Jornadas guiadas\n'
             '• Sincronização na nuvem'
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context, false),
               child: Text('Manter Premium'),
             ),
             TextButton(
               onPressed: () => Navigator.pop(context, true),
               style: TextButton.styleFrom(foregroundColor: Colors.red),
               child: Text('Cancelar'),
             ),
           ],
         ),
       );
       
       if (confirm == true) {
         await subscription.cancelSubscription();
       }
     }
     
     Widget _buildUpgradeCard(BuildContext context) {
       return Card(
         child: Padding(
           padding: EdgeInsets.all(16),
           child: Column(
             children: [
               Icon(Icons.workspace_premium, size: 48, color: Colors.grey),
               SizedBox(height: 12),
               Text('Você está no plano Free'),
               SizedBox(height: 8),
               ElevatedButton(
                 onPressed: () => Navigator.pushNamed(context, '/premium'),
                 child: Text('Virar Premium'),
               ),
             ],
           ),
         ),
       );
     }
   }
   ```

---

### ✅ AJUSTE #4: Padronização de CTAs Premium
**Problema**: Botões de upgrade inconsistentes (cor, texto, ação).

**Solução Técnica**:

1. **Criar componente reutilizável**
   ```dart
   // lib/core/widgets/premium_button.dart
   class PremiumButton extends StatelessWidget {
     final String text;
     final VoidCallback? onPressed;
     final bool isOutlined;
     final IconData? icon;
     
     const PremiumButton({
       this.text = 'Virar Premium',
       this.onPressed,
       this.isOutlined = false,
       this.icon,
     });
     
     @override
     Widget build(BuildContext context) {
       final buttonStyle = isOutlined
           ? OutlinedButton.styleFrom(
               foregroundColor: Color(0xFFC9A7FF), // Lilás
               side: BorderSide(color: Color(0xFFC9A7FF)),
             )
           : ElevatedButton.styleFrom(
               backgroundColor: Color(0xFFC9A7FF), // Lilás
               foregroundColor: Color(0xFF2B2143), // Texto escuro
             );
       
       final child = Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           if (icon != null) ...[
             Icon(icon, size: 20),
             SizedBox(width: 8),
           ],
           Text(text),
         ],
       );
       
       return isOutlined
           ? OutlinedButton(
               onPressed: onPressed ?? () => _navigateToPaywall(context),
               style: buttonStyle,
               child: child,
             )
           : ElevatedButton(
               onPressed: onPressed ?? () => _navigateToPaywall(context),
               style: buttonStyle,
               child: child,
             );
     }
     
     void _navigateToPaywall(BuildContext context) {
       Navigator.pushNamed(context, '/premium');
     }
   }
   ```

2. **Substituir todas as instâncias**
   - Buscar no projeto: "Virar Premium", "Upgrade", "Premium", "Assinar"
   - Substituir por:
     ```dart
     PremiumButton(
       text: 'Virar Premium',
       icon: Icons.workspace_premium,
     )
     ```

3. **Locais típicos para atualizar**:
   - Settings page
   - Grimório (limite atingido)
   - Diários (features bloqueadas)
   - Enciclopédia (conteúdo bloqueado)
   - Mapa astral (feature completa)

---

### ✅ AJUSTE #11: Sistema de Beta Access
**Problema**: Não há forma de conceder Premium para beta testers.

**Solução Técnica**:

1. **Backend: Tabela de códigos**
   ```sql
   CREATE TABLE beta_codes (
     id UUID PRIMARY KEY,
     code VARCHAR(16) UNIQUE NOT NULL,
     created_by UUID REFERENCES users(id),
     created_at TIMESTAMP DEFAULT NOW(),
     expires_at TIMESTAMP,
     max_uses INT DEFAULT 1,
     used_count INT DEFAULT 0,
     status VARCHAR(20) DEFAULT 'active', -- active, revoked, expired
     notes TEXT
   );
   
   CREATE TABLE beta_code_redemptions (
     id UUID PRIMARY KEY,
     code_id UUID REFERENCES beta_codes(id),
     user_id UUID REFERENCES users(id),
     redeemed_at TIMESTAMP DEFAULT NOW(),
     ip_address VARCHAR(45),
     user_agent TEXT
   );
   ```

2. **Backend: Endpoints**
   ```python
   # POST /admin/beta-codes
   async def create_beta_code(
       count: int = 1,
       expires_days: int = 30,
       max_uses: int = 1,
       notes: str = None
   ):
       """Gera códigos beta (apenas para admins)"""
       codes = []
       for _ in range(count):
           code = generate_code()  # Ex: "GRIMORIO-BETA-XXXX"
           codes.append({
               'code': code,
               'expires_at': datetime.now() + timedelta(days=expires_days),
               'max_uses': max_uses,
               'notes': notes,
           })
       
       await db.insert_many('beta_codes', codes)
       return codes
   
   # POST /beta/redeem
   async def redeem_beta_code(code: str, user_id: str):
       """Resgata código beta"""
       # Validar código
       beta_code = await db.fetch_one(
           'SELECT * FROM beta_codes WHERE code = ? AND status = "active"',
           (code,)
       )
       
       if not beta_code:
           raise HTTPException(400, 'Código inválido ou expirado')
       
       if beta_code['used_count'] >= beta_code['max_uses']:
           raise HTTPException(400, 'Código já foi usado')
       
       if beta_code['expires_at'] < datetime.now():
           raise HTTPException(400, 'Código expirado')
       
       # Verificar rate limiting (1 código por IP/hora)
       recent = await db.fetch_one(
           'SELECT COUNT(*) as count FROM beta_code_redemptions '
           'WHERE ip_address = ? AND redeemed_at > ?',
           (request.client.host, datetime.now() - timedelta(hours=1))
       )
       
       if recent['count'] > 0:
           raise HTTPException(429, 'Aguarde 1 hora para resgatar outro código')
       
       # Conceder Premium
       await db.execute(
           'UPDATE users SET is_premium = true, premium_source = "beta", '
           'premium_expires_at = NULL WHERE id = ?',
           (user_id,)
       )
       
       # Registrar resgate
       await db.insert('beta_code_redemptions', {
           'code_id': beta_code['id'],
           'user_id': user_id,
           'ip_address': request.client.host,
           'user_agent': request.headers.get('user-agent'),
       })
       
       # Atualizar contador
       await db.execute(
           'UPDATE beta_codes SET used_count = used_count + 1 WHERE id = ?',
           (beta_code['id'],)
       )
       
       return {'success': True, 'message': 'Premium concedido!'}
   ```

3. **App: Tela de resgate**
   ```dart
   // lib/features/premium/presentation/pages/redeem_code_page.dart
   class RedeemCodePage extends StatefulWidget {
     @override
     _RedeemCodePageState createState() => _RedeemCodePageState();
   }
   
   class _RedeemCodePageState extends State<RedeemCodePage> {
     final _codeController = TextEditingController();
     bool _isRedeeming = false;
     String? _error;
     
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: Text('Resgatar Código')),
         body: Padding(
           padding: EdgeInsets.all(16),
           child: Column(
             children: [
               TextField(
                 controller: _codeController,
                 decoration: InputDecoration(
                   labelText: 'Código Beta',
                   hintText: 'GRIMORIO-BETA-XXXX',
                   errorText: _error,
                 ),
                 textCapitalization: TextCapitalization.characters,
               ),
               SizedBox(height: 24),
               ElevatedButton(
                 onPressed: _isRedeeming ? null : _redeemCode,
                 child: _isRedeeming
                     ? CircularProgressIndicator()
                     : Text('Resgatar'),
               ),
             ],
           ),
         ),
       );
     }
     
     Future<void> _redeemCode() async {
       setState(() {
         _isRedeeming = true;
         _error = null;
       });
       
       try {
         final response = await Dio().post(
           'https://api.grimoriodebolso.com/beta/redeem',
           data: {
             'code': _codeController.text.trim(),
             'user_id': FirebaseAuth.instance.currentUser?.uid,
           },
         );
         
         // Sucesso!
         await SubscriptionService().syncSubscriptionStatus();
         
         Navigator.pop(context);
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('🎉 Premium concedido!')),
         );
       } catch (e) {
         setState(() {
           _error = e.response?.data['message'] ?? 'Código inválido';
         });
       } finally {
         setState(() {
           _isRedeeming = false;
         });
       }
     }
   }
   ```

4. **Adicionar acesso em Settings**
   ```dart
   // Em SettingsPage, adicionar:
   ListTile(
     leading: Icon(Icons.confirmation_number),
     title: Text('Resgatar código'),
     trailing: Icon(Icons.chevron_right),
     onTap: () => Navigator.pushNamed(context, '/premium/redeem-code'),
   )
   ```

---

## 🟡 SPRINT 3: POLIMENTO (P2)

### ✅ AJUSTE #6: Consistência de Fontes
**Problema**: Títulos de cards Cristais/Ervas/Metais/Cores com fonte diferente de Deusas.

**Solução Técnica**:

1. **Criar constante de estilo de título**
   ```dart
   // lib/core/theme/text_styles.dart
   class AppTextStyles {
     static TextStyle cardTitle(BuildContext context) {
       return GoogleFonts.cinzelDecorative(
         fontSize: 18,
         fontWeight: FontWeight.bold,
         color: Theme.of(context).colorScheme.primary,
       );
     }
     
     static TextStyle cardSubtitle(BuildContext context) {
       return GoogleFonts.nunito(
         fontSize: 14,
         color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
       );
     }
   }
   ```

2. **Atualizar todos os cards**
   ```dart
   // lib/features/encyclopedia/presentation/widgets/crystal_card.dart
   Text(
     crystal.name,
     style: AppTextStyles.cardTitle(context), // ← Usar estilo consistente
   )
   ```

3. **Auditar e atualizar**:
   - [ ] CrystalCard
   - [ ] HerbCard
   - [ ] MetalCard
   - [ ] ColorCard
   - [ ] GoddessCard (já está correto, usar como referência)

---

### ✅ AJUSTE #7: Jornadas sem Contar Feitiços Pré-existentes
**Problema**: Gamificação conta feitiços que vieram com o app.

**Solução Técnica**:

1. **Adicionar campo source ao Spell**
   ```dart
   // lib/features/grimoire/data/models/spell.dart
   class Spell {
     final String id;
     final String userId;
     final String name;
     // ...
     final SpellSource source; // ← Novo
     
     Spell({...});
   }
   
   enum SpellSource {
     user,      // Criado pelo usuário
     default,   // Veio com o app
     imported,  // Importado de outra fonte (futuro)
   }
   ```

2. **Migration para adicionar coluna**
   ```sql
   ALTER TABLE spells 
   ADD COLUMN source TEXT DEFAULT 'default';
   ```

3. **Atualizar seeds para marcar como default**
   ```dart
   // lib/core/database/database_helper.dart
   Future<void> seedDefaultSpells() async {
     final spells = [
       Spell(
         id: Uuid().v4(),
         userId: 'system',
         name: 'Proteção da Casa',
         source: SpellSource.default, // ← Marcar
         // ...
       ),
       // ...
     ];
     
     for (final spell in spells) {
       await insertSpell(spell);
     }
   }
   ```

4. **Filtrar na lógica de jornadas**
   ```dart
   // lib/features/gamification/presentation/providers/journey_provider.dart
   int get userCreatedSpellsCount {
     return grimoire.spells
         .where((spell) => spell.source == SpellSource.user)
         .length;
   }
   
   // Jornada "Mestre do Grimório"
   bool get isMasterOfGrimoireComplete {
     return userCreatedSpellsCount >= 10;
   }
   ```

---

### ✅ AJUSTE #9: Remover "Entrar sem conta"
**Problema**: Opção disponível mas não deve ser usada (app agora requer conta).

**Solução Técnica**:

1. **Simplificar AuthPage**
   ```dart
   // lib/features/auth/presentation/pages/auth_page.dart
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       body: SafeArea(
         child: Padding(
           padding: EdgeInsets.all(24),
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               // Logo
               Image.asset('assets/images/logo.png', height: 120),
               SizedBox(height: 24),
               
               // Título
               Text(
                 'Grimório de Bolso',
                 style: GoogleFonts.cinzelDecorative(
                   fontSize: 28,
                   fontWeight: FontWeight.bold,
                 ),
               ),
               SizedBox(height: 12),
               Text(
                 'Seu companheiro mágico pessoal',
                 style: TextStyle(fontSize: 16),
                 textAlign: TextAlign.center,
               ),
               SizedBox(height: 48),
               
               // Botão Google
               ElevatedButton.icon(
                 onPressed: () => _signInWithGoogle(context),
                 icon: Image.asset('assets/images/google_logo.png', height: 20),
                 label: Text('Continuar com Google'),
                 style: ElevatedButton.styleFrom(
                   minimumSize: Size(double.infinity, 56),
                 ),
               ),
               SizedBox(height: 16),
               
               // Botão Email
               OutlinedButton.icon(
                 onPressed: () => Navigator.pushNamed(context, '/auth/email'),
                 icon: Icon(Icons.email_outlined),
                 label: Text('Continuar com Email'),
                 style: OutlinedButton.styleFrom(
                   minimumSize: Size(double.infinity, 56),
                 ),
               ),
               
               // ❌ REMOVER: Botão "Entrar sem conta"
               
               SizedBox(height: 24),
               Text(
                 'Ao continuar, você concorda com nossos\nTermos de Uso e Política de Privacidade',
                 style: TextStyle(fontSize: 12),
                 textAlign: TextAlign.center,
               ),
             ],
           ),
         ),
       ),
     );
   }
   ```

2. **Remover lógica de "usuário anônimo"**
   - Buscar e remover referências a:
     - `isAnonymous`
     - `guestMode`
     - `skipLogin`
     - `continueWithoutAccount`

---

## 🛠️ IMPLEMENTAÇÃO PRÁTICA

### Ordem de Execução Recomendada

1. **Primeira rodada (crítico, 1-2 dias)**:
   - Ajuste #1 (Login obrigatório)
   - Ajuste #8 (Bug grimório vazio)
   - Ajuste #9 (Remover entrada sem conta)

2. **Segunda rodada (premium, 1-2 dias)**:
   - Ajuste #5 (Revogação Premium)
   - Ajuste #3 (Status Premium UI)
   - Ajuste #4 (Padronizar CTAs)

3. **Terceira rodada (features, 2-3 dias)**:
   - Ajuste #10 (Sincronização)
   - Ajuste #11 (Beta access)

4. **Quarta rodada (polimento, 1 dia)**:
   - Ajuste #2 (UI condicional OAuth)
   - Ajuste #6 (Consistência de fontes)
   - Ajuste #7 (Jornadas)

### Checklist de Testes (após cada ajuste)

#### Testes de Autenticação
- [ ] Instalar app novo → Deve pedir login
- [ ] Login → Fechar → Reabrir → Deve manter sessão
- [ ] Logout → Reabrir → Deve pedir login
- [ ] Desinstalar → Reinstalar → Deve pedir login
- [ ] Login Google → Não deve mostrar "Alterar senha"
- [ ] Login Email → Deve mostrar "Alterar senha"

#### Testes de Premium
- [ ] Comprar Premium → Verificar acesso concedido imediatamente
- [ ] Cancelar Premium → Verificar acesso mantido até fim do período
- [ ] Fim do período → Verificar acesso removido
- [ ] Refund → Verificar acesso removido imediatamente
- [ ] Resgatar código beta → Verificar Premium concedido
- [ ] Usuário Premium → Não deve ver "Virar Premium"
- [ ] Usuário Premium → Deve ver status e renovação
- [ ] Todos os CTAs Premium devem abrir PaywallPage

#### Testes de Sincronização
- [ ] Criar feitiço → Verificar sync para nuvem
- [ ] Login em 2 dispositivos → Verificar dados sincronizados
- [ ] Editar offline → Conectar → Verificar sync
- [ ] Conflito de edição → Verificar resolução (last-write-wins)
- [ ] Instalar em novo dispositivo → Baixar todos os dados

#### Testes de Grimório
- [ ] Abrir grimório 50x seguidas → Nunca deve ficar vazio
- [ ] Adicionar feitiço → Reabrir → Deve aparecer
- [ ] Grimório vazio → Deve mostrar empty state
- [ ] Grimório com 100+ feitiços → Verificar performance

#### Testes de Jornadas
- [ ] Feitiços default não devem contar
- [ ] Criar 1 feitiço → Verificar progresso
- [ ] Criar 10 feitiços → Completar "Mestre do Grimório"

#### Testes de UI
- [ ] Verificar consistência de fontes em todos os cards
- [ ] Verificar cores seguem paleta (lilás, rosa, menta, amarelo)
- [ ] Verificar espaçamentos consistentes
- [ ] Modo claro/escuro funcionando

---

## 📊 MÉTRICAS DE SUCESSO

### Sprint 1 (P0) - Deve atingir 100%
- ✅ 0 usuários conseguem entrar sem login
- ✅ 0 reports de grimório vazio
- ✅ 100% dos usuários forçados a criar conta

### Sprint 2 (P1) - Deve atingir 95%+
- ✅ 100% dos cancelamentos removem acesso
- ✅ 0 usuários Premium veem "Virar Premium"
- ✅ 100% dos CTAs Premium funcionam
- ✅ 30+ beta testers com acesso controlado

### Sprint 3 (P2) - Deve atingir 100%
- ✅ 100% dos cards com fonte consistente
- ✅ Jornadas progridem apenas com feitiços do usuário
- ✅ 95%+ de sucesso em sincronizações

---

## 🚨 PONTOS DE ATENÇÃO

### Segurança
- Nunca armazenar tokens de pagamento localmente
- Validar SEMPRE no backend (app pode ser hackeado)
- Rate limiting em endpoints sensíveis (redeem, verify)
- HTTPS obrigatório em todas as chamadas

### Performance
- Sincronização em background (não bloquear UI)
- Paginação para grimório com 100+ itens
- Índices no SQLite para queries frequentes
- Cache de imagens e assets

### Experiência do Usuário
- Loading states em todas as operações
- Mensagens de erro claras e actionáveis
- Retry automático em falhas de rede
- Feedback visual para ações (toast, snackbar)

### Backend
- Implementar idempotência em webhooks
- Logging detalhado de eventos de pagamento
- Monitoramento de falhas de sincronização
- Backup diário do banco de dados

---

## 📝 NOTAS FINAIS

Este prompt foi estruturado para permitir implementação incremental, com cada ajuste podendo ser testado independentemente. Priorize a ordem sugerida, mas sinta-se livre para adaptar conforme necessário.

**Após implementação completa**:
- Rodar todos os testes listados
- Fazer code review
- Gerar APK de teste
- Distribuir para beta testers
- Coletar feedback por 1-2 semanas
- Ajustar antes do lançamento público

**Boa sorte! 🔮✨**
