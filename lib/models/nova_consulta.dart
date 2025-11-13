import 'package:flutter/material.dart';
import 'dart:math';
import 'api_service.dart';

class NovaConsultaPage extends StatefulWidget {
  const NovaConsultaPage({super.key});

  @override
  State<NovaConsultaPage> createState() => _NovaConsultaPageState();
}

class _NovaConsultaPageState extends State<NovaConsultaPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final ApiService _apiService = ApiService();

  DateTime? _selectedDate;
  String? _selectedMedicoCpf;
  Map<String, dynamic>? _selectedHorario;

  List<dynamic> _medicos = [];
  List<dynamic> _horariosDisponiveis = [];

  bool _isLoading = false;
  bool _isLoadingMedicos = true;
  bool _isLoadingHorarios = false;

  @override
  void initState() {
    super.initState();
    _loadMedicos();
  }

  Future<void> _loadMedicos() async {
    setState(() => _isLoadingMedicos = true);

    try {
      final medicos = await _apiService.getMedicos();

      setState(() {
        _medicos = medicos;
        _isLoadingMedicos = false;
      });
    } catch (e) {
      print('Erro ao carregar médicos: $e');
      setState(() {
        _medicos = [];
        _isLoadingMedicos = false;
      });
    }
  }

  Future<void> _selectDate() async {
    if (_selectedMedicoCpf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um médico primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedHorario = null;
      });

      await _loadHorariosDisponiveis();
    }
  }

  Future<void> _loadHorariosDisponiveis() async {
    if (_selectedMedicoCpf == null || _selectedDate == null) return;

    setState(() => _isLoadingHorarios = true);

    try {
      final dataFormatada = _selectedDate!.toIso8601String().split('T')[0];

      final horarios = await _apiService.getHorariosDisponiveis(
        medicoCpf: _selectedMedicoCpf!,
        data: dataFormatada,
      );

      setState(() {
        _horariosDisponiveis = horarios;
        _isLoadingHorarios = false;
      });

      if (horarios.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum horário disponível nesta data'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Erro ao buscar horários: $e');
      setState(() {
        _horariosDisponiveis = [];
        _isLoadingHorarios = false;
      });
    }
  }

  Future<void> _criarConsulta() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma data'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedHorario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um horário'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMedicoCpf == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um médico'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final codigo = Random().nextInt(10000);

      final horaInicio = _selectedHorario!['hora_inicio'].split(':');
      final hora = int.parse(horaInicio[0]);
      final minuto = int.parse(horaInicio[1]);

      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hora,
        minuto,
      );

      final userData = await _apiService.getUserData();

      final result = await _apiService.criarConsulta(
        codigo: codigo,
        data: dateTime.toIso8601String(),
        descricao: _descricaoController.text,
        userCpf: userData!['cpf'],
        medicoCpf: _selectedMedicoCpf!,
      );

      setState(() => _isLoading = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao criar consulta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Consulta'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Seletor de Médico - CORRIGIDO
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isLoadingMedicos
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : _medicos.isEmpty
                      ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Nenhum médico disponível',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Selecione o Médico',
                      prefixIcon: Icon(Icons.medical_services, color: Colors.blue),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                    value: _selectedMedicoCpf,
                    isExpanded: true,
                    items: _medicos.map((medico) {
                      return DropdownMenuItem<String>(
                        value: medico['cpf'],
                        child: Text(
                          '${medico['nome'] ?? 'Nome não informado'} - ${medico['especificacao'] ?? 'Especialização'}',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMedicoCpf = value;
                        _selectedDate = null;
                        _selectedHorario = null;
                        _horariosDisponiveis = [];
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione um médico';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Seletor de Data
              Card(
                elevation: 2,
                child: ListTile(
                  enabled: _selectedMedicoCpf != null,
                  leading: Icon(
                    Icons.calendar_today,
                    color: _selectedMedicoCpf != null ? Colors.blue : Colors.grey,
                  ),
                  title: const Text('Data da Consulta'),
                  subtitle: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                        : _selectedMedicoCpf == null
                        ? 'Selecione um médico primeiro'
                        : 'Selecione a data',
                    style: TextStyle(
                      color: _selectedMedicoCpf == null ? Colors.grey : null,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: _selectedMedicoCpf != null ? null : Colors.grey,
                  ),
                  onTap: _selectedMedicoCpf != null ? _selectDate : null,
                ),
              ),
              const SizedBox(height: 16),

              // Seletor de Horário
              if (_selectedDate != null) ...[
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.blue),
                            const SizedBox(width: 12),
                            const Text(
                              'Selecione o Horário',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (_isLoadingHorarios)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_horariosDisponiveis.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Nenhum horário disponível nesta data',
                                    style: TextStyle(color: Colors.orange[800]),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _horariosDisponiveis.map((horario) {
                              final isSelected = _selectedHorario == horario;
                              final horaInicio = horario['hora_inicio'].substring(0, 5);
                              final horaFim = horario['hora_fim'].substring(0, 5);

                              return ChoiceChip(
                                label: Text('$horaInicio - $horaFim'),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedHorario = selected ? horario : null;
                                  });
                                },
                                selectedColor: Colors.blue,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                backgroundColor: Colors.grey[200],
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Campo de Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição da Consulta',
                  hintText: 'Ex: Consulta de rotina, exame de sangue...',
                  prefixIcon: Icon(Icons.description, color: Colors.blue),
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe uma descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botão de Criar
              ElevatedButton(
                onPressed: _isLoading ? null : _criarConsulta,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Criar Consulta',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}