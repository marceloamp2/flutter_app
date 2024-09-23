import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/exercise_group.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/services/auth/auth_service.dart';
import 'package:personal_trx_app/services/exercise_group/exercise_group_service.dart';
import 'package:personal_trx_app/views/personal/exercises_groups/exercise_group_card.dart';
import 'package:provider/provider.dart';

class ExerciseGroupsView extends StatefulWidget {
  const ExerciseGroupsView({Key? key}) : super(key: key);

  @override
  State<ExerciseGroupsView> createState() => _ExerciseGroupsViewState();
}

class _ExerciseGroupsViewState extends State<ExerciseGroupsView> {
  bool _isLoading = false;
  List<ExerciseGroup> exerciseGroups = [];
  List<ExerciseGroup> exerciseGroupsBackup = [];
  late AuthProvider _authProvider = AuthProvider('');
  final popupButtonKey = GlobalKey<State>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final _exerciseGroupService = ExerciseGroupService();

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _getExerciseGroups(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getExerciseGroups(BuildContext context) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      exerciseGroups = await _exerciseGroupService.index(context, _authProvider.getToken);
      exerciseGroupsBackup = exerciseGroups;

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

  Future<void> _submit([exerciseGroupId]) async {
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

      if (exerciseGroupId == null) {
        await _exerciseGroupService.store(context, _authProvider.getToken, _nameController.text, userable['id']);
      } else {
        await _exerciseGroupService.update(context, _authProvider.getToken, _nameController.text, userable['id'], exerciseGroupId);
      }

      _getExerciseGroups(context);

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

  _showModal(context, [exerciseGroup]) {
    var exerciseGroupId = exerciseGroup?.id;
    _nameController.text = exerciseGroup != null ? exerciseGroup.name : '';

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
                        _submit(exerciseGroupId);
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

  void _searchExerciseGroup(value) {
    if (value.toString().isNotEmpty) {
      var newList = exerciseGroups.where((element) => element.name.toLowerCase().contains(value.toLowerCase())).toList();
      setState(() {
        exerciseGroups = newList;
      });
    } else {
      setState(() {
        exerciseGroups = exerciseGroupsBackup;
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
                'Grupo de exercícios',
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
                        'Novo grupo de exercícios',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Digite o nome do grupo',
                      prefixIcon: Icon(FontAwesomeIcons.search, size: 18),
                    ),
                    onChanged: (value) => _searchExerciseGroup(value),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    controller: _searchController,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: exerciseGroups.length,
                      itemBuilder: (context, index) {
                        return ExerciseGroupCard(
                          exerciseGroup: exerciseGroups[index],
                          onShowModal: (_, exerciseGroup) => _showModal(_, exerciseGroup),
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
