// src/models/desireModel.js
const db = require('../config/db');

async function getAllDesires() {
  const [rows] = await db.query('SELECT * FROM desires ORDER BY created_at DESC');
  return rows;
}

async function getDesireById(id) {
  const [rows] = await db.query('SELECT * FROM desires WHERE id = ?', [id]);
  return rows[0];
}

async function createDesire(data) {
  const {
    title,
    category,
    status,
    notes,
  } = data;

  const [result] = await db.query(
    `INSERT INTO desires
      (title, category, status, notes)
     VALUES (?, ?, ?, ?)`,
    [
      title,
      category || null,
      status || 'open',
      notes || null,
    ]
  );

  const [rows] = await db.query('SELECT * FROM desires WHERE id = ?', [result.insertId]);
  return rows[0];
}

async function updateDesire(id, data) {
  const existing = await getDesireById(id);
  if (!existing) return null;

  const updated = {
    title: data.title ?? existing.title,
    category: data.category ?? existing.category,
    status: data.status ?? existing.status,
    notes: data.notes ?? existing.notes,
  };

  await db.query(
    `UPDATE desires SET
      title = ?,
      category = ?,
      status = ?,
      notes = ?
     WHERE id = ?`,
    [
      updated.title,
      updated.category,
      updated.status,
      updated.notes,
      id,
    ]
  );

  return getDesireById(id);
}

async function deleteDesire(id) {
  const [result] = await db.query('DELETE FROM desires WHERE id = ?', [id]);
  return result.affectedRows > 0;
}

module.exports = {
  getAllDesires,
  getDesireById,
  createDesire,
  updateDesire,
  deleteDesire,
};
