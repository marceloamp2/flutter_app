import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:personal_trx_app/models/customer.dart';
import 'package:personal_trx_app/views/personal/customers/training_plans/training_plans_view.dart';

enum options { trainingPlan, edit }

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final Function(BuildContext context, Customer customer) onShowModal;
  final Function(BuildContext context, Customer customer) onTrainingPlan;

  const CustomerCard({
    Key? key,
    required this.customer,
    required this.onShowModal,
    required this.onTrainingPlan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        leading: customer.picture != null
            ? CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(customer.picture!),
              )
            : const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/images/logo.png"),
              ),
        title: Text(customer.name),
        subtitle: Column(
          children: [
            Row(
              children: [
                Text(customer.user.email.toString().length > 17 ? '${customer.user.email.substring(0, 17)}...' : customer.user.email),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Text(customer.cellphone),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<options>(
          onSelected: (options result) {
            if (result == options.trainingPlan) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrainingPlansView(customer: customer)),
              );
            }
            if (result == options.edit) {
              onShowModal(context, customer);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<options>>[
            PopupMenuItem<options>(
              value: options.trainingPlan,
              child: Row(
                children: const [
                  Icon(FontAwesomeIcons.dumbbell, size: 16),
                  SizedBox(width: 15),
                  Text('Plano de treino'),
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
          ],
        ),
      ),
    );
  }
}
