import 'package:flutter/material.dart';

import 'package:drift/drift.dart';

import '../extensions/localization.dart';
import '../utils/db.dart';
import '../utils/logger.dart';
import '../widgets/form/progress_button.dart';

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
          await db.into(db.coreType).insertOnConflictUpdate(CoreTypeCompanion(
                id: Value(widget.coreType!.id),
                name: Value(_typeController.text),
              ));
        } else {
          await db.into(db.coreType).insert(CoreTypeCompanion(
                name: Value(_typeController.text),
              ));
        }
      }
      ok = true;
    } catch (e) {
      logger.e("_submitForm: $e");
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
      if (mounted && Navigator.canPop(context)) Navigator.pop(context, {'ok': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      TextFormField(
        enabled: widget.coreType != null ? widget.coreType!.id > 2 : true,
        controller: _typeController,
        decoration: InputDecoration(
          labelText: context.loc.type,
          border: OutlineInputBorder(),
        ),
      ),
      ProgressButton(
        isInProgress: _isSubmitting,
        onPressed: _submitForm,
        child: Text(context.loc.save_and_update),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: Text(context.loc.edit_core_type),
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
