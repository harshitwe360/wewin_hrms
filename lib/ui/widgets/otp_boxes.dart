import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One-digit-per-box OTP input (the app's original box style).
///
/// [length] defaults to 6, matching the WinHRMS OTP (`"otp": "123456"`).
/// Typing moves to the next box, clearing moves back, and pasting or
/// SMS-autofilling a full code fills every box. Give it a new [Key] to reset.
class OtpBoxes extends StatefulWidget {
  const OtpBoxes({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
    this.autofocus = true,
  });

  final int length;

  /// Current code (digits typed so far, in order).
  final ValueChanged<String> onChanged;

  /// Called once all boxes are filled.
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> {
  late final List<FocusNode> _focusNodes =
      List.generate(widget.length, (_) => FocusNode());
  late final List<TextEditingController> _controllers =
      List.generate(widget.length, (_) => TextEditingController());

  @override
  void dispose() {
    for (final n in _focusNodes) {
      n.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      // Paste / autofill: spread the digits from this box onwards.
      final digits = value.replaceAll(RegExp(r'\D'), '').split('');
      for (int i = 0; i < digits.length && index + i < widget.length; i++) {
        _controllers[index + i].text = digits[i];
      }
      final next = (index + digits.length).clamp(0, widget.length - 1);
      if (index + digits.length >= widget.length) {
        FocusScope.of(context).unfocus();
      } else {
        _focusNodes[next].requestFocus();
      }
    } else if (value.isNotEmpty) {
      if (index + 1 < widget.length) {
        _focusNodes[index + 1].requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _code;
    widget.onChanged(code);
    if (code.length == widget.length) widget.onCompleted?.call(code);
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(widget.length, (index) {
          return SizedBox(
            width: 50,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              autofocus: widget.autofocus && index == 0,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              autofillHints:
                  index == 0 ? const [AutofillHints.oneTimeCode] : null,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              // The first box accepts a whole pasted/autofilled code.
              maxLength: index == 0 ? widget.length : 1,
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _onChanged(value, index),
            ),
          );
        }),
      ),
    );
  }
}
