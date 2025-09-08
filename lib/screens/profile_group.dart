import 'package:flutter/material.dart';

import '../extensions/localization.dart';
import '../models/profile_group.dart';
import '../utils/db.dart';
import '../utils/db/update_profile_group.dart';
import '../utils/logger.dart';
import '../utils/show_snack_bar_now.dart';
import '../widgets/form/progress_button.dart';

class ProfileGroupScreen extends StatefulWidget {
  final ProfileGroupData? profileGroup;

  const ProfileGroupScreen({
    super.key,
    this.profileGroup,
  });

  @override
  State<ProfileGroupScreen> createState() => _ProfileGroupScreenState();
}

class _ProfileGroupScreenState extends State<ProfileGroupScreen> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for each text field
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _autoUpdateIntervalController = TextEditingController();

  // ignore: prefer_final_fields
  ProfileGroupType _profileGroupType = ProfileGroupType.remote;
  // ignore: prefer_final_fields
  ProfileGroupRemoteProtocol _profileGroupRemoteProtocol =
      ProfileGroupRemoteProtocol.anyportalRest;
  List<CoreTypeData> _coreTypeDataList = [];
  int? _coreTypeId;

  Future<void> _loadProfileGroup() async {
    if (widget.profileGroup != null) {
      _nameController.text = widget.profileGroup!.name;
      _profileGroupType = widget.profileGroup!.type;
      final profileGroupId = widget.profileGroup!.id;
      _coreTypeId = widget.profileGroup!.coreTypeId;

      switch (_profileGroupType) {
        case ProfileGroupType.remote:
          final profileGroupRemote = await (db.select(
            db.profileGroupRemote,
          )..where((p) => p.profileGroupId.equals(profileGroupId))).getSingle();
          _urlController.text = profileGroupRemote.url;
          _autoUpdateIntervalController.text = profileGroupRemote
              .autoUpdateInterval
              .toString();
          _profileGroupRemoteProtocol = profileGroupRemote.protocol;
        case ProfileGroupType.local:
      }
    }
  }

  Future<void> _loadCoreTypes() async {
    _coreTypeDataList = await (db.select(db.coreType).get());
    if (mounted) {
      setState(() {
        _coreTypeDataList = _coreTypeDataList;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfileGroup();
    _loadCoreTypes();
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
        await updateProfileGroup(
          name: _nameController.text,
          profileGroupType: _profileGroupType,
          profileGroupRemoteProtocol: _profileGroupRemoteProtocol,
          url: _urlController.text,
          autoUpdateInterval: int.tryParse(_autoUpdateIntervalController.text),
          oldProfileGroup: widget.profileGroup,
          coreTypeId: _coreTypeId,
        );
      }
      ok = true;
    } catch (e) {
      logger.e("_submitForm: $e");
      if (mounted) showSnackBarNow(context, Text("_submitForm: $e"));
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }

    if (ok) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context, {'ok': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String urlHintText = "";
    switch (_profileGroupRemoteProtocol) {
      case ProfileGroupRemoteProtocol.file:
        urlHintText = 'file:///path/to/folder/';
      case _:
        urlHintText = 'https://url/to/config/';
    }
    final coreTypeList = _coreTypeDataList.map((e) {
      return DropdownMenuItem<int?>(value: e.id, child: Text(e.name));
    }).toList();
    coreTypeList.insert(
      0,
      DropdownMenuItem<int?>(value: null, child: Text("[null]")),
    );

    final fields = [
      DropdownButtonFormField<ProfileGroupType>(
        decoration: InputDecoration(
          labelText: context.loc.type,
          border: OutlineInputBorder(),
        ),
        items: ProfileGroupType.values.map((ProfileGroupType t) {
          return DropdownMenuItem<ProfileGroupType>(
            value: t,
            child: Text(t.name),
          );
        }).toList(),
        onChanged: widget.profileGroup != null
            ? null
            : (value) {
                setState(() {
                  _profileGroupType = value!;
                });
              },
        value: _profileGroupType,
      ),
      if (_profileGroupType == ProfileGroupType.remote)
        DropdownButtonFormField<ProfileGroupRemoteProtocol>(
          decoration: InputDecoration(
            labelText: context.loc.protocol,
            border: OutlineInputBorder(),
          ),
          items: ProfileGroupRemoteProtocol.values.map((
            ProfileGroupRemoteProtocol t,
          ) {
            return DropdownMenuItem<ProfileGroupRemoteProtocol>(
              value: t,
              child: Text(t.name),
            );
          }).toList(),
          onChanged: widget.profileGroup != null
              ? null
              : (value) {
                  setState(() {
                    _profileGroupRemoteProtocol = value!;
                  });
                },
          value: _profileGroupRemoteProtocol,
        ),
      DropdownButtonFormField<int?>(
        decoration: InputDecoration(
          labelText: context.loc.core_type,
          border: OutlineInputBorder(),
        ),
        items: coreTypeList,
        onChanged: (value) {
          setState(() {
            _coreTypeId = value;
          });
        },
        value: coreTypeList.map((e) => e.value).contains(_coreTypeId)
            ? _coreTypeId
            : null,
      ),
      if (_profileGroupType == ProfileGroupType.remote)
        TextFormField(
          controller: _urlController,
          decoration: InputDecoration(
            labelText: context.loc.url,
            hintText: urlHintText,
            border: OutlineInputBorder(),
          ),
        ),
      TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: context.loc.name,
          border: OutlineInputBorder(),
        ),
      ),
      if (_profileGroupType == ProfileGroupType.remote &&
          _profileGroupRemoteProtocol != ProfileGroupRemoteProtocol.file)
        TextFormField(
          controller: _autoUpdateIntervalController,
          decoration: InputDecoration(
            labelText: context.loc.auto_update_interval_seconds_0_to_disable,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      ProgressButton(
        isInProgress: _isSubmitting,
        onPressed: _submitForm,
        child: Text(context.loc.save_and_update),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        // Use the selected tab's label for the AppBar title
        title: Text(context.loc.edit_profile_group),
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
