// src/server.js
const app = require('./app');

const port = process.env.PORT || 3000;

app.listen(port, () => {
  console.log(`Grimório de Bolso API ouvindo na porta ${port}`);
});
