import 'package:flutter/material.dart';
import 'nova_consulta.dart';
import 'api_service.dart';

class AgendamentosPage extends StatefulWidget {
  const AgendamentosPage({super.key});

  @override
  State<AgendamentosPage> createState() => _AgendamentosPageState();
}

class _AgendamentosPageState extends State<AgendamentosPage> {
  final ApiService _apiService = ApiService();
  List<dynamic> _consultasHoje = [];
  List<dynamic> _consultasFuturas = [];
  List<dynamic> _consultasFinalizadas = [];
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _userData = await _apiService.getUserData();

    if (_userData != null) {
      final consultas = await _apiService.getConsultas(
        cpf: _userData!['cpf'],
        typeUser: _userData!['type'],
      );

      _organizarConsultas(consultas);
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _organizarConsultas(List<dynamic> consultas) {
    final hoje = DateTime.now();
    final hojeInicio = DateTime(hoje.year, hoje.month, hoje.day);
    final hojeFim = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59);

    _consultasHoje = [];
    _consultasFuturas = [];
    _consultasFinalizadas = [];

    for (var consulta in consultas) {
      final status = (consulta['status'] ?? 'em-andamento').toLowerCase();

      // Se está finalizada, vai para FINALIZADAS
      if (status.contains('realizado')) {
        _consultasFinalizadas.add(consulta);
        continue;
      }

      // Se está em andamento, verifica a data
      try {
        final dataConsulta = DateTime.parse(consulta['horario']);

        // APENAS consultas de HOJE ou FUTURAS são mostradas
        if (dataConsulta.isAfter(hojeInicio) && dataConsulta.isBefore(hojeFim)) {
          // É hoje
          _consultasHoje.add(consulta);
        } else if (dataConsulta.isAfter(hojeFim)) {
          // É futuro
          _consultasFuturas.add(consulta);
        }
        // Se a data for anterior a hoje, NÃO adiciona em nenhuma lista (ignora)
      } catch (e) {
        // Se não conseguir parsear a data, ignora a consulta
        print('Erro ao parsear data da consulta: $e');
      }
    }

    // Ordenar por data (mais recente primeiro)
    _consultasHoje.sort((a, b) => _compararDatas(a['horario'], b['horario']));
    _consultasFuturas.sort((a, b) => _compararDatas(a['horario'], b['horario']));
    _consultasFinalizadas.sort((a, b) => _compararDatas(b['horario'], a['horario'])); // Finalizadas: mais recente primeiro

    setState(() => _isLoading = false);
  }

  int _compararDatas(String? data1, String? data2) {
    try {
      final d1 = DateTime.parse(data1 ?? '');
      final d2 = DateTime.parse(data2 ?? '');
      return d1.compareTo(d2);
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalConsultas = _consultasHoje.length + _consultasFuturas.length + _consultasFinalizadas.length;
    final isCliente = _userData?['type'] == 'cliente';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        backgroundColor: Colors.blue,
      ),
      // Só mostra o botão se NÃO for cliente (ou seja, se for médico)
      floatingActionButton: !isCliente ? FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NovaConsultaPage(),
            ),
          );

          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : totalConsultas == 0
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum agendamento encontrado',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (!isCliente) ...[
              SizedBox(height: 8),
              Text(
                'Clique no + para criar um novo',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seção HOJE
            if (_consultasHoje.isNotEmpty) ...[
              _buildSectionHeader('HOJE', Colors.orange, _consultasHoje.length),
              const SizedBox(height: 12),
              ..._consultasHoje.map((consulta) => _buildConsultaCard(consulta, Colors.orange)),
              const SizedBox(height: 24),
            ],

            // Seção FUTURAS
            if (_consultasFuturas.isNotEmpty) ...[
              _buildSectionHeader('FUTURAS', Colors.blue, _consultasFuturas.length),
              const SizedBox(height: 12),
              ..._consultasFuturas.map((consulta) => _buildConsultaCard(consulta, Colors.blue)),
              const SizedBox(height: 24),
            ],

            // Seção FINALIZADAS
            if (_consultasFinalizadas.isNotEmpty) ...[
              _buildSectionHeader('FINALIZADAS', Colors.green, _consultasFinalizadas.length),
              const SizedBox(height: 12),
              ..._consultasFinalizadas.map((consulta) => _buildConsultaCard(consulta, Colors.green)),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            title == 'HOJE'
                ? Icons.today
                : title == 'FUTURAS'
                ? Icons.event
                : Icons.check_circle,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultaCard(Map<String, dynamic> consulta, Color accentColor) {
    final isMedico = _userData!['type'] == 'medico';
    final status = (consulta['status'] ?? 'em-andamento').toLowerCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Código: ${consulta['codigo']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: accentColor,
                    ),
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            const Divider(height: 20),

            // Informação da pessoa (médico ou paciente)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: accentColor.withOpacity(0.2),
                child: Icon(
                  isMedico ? Icons.person : Icons.medical_services,
                  color: accentColor,
                ),
              ),
              title: Text(
                isMedico
                    ? consulta['user_nome'] ?? 'Cliente'
                    : consulta['medico_nome'] ?? 'Médico',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              // subtitle: Text(
              //   isMedico
              //       ? 'Paciente'
              //       : consulta['medico_especializacao'] ?? 'Especialização',
              // ),
            ),

            const SizedBox(height: 8),

            // Data e Hora
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(consulta['horario']),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Descrição
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Descrição',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    consulta['descricao'] ?? 'Sem descrição',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    if (status.contains('realizado')) {
      color = Colors.green;
      label = 'Realizado';
    } else {
      color = Colors.orange;
      label = 'Em Andamento';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'Data não informada';

    try {
      final dt = DateTime.parse(dateTime);
      final hoje = DateTime.now();
      final amanha = hoje.add(const Duration(days: 1));

      String dataTexto;
      if (dt.year == hoje.year && dt.month == hoje.month && dt.day == hoje.day) {
        dataTexto = 'Hoje';
      } else if (dt.year == amanha.year && dt.month == amanha.month && dt.day == amanha.day) {
        dataTexto = 'Amanhã';
      } else {
        dataTexto = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
      }

      return '$dataTexto às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
}