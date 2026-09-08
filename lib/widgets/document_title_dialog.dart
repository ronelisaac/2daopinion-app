import 'package:flutter/material.dart';
import '../core/localization.dart';
import '../domain/form_limits.dart';
import 'text_limit_formatter.dart';

class DocumentTitleDialog extends StatefulWidget {
  const DocumentTitleDialog({super.key, required this.title});
  final String title;
  @override
  State<DocumentTitleDialog> createState() => _DocumentTitleDialogState();
}

class _DocumentTitleDialogState extends State<DocumentTitleDialog> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.title);
  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = strings(context);
    return AlertDialog(
      title: Text(text.editDocumentTitle),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _title,
          autofocus: true,
          maxLength: FormLimits.documentTitle,
          inputFormatters: [const TextLimitFormatter(FormLimits.documentTitle)],
          decoration: InputDecoration(labelText: text.documentTitle),
          validator: (value) =>
              value == null ||
                  value.trim().isEmpty ||
                  value.length > FormLimits.documentTitle
              ? text.documentTitleRequired
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.pop(context, _title.text);
            }
          },
          child: Text(text.applyDocumentTitle),
        ),
      ],
    );
  }
}
