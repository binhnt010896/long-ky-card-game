import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../data/progress.dart';
import '../data/progress_repository.dart';
import '../features/settings/progress_cubit.dart';
import 'l10n/app_localizations.dart';
import 'routes.dart';
import 'theme.dart';

/// Root widget: progress and settings, theme, localization and routes.
class LongKyApp extends StatelessWidget {
  const LongKyApp({super.key, required this.repository, required this.initial});

  final ProgressRepository repository;
  final Progress initial;

  /// The product name. It is a proper name, identical in vi and en.
  static const String productName = 'Long Ký - The Game';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgressCubit(repository, initial),
      child: BlocBuilder<ProgressCubit, Progress>(
        buildWhen: (a, b) => a.settings != b.settings,
        builder: (context, progress) {
          final settings = progress.settings;
          return MaterialApp(
            title: productName,
            debugShowCheckedModeBanner: false,
            theme: buildLongKyTheme(),
            locale: Locale(settings.languageCode),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: Routes.title,
            routes: Routes.table,
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: TextScaler.linear(settings.textScale),
                  disableAnimations: mq.disableAnimations || settings.reduceMotion,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
