import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../utils/db.dart';

class CoreTypeScreen extends StatefulWidget {
  final CoreTypeData? coreType;

  const CoreTypeScreen({
    super.key,
    this.coreType,
  });

  @override
  State<CoreTypeScreen> createState() => _CoreTypeScreenState();
}

class _CoreTypeScreenState extends State<CoreTypeScreen> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for each text field
  final _typeController = TextEditingController();

  Future<void> _loadCoreType() async {
    if (widget.coreType != null) {
      _typeController.text = widget.coreType!.name;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCoreType();
  }

  // Method to handle form submission
  void _submitForm() async {
    if (mounted) {
      setState(() {
        _isSubmitting = true;
      });
    }
    bool ok = false;

    try {
      if (_formKey.currentState?.validate() ?? false) {
        if (widget.coreType != null) {
          db.into(db.coreType).insertOnConflictUpdate(CoreTypeCompanion(
                id: Value(widget.coreType!.id),
                name: Value(_typeController.text),
              ));
        } else {
          db.into(db.coreType).insert(CoreTypeCompanion(
                name: Value(_typeController.text),
              ));
        }
      }
      ok = true;
    } catch (e) {
      final snackBar = SnackBar(
        content: Text("$e"),
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }

    if (ok) {
      if (mounted) Navigator.pop(context, {'ok': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      TextFormField(
        enabled: widget.coreType != null ? widget.coreType!.id > 2 : true,
        controller: _typeController,
        decoration: const InputDecoration(
          labelText: 'type',
          border: OutlineInputBorder(),
        ),
      ),
      Center(
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
          ),
          child: const Text('Save and update'),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: const Text("Edit core type"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView.separated(
            itemCount: fields.length,
            itemBuilder: (context, index) => fields[index],
            separatorBuilder: (context, index) => const SizedBox(height: 16),
          ),
        ),
      ),
    );
  }
}
