import 'package:flutter/material.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/customer.dart';
import 'package:personal_trx_app/models/training_plan.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/services/auth/auth_service.dart';
import 'package:personal_trx_app/services/training_plan/training_plan_service.dart';
import 'package:personal_trx_app/views/personal/customers/training_plans/training_plan_card.dart';
import 'package:provider/provider.dart';

class TrainingPlansView extends StatefulWidget {
  final Customer customer;

  const TrainingPlansView({
    Key? key,
    required this.customer,
  }) : super(key: key);

  @override
  State<TrainingPlansView> createState() => _TrainingPlansViewState();
}

class _TrainingPlansViewState extends State<TrainingPlansView> {
  bool _isLoading = false;
  List<TrainingPlan> trainingPlans = [];
  late AuthProvider _authProvider = AuthProvider('');
  final popupButtonKey = GlobalKey<State>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _trainingPlanService = TrainingPlanService();

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _getTrainingPlans(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _getTrainingPlans(BuildContext context) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      trainingPlans = await _trainingPlanService.index(context, _authProvider.getToken, 1);

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

  Future<void> _submit([trainingPlanId]) async {
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

      if (trainingPlanId == null) {
        await _trainingPlanService.store(context, _authProvider.getToken, _nameController.text, userable['id']);
      } else {
        await _trainingPlanService.update(context, _authProvider.getToken, _nameController.text, userable['id'], trainingPlanId);
      }

      _getTrainingPlans(context);

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

  _showModal(context, [trainingPlan]) {
    var trainingPlanId = trainingPlan?.id;
    _nameController.text = trainingPlan != null ? trainingPlan.name : '';

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
                        _submit(trainingPlanId);
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
                'Planos de treino',
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
                        'Novo plano de treino',
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
                      itemCount: trainingPlans.length,
                      itemBuilder: (context, index) {
                        return TrainingPlanCard(
                          trainingPlan: trainingPlans[index],
                          onShowModal: (_, trainingPlan) => _showModal(_, trainingPlan),
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
