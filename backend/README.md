# Backend – Grimório de Bolso (API REST)

Stack:
- Node.js + Express
- MySQL (com JSON para tags)
- Pensado para deploy em AWS (por exemplo, ECS Fargate ou EC2/Elastic Beanstalk).

## Como rodar localmente

1. Crie o banco e tabelas:

```bash
mysql -u root -p < sql/schema.sql
```

2. Crie um arquivo `.env` baseado em `.env.example`:

```bash
cp .env.example .env
```

Ajuste `DB_HOST`, `DB_USER`, `DB_PASSWORD` e `DB_NAME`.

3. Instale as dependências e suba a API:

```bash
npm install
npm run dev
```

4. Teste a API:

```bash
curl http://localhost:3000/health
```

Endpoints principais:

- `GET /api/spells` – lista feitiços
- `POST /api/spells` – cria feitiço
- `PUT /api/spells/:id` – atualiza
- `DELETE /api/spells/:id` – remove

E equivalentes para:

- `/api/dreams`
- `/api/desires`
- `/api/rituals`
