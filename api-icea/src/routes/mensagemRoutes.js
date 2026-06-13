const express = require('express');
const router = express.Router();
const mensagemController = require('../controllers/mensagemController');

router.post('/enviar', mensagemController.enviar);
router.get('/:id1/:id2', mensagemController.buscarChat);

module.exports = router;