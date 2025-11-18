// src/routes/spells.js
const express = require('express');
const router = express.Router();
const Spell = require('../models/spellModel');

router.get('/', async (req, res, next) => {
  try {
    const spells = await Spell.getAllSpells();
    res.json(spells);
  } catch (err) {
    next(err);
  }
});

router.get('/:id', async (req, res, next) => {
  try {
    const spell = await Spell.getSpellById(req.params.id);
    if (!spell) {
      res.status(404);
      throw new Error('Feitiço não encontrado');
    }
    res.json(spell);
  } catch (err) {
    next(err);
  }
});

router.post('/', async (req, res, next) => {
  try {
    const created = await Spell.createSpell(req.body);
    res.status(201).json(created);
  } catch (err) {
    next(err);
  }
});

router.put('/:id', async (req, res, next) => {
  try {
    const updated = await Spell.updateSpell(req.params.id, req.body);
    if (!updated) {
      res.status(404);
      throw new Error('Feitiço não encontrado');
    }
    res.json(updated);
  } catch (err) {
    next(err);
  }
});

router.delete('/:id', async (req, res, next) => {
  try {
    const deleted = await Spell.deleteSpell(req.params.id);
    if (!deleted) {
      res.status(404);
      throw new Error('Feitiço não encontrado');
    }
    res.json({ success: true });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
