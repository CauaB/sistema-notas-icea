const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// AJUSTE ESTES CAMINHOS DE ACORDO COM A SUA ESTRUTURA DO BACKEND
const Usuario = require('./src/models/Usuario'); 
const Disciplina = require('./src/models/Disciplina');

// AJUSTE O SEU LINK DO MONGODB AQUI
const MONGO_URI = 'mongodb://localhost:27017/icea_db';

// Lista exata de disciplinas do 1º ao 6º período (com as turmas duplas solicitadas)
const nomeDisciplinas = [
  "Programação de Computadores I", "Fundamentos de Cálculo", "Fundamentos de GAAL", "Fundamentos de SI", "Informática e Sociedade", "Metodologia de Pesquisa",
  "Programação de Computadores II", 
  "Algoritmos e Estruturas de Dados I - Turma A", "Algoritmos e Estruturas de Dados I - Turma B", 
  "Matemática Discreta - Turma A", "Matemática Discreta - Turma B",
  "Gestão da Informação", "Teoria Geral da Administração",
  "Algoritmos e Estruturas de Dados II", "Algoritmos e Estruturas de Dados III", "Organização e Arq. de Computadores I", "Estatística e Probabilidade", "Comportamento Organizacional",
  "Engenharia de Software I", "Banco de Dados I", "Sistemas Operacionais", "Programação Linear e Inteira", "Economia",
  "Engenharia de Software II", "Banco de Dados II", "Fundamentos Teóricos da Computação", "Redes de Computadores I", "Inteligência Artificial",
  "Gerência de Projetos de Software", "Sistemas Web I", "Interação Humano-Computador", "Linguagens de Programação", "Sistemas Distribuídos"
];

// Nomes e Sobrenomes para gerar combinações reais
const nomes = ["Ana", "Bruno", "Carlos", "Daniela", "Eduardo", "Fernanda", "Gabriel", "Helena", "Igor", "Julia", "Lucas", "Mariana", "Nicolas", "Olivia", "Pedro", "Rafael", "Sofia", "Tiago", "Vitoria", "Cauã"];
const sobrenomes = ["Silva", "Santos", "Oliveira", "Souza", "Rodrigues", "Ferreira", "Alves", "Pereira", "Lima", "Gomes", "Costa", "Ribeiro", "Martins", "Carvalho", "Almeida"];

// Função para gerar CPF único (11 dígitos)
const cpfsGerados = new Set();
function gerarCPFUnico() {
  let cpf;
  do {
    cpf = Math.floor(10000000000 + Math.random() * 90000000000).toString();
  } while (cpfsGerados.has(cpf));
  cpfsGerados.add(cpf);
  return cpf;
}

// Função para gerar data de nascimento aleatória (entre 1995 e 2005)
function gerarDataNascimento() {
  const ano = Math.floor(Math.random() * (2005 - 1995 + 1)) + 1995;
  const mes = String(Math.floor(Math.random() * 12) + 1).padStart(2, '0');
  const dia = String(Math.floor(Math.random() * 28) + 1).padStart(2, '0');
  return `${dia}/${mes}/${ano}`;
}

// Função para baralhar um array (Fisher-Yates)
function shuffleArray(array) {
  for (let i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [array[i], array[j]] = [array[j], array[i]];
  }
  return array;
}

async function runSeed() {
  try {
    console.log("⏳ A ligar à Base de Dados...");
    await mongoose.connect(MONGO_URI);
    console.log("✅ Ligado ao MongoDB!");

    // 1. LIMPEZA DOS DADOS ATUAIS
    console.log("🧹 A limpar utilizadores antigos (mantendo Admin) e disciplinas...");
    await Disciplina.deleteMany({});
    // Apaga todos onde o tipo NÃO é Admin
    await Usuario.deleteMany({ tipo: { $ne: 'Admin' } }); 

    // 2. PREPARAR A SENHA '123456' CRIPTOGRAFADA
    const salt = await bcrypt.genSalt(10);
    const senhaHash = await bcrypt.hash('123456', salt);

    // 3. CRIAR 30 PROFESSORES
    console.log("👨‍🏫 A gerar 30 Professores...");
    const professoresSeed = [];
    for (let i = 1; i <= 30; i++) {
      const nomeBase = nomes[Math.floor(Math.random() * nomes.length)];
      const sobrenomeBase = sobrenomes[Math.floor(Math.random() * sobrenomes.length)];
      professoresSeed.push({
        nome: `${nomeBase} ${sobrenomeBase} (Prof ${i})`,
        email: `prof${i}@icea.com`,
        cpf: gerarCPFUnico(),
        dataNascimento: gerarDataNascimento(),
        senha: senhaHash,
        tipo: 'Professor'
      });
    }
    const professoresInseridos = await Usuario.insertMany(professoresSeed);

    // 4. CRIAR 500 ALUNOS
    console.log("🎓 A gerar 500 Alunos...");
    const alunosSeed = [];
    for (let i = 1; i <= 500; i++) {
      const nomeBase = nomes[Math.floor(Math.random() * nomes.length)];
      const sobrenomeBase = sobrenomes[Math.floor(Math.random() * sobrenomes.length)];
      alunosSeed.push({
        nome: `${nomeBase} ${sobrenomeBase} ${i}`,
        email: `aluno${i}@icea.com`,
        cpf: gerarCPFUnico(),
        dataNascimento: gerarDataNascimento(),
        senha: senhaHash,
        tipo: 'Aluno'
      });
    }
    const alunosInseridos = await Usuario.insertMany(alunosSeed);

    // 5. CRIAR DISCIPLINAS E MATRICULAR ALUNOS
    console.log("📚 A gerar Disciplinas e a alocar alunos (15 a 35 por turma)...");
    const disciplinasSeed = [];

    for (const materia of nomeDisciplinas) {
      // Escolhe um professor aleatório
      const profAleatorio = professoresInseridos[Math.floor(Math.random() * professoresInseridos.length)];
      
      // Sorteia quantos alunos terá esta turma (entre 15 e 35)
      const qtdAlunos = Math.floor(Math.random() * (35 - 15 + 1)) + 15;
      
      // Sorteia alunos aleatórios da base total de 500 para esta disciplina
      const alunosEmbaralhados = shuffleArray([...alunosInseridos]);
      const alunosSelecionados = alunosEmbaralhados.slice(0, qtdAlunos).map(a => a._id);

      disciplinasSeed.push({
        nome: materia,
        professor: profAleatorio._id,
        alunos: alunosSelecionados,
        avaliacoes: [],
        notas: [],
        faltas: [],
        forum: []
      });
    }

    await Disciplina.insertMany(disciplinasSeed);

    console.log("🎉 POVOAMENTO CONCLUÍDO COM SUCESSO!");
    console.log(`- ${professoresInseridos.length} Professores criados.`);
    console.log(`- ${alunosInseridos.length} Alunos criados.`);
    console.log(`- ${disciplinasSeed.length} Disciplinas criadas.`);
    console.log("Todas as senhas novas são: 123456");

    process.exit(0);
  } catch (error) {
    console.error("❌ ERRO DURANTE O POVOAMENTO:", error);
    process.exit(1);
  }
}

runSeed();