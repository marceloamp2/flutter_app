import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/customer.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/services/auth/auth_service.dart';
import 'package:personal_trx_app/services/customer/customer_service.dart';
import 'package:personal_trx_app/views/personal/customers/customer_card.dart';
import 'package:provider/provider.dart';

class CustomersView extends StatefulWidget {
  const CustomersView({Key? key}) : super(key: key);

  @override
  State<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<CustomersView> {
  bool _isLoading = false;
  List<Customer> customers = [];
  List<Customer> customersBackup = [];
  late AuthProvider _authProvider = AuthProvider('');
  final popupButtonKey = GlobalKey<State>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cellphoneController = TextEditingController();
  final _searchController = TextEditingController();
  final _customerService = CustomerService();

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _getCustomers(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cellphoneController.dispose();
    _searchController.dispose();
    super.dispose();
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

      customers = await _customerService.index(context, _authProvider.getToken, userable['id']);
      customersBackup = customers;

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

  Future<void> _submit([customerId]) async {
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

      if (customerId == null) {
        await _customerService.store(
            context, _authProvider.getToken, _nameController.text, _emailController.text, _cellphoneController.text, userable['id']);
      } else {
        await _customerService.update(
            context, _authProvider.getToken, _nameController.text, _emailController.text, _cellphoneController.text, userable['id'], customerId);
      }

      _getCustomers(context);

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

  _showModal(context, [customer]) {
    var customerId = customer?.id;
    _nameController.text = customer != null ? customer.name : '';
    _emailController.text = customer != null ? customer.user.email : '';
    _cellphoneController.text = customer != null ? customer.cellphone : '';

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
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Celular',
                    ),
                    textInputAction: TextInputAction.next,
                    controller: _cellphoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      MaskedInputFormatter('(00)00000-0000'),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Celular obrigatório';
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
                        _submit(customerId);
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

  void _searchCustomer(value) {
    if (value.toString().isNotEmpty) {
      var newList = customers.where((element) => element.name.toLowerCase().contains(value.toLowerCase())).toList();
      setState(() {
        customers = newList;
      });
    } else {
      setState(() {
        customers = customersBackup;
      });
    }
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
                'Alunos',
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
                        'Novo aluno',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Digite o nome do aluno',
                      prefixIcon: Icon(FontAwesomeIcons.search, size: 18),
                    ),
                    onChanged: (value) => _searchCustomer(value),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    controller: _searchController,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        return CustomerCard(
                          customer: customers[index],
                          onShowModal: (_, customer) => _showModal(_, customer),
                          onTrainingPlan: (_, customer) => _showModal(_, customer),
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
