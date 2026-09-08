import 'package:flutter/material.dart';
import '../controllers/chip_input_controller.dart';
import '../core/localization.dart';
import '../domain/form_limits.dart';

class ChipRequestField extends StatefulWidget {
  const ChipRequestField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.onChanged,
  });
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  @override
  State<ChipRequestField> createState() => _ChipRequestFieldState();
}

class _ChipRequestFieldState extends State<ChipRequestField> {
  late final _chips = ChipInputController(widget.controller.text);
  final _input = TextEditingController();
  bool _updating = false;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_restore);
  }

  void _restore() {
    if (_updating) return;
    _chips.restore(widget.controller.text);
    _input.clear();
  }

  @override
  void didUpdateWidget(covariant ChipRequestField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_restore);
      widget.controller.addListener(_restore);
      _restore();
    }
  }

  void _publish() {
    _updating = true;
    widget.controller.text = _chips.value;
    _updating = false;
    widget.onChanged?.call(_chips.value);
  }

  void _edit(String value, {bool commit = false}) {
    _chips.edit(value, commit: commit);
    if (_input.text != _chips.pending) {
      _input.value = TextEditingValue(
        text: _chips.pending,
        selection: TextSelection.collapsed(offset: _chips.pending.length),
      );
    }
    _publish();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_restore);
    _chips.dispose();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _chips,
    builder: (context, _) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _input,
            onChanged: (value) => _edit(value),
            onFieldSubmitted: (value) => _edit(value, commit: true),
            textInputAction: TextInputAction.done,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              helperText: strings(context).chipInstruction,
              helperMaxLines: 3,
              counterText: '${_chips.value.length}/${FormLimits.text}',
              errorText: _chips.limitReached
                  ? strings(context).textLimitReached
                  : null,
              errorMaxLines: 3,
              suffixIcon: IconButton(
                tooltip: strings(context).addItem,
                onPressed: () => _edit(_input.text, commit: true),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var index = 0; index < _chips.items.length; index++)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    child: InputChip(
                      label: Text(
                        _chips.items[index],
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      tooltip: _chips.items[index],
                      onDeleted: () {
                        _chips.remove(index);
                        _publish();
                      },
                      deleteButtonTooltipMessage: strings(context).removeItem,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
