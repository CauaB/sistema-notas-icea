import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // http://localhost:3000/api ou http://10.0.3.2:3000
 static const String baseUrl = 'http://10.0.3.2:3000/api';

  // ================= LOGIN =================
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      /*final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );
*/
final response = await http.post(
  Uri.parse('$baseUrl/auth/login'),
  headers: {
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'email': email,
    'senha': senha,
  }),
);
      if (response.statusCode == 200) {
        return {'sucesso': true, 'dados': jsonDecode(response.body)};
      } else {
        return {'sucesso': false, 'erro': jsonDecode(response.body)['erro']};
      }
    } catch (e) {
        print("ERRO LOGIN: $e");
        return {
          'sucesso': false,
          'erro': e.toString(),
        };
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
static Future<List<dynamic>> buscarUsuarios([String? meuId]) async {
    try {
      String url = '$baseUrl/auth/usuarios';
      
      // Se receber um ID, passa pela URL em vez do cabeçalho para evitar bloqueios no Chrome (CORS)
      if (meuId != null) {
        url += '?meuId=$meuId'; 
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); 
      } else {
        return [];
      }
    } catch (e) {
      print("Erro na API: $e");
      return [];
    }
  }

// ================= ATUALIZAR USUÁRIO (ADMIN E PERFIL) =================
  static Future<bool> atualizarUsuario(String id, String novoNome, String novoEmail, String novoCpf, String novaDataNascimento, String novoTipo, [String? novaSenha, String? novaObservacao]) async {
    try {
      final Map<String, dynamic> bodyPayload = {
        'nome': novoNome, 
        'email': novoEmail,
        'cpf': novoCpf,    
        'dataNascimento': novaDataNascimento,
        'tipo': novoTipo
      };
      
      if (novaSenha != null && novaSenha.trim().isNotEmpty) {
        bodyPayload['senha'] = novaSenha;
      }
      
      // Adiciona a observação ao envio se existir
      if (novaObservacao != null) {
        bodyPayload['observacoes'] = novaObservacao; 
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

// ================= MARCAR MENSAGENS COMO LIDAS =================
  static Future<void> marcarMensagensLidas(String meuId, String contatoId) async {
    try {
      await http.put(Uri.parse('$baseUrl/mensagens/lidas/$meuId/$contatoId'));
    } catch (e) {
      // Ignora erro de rede silenciosamente
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

  static Future<bool> salvarFotoPerfil(String id, String base64Img) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/usuarios/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fotoPerfil': base64Img}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

// ================= REMOVER FOTO DE PERFIL =================
  static Future<bool> removerFotoPerfil(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/remover-foto'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}