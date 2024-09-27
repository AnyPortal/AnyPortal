import 'package:flutter/material.dart';

class RadioListSelectionPopup<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final T? initialValue;
  final Function(T) onSaved;
  final String Function(T) itemToString;

  const RadioListSelectionPopup({
    super.key,
    required this.title,
    required this.items,
    required this.onSaved,
    this.initialValue,
    required this.itemToString,
  });

  @override
  RadioListSelectionPopupState<T> createState() => RadioListSelectionPopupState<T>();
}

class RadioListSelectionPopupState<T> extends State<RadioListSelectionPopup<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Wrap(
        // shrinkWrap: true,
        children: widget.items.map((item) {
          return RadioListTile<T>(
            title: Text(widget.itemToString(item)),
            value: item,
            groupValue: _selectedValue,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSaved(_selectedValue as T);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}