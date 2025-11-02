import 'package:flutter/material.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int seconds = 0;
  bool isRunning = false;
  late final ticker = Stream.periodic(const Duration(seconds: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Defense Timer'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$seconds s',
              style: const TextStyle(color: Colors.white, fontSize: 40),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!isRunning) {
                  isRunning = true;
                  ticker.listen((_) {
                    if (!mounted) return;
                    setState(() => seconds++);
                  });
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Start Timer'),
            ),
          ],
        ),
      ),
    );
  }
}
