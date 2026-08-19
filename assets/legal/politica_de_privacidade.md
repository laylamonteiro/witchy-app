# Política de Privacidade — Grimório de Bolso

Última atualização: 19 de agosto 2026

Sua intimidade espiritual é sagrada — e seus dados também. Esta política explica, em linguagem direta, o que coletamos, por quê, e o que NUNCA fazemos.

## 1. Resumo em uma vela

- Seus registros (feitiços, diários, sonhos, reflexões) ficam no SEU aparelho.
- A sincronização na nuvem é opcional, exclusiva do Premium, e protegida por regras que só permitem a VOCÊ acessar seus dados.
- Não vendemos seus dados. Nunca.
- Textos enviados ao Conselheiro Místico são processados para gerar a resposta e não são usados para outros fins pelo aplicativo.
- A foto da leitura de mãos é processada na hora e descartada — não é armazenada.
- As fotos que você anexa (perfil e verbetes da enciclopédia) ficam no seu aparelho no aplicativo de celular; no navegador, são guardadas em um espaço privado da sua conta, acessível só por você.

## 2. O que coletamos e por quê

### Dados de conta (se você criar uma)
Nome de exibição, e-mail e credenciais — para autenticação e recuperação de acesso. Provedor: Supabase.

### Conteúdo que você cria
Feitiços, diários (sonhos, desejos, gratidão, afirmações, reflexões), sigilos, leituras salvas, perfil mágico e preferências (tema, idioma, gênero de tratamento). Armazenados localmente no aparelho; sincronizados com a nuvem apenas se você for Premium E ativar a sincronização.

Também entram aqui as **fotos que você anexa**: a imagem de perfil e as fotos dos verbetes que você cria na enciclopédia. No aplicativo de celular elas ficam no próprio aparelho. No navegador não existe essa pasta local, então são enviadas para um armazenamento privado da sua conta (Supabase Storage) — veja a seção 4.

### Dados de nascimento (opcionais)
Data, hora e local — usados exclusivamente para cálculos de astrologia e numerologia.

### Dados de pagamento
Assinaturas são processadas pela loja (Google Play/App Store) via RevenueCat. Não temos acesso ao número do seu cartão.

### Dados técnicos mínimos
Registros de erro para diagnóstico e estatísticas de uso agregadas (se habilitadas nas configurações de privacidade), sem conteúdo pessoal dos seus registros.

## 3. O Conselheiro Místico (recursos inteligentes)

Para gerar respostas (feitiços, interpretações de sonhos e tiragens, explicações de numerologia, leitura de mãos), o texto que você fornece — e, na quiromancia, a foto da palma — é enviado de forma segura ao provedor de processamento (Groq) e usado apenas para gerar aquela resposta.

- A foto da palma é redimensionada no aparelho, enviada, processada e descartada — não fica salva em lugar nenhum.
- Suas anotações pessoais NUNCA são enviadas sem você acionar um recurso do Conselheiro.
- O idioma e a forma de tratamento escolhidos acompanham a solicitação para personalizar a resposta.

## 4. Onde seus dados vivem

- **No aparelho**: banco local (SQLite) e preferências. Desinstalar o app sem backup apaga esses dados.
- **Na nuvem (opcional, Premium)**: Supabase, com Row Level Security — cada conta só enxerga os próprios registros.
- **Fotos anexadas, quando usadas pelo navegador**: armazenamento privado no Supabase Storage. Os arquivos ficam em uma pasta identificada pela sua conta, e as regras do servidor impedem que uma pessoa acesse a pasta de outra. O armazenamento não é público: para exibir a imagem, o aplicativo gera um endereço temporário, válido por cerca de uma hora. Ao remover a foto no aplicativo, o arquivo é apagado do armazenamento.

## 5. Compartilhamento

Compartilhamos dados apenas com os operadores necessários ao funcionamento: Supabase (conta e sincronização), RevenueCat/lojas (assinaturas) e Groq (respostas do Conselheiro). Não vendemos nem alugamos dados pessoais a terceiros.

## 6. Seus direitos (LGPD)

Você pode, a qualquer momento:

- **Acessar e exportar** seus dados (Perfil → Gerenciar Seus Dados → Exportar);
- **Corrigir** informações do perfil;
- **Excluir** dados locais e/ou a conta com os dados na nuvem (Perfil → Gerenciar Seus Dados);
- **Desativar** estatísticas e relatórios de erro nas configurações de privacidade;
- **Revogar** a sincronização em nuvem quando quiser.

A exclusão da conta remove seus dados da nuvem; dados locais são de controle direto seu.

## 7. Permissões do aparelho

- **Câmera/Galeria**: para a leitura de mãos (Premium), a foto de perfil e as fotos dos verbetes que você cria na enciclopédia, sempre por ação sua.
- **Notificações**: lembretes de lua e sabás, se você permitir.
- **Galeria (salvar)**: exportação de sigilos, por ação sua.

## 8. Crianças e adolescentes

O aplicativo não é direcionado a menores de 13 anos e não coletamos conscientemente dados de crianças.

## 9. Segurança

Usamos comunicação criptografada (HTTPS), autenticação segura e isolamento por usuário na nuvem. Nenhum sistema é infalível — mantenha sua senha protegida.

## 10. Alterações desta política

Publicaremos atualizações no próprio aplicativo, com data de revisão. Mudanças significativas serão destacadas.

## 11. Contato e encarregado (DPO)

Dúvidas ou solicitações sobre dados pessoais: suporte.grimoriodebolso@gmail.com
