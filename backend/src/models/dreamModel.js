// src/models/dreamModel.js
const db = require('../config/db');

async function getAllDreams() {
  const [rows] = await db.query('SELECT * FROM dreams ORDER BY date DESC, created_at DESC');
  return rows;
}

async function getDreamById(id) {
  const [rows] = await db.query('SELECT * FROM dreams WHERE id = ?', [id]);
  return rows[0];
}

async function createDream(data) {
  const {
    date,
    title,
    content,
    tags,
    feelingOnWake,
  } = data;

  const [result] = await db.query(
    `INSERT INTO dreams
      (date, title, content, tags, feeling_on_wake)
     VALUES (?, ?, ?, CAST(? AS JSON), ?)`,
    [
      date || new Date(),
      title || null,
      content,
      JSON.stringify(tags || []),
      feelingOnWake || null,
    ]
  );

  const [rows] = await db.query('SELECT * FROM dreams WHERE id = ?', [result.insertId]);
  return rows[0];
}

async function updateDream(id, data) {
  const existing = await getDreamById(id);
  if (!existing) return null;

  const updated = {
    date: data.date ?? existing.date,
    title: data.title ?? existing.title,
    content: data.content ?? existing.content,
    tags: data.tags ?? JSON.parse(existing.tags || '[]'),
    feelingOnWake: data.feelingOnWake ?? existing.feeling_on_wake,
  };

  await db.query(
    `UPDATE dreams SET
      date = ?,
      title = ?,
      content = ?,
      tags = CAST(? AS JSON),
      feeling_on_wake = ?
     WHERE id = ?`,
    [
      updated.date,
      updated.title,
      updated.content,
      JSON.stringify(updated.tags || []),
      updated.feelingOnWake,
      id,
    ]
  );

  return getDreamById(id);
}

async function deleteDream(id) {
  const [result] = await db.query('DELETE FROM dreams WHERE id = ?', [id]);
  return result.affectedRows > 0;
}

module.exports = {
  getAllDreams,
  getDreamById,
  createDream,
  updateDream,
  deleteDream,
};
