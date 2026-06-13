const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Define os caminhos da API para login e registro
router.post('/registrar', authController.registrar);
router.post('/login', authController.login);
router.get('/usuarios', authController.listarUsuarios);
router.put('/usuarios/:id', authController.atualizarUsuario);
router.delete('/usuarios/:id', authController.deletarUsuario);

module.exports = router;