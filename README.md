# 🎓 Aplicativo para Lançamento de Notas e Faltas - ICEA

Aplicativo desenvolvido para facilitar a gestão acadêmica de instituições de ensino, permitindo que **alunos**, **professores** e **administradores** realizem suas atividades de forma prática e centralizada.

O projeto foi desenvolvido, utilizando Flutter no frontend e Node.js no backend.

---

## 📚 Funcionalidades

### 👨‍🎓 Aluno
- Login no sistema
- Visualização de notas
- Consulta de faltas
- Participação no fórum da disciplina
- Chat em tempo real
- Consulta de disciplinas matriculadas

### 👨‍🏫 Professor
- Login no sistema
- Cadastro de notas
- Lançamento de faltas
- Responder dúvidas no fórum
- Chat com alunos
- Gerenciamento das disciplinas

### 👨‍💼 Administrador
- Gerenciamento de usuários
- Gerenciamento de disciplinas
- Gerenciamento de turmas
- Controle geral do sistema

---

# 🏗 Arquitetura

```text
Flutter (Mobile)
        │
 REST API (HTTP)
        │
Node.js + Express
        │
MongoDB
```

---

# 🚀 Tecnologias Utilizadas

## Frontend

- Flutter
- Dart

## Backend

- Node.js
- Express.js
- Mongoose

## Banco de Dados

- MongoDB

## Infraestrutura

- Docker
- Docker Compose

---

# 📂 Estrutura do Projeto

```text
sistema-notas-icea
│
├── api-icea
│   ├── src
│   │   ├── controllers
│   │   ├── middlewares
│   │   ├── models
│   │   ├── routes
│   │   └── server.js
│   └── docker-compose.yml
│
├── app_icea
│   ├── lib
│   ├── assets
│   └── pubspec.yaml
│
└── README.md
```

---

# 📋 Pré-requisitos

Antes de executar o projeto, instale:

- Git
- Node.js
- Flutter SDK
- Docker
- Docker Compose
- Genymotion ou VS Code
- Emulador Android ou dispositivo físico

---

# 🛠 Como executar o projeto

## 1. Clone o repositório

```bash
git clone https://github.com/CauaB/sistema-notas-icea.git

cd sistema-notas-icea
```

---

## 2. Inicie o Banco de Dados

Entre na pasta da API.

```bash
cd api-icea
```

Suba o MongoDB utilizando Docker.

```bash
docker-compose up -d
```

---

## 3. Instale as dependências da API

```bash
npm install
```

---

## 4. Inicie o servidor

```bash
node src/server.js
```

Caso utilize o Nodemon:

```bash
npm run dev
```

---

## 5. Execute o aplicativo Flutter

Abra outro terminal.

```bash
cd app_icea
```

Instale as dependências.

```bash
flutter pub get
```

Execute o aplicativo.

```bash
flutter run
```

---

# 🔐 Variáveis de Ambiente

Caso utilize um arquivo `.env`, crie-o na pasta da API.

Exemplo:

```env
PORT=3000

MONGO_URI=mongodb://localhost:27017/icea

JWT_SECRET=sua_chave_secreta
```
