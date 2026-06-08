import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CodeInput extends StatelessWidget {
  const CodeInput({
    super.key,
    required this.controller,
    this.enabled = true,
    this.onSubmitted,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      autofillHints: const [AutofillHints.oneTimeCode],
      style: const TextStyle(
        fontSize: 32,
        letterSpacing: 12,
        fontFeatures: [
          FontFeature.tabularFigures()
          ],
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: const InputDecoration(
        counterText: '',
        hintText: '••••••',
        border: OutlineInputBorder(),
      ),
      onSubmitted: onSubmitted,
    );
  }
}