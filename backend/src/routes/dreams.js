// src/routes/dreams.js
const express = require('express');
const router = express.Router();
const Dream = require('../models/dreamModel');

router.get('/', async (req, res, next) => {
  try {
    const dreams = await Dream.getAllDreams();
    res.json(dreams);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const dream = await Dream.getDreamById(req.params.id);
    if (!dream) {
      res.status(404);
      throw new Error('Sonho não encontrado');
    }
    res.json(dream);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const created = await Dream.createDream(req.body);
    res.status(201).json(created);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const updated = await Dream.updateDream(req.params.id, req.body);
    if (!updated) {
      res.status(404);
      throw new Error('Sonho não encontrado');
    }
    res.json(updated);
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const deleted = await Dream.deleteDream(req.params.id);
    if (!deleted) {
      res.status(404);
      throw new Error('Sonho não encontrado');
    }
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
