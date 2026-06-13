const mongoose = require('mongoose');

const MensagemSchema = new mongoose.Schema({
  remetente: { type: mongoose.Schema.Types.ObjectId, ref: 'Usuario', required: true },
  destinatario: { type: mongoose.Schema.Types.ObjectId, ref: 'Usuario', required: true },
  texto: { type: String, required: true },
  dataEnvio: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Mensagem', MensagemSchema);