const mongoose = require('mongoose');

const disciplinaSchema = new mongoose.Schema({
  nome: { type: String, required: true },
  professor: { type: mongoose.Schema.Types.ObjectId, ref: 'Usuario' },
  alunos: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Usuario' }],
  
  // NOVOS CAMPOS PARA O DIÁRIO E FÓRUM
  avaliacoes: { type: Array, default: [] },
  notas: { type: Array, default: [] },
  faltas: { type: Array, default: [] },
  forum: { type: Array, default: [] }
});

module.exports = mongoose.model('Disciplina', disciplinaSchema);