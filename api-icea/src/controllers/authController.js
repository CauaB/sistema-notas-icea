const Usuario = require('../models/Usuario');
const Mensagem = require('../models/Mensagem');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

exports.registrar = async (req, res) => {
  try {
    const { nome, email, cpf, dataNascimento, senha, obs } = req.body;

    // 1. VERIFICAÇÕES VÊM PRIMEIRO
    const emailExiste = await Usuario.findOne({ email });
    if (emailExiste) {
      return res.status(400).json({ erro: 'Este e-mail já está em uso.' });
    }

    const cpfExiste = await Usuario.findOne({ cpf });
    if (cpfExiste) {
      return res.status(400).json({ erro: 'Este CPF já está cadastrado no sistema.' });
    }

    // 2. SE PASSOU NAS VERIFICAÇÕES, GERA A SENHA E SALVA
    const salt = await bcrypt.genSalt(10);
    const senhaHash = await bcrypt.hash(senha, salt);

    const novoUsuario = new Usuario({
      nome, 
      email, 
      cpf, 
      dataNascimento, 
      senha: senhaHash, 
      tipo: 'Pendente',
      observacoes: obs
    });

    await novoUsuario.save();

    res.status(201).json({ mensagem: 'Usuário criado com sucesso e aguardando aprovação!' });
  } catch (erro) {
    console.error("Erro no registro:", erro); 
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
        dataNascimento: usuario.dataNascimento,
        fotoPerfil: usuario.fotoPerfil
      }
    });
  } catch (erro) {
    console.log("Erro no login:", erro);
    res.status(500).json({ erro: 'Erro no servidor.' });
  }
};

exports.listarUsuarios = async (req, res) => {
  try {
    const usuarios = await Usuario.find().lean(); 
    
    // 👇 Mudou de req.headers para req.query 👇
    const meuId = req.query.meuId; 

    if (meuId) {
      const mensagensNaoLidas = await Mensagem.find({ destinatario: meuId, lida: false }).lean();
      
      const contagemNaoLidas = {};
      mensagensNaoLidas.forEach(msg => {
        const idRemetente = msg.remetente.toString();
        contagemNaoLidas[idRemetente] = (contagemNaoLidas[idRemetente] || 0) + 1;
      });

      for (let u of usuarios) {
        u.mensagensNaoLidas = contagemNaoLidas[u._id.toString()] || 0;
        u.hasUnread = u.mensagensNaoLidas > 0;
      }
    }

    res.status(200).json(usuarios);
  } catch (erro) {
    console.log("Erro ao buscar usuários:", erro);
    res.status(500).json({ erro: 'Erro ao buscar usuários.' });
  }
};

exports.atualizarUsuario = async (req, res) => {
  try {
    const { id } = req.params;
    // 1. MUDADO PARA O PLURAL: 'observacoes' 
    const { nome, email, cpf, dataNascimento, tipo, senha, observacoes, fotoPerfil } = req.body; 

    // Busca o usuário atual no banco de dados
    const usuario = await Usuario.findById(id);
    
    if (!usuario) {
      return res.status(404).json({ erro: 'Utilizador não encontrado' });
    }

    // Atualiza os dados básicos
    usuario.nome = nome || usuario.nome;
    usuario.email = email || usuario.email;
    usuario.cpf = cpf || usuario.cpf;
    usuario.dataNascimento = dataNascimento || usuario.dataNascimento;
    usuario.tipo = tipo || usuario.tipo;

    // 2. MUDADO PARA O PLURAL AQUI TAMBÉM 👇
    if (observacoes !== undefined) {
      usuario.observacoes = observacoes;
    }

    // Só atualiza a senha se o utilizador digitou uma nova
    if (senha && senha.trim() !== '') {
      const bcrypt = require('bcryptjs');
      const salt = await bcrypt.genSalt(10);
      usuario.senha = await bcrypt.hash(senha, salt);
    }

    if (fotoPerfil !== undefined) {
      usuario.fotoPerfil = fotoPerfil;
    }
    
    await usuario.save();
    res.status(200).json({ mensagem: 'Usuário atualizado com sucesso!' });

  } catch (erro) {
    console.log("Erro ao atualizar usuário:", erro);
    res.status(500).json({ erro: 'Erro ao atualizar usuário' });
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

exports.removerFotoPerfil = async (req, res) => {
  try {
    // AQUI ESTÁ A CORREÇÃO: Pegamos o 'id' que o Flutter enviou no req.body
    const usuarioId = req.body.id; 

    if (!usuarioId) {
      return res.status(400).json({ erro: 'ID do usuário não fornecido.' });
    }

    // Atualiza o documento setando a fotoPerfil como null
    const usuarioAtualizado = await Usuario.findByIdAndUpdate(
      usuarioId,
      { fotoPerfil: null },
      { new: true } 
    );

    if (!usuarioAtualizado) {
      return res.status(404).json({ erro: 'Usuário não encontrado.' });
    }

    res.status(200).json({ 
      mensagem: 'Foto de perfil removida com sucesso!', 
      usuario: usuarioAtualizado 
    });

  } catch (erro) {
    console.error("Erro ao remover foto de perfil:", erro);
    res.status(500).json({ erro: 'Erro ao remover foto de perfil.' });
  }
};