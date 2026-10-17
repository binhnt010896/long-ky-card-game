import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lk_content/lk_content.dart';

import '../../app/l10n/app_localizations.dart';
import '../../app/lacquer.dart';
import '../../app/theme.dart';
import '../../data/codex.dart';
import '../../data/content_repository.dart';
import '../../data/long_ky_access.dart';
import '../../data/progress.dart';
import '../battle/labels.dart';
import '../battle/overlays/panel.dart';
import '../settings/progress_cubit.dart';
import 'codex_entry_screen.dart';
import 'redeem.dart';

/// The Codex (build-spec section 6): the officers, the enemy commanders and
/// the cards, each with its sources and "Read more in Long Ký", and the box
/// where an unlock code from Long Ký is typed.
class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  ContentBundle? _content;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bundle = context.getInheritedWidgetOfExactType<DefaultAssetBundle>()?.bundle ?? rootBundle;
    try {
      final c = await loadContentFromAssets(bundle);
      if (mounted) setState(() => _content = c);
    } on Object {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final content = _content;
    final Widget body;
    if (_failed) {
      body = Center(child: Text(l.battleLoadError));
    } else if (content == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = _CodexList(content: content, codex: Codex(content));
    }
    return LacquerPage(title: l.menuCodex, body: body);
  }
}

class _CodexList extends StatelessWidget {
  const _CodexList({required this.content, required this.codex});

  final ContentBundle content;
  final Codex codex;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return BlocBuilder<ProgressCubit, Progress>(
      builder: (context, progress) {
        Widget section(String heading, CodexKind kind) {
          final entries = codex.ofKind(kind);
          if (entries.isEmpty) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                child: Text(
                  heading,
                  style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _EntryTile(
                    key: Key('codex-${e.id}'),
                    entry: e,
                    unlocked: e.longKyId != null && progress.unlocks.contains(e.longKyId),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CodexEntryScreen(entry: e, sources: content.sources),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            // A column, not a lazy list: there are a dozen pages, not thousands.
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UnlockCodeBox(codex: codex),
                  section(l.codexOfficers, CodexKind.officer),
                  section(l.codexEnemies, CodexKind.enemy),
                  section(l.codexCards, CodexKind.card),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({super.key, required this.entry, required this.unlocked, required this.onTap});

  final CodexEntry entry;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final name = l.content(entry.name);
    final title = entry.title == null ? null : l.content(entry.title!);
    return Semantics(
      button: true,
      label: [name, ?title, if (unlocked) l.codexUnlocked].join(', '),
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: lacquerPanel(),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(color: LongKyColors.ivory, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      if (title != null)
                        Text(title, style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.8), fontSize: 13)),
                    ],
                  ),
                ),
                if (unlocked) const Icon(Icons.lock_open, key: Key('unlocked-mark'), color: LongKyColors.goldLeaf),
                const Icon(Icons.chevron_right, color: LongKyColors.goldLeaf),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The unlock-code box: type `LK-XXXX-XXXX` from Long Ký, press Unlock.
class UnlockCodeBox extends StatefulWidget {
  const UnlockCodeBox({super.key, required this.codex});

  final Codex codex;

  @override
  State<UnlockCodeBox> createState() => _UnlockCodeBoxState();
}

class _UnlockCodeBoxState extends State<UnlockCodeBox> {
  final _controller = TextEditingController();
  String? _message;
  bool _ok = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final progress = context.read<ProgressCubit>();
    final access = context.read<LongKyAccess>();
    final result = await redeemCode(input: _controller.text, access: access, codex: widget.codex, progress: progress);
    if (!mounted) return;
    setState(() {
      _message = redeemMessage(l, result);
      _ok = result is Redeemed;
      if (_ok) _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      key: const Key('unlock-box'),
      padding: const EdgeInsets.all(16),
      decoration: lacquerPanel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.codexCodeTitle,
            style: const TextStyle(color: LongKyColors.goldLeaf, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(l.codexCodeHelp, style: TextStyle(color: LongKyColors.ivory.withValues(alpha: 0.85), fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                child: TextField(
                  key: const Key('code-field'),
                  controller: _controller,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  enableSuggestions: false,
                  onSubmitted: (_) => _submit(),
                  inputFormatters: [LengthLimitingTextInputFormatter(24)],
                  decoration: InputDecoration(labelText: l.codexCodeField, hintText: 'LK-XXXX-XXXX'),
                ),
              ),
              FilledButton(
                key: const Key('code-redeem'),
                onPressed: _submit,
                style: FilledButton.styleFrom(minimumSize: const Size(0, minTouch)),
                child: Text(l.codexCodeRedeem),
              ),
            ],
          ),
          if (_message != null) ...[
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                _message!,
                key: const Key('code-result'),
                style: TextStyle(color: _ok ? LongKyColors.goldLeaf : LongKyColors.ivory, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
