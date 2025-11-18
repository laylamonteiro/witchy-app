// src/routes/rituals.js
const express = require('express');
const router = express.Router();
const Ritual = require('../models/ritualModel');

router.get('/', async (req, res, next) => {
  try {
    const rituals = await Ritual.getAllRituals();
    res.json(rituals);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const ritual = await Ritual.getRitualById(req.params.id);
    if (!ritual) {
      res.status(404);
      throw new Error('Ritual não encontrado');
    }
    res.json(ritual);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const created = await Ritual.createRitual(req.body);
    res.status(201).json(created);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const updated = await Ritual.updateRitual(req.params.id, req.body);
    if (!updated) {
      res.status(404);
      throw new Error('Ritual não encontrado');
    }
    res.json(updated);
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const deleted = await Ritual.deleteRitual(req.params.id);
    if (!deleted) {
      res.status(404);
      throw new Error('Ritual não encontrado');
    }
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
