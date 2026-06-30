const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// AJUSTE ESTES CAMINHOS DE ACORDO COM A SUA ESTRUTURA DO BACKEND
const Usuario = require('./src/models/Usuario'); 
const Disciplina = require('./src/models/Disciplina');

// O SEU LINK CORRETO DO MONGODB BASEADO NO .ENV
const MONGO_URI = 'mongodb://localhost:27017/icea_db'; 

// Lista exata de disciplinas do 1º ao 6º período
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

// Nomes e Sobrenomes base
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
    await Usuario.deleteMany({ tipo: { $ne: 'Admin' } }); // Apaga todos, exceto Admin

    // 2. GERAR NOMES ÚNICOS (Sem Números)
    // Combinando os 20 nomes com 15 sobrenomes, temos 300 nomes únicos
    const todosNomesUnicos = [];
    for (const n of nomes) {
      for (const s of sobrenomes) {
        todosNomesUnicos.push(`${n} ${s}`);
      }
    }
    shuffleArray(todosNomesUnicos); // Misturamos tudo para ficar aleatório

    // 3. PREPARAR A SENHA '123456' CRIPTOGRAFADA
    const salt = await bcrypt.genSalt(10);
    const senhaHash = await bcrypt.hash('123456', salt);

    // 4. CRIAR 30 PROFESSORES
    console.log("👨‍🏫 A gerar 30 Professores...");
    const professoresSeed = [];
    for (let i = 0; i < 30; i++) {
      professoresSeed.push({
        nome: todosNomesUnicos[i], // Pega os primeiros 30 nomes
        email: `prof${i+1}@icea.com`,
        cpf: gerarCPFUnico(),
        dataNascimento: gerarDataNascimento(),
        senha: senhaHash,
        tipo: 'Professor'
      });
    }
    const professoresInseridos = await Usuario.insertMany(professoresSeed);

    // 5. CRIAR 100 ALUNOS
    console.log("🎓 A gerar 100 Alunos...");
    const alunosSeed = [];
    for (let i = 30; i < 130; i++) {
      alunosSeed.push({
        nome: todosNomesUnicos[i], // Pega os próximos 100 nomes da lista
        email: `aluno${i-29}@icea.com`,
        cpf: gerarCPFUnico(),
        dataNascimento: gerarDataNascimento(),
        senha: senhaHash,
        tipo: 'Aluno'
      });
    }
    const alunosInseridos = await Usuario.insertMany(alunosSeed);

    // 6. CRIAR DISCIPLINAS E MATRICULAR ALUNOS
    // Regra: Exatamente 15 alunos por disciplina, máximo de 5 disciplinas por aluno
    console.log("📚 A gerar Disciplinas e a alocar alunos (Exatamente 15 por turma, limite de 5 por aluno)...");
    
    const matriculasPorAluno = {};
    for (const aluno of alunosInseridos) {
      matriculasPorAluno[aluno._id] = 0; // Inicializa o contador de disciplinas de cada aluno
    }

    const disciplinasSeed = [];

    for (const materia of nomeDisciplinas) {
      // Escolhe um professor aleatório
      const profAleatorio = professoresInseridos[Math.floor(Math.random() * professoresInseridos.length)];
      
      // Filtra os alunos que ainda têm menos de 5 matrículas
      let alunosDisponiveis = alunosInseridos.filter(a => matriculasPorAluno[a._id] < 5);

      // Mistura e ordena os alunos disponíveis para priorizar os que têm MENOS matrículas, garantindo distribuição justa
      shuffleArray(alunosDisponiveis);
      alunosDisponiveis.sort((a, b) => matriculasPorAluno[a._id] - matriculasPorAluno[b._id]);

      // Seleciona exatamente os 15 primeiros
      const alunosSelecionados = alunosDisponiveis.slice(0, 15).map(a => a._id);

      // Incrementa o contador desses alunos
      for (const id of alunosSelecionados) {
        matriculasPorAluno[id]++;
      }

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
    console.log(`- ${disciplinasSeed.length} Disciplinas criadas (com 15 alunos cada).`);
    console.log("Todas as senhas novas são: 123456");

    process.exit(0);
  } catch (error) {
    console.error("❌ ERRO DURANTE O POVOAMENTO:", error);
    process.exit(1);
  }
}

runSeed();