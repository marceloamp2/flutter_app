import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:personal_trx_app/exceptions/api_exceptions.dart';
import 'package:personal_trx_app/models/exercise.dart';
import 'package:personal_trx_app/providers/auth_provider.dart';
import 'package:personal_trx_app/services/exercise/exercise_service.dart';
import 'package:provider/provider.dart';

import 'exercise_card.dart';

class ExercisesView extends StatefulWidget {
  final int exerciseGroupId;

  const ExercisesView({
    Key? key,
    required this.exerciseGroupId,
  }) : super(key: key);

  @override
  State<ExercisesView> createState() => _ExercisesViewState();
}

class _ExercisesViewState extends State<ExercisesView> {
  bool _isLoading = false;
  List<Exercise> exercises = [];
  List<Exercise> exercisesBackup = [];
  late AuthProvider _authProvider = AuthProvider('');
  final popupButtonKey = GlobalKey<State>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  final _exerciseService = ExerciseService();

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _getExercises(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getExercises(BuildContext context) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      exercises = await _exerciseService.index(context, _authProvider.getToken, widget.exerciseGroupId);
      exercisesBackup = exercises;

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

  Future<void> _submit([exerciseId]) async {
    try {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      if (exerciseId == null) {
        await _exerciseService.store(context, _authProvider.getToken, _nameController.text, exercises[0].exerciseGroupId);
      } else {
        await _exerciseService.update(context, _authProvider.getToken, _nameController.text, exercises[0].exerciseGroupId, exerciseId);
      }

      _getExercises(context);

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

  _showModal(context, [exercise]) {
    var exerciseId = exercise?.id;
    _nameController.text = exercise != null ? exercise.name : '';

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
                        _submit(exerciseId);
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

  void _searchExercise(value) {
    if (value.toString().isNotEmpty) {
      var newList = exercises.where((element) => element.name.toLowerCase().contains(value.toLowerCase())).toList();
      setState(() {
        exercises = newList;
      });
    } else {
      setState(() {
        exercises = exercisesBackup;
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
              title: Text(
                'Exercícios ${exercises[0].exerciseGroup.name}',
                style: const TextStyle(
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
                        'Novo exercício',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Digite o nome do exercício',
                      prefixIcon: Icon(FontAwesomeIcons.search, size: 18),
                    ),
                    onChanged: (value) => _searchExercise(value),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    controller: _searchController,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return ExerciseCard(
                          exercise: exercises[index],
                          onShowModal: (_, exercise) => _showModal(_, exercise),
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
