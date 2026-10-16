import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../art/art_library.dart';
import '../audio/audio_service.dart';
import '../data/battle_save_repository.dart';
import '../data/battle_save_store.dart';
import '../data/progress.dart';
import '../data/progress_repository.dart';
import '../features/settings/progress_cubit.dart';
import 'audio_scope.dart';
import 'l10n/app_localizations.dart';
import 'routes.dart';
import 'theme.dart';

/// Root widget: progress and settings, theme, localization and routes.
class LongKyApp extends StatelessWidget {
  LongKyApp({
    super.key,
    required this.repository,
    required this.initial,
    BattleSaveRepository? saves,
    AudioService? audio,
    ArtLibrary? art,
  }) : saves = saves ?? BattleSaveRepository(MemoryBattleSaveStore()),
       audio = audio ?? AudioService.silent(),
       art = art ?? ArtLibrary.empty();

  final ProgressRepository repository;
  final Progress initial;

  /// The battle save (`battle.json`). In memory unless the app gives it a file.
  final BattleSaveRepository saves;

  /// Narration, music and effects. Silent unless the app gives it a backend.
  final AudioService audio;

  /// The painted art that ships; none until it is delivered, so placeholders show.
  final ArtLibrary art;

  /// The product name. It is a proper name, identical in vi and en.
  static const String productName = 'Long Ký - The Game';

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: saves),
        RepositoryProvider.value(value: audio),
        RepositoryProvider.value(value: art),
      ],
      child: BlocProvider(
        create: (_) => ProgressCubit(repository, initial),
        child: AudioScope(
          audio: audio,
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
        ),
      ),
    );
  }
}
