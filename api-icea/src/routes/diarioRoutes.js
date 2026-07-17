const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.status(200).json({ mensagem: 'Rota do diário em construção!' });
});

module.exports = router;