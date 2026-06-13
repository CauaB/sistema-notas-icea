const mongoose = require('mongoose');

const DiarioSchema = new mongoose.Schema({
  disciplina: { type: mongoose.Schema.Types.ObjectId, ref: 'Disciplina', required: true },
  aluno: { type: mongoose.Schema.Types.ObjectId, ref: 'Usuario', required: true },
  faltas: [{ data: Date, ausente: Boolean }],
  notas: [{
    nomeAvaliacao: String,
    pontosObtidos: Number
  }]
});

module.exports = mongoose.model('Diario', DiarioSchema);