import 'package:flutter/material.dart';

import '../../core/config/config.dart';

class TextWithProgressBar extends StatelessWidget {
  const TextWithProgressBar(
      {super.key,
        required this.label,
        required this.valueText,
        required this.percent,
        this.fillColor
      });

  final String label;
  final String valueText;
  final double percent;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: VerticalLabelValue(label: label, value: valueText),
        ),
        const SizedBox(width: 5),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 45,
                    height: 12,
                    margin: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(80)),
                      child: LinearProgressIndicator(
                        value: (percent / 100) ,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            fillColor ?? AppColors.colorAccent),
                        backgroundColor: AppColors.graphBgBar.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 46.0,
                    child: Text(
                      '${percent.toStringAsFixed(2)}%',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.smallLabel,
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}
