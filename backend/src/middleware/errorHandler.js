// src/middleware/errorHandler.js
function notFound(req, res, next) {
  res.status(404);
  const error = new Error(`Rota não encontrada - ${req.originalUrl}`);
  next(error);
}

function errorHandler(err, req, res, next) { // eslint-disable-line no-unused-vars
  console.error(err);
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  res.status(statusCode);
  res.json({
    message: err.message || 'Erro interno do servidor',
  });
}

module.exports = { notFound, errorHandler };
