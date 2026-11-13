import 'package:flutter/material.dart';

/// Shared look for the login form (matches the web sign-in design).
class LoginStyle {
  LoginStyle._();

  static const Color title = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color label = Color(0xFF334155);
  static const Color icon = Color(0xFF94A3B8);
  /// Field border/fill: soft blue, inside the white form panel.
  static const Color border = Color(0xFFDCE6F8);
  static const Color fieldFill = Color(0xFFF3F7FF);

  static const List<BoxShadow> panelShadow = [
    BoxShadow(color: Color(0x141E3A8A), blurRadius: 18, offset: Offset(0, 6)),
  ];
  static const Color focus = Color(0xFF3B6FE0);
  static const Color error = Color(0xFFE5484D);
  static const Color success = Color(0xFF2F6F5E);
  static const Color tabTrack = Color(0xFFE6EEFC);

  /// Text typed into fields.
  static const TextStyle fieldText =
      TextStyle(color: title, fontSize: 15, fontWeight: FontWeight.w500);

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF5B8DEF), Color(0xFF2A4FB8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const BorderRadius radius = BorderRadius.all(Radius.circular(12));

  static InputDecoration input({
    required String hint,
    required IconData icon,
    Widget? suffix,
    String? errorText,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: radius, borderSide: BorderSide(color: c, width: w));
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
          color: LoginStyle.icon, fontSize: 15, fontWeight: FontWeight.w400),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 14, right: 10),
        child: Icon(icon, color: LoginStyle.icon, size: 20),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
      isDense: true,
      filled: true,
      fillColor: fieldFill,
      // ~50px tall field.
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      enabledBorder: border(LoginStyle.border),
      disabledBorder: border(LoginStyle.border),
      focusedBorder: border(LoginStyle.focus, 1.5),
      errorBorder: border(LoginStyle.error),
      focusedErrorBorder: border(LoginStyle.error, 1.5),
      errorText: errorText,
      errorStyle: const TextStyle(color: LoginStyle.error, fontSize: 13),
      errorMaxLines: 2,
    );
  }
}

/// "Email *" style label above a field.
class LoginFieldLabel extends StatelessWidget {
  const LoginFieldLabel(this.text, {super.key, this.required = true});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text.rich(TextSpan(
        text: text,
        style: const TextStyle(
            color: LoginStyle.label, fontSize: 14, fontWeight: FontWeight.w600),
        children: [
          if (required)
            const TextSpan(
                text: " *", style: TextStyle(color: LoginStyle.error)),
        ],
      )),
    );
  }
}

/// Full-width gradient button with a trailing arrow.
class LoginGradientButton extends StatelessWidget {
  const LoginGradientButton(
      {super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LoginStyle.buttonGradient,
          borderRadius: LoginStyle.radius,
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF2A4FB8).withValues(alpha: 0.16),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: LoginStyle.radius,
            onTap: onPressed,
            child: SizedBox(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 19),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White rounded form panel (same look as the login tab panel).
class LoginPanel extends StatelessWidget {
  const LoginPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: LoginStyle.panelShadow,
      ),
      child: child,
    );
  }
}

/// Centered title + subtitle used on auth screens.
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: LoginStyle.title,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: LoginStyle.muted, fontSize: 14, height: 1.4)),
        const SizedBox(height: 20),
      ],
    );
  }
}
