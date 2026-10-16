import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lk_content/lk_content.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/long_ky_app.dart';
import '../../app/theme.dart';
import '../../data/content_repository.dart';

/// Credits and the citation registry (sources.json).
class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key, this.bundle});

  /// Asset bundle to read content from (tests inject one).
  final AssetBundle? bundle;

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  late final Future<ContentBundle> _content = loadContentFromAssets(widget.bundle ?? rootBundle);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final heading = Theme.of(context).textTheme.titleMedium?.copyWith(color: LongKyColors.goldLeaf);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsCredits)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: FutureBuilder<ContentBundle>(
            future: _content,
            builder: (context, snapshot) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(l.appTitle, style: heading),
                  const SizedBox(height: 8),
                  Text(l.creditsFont),
                  TextButton(
                    onPressed: () => showLicensePage(context: context, applicationName: LongKyApp.productName),
                    child: Text(l.creditsLicenses),
                  ),
                  const SizedBox(height: 16),
                  Text(l.creditsSources, style: heading),
                  const SizedBox(height: 8),
                  if (snapshot.hasError)
                    Text(l.creditsLoadError, style: const TextStyle(color: LongKyColors.cinnabar))
                  else if (!snapshot.hasData)
                    const Center(child: CircularProgressIndicator())
                  else
                    for (final s in snapshot.data!.sources.values) _SourceTile(source: s),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source});

  final SourceDef source;

  @override
  Widget build(BuildContext context) {
    final details = [source.publisher, source.author, source.section].whereType<String>().where((x) => x.isNotEmpty);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(source.work),
      subtitle: SelectableText([...details, ?source.url].join(' · ')),
    );
  }
}
