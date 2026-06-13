import 'api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Define a cor da barra de status do telemóvel para combinar com a App
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ICEAApp());
}

class ICEAApp extends StatelessWidget {
  const ICEAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ICEA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003366),
          primary: const Color(0xFF003366),
          secondary: Colors.orange,
        ),
        useMaterial3: true,
        // Fundo cinza super claro e moderno
        scaffoldBackgroundColor: const Color(0xFFF4F7FC), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0, // AppBar plana moderna
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18, 
            fontWeight: FontWeight.w600, 
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF003366), width: 1.5),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade600),
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003366),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

// ============================================================================
// FORMATADOR DE CPF (MÁSCARA AUTOMÁTICA)
// ============================================================================
class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length > 11) {
      text = text.substring(0, 11);
    }
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += text[i];
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ============================================================================
// WIDGET AUXILIAR PARA TÍTULOS COM LOGO DA UFOP
// ============================================================================
Widget tituloComUFOP(String texto) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/logo.png',
        height: 62,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.school, color: Colors.white);
        },
      ),
      const SizedBox(width: 12),
      Text(
        texto,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  );
}

// ============================================================================
// TELA DE LOGIN (DESIGN PREMIUM E LOGO SOMBREADA)
// ============================================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _isLoading = false;

  Future<void> _fazerLogin() async {
    setState(() => _isLoading = true);

    final resultado = await ApiService.login(_email.text.trim(), _senha.text.trim());
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (resultado['sucesso'] == true) {
      final usuario = resultado['dados']['usuario'] ?? resultado['dados']['user'];
      if (usuario != null) {
        final perfil = usuario['tipo'] ?? usuario['perfil'] ?? 'Pendente';
        if (perfil == 'Admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminDashboard(usuarioLogado: usuario)));
        } else if (perfil == 'Professor') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProfessorDashboard(usuarioLogado: usuario)));
        } else if (perfil == 'Aluno') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AlunoDashboard(usuarioLogado: usuario)));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A sua conta está em análise.', style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['erro'] ?? 'Erro', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _abrirCadastro() {
    final nomeCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final cpfCtrl = TextEditingController();
    final dataNascCtrl = TextEditingController();
    final senhaCtrl = TextEditingController();
    final obsCtrl = TextEditingController();
    String? tipoSelecionado;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Criar Nova Conta',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade800),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'O seu registo ficará na fila de espera até aprovação.',
                              style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Tipo de Conta *'),
                      value: tipoSelecionado,
                      items: const [
                        DropdownMenuItem(value: 'Aluno', child: Text('Aluno')),
                        DropdownMenuItem(value: 'Professor', child: Text('Professor')),
                      ],
                      onChanged: (val) {
                        setStateDialog(() {
                          tipoSelecionado = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nomeCtrl,
                      decoration: const InputDecoration(labelText: 'Nome Completo *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'E-mail *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cpfCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CpfInputFormatter()],
                      decoration: const InputDecoration(labelText: 'CPF *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dataNascCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data de Nascimento *',
                        suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                      ),
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF003366),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          dataNascCtrl.text = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: senhaCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Senha *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: obsCtrl,
                      decoration: const InputDecoration(labelText: 'Observações'),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String email = emailCtrl.text.trim();
                    String cpfSomenteNumeros = cpfCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
                    String senha = senhaCtrl.text;

                    if (tipoSelecionado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecione se você é Aluno ou Professor.'), backgroundColor: Colors.redAccent));
                      return;
                    }
                    if (!email.contains('@') || !email.contains('.com')) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail inválido! Exige @ e .com'), backgroundColor: Colors.redAccent));
                      return;
                    }
                    if (cpfSomenteNumeros.length != 11) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CPF inválido! Preencha os 11 números.'), backgroundColor: Colors.redAccent));
                      return;
                    }
                    if (senha.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A senha deve ter no mínimo 6 dígitos.'), backgroundColor: Colors.redAccent));
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (c) => const Center(child: CircularProgressIndicator()),
                    );

                    final res = await ApiService.registrar(
                      nomeCtrl.text.trim(),
                      email,
                      cpfSomenteNumeros,
                      dataNascCtrl.text.trim(),
                      senha,
                      tipoSelecionado!,
                      obsCtrl.text.trim(),
                    );

                    if (context.mounted) Navigator.pop(context);

                    if (res['sucesso'] == true) {
                      if (context.mounted) Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registo realizado com sucesso!'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res['erro'] ?? 'Erro'), backgroundColor: Colors.redAccent),
                      );
                    }
                  },
                  child: const Text('Registrar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Stack(
        children: [
          // Fundo Gradiente Superior
          Container(
            height: size.height * 0.45,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF001A33), Color(0xFF003366), Color(0xFF004C99)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO SOMBREADA
                Container(
                    height: 200,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.school, color: Colors.white, size: 70);
                      },
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Sistema para Lançamento de Notas e Faltas - ICEA',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 40), // Espaço para o cartão sobrepor
                ],
              ),
            ),
          ),
          
          // Cartão Flutuante de Login
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: size.height * 0.60,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F7FC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003366),
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _senha,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _fazerLogin,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isLoading 
                                  ? const SizedBox(
                                      width: 24, 
                                      height: 24, 
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                                    )
                                  : const Text('ENTRAR', style: TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: _abrirCadastro,
                            child: const Text(
                              'Ainda não tem conta? Registre-se aqui',
                              style: TextStyle(
                                color: Color(0xFF003366),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PERFIL DO USUÁRIO (PERMITE EDITAR DADOS BÁSICOS, BLOQUEIA CPF/NASCIMENTO)
// ============================================================================

class PerfilPage extends StatefulWidget {
  final Map<String, dynamic> usuarioLogado;

  const PerfilPage({super.key, required this.usuarioLogado});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late TextEditingController _nomeCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _cpfCtrl;
  late TextEditingController _dataNascCtrl;
  late TextEditingController _tipoCtrl;
  late TextEditingController _senhaCtrl;

@override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.usuarioLogado['nome'] ?? 'Não cadastrado');
    _emailCtrl = TextEditingController(text: widget.usuarioLogado['email'] ?? '');
    _senhaCtrl = TextEditingController(); 
    
    // Forçamos a conversão para String usando ?.toString() para evitar erros do backend
    String cpfCru = widget.usuarioLogado['cpf']?.toString() ?? '';
    if (cpfCru.length == 11) {
      cpfCru = "${cpfCru.substring(0,3)}.${cpfCru.substring(3,6)}.${cpfCru.substring(6,9)}-${cpfCru.substring(9,11)}";
    }
    _cpfCtrl = TextEditingController(text: cpfCru.isEmpty ? 'Não cadastrado' : cpfCru);
    
    String dataNasc = widget.usuarioLogado['dataNascimento']?.toString() ?? '';
    _dataNascCtrl = TextEditingController(text: dataNasc.isEmpty ? 'Não cadastrada' : dataNasc);
    
    _tipoCtrl = TextEditingController(text: widget.usuarioLogado['tipo'] ?? 'Desconhecido');
  }

  void _salvarAlteracoes() async {
    String email = _emailCtrl.text.trim();
    String senha = _senhaCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O E-mail não pode estar vazio.'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (!email.contains('@') || !email.contains('.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail inválido! Exige @ e .com'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (senha.isNotEmpty && senha.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A nova senha deve ter no mínimo 6 dígitos.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    // Envia os dados mantendo os originais para os bloqueados e atualizando email/senha
    bool suc = await ApiService.atualizarUsuario(
      widget.usuarioLogado['_id'],
      widget.usuarioLogado['nome'] ?? '', 
      email,
      widget.usuarioLogado['cpf'] ?? '', 
      widget.usuarioLogado['dataNascimento'] ?? '',
      widget.usuarioLogado['tipo'] ?? 'Aluno',
      senha, // Envia a nova senha (se estiver em branco, a API ignora e mantém a atual)
    );

    if (context.mounted) Navigator.pop(context);

    if (suc) {
      setState(() {
        widget.usuarioLogado['email'] = email;
        _senhaCtrl.clear(); // Limpa o campo de senha após sucesso
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.green),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar perfil.'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade100, width: 4),
                ),
                child: Icon(Icons.person_rounded, size: 64, color: Colors.blue.shade800),
              ),
            ),
            const SizedBox(height: 32),
            
            // DADOS EDITÁVEIS
            const Align(
              alignment: Alignment.centerLeft, 
              child: Text('Dados Editáveis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF003366)))
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _senhaCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nova Senha',
                hintText: 'Deixe em branco para manter a atual',
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(),
            ),

            // DADOS BLOQUEADOS (READ-ONLY) COM CARTÕES ELEGANTES
            const Align(
              alignment: Alignment.centerLeft, 
              child: Text('Dados Bloqueados (Somente Leitura)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey))
            ),
            const SizedBox(height: 16),
            _buildLockedField('Nome Completo', _nomeCtrl.text, Icons.person_outline),
            const SizedBox(height: 12),
            _buildLockedField('CPF', _cpfCtrl.text, Icons.badge_outlined),
            const SizedBox(height: 12),
            _buildLockedField('Data de Nascimento', _dataNascCtrl.text, Icons.calendar_today_outlined),
            const SizedBox(height: 12),
            _buildLockedField('Acesso (Perfil)', _tipoCtrl.text, Icons.admin_panel_settings_outlined),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _salvarAlteracoes,
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: const Text('Salvar Alterações', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET AUXILIAR PARA CAMPOS BLOQUEADOS
  Widget _buildLockedField(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Fundo cinza suave para indicar que é inativo
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.grey.shade600, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Não cadastrado' : value, 
                  style: const TextStyle(fontSize: 16, color: Color(0xFF001A33), fontWeight: FontWeight.w700)
                ),
              ],
            ),
          ),
          Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }
}

// ============================================================================
// CHAT - FILTRO E ORGANIZAÇÃO ALFABÉTICA
// ============================================================================
class ChatSearchPage extends StatefulWidget {
  final Map<String, dynamic> usuarioLogado;

  const ChatSearchPage({super.key, required this.usuarioLogado});

  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  String _searchQuery = '';
  String _filtroAtual = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens Diretas', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar utilizador...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF4F7FC),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['Todos', 'Aluno', 'Professor'].map((tipo) {
                    final isSel = _filtroAtual == tipo;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(
                          tipo == 'Todos' ? 'Todos' : '${tipo}s',
                          style: TextStyle(
                            color: isSel ? Colors.white : Colors.grey.shade700,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: const Color(0xFF003366),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSel ? const Color(0xFF003366) : Colors.grey.shade300),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _filtroAtual = tipo;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: ApiService.buscarUsuarios(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum utilizador encontrado.', style: TextStyle(color: Colors.grey)));
                }

                final filteredUsers = snapshot.data!.where((u) {
                  final nomeMatches = (u['nome'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
                  final tipoMatches = _filtroAtual == 'Todos' || u['tipo'] == _filtroAtual;
                  return nomeMatches && tipoMatches && u['_id'] != widget.usuarioLogado['_id'];
                }).toList();

                filteredUsers.sort((a, b) => (a['nome'] ?? '').toLowerCase().compareTo((b['nome'] ?? '').toLowerCase()));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final u = filteredUsers[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          radius: 26,
                          backgroundColor: u['tipo'] == 'Professor' ? Colors.green.shade100 : Colors.blue.shade100,
                          child: Text(
                            (u['nome'] ?? 'U')[0].toUpperCase(),
                            style: TextStyle(
                              color: u['tipo'] == 'Professor' ? Colors.green.shade800 : Colors.blue.shade800, 
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          u['nome'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF001A33)),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('${u['tipo']}', style: TextStyle(color: Colors.grey.shade600)),
                        ),
                        trailing: Icon(Icons.chat_bubble_outline, color: Colors.grey.shade400),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatThreadPage(
                                meuUsuario: widget.usuarioLogado,
                                contatoUsuario: u,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChatThreadPage extends StatefulWidget {
  final Map<String, dynamic> meuUsuario;
  final Map<String, dynamic> contatoUsuario;

  const ChatThreadPage({super.key, required this.meuUsuario, required this.contatoUsuario});

  @override
  State<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<ChatThreadPage> {
  final TextEditingController _msgCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Text(
                (widget.contatoUsuario['nome'] ?? 'U')[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contatoUsuario['nome'] ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.contatoUsuario['tipo'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: StatefulBuilder(
        builder: (context, setStateTela) {
          return Column(
            children: [
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: ApiService.buscarChat(widget.meuUsuario['_id'], widget.contatoUsuario['_id']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('Diga olá para iniciar a conversa!', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                          ],
                        ),
                      );
                    }
                    final mensagens = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: mensagens.length,
                      itemBuilder: (context, index) {
                        final msg = mensagens[index];
                        final isMe = msg['remetente'] == widget.meuUsuario['_id'];
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: isMe ? const Color(0xFF003366) : Colors.white,
                              borderRadius: BorderRadius.circular(20).copyWith(
                                bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
                                bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Text(
                              msg['texto'] ?? '',
                              style: TextStyle(
                                color: isMe ? Colors.white : const Color(0xFF001A33),
                                fontSize: 15,
                                height: 1.3,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ]
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgCtrl,
                        decoration: InputDecoration(
                          hintText: 'Escreva uma mensagem...',
                          filled: true,
                          fillColor: const Color(0xFFF4F7FC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () async {
                        if (_msgCtrl.text.trim().isEmpty) return;
                        await ApiService.enviarMensagem(
                          widget.meuUsuario['_id'],
                          widget.contatoUsuario['_id'],
                          _msgCtrl.text.trim(),
                        );
                        _msgCtrl.clear();
                        setStateTela(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF003366),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// CHAT DO FÓRUM (DESIGN MODERNO DE CARTÕES DE MENSAGEM)
// ============================================================================
class ChatDisciplinaPage extends StatefulWidget {
  final Map<String, dynamic> disciplina;
  final Map<String, dynamic> usuarioLogado;

  const ChatDisciplinaPage({super.key, required this.disciplina, required this.usuarioLogado});

  @override
  State<ChatDisciplinaPage> createState() => _ChatDisciplinaPageState();
}

class _ChatDisciplinaPageState extends State<ChatDisciplinaPage> {
  final TextEditingController _msgCtrl = TextEditingController();
  Map<String, dynamic>? _msgSendoRespondida;

  String _obterDataFormatada(dynamic data) {
    if (data == null) return "Agora";
    try {
      DateTime dt = DateTime.parse(data.toString()).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "Recente";
    }
  }

  void _abrirRespostas(BuildContext context, List<dynamic> respostas) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Respostas da Turma',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: respostas.length,
            itemBuilder: (ctx, i) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(Icons.person, size: 12, color: Colors.blue.shade800),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              respostas[i]['remetente'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blue.shade900),
                            ),
                          ],
                        ),
                        Text(
                          _obterDataFormatada(respostas[i]['data']),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ]
                    ),
                    const SizedBox(height: 8),
                    Text(
                      respostas[i]['texto'] ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Fechar', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fórum da Turma',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.disciplina['nome'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: StatefulBuilder(
        builder: (context, setStateTela) {
          return Column(
            children: [
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: ApiService.buscarDisciplinas(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final discAtualizada = snapshot.data?.firstWhere(
                      (d) => d['_id'] == widget.disciplina['_id'],
                      orElse: () => widget.disciplina,
                    );
                    final List<dynamic> forum = discAtualizada['forum'] ?? [];

                    if (forum.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Seja o primeiro a enviar uma dúvida!',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    List<Widget> forumWidgets = [];
                    var mensagensRaiz = forum.where((m) => m['respondendoA'] == null || m['respondendoA'] == '').toList();

                    for (var msg in mensagensRaiz) {
                      var respostas = forum.where((r) => r['respondendoA'] == msg['texto']).toList();

                      forumWidgets.add(
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black.withOpacity(0.03)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F7FC),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.blue.shade100,
                                          child: Icon(Icons.person, size: 14, color: Colors.blue.shade900),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          msg['remetente'] ?? 'Usuário',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      _obterDataFormatada(msg['data']),
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  msg['texto'] ?? '',
                                  style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setStateTela(() {
                                          _msgSendoRespondida = msg;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.reply_rounded, size: 16, color: Colors.blue.shade700),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Responder',
                                              style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (respostas.isNotEmpty) ...[
                                      const SizedBox(width: 12),
                                      InkWell(
                                        onTap: () => _abrirRespostas(context, respostas),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${respostas.length} Respostas',
                                            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      children: forumWidgets,
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, -5))
                  ]
                ),
                child: Column(
                  children: [
                    if (_msgSendoRespondida != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.format_quote_rounded, size: 20, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('A responder a ${_msgSendoRespondida!['remetente']}:', style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                                  Text(
                                    '"${_msgSendoRespondida!['texto']}"',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.blue.shade900, fontStyle: FontStyle.italic),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              color: Colors.blue.shade900,
                              onPressed: () {
                                setStateTela(() {
                                  _msgSendoRespondida = null;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            )
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgCtrl,
                            decoration: InputDecoration(
                              hintText: 'Escreva para a turma...',
                              filled: true,
                              fillColor: const Color(0xFFF4F7FC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () async {
                            if (_msgCtrl.text.trim().isEmpty) return;

                            String? respostaA = _msgSendoRespondida != null ? _msgSendoRespondida!['texto'] : null;

                            await ApiService.enviarMensagemForum(
                              widget.disciplina['_id'],
                              widget.usuarioLogado['nome'],
                              _msgCtrl.text.trim(),
                              respostaA,
                            );

                            _msgCtrl.clear();
                            setStateTela(() {
                              _msgSendoRespondida = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFF003366),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// ADMIN - EDIÇÃO TOTAL E MATRÍCULA COM BUSCA GLOBAL (DESIGN REFINADO)
// ============================================================================
class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> usuarioLogado;

  const AdminDashboard({super.key, required this.usuarioLogado});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  void _atualizarTela() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel Admin', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PerfilPage(usuarioLogado: widget.usuarioLogado)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatSearchPage(usuarioLogado: widget.usuarioLogado)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.orange,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Utilizadores'),
              Tab(text: 'Disciplinas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            AdminUsuariosTab(onUpdate: _atualizarTela),
            AdminDisciplinasTab(onUpdate: _atualizarTela),
          ],
        ),
      ),
    );
  }
}

class AdminUsuariosTab extends StatelessWidget {
  final VoidCallback onUpdate;

  const AdminUsuariosTab({super.key, required this.onUpdate});

  void _editarPerfilCompleto(BuildContext context, Map<String, dynamic> usuario) {
    final nomeCtrl = TextEditingController(text: usuario['nome']);
    final emailCtrl = TextEditingController(text: usuario['email']);
    final cpfCtrl = TextEditingController(text: usuario['cpf']);
    final dataNascCtrl = TextEditingController(text: usuario['dataNascimento']);
    String perfilSel = usuario['tipo'] ?? 'Aluno';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Editar Dados',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nomeCtrl,
                      decoration: const InputDecoration(labelText: 'Nome Completo'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      decoration: const InputDecoration(labelText: 'E-mail'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cpfCtrl,
                      decoration: const InputDecoration(labelText: 'CPF'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dataNascCtrl,
                      decoration: const InputDecoration(labelText: 'Data de Nascimento'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Perfil de Acesso'),
                      value: perfilSel,
                      items: const [
                        DropdownMenuItem(value: 'Aluno', child: Text('Aluno')),
                        DropdownMenuItem(value: 'Professor', child: Text('Professor')),
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'Pendente', child: Text('Pendente / Bloqueado')),
                      ],
                      onChanged: (val) {
                        setStateDialog(() {
                          perfilSel = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool suc = await ApiService.atualizarUsuario(
                      usuario['_id'],
                      nomeCtrl.text.trim(),
                      emailCtrl.text.trim(),
                      cpfCtrl.text.trim(),
                      dataNascCtrl.text.trim(),
                      perfilSel,
                    );

                    if (context.mounted) Navigator.pop(context);

                    if (suc) {
                      onUpdate();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dados salvos com sucesso!', style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.buscarUsuarios(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Nenhum utilizador encontrado.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final u = snapshot.data![index];
            final bool isPendente = u['tipo'] == 'Pendente';
            
            return Card(
              color: isPendente ? Colors.orange.shade50 : Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: isPendente ? Colors.orange.shade100 : Colors.blue.shade50,
                  child: Icon(
                    isPendente ? Icons.warning_amber_rounded : Icons.person, 
                    color: isPendente ? Colors.orange.shade800 : const Color(0xFF003366)
                  ),
                ),
                title: Text(
                  u['nome'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF001A33)),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text('${u['tipo']} • ${u['email']}', style: TextStyle(color: Colors.grey.shade600)),
                ),
                trailing: Container(
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(Icons.edit_rounded, color: Colors.blue.shade700, size: 20),
                    onPressed: () => _editarPerfilCompleto(context, u),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AdminDisciplinasTab extends StatelessWidget {
  final VoidCallback onUpdate;

  const AdminDisciplinasTab({super.key, required this.onUpdate});

  void _criarNova(BuildContext context, List<dynamic> disciplinasExistentes) async {
    final todos = await ApiService.buscarUsuarios();
    final profs = todos.where((u) => u['tipo'] == 'Professor').toList();
    final nomeCtrl = TextEditingController();
    String? profSel;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Nova Disciplina',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeCtrl,
                    decoration: const InputDecoration(labelText: 'Nome da Matéria'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Professor Responsável'),
                    value: profSel,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sem Professor')),
                      ...profs.map((p) => DropdownMenuItem(
                        value: p['_id'] as String,
                        child: Text(p['nome'] ?? ''),
                      ))
                    ],
                    onChanged: (val) {
                      setStateDialog(() {
                        profSel = val;
                      });
                    },
                  )
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String nomeMateria = nomeCtrl.text.trim();
                    if (nomeMateria.isEmpty) return;

                    bool jaExiste = disciplinasExistentes.any((d) =>
                      d['nome'].toString().toLowerCase() == nomeMateria.toLowerCase()
                    );

                    if (jaExiste) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Já existe uma matéria com este nome! Adicione "Turma A", "B", etc.', style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    bool suc = await ApiService.criarDisciplina(nomeMateria, profSel);
                    if (context.mounted) Navigator.pop(context);
                    if (suc) onUpdate();
                  },
                  child: const Text('Criar'),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _editarMatriculasEDisciplina(BuildContext context, Map<String, dynamic> disciplina) async {
    final todos = await ApiService.buscarUsuarios();
    final alunosDisp = todos.where((u) => u['tipo'] == 'Aluno').toList();
    final profsDisp = todos.where((u) => u['tipo'] == 'Professor').toList();

    showDialog(
      context: context,
      builder: (context) {
        List<dynamic> matriculados = List.from((disciplina['alunos'] as List<dynamic>?) ?? []);
        String? profAtual = disciplina['professor'] != null ? disciplina['professor']['_id'] : null;
        String filtroBusca = '';

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final naoMatriculados = alunosDisp.where((a) => !matriculados.any((m) => m['_id'] == a['_id'])).toList();

            final alunosFiltrados = naoMatriculados.where((a) {
              final query = filtroBusca.toLowerCase();
              final nomeMatches = (a['nome'] ?? '').toLowerCase().contains(query);
              final emailMatches = (a['email'] ?? '').toLowerCase().contains(query);
              final cpfMatches = (a['cpf'] ?? '').contains(query);
              return nomeMatches || emailMatches || cpfMatches;
            }).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Gerenciar: ${disciplina['nome']}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366)),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Professor Responsável', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: profAtual,
                            items: [
                              const DropdownMenuItem(value: null, child: Text('Sem Professor')),
                              ...profsDisp.map((p) => DropdownMenuItem(
                                value: p['_id'] as String,
                                child: Text(p['nome'] ?? ''),
                              ))
                            ],
                            onChanged: (val) {
                              setStateDialog(() {
                                profAtual = val;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                          child: IconButton(
                            icon: Icon(Icons.save_rounded, color: Colors.green.shade700),
                            onPressed: () async {
                              await ApiService.atualizarProfessorDisciplina(disciplina['_id'], profAtual);
                              onUpdate();
                            },
                          ),
                        )
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(height: 1),
                    ),
                    const Text(
                      'Matricular Aluno (Busca por Nome, CPF ou E-mail)',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Pesquisar Aluno...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (val) {
                        setStateDialog(() {
                          filtroBusca = val;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListView.builder(
                          itemCount: alunosFiltrados.length,
                          itemBuilder: (c, i) {
                            final Aluno = alunosFiltrados[i];
                            return ListTile(
                              title: Text(Aluno['nome'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              subtitle: Text('CPF: ${Aluno['cpf'] ?? ""}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              trailing: IconButton(
                                icon: Icon(Icons.add_circle, color: Colors.green.shade600),
                                onPressed: () async {
                                  bool suc = await ApiService.adicionarAlunoDisciplina(disciplina['_id'], Aluno['_id']);
                                  if (suc) {
                                    setStateDialog(() {
                                      matriculados.add(Aluno);
                                    });
                                    onUpdate();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Matriculados (${matriculados.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListView.builder(
                          itemCount: matriculados.length,
                          itemBuilder: (c, i) {
                            final m = matriculados[i];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(Icons.person, size: 16, color: Colors.blue.shade800),
                              ),
                              title: Text(m['nome'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () async {
                                  bool suc = await ApiService.removerAlunoDisciplina(disciplina['_id'], m['_id']);
                                  if (suc) {
                                    setStateDialog(() {
                                      matriculados.removeAt(i);
                                    });
                                    onUpdate();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Concluído', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.buscarDisciplinas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final disciplinas = snapshot.data ?? [];
        
        if (disciplinas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.class_outlined, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Nenhuma disciplina criada.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
              ],
            ),
          );
        }

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _criarNova(context, disciplinas),
            icon: const Icon(Icons.add),
            label: const Text('Nova Disciplina', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16).copyWith(bottom: 80),
            itemCount: disciplinas.length,
            itemBuilder: (context, index) {
              final d = disciplinas[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.book_rounded, color: Colors.blue.shade800, size: 28),
                  ),
                  title: Text(
                    d['nome'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF001A33)),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: [
                        Icon(Icons.groups_rounded, size: 16, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text('${d['alunos']?.length ?? 0} Alunos matriculados', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.settings_rounded, color: Colors.orange.shade700),
                      onPressed: () => _editarMatriculasEDisciplina(context, d),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ============================================================================
// PROFESSOR - BLOQUEIO DE 100 PONTOS E VALIDAÇÃO DE NOTAS (DESIGN REFINADO)
// ============================================================================
class ProfessorDashboard extends StatefulWidget {
  final Map<String, dynamic> usuarioLogado;

  const ProfessorDashboard({super.key, required this.usuarioLogado});

  @override
  State<ProfessorDashboard> createState() => _ProfessorDashboardState();
}

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prof. ${widget.usuarioLogado['nome']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PerfilPage(usuarioLogado: widget.usuarioLogado)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatSearchPage(usuarioLogado: widget.usuarioLogado)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.buscarDisciplinas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final minhasDisciplinas = (snapshot.data ?? []).where((d) =>
            d['professor'] != null && d['professor']['_id'] == widget.usuarioLogado['_id']
          ).toList();

          if (minhasDisciplinas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Você não possui turmas ativas.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: minhasDisciplinas.length,
            itemBuilder: (context, index) {
              final d = minhasDisciplinas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfessorDiarioPage(disciplina: d, usuarioLogado: widget.usuarioLogado),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF003366), Color(0xFF004C99)]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: const Color(0xFF003366).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(Icons.class_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['nome'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF001A33)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Toque para abrir o diário',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProfessorDiarioPage extends StatefulWidget {
  final Map<String, dynamic> disciplina;
  final Map<String, dynamic> usuarioLogado;

  const ProfessorDiarioPage({super.key, required this.disciplina, required this.usuarioLogado});

  @override
  State<ProfessorDiarioPage> createState() => _ProfessorDiarioPageState();
}

class _ProfessorDiarioPageState extends State<ProfessorDiarioPage> {
  DateTime _dataSelecionada = DateTime.now();
  List<dynamic> avaliacoes = [];
  List<dynamic> notas = [];
  List<dynamic> faltas = [];
  List<dynamic> alunosMatriculados = [];

  @override
  void initState() {
    super.initState();
    alunosMatriculados = widget.disciplina['alunos'] ?? [];
    avaliacoes = List.from(widget.disciplina['avaliacoes'] ?? []);
    notas = List.from(widget.disciplina['notas'] ?? []);
    faltas = List.from(widget.disciplina['faltas'] ?? []);
  }

  void _salvarAutomaticamente() {
    ApiService.salvarDiario(widget.disciplina['_id'], avaliacoes, notas, faltas);
  }

  int get totalPontos {
    return avaliacoes.fold(0, (sum, item) => sum + (item['valor'] as int));
  }

  void _adicionarAvaliacao() {
    final nomeCtrl = TextEditingController();
    final valorCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nova Avaliação', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome da Avaliação'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valorCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Valor em Pontos'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              int val = int.tryParse(valorCtrl.text) ?? 0;

              if (totalPontos + val > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bloqueado! O total da disciplina não pode passar de 100 pts. Atual: $totalPontos', style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              setState(() {
                avaliacoes.add({'nome': nomeCtrl.text, 'valor': val});
              });

              _salvarAutomaticamente();
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          )
        ],
      ),
    );
  }

  void _editarAvaliacao(int index) {
    final nomeCtrl = TextEditingController(text: avaliacoes[index]['nome']);
    final valorCtrl = TextEditingController(text: avaliacoes[index]['valor'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar Avaliação', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeCtrl, decoration: const InputDecoration(labelText: 'Nome da Avaliação')),
            const SizedBox(height: 12),
            TextField(
              controller: valorCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Valor em Pontos'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              int val = int.tryParse(valorCtrl.text) ?? 0;
              int novoTotal = totalPontos - (avaliacoes[index]['valor'] as int) + val;
              if (novoTotal > 100) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Operação bloqueada: Limite de 100 pontos excedido!'), backgroundColor: Colors.redAccent));
                return;
              }
              setState(() {
                avaliacoes[index] = {'nome': nomeCtrl.text, 'valor': val};
              });
              _salvarAutomaticamente();
              Navigator.pop(context);
            },
            child: const Text('Atualizar'),
          )
        ],
      ),
    );
  }

  String _getNota(String alunoId, String avalNome) {
    var notaObj = notas.firstWhere((n) =>
      n['alunoId'] == alunoId && n['avaliacaoNome'] == avalNome,
      orElse: () => null
    );
    return notaObj != null ? notaObj['nota'].toString() : '';
  }

  void _setNota(String alunoId, String avalNome, String valor, int valorMaximo) {
    notas.removeWhere((n) => n['alunoId'] == alunoId && n['avaliacaoNome'] == avalNome);

    if (valor.isNotEmpty) {
      int notaDigitada = int.tryParse(valor) ?? 0;

      if (notaDigitada > valorMaximo) {
        notaDigitada = valorMaximo;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nota limitada ao valor máximo de $valorMaximo pontos!'),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      notas.add({
        'alunoId': alunoId,
        'avaliacaoNome': avalNome,
        'nota': notaDigitada
      });
    }

    _salvarAutomaticamente();
  }

  bool _isPresente(String alunoId, String dataFormatada) {
    var faltaObj = faltas.firstWhere((f) =>
      f['alunoId'] == alunoId && f['data'] == dataFormatada,
      orElse: () => null
    );
    return faltaObj != null ? faltaObj['presente'] : true;
  }

  @override
  Widget build(BuildContext context) {
    String dataFormatada = "${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}";

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.disciplina['nome']),
          actions: [
            IconButton(
              icon: const Icon(Icons.forum_rounded),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatDisciplinaPage(disciplina: widget.disciplina, usuarioLogado: widget.usuarioLogado)),
                );
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.orange,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Avaliações'),
              Tab(text: 'Notas'),
              Tab(text: 'Faltas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ABA 1: AVALIAÇÕES
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF003366), Color(0xFF004C99)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Distribuído', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                            Text(
                              '$totalPontos / 100 pts',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: totalPontos == 100 ? Colors.greenAccent : Colors.white),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _adicionarAvaliacao,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF003366),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.add, size: 20),
                          label: const Text('Nova'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: avaliacoes.isEmpty
                        ? Center(child: Text('Nenhuma avaliação cadastrada.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)))
                        : ListView.builder(
                            itemCount: avaliacoes.length,
                            itemBuilder: (c, i) {
                              return Card(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  title: Text(avaliacoes[i]['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  subtitle: Text('${avaliacoes[i]['valor']} pontos', style: TextStyle(color: Colors.grey.shade600)),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                                        child: IconButton(
                                          icon: Icon(Icons.edit_rounded, color: Colors.blue.shade700, size: 20),
                                          onPressed: () => _editarAvaliacao(i)
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                                        child: IconButton(
                                          icon: Icon(Icons.delete_rounded, color: Colors.red.shade700, size: 20),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (c) => AlertDialog(
                                                title: const Text('Remover Avaliação?'),
                                                content: Text('Deseja excluir a avaliação "${avaliacoes[i]['nome']}"? As notas dos alunos também serão apagadas.'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancelar')),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        String nomeAval = avaliacoes[i]['nome'];
                                                        avaliacoes.removeAt(i);
                                                        notas.removeWhere((n) => n['avaliacaoNome'] == nomeAval);
                                                      });
                                                      _salvarAutomaticamente();
                                                      Navigator.pop(c);
                                                    },
                                                    child: const Text('Remover', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  )
                ],
              ),
            ),
            
            // ABA 2: NOTAS
            alunosMatriculados.isEmpty
                ? Center(child: Text('Nenhum aluno matriculado.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: alunosMatriculados.length,
                    itemBuilder: (c, idx) {
                      final Aluno = alunosMatriculados[idx];
                      return Card(
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade50,
                              child: Icon(Icons.person, color: Colors.indigo.shade400),
                            ),
                            title: Text(Aluno['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            children: avaliacoes.isEmpty
                                ? [Padding(padding: const EdgeInsets.all(16.0), child: Text('Crie avaliações primeiro.', style: TextStyle(color: Colors.grey.shade500)))]
                                : avaliacoes.map((aval) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border(top: BorderSide(color: Colors.grey.shade100)),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                                        title: Text(aval['nome']),
                                        subtitle: Text('Máximo: ${aval['valor']} pts', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                        trailing: SizedBox(
                                          width: 90,
                                          child: TextField(
                                            controller: TextEditingController(text: _getNota(Aluno['_id'], aval['nome'])),
                                            keyboardType: TextInputType.number,
                                            textAlign: TextAlign.center,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            decoration: InputDecoration(
                                              hintText: 'Nota',
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                                              fillColor: Colors.grey.shade100,
                                            ),
                                            onChanged: (val) {
                                              _setNota(Aluno['_id'], aval['nome'], val, aval['valor'] as int);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                  
            // ABA 3: FALTAS
            Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Text(dataFormatada, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          var d = await showDatePicker(
                            context: context,
                            initialDate: _dataSelecionada,
                            firstDate: DateTime(2025),
                            lastDate: DateTime(2030),
                          );
                          if (d != null) {
                            setState(() {
                              _dataSelecionada = d;
                            });
                          }
                        },
                        icon: const Icon(Icons.edit_calendar_rounded, size: 18),
                        label: const Text('Alterar', style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: alunosMatriculados.isEmpty
                      ? Center(child: Text('Nenhum aluno matriculado.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: alunosMatriculados.length,
                          itemBuilder: (c, i) {
                            final Aluno = alunosMatriculados[i];
                            bool pres = _isPresente(Aluno['_id'], dataFormatada);
                            
                            return Card(
                              color: pres ? Colors.white : Colors.red.shade50,
                              elevation: pres ? 0 : 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: pres ? Colors.grey.shade200 : Colors.red.shade100),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: pres ? Colors.green.shade50 : Colors.white,
                                  child: Icon(pres ? Icons.check_circle_rounded : Icons.cancel_rounded, color: pres ? Colors.green : Colors.red),
                                ),
                                title: Text(Aluno['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Presença',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: pres ? Colors.grey.shade700 : Colors.red.shade700),
                                    ),
                                    const SizedBox(width: 8),
                                    Switch(
                                      value: pres,
                                      activeColor: Colors.white,
                                      activeTrackColor: Colors.green,
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: Colors.redAccent,
                                      onChanged: (val) {
                                        setState(() {
                                          faltas.removeWhere((f) => f['alunoId'] == Aluno['_id'] && f['data'] == dataFormatada);
                                          faltas.add({'alunoId': Aluno['_id'], 'data': dataFormatada, 'presente': val});
                                          _salvarAutomaticamente();
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ALUNO - VISUALIZAR DIAS TOTAIS, STATUS E NOTAS (DESIGN REFINADO)
// ============================================================================
class AlunoDashboard extends StatefulWidget {
  final Map<String, dynamic> usuarioLogado;

  const AlunoDashboard({super.key, required this.usuarioLogado});

  @override
  State<AlunoDashboard> createState() => _AlunoDashboardState();
}

class _AlunoDashboardState extends State<AlunoDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Olá, ${widget.usuarioLogado['nome'].split(' ')[0]}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PerfilPage(usuarioLogado: widget.usuarioLogado)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatSearchPage(usuarioLogado: widget.usuarioLogado)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: ApiService.buscarDisciplinas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final minhasDisciplinas = (snapshot.data ?? []).where((d) {
            final alunosList = d['alunos'] as List<dynamic>? ?? [];
            return alunosList.any((a) => a['_id'] == widget.usuarioLogado['_id']);
          }).toList();
          
          if (minhasDisciplinas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_dissatisfied_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Você não está matriculado em nenhuma turma.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: minhasDisciplinas.length,
            itemBuilder: (context, index) {
              final d = minhasDisciplinas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlunoDisciplinaPage(disciplina: d, usuarioLogado: widget.usuarioLogado),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF003366), Color(0xFF004C99)]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: const Color(0xFF003366).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(Icons.class_rounded, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['nome'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF001A33)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Prof: ${d['professor']?['nome'] ?? "Sem professor"}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AlunoDisciplinaPage extends StatelessWidget {
  final Map<String, dynamic> disciplina;
  final Map<String, dynamic> usuarioLogado;

  const AlunoDisciplinaPage({super.key, required this.disciplina, required this.usuarioLogado});

  @override
  Widget build(BuildContext context) {
    int pontosObtidos = 0;
    for (var n in disciplina['notas'] ?? []) {
      if (n['alunoId'] == usuarioLogado['_id']) {
        pontosObtidos += (n['nota'] as num).toInt();
      }
    }

    int faltasAtuais = 0;
    List<Map<String, dynamic>> frequenciaCompleta = [];

    for (var f in disciplina['faltas'] ?? []) {
      if (f['alunoId'] == usuarioLogado['_id']) {
        if (f['presente'] == false) {
          faltasAtuais += 1;
        }
        frequenciaCompleta.add({'data': f['data'], 'presente': f['presente']});
      }
    }

    final List<dynamic> atividades = disciplina['avaliacoes'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(disciplina['nome']),
        actions: [
          IconButton(
            icon: const Icon(Icons.forum_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatDisciplinaPage(disciplina: disciplina, usuarioLogado: usuarioLogado)),
              );
            }
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: pontosObtidos >= 60 ? Colors.green.shade50 : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: pontosObtidos >= 60 ? Colors.green.shade200 : Colors.blue.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_rounded, color: pontosObtidos >= 60 ? Colors.green : Colors.blue, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              '$pontosObtidos pts',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: pontosObtidos >= 60 ? Colors.green.shade800 : Colors.blue.shade900
                              )
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: pontosObtidos >= 60 ? Colors.green.shade100 : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                pontosObtidos >= 60 ? 'Aprovado' : 'Faltam ${60 - pontosObtidos} pts',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: pontosObtidos >= 60 ? Colors.green.shade800 : Colors.blue.shade800
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: const Text('Frequência Completa', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                            content: frequenciaCompleta.isEmpty
                                ? const Text('Nenhum registro de aula lançado.')
                                : SizedBox(
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: frequenciaCompleta.length,
                                      itemBuilder: (ctx, i) {
                                        final dia = frequenciaCompleta[i];
                                        bool foiPresente = dia['presente'] == true;
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            color: foiPresente ? Colors.white : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade200)
                                          ),
                                          child: ListTile(
                                            leading: Icon(
                                              foiPresente ? Icons.check_circle : Icons.cancel,
                                              color: foiPresente ? Colors.green : Colors.red,
                                            ),
                                            title: Text(dia['data'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                            trailing: Text(
                                              foiPresente ? 'Presente' : 'Falta',
                                              style: TextStyle(
                                                color: foiPresente ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c),
                                child: const Text('Fechar', style: TextStyle(fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: faltasAtuais > 9 ? Colors.red.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: faltasAtuais > 9 ? Colors.red.shade200 : Colors.orange.shade200),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today_rounded, color: faltasAtuais > 9 ? Colors.red : Colors.orange.shade800, size: 36),
                              const SizedBox(height: 12),
                              Text(
                                '$faltasAtuais Faltas',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: faltasAtuais > 9 ? Colors.red.shade800 : Colors.orange.shade900
                                )
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: faltasAtuais > 9 ? Colors.red.shade100 : Colors.orange.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  faltasAtuais > 9 ? 'Reprovado' : 'Limite: 9',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: faltasAtuais > 9 ? Colors.red.shade900 : Colors.orange.shade900
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Toque para ver dias',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Cronograma e Notas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF003366)),
            ),
            const SizedBox(height: 16),
            atividades.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.assignment_outlined, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('O professor ainda não lançou o cronograma.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: atividades.map((ativ) {
                      var notaObj = (disciplina['notas'] as List<dynamic>? ?? []).firstWhere(
                        (n) => n['alunoId'] == usuarioLogado['_id'] && n['avaliacaoNome'] == ativ['nome'],
                        orElse: () => null
                      );
                      var notaReal = notaObj != null ? notaObj['nota'] : null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.assignment_rounded, color: Colors.blue.shade800),
                          ),
                          title: Text(ativ['nome'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('Valor Total: ${ativ['valor']} pts', style: TextStyle(color: Colors.grey.shade600)),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: notaReal != null ? Colors.green.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: notaReal != null ? Colors.green.shade200 : Colors.grey.shade300)
                            ),
                            child: Text(
                              notaReal != null ? '$notaReal pts' : 'Pendente',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: notaReal != null ? Colors.green.shade800 : Colors.grey.shade600
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}