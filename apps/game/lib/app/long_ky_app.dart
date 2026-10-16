import 'package:flutter/material.dart';

import '../features/menu/title_screen.dart';

/// Root widget. Routing, theme tokens and gen-l10n arrive in T-14.
class LongKyApp extends StatelessWidget {
  const LongKyApp({super.key});

  /// The product name. It is a proper name, identical in vi and en.
  static const String productName = 'Long Ký - The Game';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: productName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E0B0A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC9A24A),
          secondary: Color(0xFFB3261E),
          surface: Color(0xFF0E0B0A),
          onSurface: Color(0xFFF2E8D5),
        ),
      ),
      home: const TitleScreen(),
    );
  }
}
