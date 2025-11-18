# Grimório de Bolso – MVP


Este repositório contém um esqueleto funcional do MVP do app **Grimório de Bolso**, dividido em:

- `app/` – Aplicativo Flutter (MVP offline, com navegação, telas principais e repositórios em memória).
- `backend/` – API Node.js/Express com MySQL (pensada para deploy em AWS posteriormente).
- `sql/` – Script inicial de criação de tabelas no MySQL.
> Observação: este é um ponto de partida. A persistência local está em memória; você pode trocar por `sqflite` ou outro banco local. O backend não está integrado ao app no MVP offline, mas a estrutura está pronta para futura sincronização.

## Estrutura

- `app/` – Flutter (MVP offline)
- `backend/` – API Node.js/Express + MySQL (para rodar em AWS)

Flutter + backend Node/Express + MySQL + SQL + Dockerfile:

O que vem dentro

app/ – código do app Flutter:

lib/main.dart + navegação com bottom bar (Início, Lua, Grimório, Diários, Mais)

Telas:

Home (HomeScreen)

Calendário Lunar (CalendarScreen) com cálculo de fase da lua

Grimório (SpellsListScreen + SpellFormScreen)

Diários: Sonhos e Desejos (DiariesShell, DreamsListScreen, DesiresListScreen + forms)

Mais (MoreScreen) com cristais e cores mágicas estáticas


Models: Spell, Dream, Desire, RitualReminder, Crystal, MagicColor

Repositórios em memória (MVP offline): spell_repository.dart, dream_repository.dart, desire_repository.dart

Paleta dark com vibe mística.


> Obs.: é um esqueleto Flutter focado em lib/ + pubspec.yaml. 

Para rodar:

Crie um projeto Flutter vazio (flutter create app)

Substitua a pasta lib/ pela deste zip e copie o pubspec.yaml.


backend/ – API Node.js + Express + MySQL, pronta para subir em AWS (ECS/EC2/etc.):

package.json com express, mysql2, cors, dotenv, morgan

src/config/db.js – pool MySQL usando variáveis de ambiente

src/app.js + src/server.js

src/middleware/errorHandler.js

Models:

spellModel.js

dreamModel.js

desireModel.js

ritualModel.js


Rotas:

/api/spells

/api/dreams

/api/desires

/api/rituals


Dockerfile para conteinerizar o backend

.env.example com:

DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME, PORT


backend/README.md com passo a passo de execução.


backend/sql/schema.sql

Cria o banco grimorio_db

Tabelas:

spells (tags em JSON, tipo como ENUM('attraction','banishment'))

dreams (tags JSON, data, título, conteúdo, sentimento ao acordar)

desires (status ENUM('open','inProgress','realized'))

ritual_reminders (tipo, label, hora, minuto, enabled)

