const mongoose = require('mongoose');

const usuarioSchema = new mongoose.Schema({
  nome: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  cpf: { type: String, required: true, unique: true },
  dataNascimento: { type: String },
  senha: { type: String, required: true },
  tipo: { type: String, enum: ['Admin', 'Professor', 'Aluno', 'Pendente'], required: true },
  fotoPerfil: { type: String, default: null },
  observacoes: { type: String, default: '' }
});

module.exports = mongoose.model('Usuario', usuarioSchema);