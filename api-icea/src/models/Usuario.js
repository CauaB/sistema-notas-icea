const mongoose = require('mongoose');

const usuarioSchema = new mongoose.Schema({
  nome: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  cpf: { type: String }, // <-- ADICIONADO
  dataNascimento: { type: String }, // <-- ADICIONADO
  senha: { type: String, required: true },
  tipo: { type: String, enum: ['Admin', 'Professor', 'Aluno', 'Pendente'], required: true }
});

module.exports = mongoose.model('Usuario', usuarioSchema);