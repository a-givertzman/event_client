import 'package:event_client/operation/actions/edit_actions.dart';
import 'package:flutter/material.dart';

class EditWidget extends StatefulWidget {
  final EditActions? actions;
  final String? text;
  const EditWidget({
    super.key,
    this.actions,
    this.text,
  });
  //
  @override
  State<EditWidget> createState() => _EditWidgetState();
}
//
//
class _EditWidgetState extends State<EditWidget> {
  late final TextEditingController _controller;
  //
  @override
  void initState() {
    _controller = TextEditingController(text: widget.text);
    super.initState();
  }
  //
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.actions?.onChanged,
      onEditingComplete: widget.actions?.onComplete,
    );
  }
}