import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.88.140:3000';

  // Registrar usuário ou médico
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nome,
    required String cpf,
    required String telefone,
    required String typeUser, // 'cliente' ou 'medico'
    String? regiao,
    String? especificacao,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'nome': nome,
          'cpf': cpf,
          'telefone': telefone,
          'typeUser': typeUser,
          if (regiao != null) 'regiao': regiao,
          if (especificacao != null) 'especificacao': especificacao,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201,
        'message': data['message'] ?? 'Erro desconhecido',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
        'statusCode': 500,
      };
    }
  }

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String typeUser, // 'cliente' ou 'medico'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'typeUser': typeUser,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        // Salvar token
        await _saveToken(token);

        // Decodificar payload do JWT
        final payload = _decodeJWT(token);

        return {
          'success': true,
          'token': token,
          'user': payload,
          'message': 'Login realizado com sucesso',
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao fazer login',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Salvar token no dispositivo
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Obter token salvo
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Remover token (logout)
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Decodificar JWT para obter dados do usuário
  Map<String, dynamic> _decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded);

      return data['payload'] ?? {};
    } catch (e) {
      return {};
    }
  }

  // Verificar se está autenticado
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Obter dados do usuário logado
  Future<Map<String, dynamic>?> getUserData() async {
    final token = await getToken();
    if (token == null) return null;
    return _decodeJWT(token);
  }

  // Buscar clientes (usuários) - usado por médicos
  Future<List<dynamic>> getMedicos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/getUsers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Erro ao buscar clientes: $e');
      return [];
    }
  }

  // Criar nova consulta
  Future<Map<String, dynamic>> criarConsulta({
    required int codigo,
    required String data,
    required String descricao,
    required String userCpf,
    required String medicoCpf,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'codigo': codigo,
          'data': data,
          'descricao': descricao,
          'user': userCpf,
          'medico_cpf': medicoCpf,
        }),
      );

      final data_response = jsonDecode(response.body);

      return {
        'success': response.statusCode == 201,
        'message': data_response['message'] ?? 'Erro desconhecido',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Buscar consultas do usuário
  Future<List<dynamic>> getConsultas({
    required String cpf,
    required String typeUser,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': cpf,
          'typeUser': typeUser,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      }
      return [];
    } catch (e) {
      print('Erro ao buscar consultas: $e');
      return [];
    }
  }
  Future<Map<String, dynamic>> buscarMedicosPorRegiao(String regiao) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/endereco/regiao'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': regiao,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'medicos': data['data'] ?? [],
          'message': data['message'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'medicos': [],
          'message': data['message'] ?? 'Erro ao buscar médicos',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'medicos': [],
        'message': 'Erro de conexão: $e',
      };
    }
  }
}
