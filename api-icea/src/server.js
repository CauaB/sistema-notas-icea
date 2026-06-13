global.crypto = require('crypto');
const express = require('express');
const mongoose = require('mongoose'); // <--- IMPORTA O MONGOOSE
const app = express();

// 1. Liberação do CORS (Para o Flutter conectar)
app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
    res.header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }
    next();
});

// Permite que o Node entenda JSON
app.use(express.json());

//
mongoose.connect('mongodb://mongo_db:27017/icea_db')
    .then(() => console.log('🔥 Conectado ao MongoDB com sucesso!'))
    .catch((err) => console.log('❌ Erro ao conectar no MongoDB:', err));


// 3. Importação das Rotas
const authRoutes = require('./routes/authRoutes');
const disciplinaRoutes = require('./routes/disciplinaRoutes');
const diarioRoutes = require('./routes/diarioRoutes');
const mensagemRoutes = require('./routes/mensagemRoutes');

// 4. Configuração dos caminhos (URLs)
app.use('/api/auth', authRoutes);
app.use('/api/disciplinas', disciplinaRoutes);
app.use('/api/diarios', diarioRoutes);
app.use('/api/mensagens', mensagemRoutes);

// 5. Iniciar o servidor
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 Servidor rodando perfeitamente na porta ${PORT}`);
});