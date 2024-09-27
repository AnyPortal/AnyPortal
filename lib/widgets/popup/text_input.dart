import 'package:flutter/material.dart';

class TextInputPopup extends StatefulWidget {
  final String title;
  final String initialValue;
  final Function(String) onSaved;
  final InputDecoration? decoration;

  const TextInputPopup({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSaved,
    this.decoration,
  });

  @override
  TextInputPopupState createState() => TextInputPopupState();
}

class TextInputPopupState extends State<TextInputPopup> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialValue;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _textController,
        autofocus: true,
        decoration: widget.decoration ?? const InputDecoration(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSaved(_textController.text);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}