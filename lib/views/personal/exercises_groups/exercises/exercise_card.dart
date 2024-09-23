import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:personal_trx_app/models/exercise.dart';

enum options { edit, delete }

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final Function(BuildContext context, Exercise exercise) onShowModal;

  const ExerciseCard({
    Key? key,
    required this.exercise,
    required this.onShowModal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        title: Text(exercise.name),
        trailing: PopupMenuButton<options>(
          onSelected: (options result) {
            if (result == options.edit) {
              onShowModal(context, exercise);
            }
            if (result == options.delete) {}
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<options>>[
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
