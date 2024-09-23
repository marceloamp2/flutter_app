import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/money_input_enums.dart';
import 'package:flutter_multi_formatter/formatters/money_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/plan.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/services/auth/auth_service.dart';
import 'package:personal_trx_app/services/plan/plan_service.dart';
import 'package:personal_trx_app/views/personal/plans/plan_card.dart';
import 'package:provider/provider.dart';

class PlansView extends StatefulWidget {
  const PlansView({Key? key}) : super(key: key);

  @override
  State<PlansView> createState() => _PlansViewState();
}

class _PlansViewState extends State<PlansView> {
  bool _isLoading = false;
  List<Plan> plans = [];
  List<Plan> plansBackup = [];
  late AuthProvider _authProvider = AuthProvider('');
  final popupButtonKey = GlobalKey<State>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationInDaysController = TextEditingController();
  final _priceController = TextEditingController();
  final _planService = PlanService();
  NumberFormat formatter = NumberFormat.simpleCurrency(locale: 'pt_BR');

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _getPlans(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationInDaysController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _getPlans(BuildContext context) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      plans = await _planService.index(context, _authProvider.getToken);
      plansBackup = plans;

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

  Future<void> _submit([planId]) async {
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

      if (planId == null) {
        await _planService.store(context, _authProvider.getToken, _nameController.text, int.parse(_durationInDaysController.text),
            double.parse(_priceController.text.replaceAll('.', '').replaceAll(',', '.')), userable['id']);
      } else {
        await _planService.update(context, _authProvider.getToken, _nameController.text, userable['id'], planId);
      }

      _getPlans(context);

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
            ));
  }

  _showModal(context, [plan]) {
    var planId = plan?.id;
    _nameController.text = plan != null ? plan.name : '';
    _durationInDaysController.text = plan != null ? plan.durationInDays.toString() : '';
    _priceController.text = plan != null ? formatter.format(plan.price).toString() : '';

    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: MediaQuery.of(context).viewInsets,
          color: Colors.grey[800],
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nome obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Duração em dias',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    controller: _durationInDaysController,
                    validator: (value) {
                      if (value == null || value.isEmpty || value == '0') {
                        return 'Duração em dias obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Valor',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      MoneyInputFormatter(
                        thousandSeparator: ThousandSeparator.Period,
                      ),
                    ],
                    controller: _priceController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'O valor obrigatório';
                      }
                      return null;
                    },
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
                      onPressed: () {
                        _submit(planId);
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Container(
            color: Colors.grey[900],
            child: const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text(
                'Planos',
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
                        'Novo plano',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        return PlanCard(
                          plan: plans[index],
                          onShowModal: (_, plan) => _showModal(_, plan),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
