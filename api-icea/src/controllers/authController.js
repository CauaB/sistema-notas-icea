const Usuario = require('../models/Usuario');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.registrar = async (req, res) => {
  try {
    const { nome, email, senha, tipo } = req.body;
    
    // Criptografa a senha antes de salvar no banco
    const salt = await bcrypt.genSalt(10);
    const senhaHash = await bcrypt.hash(senha, salt);

    const novoUsuario = new Usuario({ nome, email, senha: senhaHash, tipo });
    await novoUsuario.save();

    res.status(201).json({ mensagem: 'Usuário criado com sucesso!' });
  } catch (erro) {
    res.status(500).json({ erro: 'Erro ao criar usuário.' });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, senha } = req.body;

    // Verifica se o usuário existe
    const usuario = await Usuario.findOne({ email });
    if (!usuario) return res.status(400).json({ erro: 'Credenciais inválidas.' });

    // Compara a senha digitada com a criptografada
    const senhaValida = await bcrypt.compare(senha, usuario.senha);
    if (!senhaValida) return res.status(400).json({ erro: 'Credenciais inválidas.' });

    // Cria o token de sessão
    const token = jwt.sign({ id: usuario._id, tipo: usuario.tipo }, 'segredo_icea_123', { expiresIn: '1d' });

    res.json({ mensagem: 'Login realizado com sucesso!', token, tipo: usuario.tipo });
  } catch (erro) {
    res.status(500).json({ erro: 'Erro no servidor.' });
  }
};