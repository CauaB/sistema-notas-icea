const mongoose = require('mongoose');

const disciplinaSchema = new mongoose.Schema({
  nome: { type: String, required: true },
  professor: { type: mongoose.Schema.Types.ObjectId, ref: 'Usuario', required: true }
});

module.exports = mongoose.model('Disciplina', disciplinaSchema);