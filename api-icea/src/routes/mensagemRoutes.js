const express = require('express');
const router = express.Router();
const mensagemController = require('../controllers/mensagemController');

router.post('/enviar', mensagemController.enviar);
router.get('/:id1/:id2', mensagemController.buscarChat);
router.put('/lidas/:meuId/:contatoId', mensagemController.marcarMensagensLidas);

module.exports = router;