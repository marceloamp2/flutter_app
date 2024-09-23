import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:personal_trx_app/models/exercise_group.dart';
import 'package:personal_trx_app/views/personal/exercises_groups/exercises/exercises_view.dart';

enum options { exercises, edit, delete }

class ExerciseGroupCard extends StatelessWidget {
  final ExerciseGroup exerciseGroup;
  final Function(BuildContext context, ExerciseGroup exerciseGroup) onShowModal;

  const ExerciseGroupCard({
    Key? key,
    required this.exerciseGroup,
    required this.onShowModal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        title: Text(exerciseGroup.name),
        trailing: PopupMenuButton<options>(
          onSelected: (options result) {
            if (result == options.exercises) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExercisesView(exerciseGroupId: exerciseGroup.id)),
              );
            }
            if (result == options.edit) {
              onShowModal(context, exerciseGroup);
            }
            if (result == options.delete) {}
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<options>>[
            PopupMenuItem<options>(
              value: options.exercises,
              child: Row(
                children: const [
                  Icon(FontAwesomeIcons.dumbbell, size: 16),
                  SizedBox(width: 15),
                  Text('Exercícios'),
                ],
              ),
            ),
            PopupMenuItem<options>(
              value: options.edit,
              child: Row(
                children: const [
                  Icon(FontAwesomeIcons.edit, size: 16),
                  SizedBox(width: 15),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem<options>(
              value: options.delete,
              child: Row(
                children: const [
                  Icon(FontAwesomeIcons.trash, size: 16),
                  SizedBox(width: 15),
                  Text('Excluir'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
