import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:personal_trx_app/models/training_plan.dart';

enum options { trainings, edit, delete }

class TrainingPlanCard extends StatelessWidget {
  final TrainingPlan trainingPlan;
  final Function(BuildContext context, TrainingPlan trainingPlan) onShowModal;

  const TrainingPlanCard({
    Key? key,
    required this.trainingPlan,
    required this.onShowModal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        title: Text(trainingPlan.name),
        subtitle: Column(
          children: [
            Row(
              children: [
                Text('Objetivo: ${trainingPlan.objective}'),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Text('Período: ${trainingPlan.startDate} à ${trainingPlan.endDate}'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<options>(
          onSelected: (options result) {
            if (result == options.trainings) {}
            if (result == options.edit) {}
            if (result == options.delete) {}
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<options>>[
            PopupMenuItem<options>(
              value: options.trainings,
              child: Row(
                children: const [
                  Icon(FontAwesomeIcons.dumbbell, size: 16),
                  SizedBox(width: 15),
                  Text('Treinos'),
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
