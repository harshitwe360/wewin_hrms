import 'package:flutter/material.dart';

import '../../core/config/r.dart';

class ErrorView extends StatelessWidget {
  final String? error;
  final bool addScaffold;
  final double? height;

  const ErrorView(
      {Key? key, this.error, this.addScaffold = false, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 150.0,
      child: Center(child: Text(error ?? R.strings.errMsgDefaultAPI)),
    );
  }
}
