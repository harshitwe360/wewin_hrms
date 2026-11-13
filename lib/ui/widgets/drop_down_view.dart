import 'package:flutter/material.dart';

import '../../core/apis/repository/models/dd_model.dart';
import '../../core/config/config.dart';

class DropDownView extends StatelessWidget{
  const DropDownView({super.key, required this.labelText, this.errorText,
    this.value, this.onChanged, this.items = const [], this.labelStyle,
    this.isShowId = false, this.isShowHindi = false});

  final String labelText;
  final DdModel? value;
  final void Function(DdModel?)? onChanged;
  final List<DdModel> items;
  final String? errorText;
  final TextStyle? labelStyle;
  final bool isShowId;
  final bool isShowHindi;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DdModel>(
      isDense: true,
      isExpanded: true,
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: labelStyle,
          errorText: errorText,
      ),
      initialValue: (value!=null && items.contains(value) ? value : items.where(
            (item) => item.id == value?.id,
      ).firstOrNull),
      onChanged: onChanged,
      selectedItemBuilder: (BuildContext context) {
        return items.map((item) {
          return Text("${isShowId ? item.id : isShowHindi
              ? item.nameHindi : item.nameEng}",
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Theme.of(context).textTheme.mediumLabel
                .copyWith(color: AppColors.darkText,
                fontWeight: FontWeight.w600),
          );
        }).toList();
      },
      items: items
          .map((item) => DropdownMenuItem<DdModel>(
        value: item,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top:14, bottom: 12.0),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
            ),
          ),
          child: Text("${isShowId ? item.id : isShowHindi
              ? item.nameHindi : item.nameEng}",
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
              style: Theme.of(context).textTheme.mediumValue
                  .copyWith(color: AppColors.colorAccent,
                  fontWeight: FontWeight.w600),
          ),
        ),
      )).toList(),
    );
  }
}