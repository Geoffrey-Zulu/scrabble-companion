import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design/design.dart';

/// Pill search field that forces A–Z uppercase input.
class ScSearchField extends StatelessWidget {
  const ScSearchField({
    required this.controller,
    required this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText = 'Check a word',
    this.autofocus = false,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final String hintText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final hasText = controller.text.isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.field,
        borderRadius: BorderRadius.circular(27),
      ),
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            const SizedBox(width: 18),
            Icon(Icons.search, color: colors.muted, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                autofocus: autofocus,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.search,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.01 * 18,
                ),
                cursorColor: colors.accent,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.muted,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
                  _UpperCaseTextFormatter(),
                ],
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
            if (hasText && onClear != null)
              IconButton(
                onPressed: onClear,
                tooltip: 'Clear',
                icon: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.line,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(Icons.close, size: 12, color: colors.muted),
                  ),
                ),
              ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
