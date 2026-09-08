import 'package:flutter/material.dart';

import '../core/localization.dart';

Future<void> explainPreview(BuildContext context, String message) =>
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings(dialogContext).previewTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings(dialogContext).close),
          ),
        ],
      ),
    );
