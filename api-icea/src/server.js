const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

// Importa as rotas de autenticação
const authRoutes = require('./routes/authRoutes');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI;

// Conexão com o Banco de Dados
mongoose.connect(MONGO_URI)
  .then(() => console.log('✅ Conectado ao MongoDB com sucesso!'))
  .catch((err) => console.error('❌ Erro ao conectar ao MongoDB:', err));

// Rota de teste original
app.get('/', (req, res) => {
  res.json({ message: '🚀 API do ICEA rodando perfeitamente!' });
});

// Habilita as rotas de login e registro no caminho /api/auth
app.use('/api/auth', authRoutes);

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});