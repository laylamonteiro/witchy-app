// src/models/spellModel.js
const db = require('../config/db');

async function getAllSpells() {
  const [rows] = await db.query('SELECT * FROM spells ORDER BY created_at DESC');
  return rows;
}

async function getSpellById(id) {
  const [rows] = await db.query('SELECT * FROM spells WHERE id = ?', [id]);
  return rows[0];
}

async function createSpell(data) {
  const {
    name,
    tags,
    type,
    moonPhaseRecommendation,
    ingredients,
    steps,
    notes,
  } = data;

  const [result] = await db.query(
    `INSERT INTO spells
      (name, tags, type, moon_phase_recommendation, ingredients, steps, notes)
     VALUES (?, CAST(? AS JSON), ?, ?, ?, ?, ?)`,
    [
      name,
      JSON.stringify(tags || []),
      type,
      moonPhaseRecommendation || null,
      ingredients,
      steps,
      notes || null,
    ]
  );

  const [rows] = await db.query('SELECT * FROM spells WHERE id = ?', [result.insertId]);
  return rows[0];
}

async function updateSpell(id, data) {
  const existing = await getSpellById(id);
  if (!existing) return null;

  const updated = {
    name: data.name ?? existing.name,
    tags: data.tags ?? JSON.parse(existing.tags || '[]'),
    type: data.type ?? existing.type,
    moonPhaseRecommendation: data.moonPhaseRecommendation ?? existing.moon_phase_recommendation,
    ingredients: data.ingredients ?? existing.ingredients,
    steps: data.steps ?? existing.steps,
    notes: data.notes ?? existing.notes,
  };

  await db.query(
    `UPDATE spells SET
      name = ?,
      tags = CAST(? AS JSON),
      type = ?,
      moon_phase_recommendation = ?,
      ingredients = ?,
      steps = ?,
      notes = ?
     WHERE id = ?`,
    [
      updated.name,
      JSON.stringify(updated.tags || []),
      updated.type,
      updated.moonPhaseRecommendation,
      updated.ingredients,
      updated.steps,
      updated.notes,
      id,
    ]
  );

  return getSpellById(id);
}

async function deleteSpell(id) {
  const [result] = await db.query('DELETE FROM spells WHERE id = ?', [id]);
  return result.affectedRows > 0;
}

module.exports = {
  getAllSpells,
  getSpellById,
  createSpell,
  updateSpell,
  deleteSpell,
};
