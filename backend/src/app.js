// src/app.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');

const spellsRoutes = require('./routes/spells');
const dreamsRoutes = require('./routes/dreams');
const desiresRoutes = require('./routes/desires');
const ritualsRoutes = require('./routes/rituals');
const { notFound, errorHandler } = require('./middleware/errorHandler');

const app = express();

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Grimório de Bolso API' });
});

app.use('/api/spells', spellsRoutes);
app.use('/api/dreams', dreamsRoutes);
app.use('/api/desires', desiresRoutes);
app.use('/api/rituals', ritualsRoutes);

app.use(notFound);
app.use(errorHandler);

module.exports = app;
