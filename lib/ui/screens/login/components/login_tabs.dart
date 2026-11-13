import 'package:flutter/material.dart';

import 'login_styles.dart';

enum LoginMode { password, otp }

/// Folder-style "Work email | Email OTP" tabs with the form panel below.
/// The selected tab is white and joins the white [child] panel, so the
/// fields read as belonging to that tab.
class LoginTabbedPanel extends StatelessWidget {
  const LoginTabbedPanel({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.child,
  });

  final LoginMode selected;
  final ValueChanged<LoginMode> onChanged;
  final Widget child;

  static const double _r = 16;
  static const double _tabHeight = 46;

  @override
  Widget build(BuildContext context) {
    final bool first = selected == LoginMode.password;
    // Panel first, tabs painted on top (overlapping 2px) so the panel's
    // shadow doesn't draw a seam across the selected tab.
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: _tabHeight),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: LoginStyle.panelShadow,
              // Square corner under the selected tab so they read as one.
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(first ? 0 : _r),
                topRight: Radius.circular(first ? _r : 0),
                bottomLeft: const Radius.circular(_r),
                bottomRight: const Radius.circular(_r),
              ),
            ),
            child: child,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Row(children: [
            _tab(LoginMode.password, Icons.mail_outline, "Work email"),
            const SizedBox(width: 6),
            _tab(LoginMode.otp, Icons.verified_user_outlined, "Email OTP"),
          ]),
        ),
      ],
    );
  }

  Widget _tab(LoginMode mode, IconData icon, String label) {
    final bool active = mode == selected;
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: active ? _tabHeight + 2 : _tabHeight,
            margin: EdgeInsets.only(bottom: active ? 0 : 2),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.white.withValues(alpha: 0.45),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(_r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 17,
                    color: active ? LoginStyle.focus : LoginStyle.muted),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: active ? LoginStyle.title : LoginStyle.muted,
                          fontSize: 14,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
