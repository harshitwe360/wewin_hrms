import 'package:flutter/material.dart';

import '../../core/config/r.dart';

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key? key}) => showDialog<void>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: false,
    builder: (_) => LoadingDialog(key: key),
  ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) {
    // if(! ModalRoute.of(context)!.isFirst) {
      Navigator.pop(context);
    // }
  }

  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            // color: Theme.of(context).backgroundColor.withOpacity(0.1),
            decoration: BoxDecoration(
                border: Border.all(width: 1 ,color: Colors.transparent), //color is transparent so that it does not blend with the actual color specified
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                color: Theme.of(context).colorScheme.background.withOpacity(0.1) // Specifies the background color and the opacity
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