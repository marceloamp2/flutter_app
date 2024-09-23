import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/customer.dart';
import 'package:personal_trx_app/models/schedule.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/services/auth/auth_service.dart';
import 'package:personal_trx_app/services/customer/customer_service.dart';
import 'package:personal_trx_app/services/schedule/schedule_service.dart';
import 'package:personal_trx_app/views/personal/schedule/schedule_card.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({Key? key}) : super(key: key);

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  bool _isLoading = false;
  List<Schedule> _schedules = [];
  List<Customer> _customers = [];
  List<Customer> _customersFiltered = [];
  int _selectedCustomerId = 0;
  late AuthProvider _authProvider = AuthProvider('');
  final _formKey = GlobalKey<FormState>();
  final _scheduleService = ScheduleService();
  final _customerService = CustomerService();
  final _searchController = TextEditingController();
  Map<String, dynamic> _userable = {};
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final DateFormat formatterDate = DateFormat('dd/MM/yyyy');
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  bool _errorEndTime = false;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _getSchedules(context);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getSchedules(BuildContext context) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      AuthService _authService = AuthService();
      _userable = await _authService.userable(_authProvider.getToken);

      _schedules = await _scheduleService.index(context, _authProvider.getToken, _userable['id'], _selectedDay);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint(e.toString());
    }
  }

  Future<void> _getCustomers(BuildContext context) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      AuthService _authService = AuthService();
      Map<String, dynamic> userable = await _authService.userable(_authProvider.getToken);

      _customers = await _customerService.index(context, _authProvider.getToken, userable['id']);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint(e.toString());
    }
  }

  void _searchCustomer(String value, updateState) {
    if (value.toString().isNotEmpty) {
      var newList = _customers.where((element) => element.name.toLowerCase().contains(value.toLowerCase())).toList();
      updateState(() {
        _customersFiltered = newList;
      });
    } else {
      updateState(() {
        _customersFiltered = [];
      });
    }
  }

  Future<void> _submit() async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      AuthService _authService = AuthService();
      Map<String, dynamic> userable = await _authService.userable(_authProvider.getToken);

      String date = DateFormat('yyyy-MM-dd').format(_selectedDay);
      String startTime = '${_startTime.format(context)}:00';
      String endTime = '${_endTime.format(context)}:00';

      await _scheduleService.store(context, _authProvider.getToken, date, startTime, endTime, _selectedCustomerId, userable['id']);

      await _getSchedules(context);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on ApiExceptions catch (error) {
      debugPrint(error.toString());
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(error.toString());
      }
    } catch (error) {
      debugPrint(error.toString());
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(error.toString());
      }
    }
  }

  Future<void> _deleteSchedule(int scheduleId) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      await _scheduleService.destroy(context, _authProvider.getToken, scheduleId);

      await _getSchedules(context);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on ApiExceptions catch (error) {
      debugPrint(error.toString());
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(error.toString());
      }
    } catch (error) {
      debugPrint(error.toString());
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(error.toString());
      }
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Erro',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(
          msg,
          style: const TextStyle(fontSize: 18),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  double _startTimeDouble(TimeOfDay _startTime) => _startTime.hour + _startTime.minute / 60.0;

  double _endTimeDouble(TimeOfDay _endTime) => _endTime.hour + _endTime.minute / 60.0;

  Future<void> _showStartTimePicker(BuildContext context, updateState) async {
    TimeOfDay? startTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      cancelText: 'Cancelar',
      context: context,
      helpText: 'Selecione a hora inicial',
    );

    if (startTime != null) {
      updateState(() {
        _startTime = startTime;
        if (_startTimeDouble(_startTime) <= _endTimeDouble(_endTime)) {
          _errorEndTime = false;
        } else {
          _errorEndTime = true;
        }
      });
    }
  }

  Future<void> _showEndTimePicker(BuildContext context, updateState) async {
    TimeOfDay? endTime = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1))),
      cancelText: 'Cancelar',
      context: context,
      helpText: 'Selecione a hora final',
    );

    if (endTime != null) {
      updateState(() {
        _endTime = endTime;
        if (_startTimeDouble(_startTime) <= _endTimeDouble(_endTime)) {
          _errorEndTime = false;
        } else {
          _errorEndTime = true;
        }
      });
    }
  }

  _selectCustomer(selectedCustomer, updateState) {
    updateState(() {
      _selectedCustomerId = selectedCustomer.id;
      _searchController.text = selectedCustomer.name;
      _customers = [];
      _customersFiltered = [];
    });
  }

  _showModal(BuildContext context) async {
    _customers = [];
    _customersFiltered = [];
    _searchController.text = '';
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
    _errorEndTime = false;
    await _getCustomers(context);

    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, state) {
          return SingleChildScrollView(
            child: Container(
              padding: MediaQuery.of(context).viewInsets,
              color: Colors.grey[800],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Data selecionada:',
                                style: TextStyle(fontSize: 16, color: Color(0xFFBDBDBD)),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                formatterDate.format(_selectedDay).toString(),
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Hora inicial:',
                                style: TextStyle(fontSize: 16, color: Color(0xFFBDBDBD)),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _showStartTimePicker(context, state),
                                child: Text(
                                  _startTime.format(context).toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Hora final:',
                                style: TextStyle(fontSize: 16, color: Color(0xFFBDBDBD)),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _showEndTimePicker(context, state),
                                child: Text(
                                  _endTime.format(context).toString(),
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Digite o nome do aluno',
                        ),
                        onChanged: (value) => _searchCustomer(value, state),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        controller: _searchController,
                      ),
                      if (_customersFiltered.isNotEmpty)
                        Container(
                          constraints: const BoxConstraints(minHeight: 0, maxHeight: 150),
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.grey,
                                width: 0.8,
                              ),
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 0.8,
                              ),
                              right: BorderSide(
                                color: Colors.grey,
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: ListView.builder(
                            itemCount: _customersFiltered.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () => _selectCustomer(_customersFiltered[index], state),
                                child: ListTile(
                                  title: Text(_customersFiltered[index].name),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (_errorEndTime)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.red,
                              width: 0.8,
                            ),
                          ),
                          child: const Text('Erro! Hora inicial maior que hora final'),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 16),
                            primary: Colors.amber,
                            onPrimary: Colors.black,
                          ),
                          onPressed: _errorEndTime || _selectedCustomerId == 0
                              ? null
                              : () {
                                  _submit();
                                  Navigator.pop(context);
                                },
                          child: const Text(
                            'Salvar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agenda',
          style: TextStyle(
            color: Colors.amber,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 16),
                  primary: Colors.amber,
                  onPrimary: Colors.black,
                ),
                onPressed: () => _showModal(context),
                child: const Text(
                  'Novo agendamento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            TableCalendar(
              calendarStyle: const CalendarStyle(
                todayTextStyle: TextStyle(color: Colors.black),
                todayDecoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.black),
                selectedDecoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                titleTextFormatter: (date, locale) => DateFormat.yMMM(locale).format(date),
              ),
              locale: 'pt_BR',
              availableCalendarFormats: const {
                CalendarFormat.week: 'semana',
                CalendarFormat.month: 'mès',
              },
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
                _getSchedules(context);
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const SizedBox(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    )
                  : _schedules.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: _schedules.length,
                          itemBuilder: (context, index) {
                            return ScheduleCard(
                              schedule: _schedules[index],
                              onDelete: () => _deleteSchedule(_schedules[index].id),
                            );
                          },
                        )
                      : const Center(
                          child: Text(
                            'Sem agendamentos',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.amber,
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
