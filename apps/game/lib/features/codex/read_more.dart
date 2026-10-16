import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/l10n/app_localizations.dart';
import '../../data/long_ky_access.dart';
import '../battle/overlays/panel.dart';

/// "Read more in Long Ký" (build-spec section 6): on a phone it opens the
/// link (or the store page if that fails); on a desktop it shows the link as
/// a QR code to scan. Without a link format in the build it is not shown.
class ReadMoreButton extends StatelessWidget {
  const ReadMoreButton({super.key, required this.longKyId, required this.isPerson});

  final String longKyId;
  final bool isPerson;

  @override
  Widget build(BuildContext context) {
    final LongKyAccess access;
    try {
      access = context.read<LongKyAccess>();
    } on Object {
      return const SizedBox.shrink();
    }
    final link = access.canReadMore ? access.linkFor(longKyId: longKyId, isPerson: isPerson) : null;
    if (link == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context);
    return OutlinedButton.icon(
      key: const Key('read-more'),
      onPressed: () => _open(context, access, link),
      style: OutlinedButton.styleFrom(minimumSize: const Size(0, minTouch)),
      icon: const Icon(Icons.menu_book_outlined),
      label: Text(l.longKyReadMore),
    );
  }

  Future<void> _open(BuildContext context, LongKyAccess access, Uri link) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (access.isDesktop) {
      await showDialog<void>(
        context: context,
        builder: (_) => QrDialog(link: link),
      );
      return;
    }
    final opened = await access.openOnPhone(link);
    if (!opened) messenger?.showSnackBar(SnackBar(content: Text(l.longKyOpenFailed)));
  }
}

/// The link as a QR code, for a phone to scan. Dark modules on a light
/// ground at a fixed size, so a camera reads it whatever the theme.
class QrDialog extends StatelessWidget {
  const QrDialog({super.key, required this.link});

  final Uri link;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // A plain dialog: the QR widget sizes itself with a LayoutBuilder, which an
    // AlertDialog's intrinsic-width pass cannot measure.
    return Dialog(
      key: const Key('qr-dialog'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.longKyReadMore, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Center(
                child: Semantics(
                  label: l.longKyQrSemantics,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: QrImageView(
                      key: const Key('qr-code'),
                      data: link.toString(),
                      size: 220,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(l.longKyScan, key: const Key('qr-text'), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              // The same address as text, for a player who would rather type or copy it.
              SelectableText(link.toString(), key: const Key('qr-link'), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: () => Navigator.pop(context), child: Text(l.actionClose)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
