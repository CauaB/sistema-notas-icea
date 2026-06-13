const express = require('express');
const router = express.Router();
const disciplinaController = require('../controllers/disciplinaController');

router.get('/', disciplinaController.listarDisciplinas);
router.post('/', disciplinaController.criarDisciplina); // 
router.put('/:id/professor', disciplinaController.atualizarProfessor); // Atualiza o professor da disciplina
router.put('/:id/adicionar-aluno', disciplinaController.adicionarAluno); // Adiciona um aluno à disciplina
router.put('/:id/remover-aluno', disciplinaController.removerAluno); // Remove um aluno da disciplina
router.put('/:id/diario', disciplinaController.atualizarDiario); // Atualiza o diário da disciplina
router.post('/:id/forum', disciplinaController.enviarMensagemForum); // Envia uma mensagem para o fórum da disciplina

module.exports = router;