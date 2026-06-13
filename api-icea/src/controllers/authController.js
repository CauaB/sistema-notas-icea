const Usuario = require('../models/Usuario');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.registrar = async (req, res) => {
  try {
    // AGORA RECEBE CPF E DATA DE NASCIMENTO
    const { nome, email, cpf, dataNascimento, senha } = req.body; 
    
    const salt = await bcrypt.genSalt(10);
    const senhaHash = await bcrypt.hash(senha, salt);

    const novoUsuario = new Usuario({ 
      nome, email, cpf, dataNascimento, senha: senhaHash, tipo: 'Pendente' 
    });
    await novoUsuario.save();

    res.status(201).json({ mensagem: 'Usuário criado com sucesso e aguardando aprovação!' });
  } catch (erro) {
    res.status(500).json({ erro: 'Erro ao criar usuário.' });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, senha } = req.body;

    const usuario = await Usuario.findOne({ email });
    if (!usuario) return res.status(400).json({ erro: 'Credenciais inválidas.' });

    const senhaValida = await bcrypt.compare(senha, usuario.senha);
    if (!senhaValida) return res.status(400).json({ erro: 'Credenciais inválidas.' });

    // ==========================================
    // TRAVA DE SEGURANÇA: BLOQUEIO DE PENDENTES
    // ==========================================
    if (usuario.tipo === 'Pendente') {
      return res.status(403).json({ erro: 'Sua conta está em análise. Aguarde a liberação do Administrador.' });
    }

    const token = jwt.sign({ id: usuario._id, tipo: usuario.tipo }, 'segredo_icea_123', { expiresIn: '1d' });

    res.json({ 
      mensagem: 'Login realizado com sucesso!', 
      token, 
      usuario: {
        _id: usuario._id,
        nome: usuario.nome,
        email: usuario.email,
        tipo: usuario.tipo,
        cpf: usuario.cpf,
        dataNascimento: usuario.dataNascimento
      }
    });
  } catch (erro) {
    console.log("Erro no login:", erro);
    res.status(500).json({ erro: 'Erro no servidor.' });
  }
};

exports.listarUsuarios = async (req, res) => {
  try {
    // Pede ao MongoDB todos os usuários salvos
    const usuarios = await Usuario.find(); 
    res.status(200).json(usuarios);
  } catch (erro) {
    console.log("Erro ao buscar usuários:", erro);
    res.status(500).json({ erro: 'Erro ao buscar usuários.' });
  }
};

exports.atualizarUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, email, cpf, dataNascimento, tipo, senha } = req.body;

    // 1. Busca o usuário atual no banco de dados
    const usuario = await Usuario.findById(id);
    if (!usuario) {
      return res.status(404).json({ erro: 'Utilizador não encontrado' });
    }

    // 2. Atualiza os campos básicos se eles mudaram
    if (nome) usuario.nome = nome;
    if (email) usuario.email = email;
    if (cpf) usuario.cpf = cpf;
    if (dataNascimento) usuario.dataNascimento = dataNascimento;
    if (tipo) usuario.tipo = tipo;

    // 3. SEGREDO REVELADO: Criptografa a nova senha antes de salvar!
    if (senha && senha.trim().length >= 6) {
      const salt = await bcrypt.genSalt(10);
      usuario.senha = await bcrypt.hash(senha, salt); // Transforma em hash seguro
    }

    // 4. Salva o documento atualizado no MongoDB
    await usuario.save();

    res.status(200).json({ sucesso: true, mensagem: 'Dados atualizados com sucesso!' });
  } catch (error) {
    console.error("Erro ao atualizar utilizador:", error);
    res.status(500).json({ erro: 'Erro interno ao atualizar os dados.' });
  }
};

exports.deletarUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    await Usuario.findByIdAndDelete(id);
    res.status(200).json({ sucesso: true, mensagem: 'Usuário excluído!' });
  } catch (erro) {
    res.status(500).json({ erro: 'Erro ao excluir usuário.' });
  }
};