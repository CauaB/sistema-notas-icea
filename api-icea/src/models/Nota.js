const mongoose = require('mongoose');

const notaSchema = new mongoose.Schema({
  aluno: { type: mongoose.Schema.Types.ObjectId, ref: 'Usuario', required: true },
  disciplina: { type: mongoose.Schema.Types.ObjectId, ref: 'Disciplina', required: true },
  valor: { type: Number, required: true },
  tipo: { type: String, enum: ['Parcial', 'Final'], required: true }
});

module.exports = mongoose.model('Nota', notaSchema);