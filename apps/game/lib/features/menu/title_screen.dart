import 'package:flutter/material.dart';

import '../../app/long_ky_app.dart';

/// Blank title screen (T-01). Menu entries arrive with the app shell (T-14).
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          LongKyApp.productName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFFC9A24A),
              ),
        ),
      ),
    );
  }
}
