import 'package:flutter/material.dart';
import '../../core/config/config.dart';

class NoteView extends StatelessWidget{
  const NoteView({required this.text, this.padding, super.key});

  final String text;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(6.0),
      child: RichText(
        text: TextSpan(
          text: 'Note: ',
          style: Theme.of(context).textTheme.smallXValue,
          children: <TextSpan>[
            TextSpan(text: text, style: Theme.of(context).textTheme.smallXLabel),
          ],
        ),
      ),
    );
  }

}