import 'dart:math';
import 'package:flutter/material.dart';

Future<bool> showMathGuard(BuildContext context) async {
  final rng = Random();
  final ops = ['+', '−', '×'];
  final op = ops[rng.nextInt(ops.length)];
  int a, b, answer;

  switch (op) {
    case '−':
      a = rng.nextInt(9) + 2;
      b = rng.nextInt(a - 1) + 1;
      answer = a - b;
    case '×':
      a = rng.nextInt(5) + 2;
      b = rng.nextInt(5) + 2;
      answer = a * b;
    default:
      a = rng.nextInt(9) + 1;
      b = rng.nextInt(9) + 1;
      answer = a + b;
  }

  final ctrl = TextEditingController();
  String? error;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Caregiver Lock'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Solve to continue:',
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              '$a  $op  $b  =  ?',
              style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Your answer',
                errorText: error,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                if (int.tryParse(ctrl.text.trim()) == answer) {
                  Navigator.pop(ctx, true);
                } else {
                  setState(() => error = 'Incorrect, try again');
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () {
              if (int.tryParse(ctrl.text.trim()) == answer) {
                Navigator.pop(ctx, true);
              } else {
                setState(() => error = 'Incorrect, try again');
              }
            },
            child:
                const Text('Unlock', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );

  return result == true;
}
