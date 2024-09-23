import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:personal_trx_app/models/schedule.dart';

enum options { delete }

class ScheduleCard extends StatelessWidget {
  final Schedule schedule;
  final Function() onDelete;

  const ScheduleCard({
    Key? key,
    required this.schedule,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        title: Text(schedule.customer.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Text(schedule.startTime.toString().substring(0, 5), style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 5),
                const Text('às'),
                const SizedBox(width: 5),
                Text(schedule.endTime.toString().substring(0, 5), style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Treino executado?'),
                const SizedBox(width: 15),
                Icon(
                  FontAwesomeIcons.checkCircle,
                  size: 16,
                  color: schedule.done == true ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<options>(
          onSelected: (options result) {
            if (result == options.delete) {
              onDelete();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<options>>[
            PopupMenuItem<options>(
              value: options.delete,
              child: Row(
                children: const [
                  Icon(FontAwesomeIcons.trash, size: 18),
                  SizedBox(width: 10),
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
