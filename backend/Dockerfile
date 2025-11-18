# Dockerfile para backend do Grimório de Bolso
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

COPY src ./src
COPY .env.example ./

ENV NODE_ENV=production

EXPOSE 3000

CMD ["node", "src/server.js"]
