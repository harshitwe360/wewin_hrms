import 'package:flutter/material.dart';

import '../../core/config/config.dart';

class SearchView extends StatefulWidget{
  const SearchView({super.key,
    this.initialValue, required this.onChangeCallBack});

  final Function(String) onChangeCallBack;
  final String? initialValue;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controllerSearch = TextEditingController();

  @override
  void initState() {
    _controllerSearch.text = widget.initialValue ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecorationX.panel,
      // padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: TextField(
        // key: UniqueKey(),
        controller: _controllerSearch,
        textInputAction: TextInputAction.search,
        onChanged: widget.onChangeCallBack,
        // initialValue: context.read<AttUserListBloc>().search,
        maxLines: 1,
        keyboardType: TextInputType.text,
        // style: TextStyle(color: Color(0xFFF00)),
        decoration: const InputDecoration(
          filled: false,
          fillColor: AppColors.searchField,
          constraints: BoxConstraints(maxHeight: 42, maxWidth: 327),
          // isCollapsed: true,
          contentPadding: EdgeInsets.only(top: 8.0),
          // labelText: 'Search',
          // isDense: true,
          hintText: 'Search',
          border: InputBorder.none,
          // isDense: true,
          prefixIcon: Icon(Icons.search, color: AppColors.black87),
        ),
      ),
    );
  }
}