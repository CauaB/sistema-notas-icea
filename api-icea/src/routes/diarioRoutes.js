const express = require('express');
const router = express.Router();

// Deixamos uma rota genérica apenas para o Node.js não reclamar que o arquivo está vazio.
// Futuramente, quando formos programar o Diário de Notas, colocaremos os Controllers aqui!
router.get('/', (req, res) => {
  res.status(200).json({ mensagem: 'Rota do diário em construção!' });
});

module.exports = router;