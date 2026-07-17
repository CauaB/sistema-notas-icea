const Disciplina = require('../models/Disciplina');
const Usuario = require('../models/Usuario');

exports.listarDisciplinas = async (req, res) => {
  try {
    const disciplinas = await Disciplina.find()
      .populate('alunos', 'nome email cpf fotoPerfil') 
      .populate('professor', 'nome email fotoPerfil')  
    res.status(200).json(disciplinas);
  } catch (erro) {
    res.status(500).json({ erro: 'Erro ao buscar disciplinas.' });
  }
};

exports.adicionarAluno = async (req, res) => {
  try {
    const { id } = req.params;
    const { alunoId } = req.body;
    await Disciplina.findByIdAndUpdate(id, { $addToSet: { alunos: alunoId } });
    res.status(200).json({ sucesso: true, mensagem: 'Aluno matriculado!' });
  } catch (erro) {
    res.status(500).json({ erro: 'Erro ao matricular aluno.' });
  }
};

exports.removerAluno = async (req, res) => {
  try {
    const { id } = req.params;
    const { alunoId } = req.body;
    await Disciplina.findByIdAndUpdate(id, { $pull: { alunos: alunoId } });
    res.status(200).json({ sucesso: true, mensagem: 'Matrícula cancelada!' });
  } catch (erro) {
    res.status(500).json({ erro: 'Erro ao remover aluno.' });
  }
};

exports.criarDisciplina = async (req, res) => {
  try {
    const { nome, professor } = req.body;
    // Se não enviar professor, ele salva como null (sem professor)
    const novaDisciplina = new Disciplina({ nome, professor: professor || null });
    await novaDisciplina.save();
    res.status(201).json({ sucesso: true, mensagem: 'Disciplina criada!' });
  } catch (erro) {
    res.status(500).json({ erro: 'Erro ao criar disciplina.' });
  }
};

// ATUALIZA OU REMOVE O PROFESSOR DA DISCIPLINA
exports.atualizarProfessor = async (req, res) => {
  try {
    const { id } = req.params;
    const { professorId } = req.body;
    // Troca o ID do professor (ou coloca null para deixar sem ninguém)
    await Disciplina.findByIdAndUpdate(id, { professor: professorId || null });
    res.status(200).json({ sucesso: true, mensagem: 'Professor atualizado!' });
  } catch (erro) {
    res.status(500).json({ erro: 'Erro ao atualizar professor.' });
  }
};

// SALVA AS NOTAS, FALTAS E AVALIAÇÕES DE UMA VEZ
exports.atualizarDiario = async (req, res) => {
  try {
    const { id } = req.params;
    const { avaliacoes, notas, faltas } = req.body;
    await Disciplina.findByIdAndUpdate(id, { avaliacoes, notas, faltas });
    res.status(200).json({ sucesso: true, mensagem: 'Diário salvo!' });
  } catch (erro) {
    res.status(500).json({ erro: 'Erro ao salvar diário.' });
  }
};

// SALVA UMA MENSAGEM NO FÓRUM DE DÚVIDAS
exports.enviarMensagemForum = async (req, res) => {
  try {
    const { id } = req.params;
    const { remetente, texto, respondendoA } = req.body;
    
    const novaMensagem = { remetente, texto, respondendoA, data: new Date() };
    await Disciplina.findByIdAndUpdate(id, { $push: { forum: novaMensagem } });
    
    res.status(200).json({ sucesso: true });
  } catch (erro) {
    res.status(500).json({ erro: 'Erro ao enviar dúvida.' });
  }
};