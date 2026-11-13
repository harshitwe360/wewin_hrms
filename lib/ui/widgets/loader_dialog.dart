import 'package:flutter/material.dart';

import '../../core/config/r.dart';

class LoadingDialog extends StatelessWidget {
  /// Whether a loading dialog is currently on screen. hide() used to pop
  /// unconditionally, which closed the current page when no dialog was open.
  static bool _isShowing = false;

  static void show(BuildContext context, {Key? key}) {
    if (_isShowing) return;
    _isShowing = true;
    showDialog<void>(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(key: key),
    ).then((_) {
      _isShowing = false;
      if (context.mounted) FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  static void hide(BuildContext context) {
    if (!_isShowing) return;
    _isShowing = false;
    Navigator.of(context).pop();
  }

  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Card(
          child: Container(
            // color: Theme.of(context).backgroundColor.withOpacity(0.1),
            decoration: BoxDecoration(
                border: Border.all(width: 1 ,color: Colors.transparent), //color is transparent so that it does not blend with the actual color specified
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1) // Specifies the background color and the opacity
            ),
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(R.images.loader),
            // child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}