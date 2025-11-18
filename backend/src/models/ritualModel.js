// src/models/ritualModel.js
const db = require('../config/db');

async function getAllRituals() {
  const [rows] = await db.query('SELECT * FROM ritual_reminders ORDER BY hour, minute');
  return rows;
}

async function getRitualById(id) {
  const [rows] = await db.query('SELECT * FROM ritual_reminders WHERE id = ?', [id]);
  return rows[0];
}

async function createRitual(data) {
  const {
    type,
    customLabel,
    hour,
    minute,
    enabled,
  } = data;

  const [result] = await db.query(
    `INSERT INTO ritual_reminders
      (type, custom_label, hour, minute, enabled)
     VALUES (?, ?, ?, ?, ?)`,
    [
      type,
      customLabel || null,
      hour,
      minute,
      enabled ?? true,
    ]
  );

  const [rows] = await db.query('SELECT * FROM ritual_reminders WHERE id = ?', [result.insertId]);
  return rows[0];
}

async function updateRitual(id, data) {
  const existing = await getRitualById(id);
  if (!existing) return null;

  const updated = {
    type: data.type ?? existing.type,
    customLabel: data.customLabel ?? existing.custom_label,
    hour: data.hour ?? existing.hour,
    minute: data.minute ?? existing.minute,
    enabled: typeof data.enabled === 'boolean' ? data.enabled : !!existing.enabled,
  };

  await db.query(
    `UPDATE ritual_reminders SET
      type = ?,
      custom_label = ?,
      hour = ?,
      minute = ?,
      enabled = ?
     WHERE id = ?`,
    [
      updated.type,
      updated.customLabel,
      updated.hour,
      updated.minute,
      updated.enabled,
      id,
    ]
  );

  return getRitualById(id);
}

async function deleteRitual(id) {
  const [result] = await db.query('DELETE FROM ritual_reminders WHERE id = ?', [id]);
  return result.affectedRows > 0;
}

module.exports = {
  getAllRituals,
  getRitualById,
  createRitual,
  updateRitual,
  deleteRitual,
};
