const Mensagem = require('../models/Mensagem');

exports.enviar = async (req, res) => {
    try {
        const novaMensagem = new Mensagem(req.body);
        await novaMensagem.save();
        res.status(201).json(novaMensagem);
    } catch (error) {
        res.status(500).json({ erro: 'Erro ao enviar mensagem' });
    }
};

exports.buscarChat = async (req, res) => {
    try {
        const { id1, id2 } = req.params;
        // Busca mensagens trocadas entre os dois usuários
        const mensagens = await Mensagem.find({
            $or: [
                { remetente: id1, destinatario: id2 },
                { remetente: id2, destinatario: id1 }
            ]
        }).sort('dataEnvio');
        res.status(200).json(mensagens);
    } catch (error) {
        res.status(500).json({ erro: 'Erro ao buscar chat' });
    }
};