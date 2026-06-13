import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Se estiver no Emulador do Android Studio, mude localhost para 10.0.2.2
  static const String baseUrl = 'http://localhost:3000/api';

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        return {'sucesso': true, 'dados': jsonDecode(response.body)};
      } else {
        return {'sucesso': false, 'erro': jsonDecode(response.body)['erro']};
      }
    } catch (e) {
      return {'sucesso': false, 'erro': 'Falha ao conectar com o servidor.'};
    }
  }

// ================= CADASTRO =================
  static Future<Map<String, dynamic>> registrar(String nome, String email, String cpf, String dataNascimento, String senha, String perfil, String obs) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/registrar'), // Rota original mantida intacta
        headers: {'Content-Type': 'application/json'},
        // MANTIDO TUDO O QUE TINHA + ADICIONADO O CAMPO 'obs'
        body: jsonEncode({
          'nome': nome, 
          'email': email, 
          'cpf': cpf, 
          'dataNascimento': dataNascimento, 
          'senha': senha, 
          'tipo': perfil, 
          'obs': obs // <-- Novo campo adicionado
        }),
      );
      if (response.statusCode == 201) return {'sucesso': true};
      
      // Tratamento de erro original mantido
      return {'sucesso': false, 'erro': jsonDecode(response.body)['erro'] ?? 'Erro desconhecido'};
    } catch (e) {
      return {'sucesso': false, 'erro': 'Erro de conexão.'};
    }
  }

  // ================= USUÁRIOS =================
  static Future<List<dynamic>> buscarUsuarios() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/auth/usuarios'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Retorna a lista que veio do MongoDB
      } else {
        return [];
      }
    } catch (e) {
      print("Erro na API: $e");
      return [];
    }
  }

// ================= ATUALIZAR USUÁRIO (ADMIN E PERFIL) =================
  static Future<bool> atualizarUsuario(String id, String novoNome, String novoEmail, String novoCpf, String novaDataNascimento, String novoTipo, [String? novaSenha]) async {
    try {
      final Map<String, dynamic> bodyPayload = {
        'nome': novoNome, 
        'email': novoEmail,
        'cpf': novoCpf,    
        'dataNascimento': novaDataNascimento,
        'tipo': novoTipo
      };
      
      // Se a senha foi preenchida, adiciona ao envio para o banco de dados
      if (novaSenha != null && novaSenha.trim().isNotEmpty) {
        bodyPayload['senha'] = novaSenha;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/auth/usuarios/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyPayload), 
      );
      return response.statusCode == 200;
    } catch (e) { 
      return false; 
    }
  }

  // ================= DELETAR USUÁRIO =================
  static Future<bool> deletarUsuario(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/auth/usuarios/$id'));
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  // ================= CHAT: BUSCAR MENSAGENS =================
  static Future<List<dynamic>> buscarChat(String meuId, String contatoId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/mensagens/$meuId/$contatoId'));
      if (response.statusCode == 200) return jsonDecode(response.body);
      return [];
    } catch (e) {
      return [];
    }
  }

  // ================= CHAT: ENVIAR MENSAGEM =================
  static Future<bool> enviarMensagem(String remetenteId, String destinatarioId, String texto) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mensagens/enviar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'remetente': remetenteId,
          'destinatario': destinatarioId,
          'texto': texto,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ================= BUSCAR DISCIPLINAS =================
  static Future<List<dynamic>> buscarDisciplinas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/disciplinas'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

// ================= GERENCIAR MATRÍCULAS (ALUNOS/DISCIPLINAS) =================
  static Future<bool> adicionarAlunoDisciplina(String disciplinaId, String alunoId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/disciplinas/$disciplinaId/adicionar-aluno'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'alunoId': alunoId}),
      );
      return response.statusCode == 200;
    } catch (e) { 
      return false; 
    }
  }

  static Future<bool> removerAlunoDisciplina(String disciplinaId, String alunoId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/disciplinas/$disciplinaId/remover-aluno'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'alunoId': alunoId}),
      );
      return response.statusCode == 200;
    } catch (e) { 
      return false; 
    }
  }

// ================= CRIAR E EDITAR DISCIPLINAS =================
  static Future<bool> criarDisciplina(String nome, String? professorId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/disciplinas'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nome': nome, 'professor': professorId}),
      );
      return response.statusCode == 201;
    } catch (e) { return false; }
  }

  static Future<bool> atualizarProfessorDisciplina(String disciplinaId, String? professorId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/disciplinas/$disciplinaId/professor'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'professorId': professorId}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }
  
  // ================= DIÁRIO E FÓRUM =================
  static Future<bool> salvarDiario(String disciplinaId, List avaliacoes, List notas, List faltas) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/disciplinas/$disciplinaId/diario'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'avaliacoes': avaliacoes, 'notas': notas, 'faltas': faltas}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> enviarMensagemForum(String disciplinaId, String remetente, String texto, String? respondendoA) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/disciplinas/$disciplinaId/forum'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'remetente': remetente, 'texto': texto, 'respondendoA': respondendoA}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  
}