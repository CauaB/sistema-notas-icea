const mongoose = require('mongoose');

const usuarioSchema = new mongoose.Schema({
  nome: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  senha: { type: String, required: true }, // Aqui futuramente salvaremos a senha com Hash
  tipo: { type: String, enum: ['Admin', 'Professor', 'Aluno'], required: true }
});

module.exports = mongoose.model('Usuario', usuarioSchema);