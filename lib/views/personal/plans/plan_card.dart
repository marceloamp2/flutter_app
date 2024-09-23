import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:personal_trx_app/models/plan.dart';

enum options { edit, delete }

class PlanCard extends StatelessWidget {
  final Plan plan;
  final Function(BuildContext context, Plan plan) onShowModal;

  const PlanCard({
    Key? key,
    required this.plan,
    required this.onShowModal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NumberFormat formatter = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        title: Text(plan.name),
        subtitle: Text('Valor: ${formatter.format(plan.price)}'),
        trailing: PopupMenuButton<options>(
          onSelected: (options result) {
            if (result == options.edit) {
              onShowModal(context, plan);
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
