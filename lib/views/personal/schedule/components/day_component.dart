import 'package:flutter/material.dart';

class DayComponent extends StatelessWidget {
  final int day;

  const DayComponent({
    Key? key,
    this.day = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Center(
            child: Text(
          day.toString(),
          style: const TextStyle(color: Colors.white),
        )),
      ),
    );
  }
}
