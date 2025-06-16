import 'package:flutter/material.dart';

class SleepTimerPicker extends StatelessWidget {
  final List<Duration> timerOptions = const [
    Duration(seconds: 10),
    Duration(seconds: 5),
    Duration(seconds: 30),
    Duration(seconds: 60),
    Duration(seconds: 90),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Wrap(
        children: timerOptions.map((duration) {
          return ListTile(
            title: Text(
              '${duration.inSeconds} seconds',
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () => Navigator.pop(context, duration),
          );
        }).toList()
          ..add(
            ListTile(
              title: const Text('Cancel Timer',
                  style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, null),
            ),
          ),
      ),
    );
  }
}
