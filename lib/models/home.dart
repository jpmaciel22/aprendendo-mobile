import 'dart:ui';
import 'package:flutter/material.dart';
import 'login.dart';
import 'api_service.dart';
import 'agendamentos_page.dart';
import 'encontrar_medicos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  // Verificar se o usuário está autenticado
  Future<void> _checkAuthentication() async {
    final isAuth = await _apiService.isAuthenticated();
    final userData = await _apiService.getUserData();

    setState(() {
      _isAuthenticated = isAuth;
      _userData = userData;
    });
  }

  // Fazer logout
  Future<void> _logout() async {
    await _apiService.removeToken();
    setState(() {
      _isAuthenticated = false;
      _userData = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logout realizado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff4400ff),
      appBar: AppBar(
        title: const Text('Página Inicial'),
        backgroundColor: Colors.blue,
        actions: [
          if (_isAuthenticated)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirmar Logout'),
                    content: Text('Deseja sair da sua conta?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _logout();
                        },
                        child: Text('Sair', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  if (_isAuthenticated && _userData != null) ...[
                    Text(
                      'Olá, ${_userData!['nome']}!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _userData!['type'] == 'medico' ? 'Médico' : 'Cliente',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ] else
                    Text(
                      'Não autenticado',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: const Text('NutriHELP'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            Divider(),

            if (!_isAuthenticated)
              ListTile(
                leading: Icon(Icons.login),
                title: const Text('Login'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                  // Verificar autenticação novamente após voltar do login
                  _checkAuthentication();
                },
              )
            else
              ListTile(
                leading: Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  Navigator.of(context).pop();
                  _logout();
                },
              ),

            if (_isAuthenticated && _userData!['type'] == 'cliente') ...[
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: const Text('Meus Agendamentos'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AgendamentosPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: const Text('Encontrar Médicos'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EncontrarMedicosPage(),
                    ),
                  );
                },
              ),
            ],
            if (_isAuthenticated && _userData!['type'] == 'medico') ...[
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: const Text('Meus Agendamentos'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AgendamentosPage(),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/nutricao.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.blue.shade900,
              );
            },
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
          ),
          Container(
            color: Colors.black45,
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'NutriHelp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 3,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Um aplicativo para te ajudar a conquistar seus objetivos!\n'
                        'Descubra seu limite conosco.\n\n'
                        '- Que desgraça é para o homem envelhecer sem nunca ver a beleza '
                        'e a força de que seu corpo é capaz! , Sócrates',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Mostrar status de autenticação
                  if (!_isAuthenticated)
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                        _checkAuthentication();
                      },
                      icon: Icon(Icons.login),
                      label: Text('Fazer Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'Você está logado!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_userData != null)
                            Text(
                              'Bem-vindo, ${_userData!['nome']}',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}