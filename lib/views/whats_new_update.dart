import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../CONSTANTS.dart';
import '../utils/launchUrl.dart';

// Update Markdown body / content

class WhatsNewUpdateDialog extends StatelessWidget {
  const WhatsNewUpdateDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.whatsUpdateTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MarkdownBody(
            // styleSheet: MarkdownStyleSheet(textAlign: WrapAlignment.spaceAround),
            data: AppLocalizations.of(context)!
                .whatsUpdateContent(kReleaseNotesLink),
            onTapLink: (_, href, __) => LaunchUrl.normalLaunchUrl(url: href!),
          ),
        ],
      ),
    );
  }
}
