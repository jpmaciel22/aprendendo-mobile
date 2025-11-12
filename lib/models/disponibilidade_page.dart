import 'package:flutter/material.dart';
import 'api_service.dart';

class DisponibilidadePage extends StatefulWidget {
  const DisponibilidadePage({super.key});

  @override
  State<DisponibilidadePage> createState() => _DisponibilidadePageState();
}

class _DisponibilidadePageState extends State<DisponibilidadePage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  DateTime? _dataInicio;
  DateTime? _dataFim;
  List<Map<String, String>> _horarios = [];

  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFim;

  bool _isLoading = false;
  List<dynamic> _disponibilidades = [];
  bool _isLoadingDisponibilidades = true;

  @override
  void initState() {
    super.initState();
    _loadDisponibilidades();
  }

  Future<void> _loadDisponibilidades() async {
    setState(() => _isLoadingDisponibilidades = true);

    final userData = await _apiService.getUserData();
    if (userData != null) {
      final disp = await _apiService.getDisponibilidades(userData['cpf']);
      setState(() {
        _disponibilidades = disp;
        _isLoadingDisponibilidades = false;
      });
    } else {
      setState(() => _isLoadingDisponibilidades = false);
    }
  }

  Future<void> _selectDataInicio() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _dataInicio = picked);
    }
  }

  Future<void> _selectDataFim() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataInicio ?? DateTime.now(),
      firstDate: _dataInicio ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _dataFim = picked);
    }
  }

  Future<void> _selectHoraInicio() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _horaInicio = picked);
    }
  }

  Future<void> _selectHoraFim() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaInicio ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _horaFim = picked);
    }
  }

  void _adicionarHorario() {
    if (_horaInicio == null || _horaFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione hora de início e fim'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _horarios.add({
        'hora_inicio': '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}:00',
        'hora_fim': '${_horaFim!.hour.toString().padLeft(2, '0')}:${_horaFim!.minute.toString().padLeft(2, '0')}:00',
      });
      _horaInicio = null;
      _horaFim = null;
    });
  }

  void _removerHorario(int index) {
    setState(() {
      _horarios.removeAt(index);
    });
  }

  Future<void> _salvarDisponibilidade() async {
    if (_dataInicio == null || _dataFim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o período de datas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_horarios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um horário'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userData = await _apiService.getUserData();

    final result = await _apiService.criarDisponibilidade(
      medicoCpf: userData!['cpf'],
      dataInicio: _dataInicio!.toIso8601String().split('T')[0],
      dataFim: _dataFim!.toIso8601String().split('T')[0],
      horarios: _horarios,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result['message']} (${result['total']} horários criados)'),
          backgroundColor: Colors.green,
        ),
      );

      // Limpar formulário
      setState(() {
        _dataInicio = null;
        _dataFim = null;
        _horarios = [];
      });

      // Recarregar lista
      _loadDisponibilidades();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Disponibilidade'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seção de criar disponibilidade
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Definir Período de Disponibilidade',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Data início
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today, color: Colors.blue),
                      title: const Text('Data Início'),
                      subtitle: Text(
                        _dataInicio != null
                            ? '${_dataInicio!.day.toString().padLeft(2, '0')}/${_dataInicio!.month.toString().padLeft(2, '0')}/${_dataInicio!.year}'
                            : 'Selecione',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectDataInicio,
                    ),

                    // Data fim
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event, color: Colors.blue),
                      title: const Text('Data Fim'),
                      subtitle: Text(
                        _dataFim != null
                            ? '${_dataFim!.day.toString().padLeft(2, '0')}/${_dataFim!.month.toString().padLeft(2, '0')}/${_dataFim!.year}'
                            : 'Selecione',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectDataFim,
                    ),

                    const Divider(),
                    const SizedBox(height: 8),

                    const Text(
                      'Horários Disponíveis',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Adicionar horário
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectHoraInicio,
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _horaInicio != null
                                  ? '${_horaInicio!.hour.toString().padLeft(2, '0')}:${_horaInicio!.minute.toString().padLeft(2, '0')}'
                                  : 'Início',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectHoraFim,
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              _horaFim != null
                                  ? '${_horaFim!.hour.toString().padLeft(2, '0')}:${_horaFim!.minute.toString().padLeft(2, '0')}'
                                  : 'Fim',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _adicionarHorario,
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          iconSize: 32,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Lista de horários adicionados
                    if (_horarios.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _horarios.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, String> horario = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule, size: 20, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${horario['hora_inicio']!.substring(0, 5)} - ${horario['hora_fim']!.substring(0, 5)}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => _removerHorario(index),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    iconSize: 20,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Botão salvar
                    ElevatedButton(
                      onPressed: _salvarDisponibilidade,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Salvar Disponibilidade',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Seção de disponibilidades salvas
            const Text(
              'Minhas Disponibilidades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _isLoadingDisponibilidades
                ? const Center(child: CircularProgressIndicator())
                : _disponibilidades.isEmpty
                ? const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhuma disponibilidade cadastrada',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
                : Column(
              children: _disponibilidades.map((disp) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.event_available, color: Colors.green),
                    title: Text(
                      '${disp['data']} - ${disp['hora_inicio'].substring(0, 5)} às ${disp['hora_fim'].substring(0, 5)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      disp['disponivel'] ? 'Disponível' : 'Ocupado',
                      style: TextStyle(
                        color: disp['disponivel'] ? Colors.green : Colors.red,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text('Deseja deletar esta disponibilidade?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Deletar', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );

                        if (confirmar == true) {
                          final result = await _apiService.deletarDisponibilidade(disp['id_disponibilidade']);

                          if (result['success']) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _loadDisponibilidades();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message']),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
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