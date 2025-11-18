// src/routes/desires.js
const express = require('express');
const router = express.Router();
const Desire = require('../models/desireModel');

router.get('/', async (req, res, next) => {
  try {
    const desires = await Desire.getAllDesires();
    res.json(desires);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const desire = await Desire.getDesireById(req.params.id);
    if (!desire) {
      res.status(404);
      throw new Error('Desejo não encontrado');
    }
    res.json(desire);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const created = await Desire.createDesire(req.body);
    res.status(201).json(created);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const updated = await Desire.updateDesire(req.params.id, req.body);
    if (!updated) {
      res.status(404);
      throw new Error('Desejo não encontrado');
    }
    res.json(updated);
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const deleted = await Desire.deleteDesire(req.params.id);
    if (!deleted) {
      res.status(404);
      throw new Error('Desejo não encontrado');
    }
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
