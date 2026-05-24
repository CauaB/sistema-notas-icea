const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Define os caminhos da API para login e registro
router.post('/registrar', authController.registrar);
router.post('/login', authController.login);

module.exports = router;