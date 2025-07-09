import 'package:flutter/material.dart';

import 'package:anyportal/utils/show_snack_bar_now.dart';

import '../extensions/localization.dart';
import '../models/core.dart';
import '../models/profile.dart';
import '../utils/db.dart';
import '../utils/db/update_profile.dart';
import '../utils/json.dart';
import '../utils/logger.dart';
import '../widgets/form/progress_button.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileData? profile;

  const ProfileScreen({
    super.key,
    this.profile,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers for each text field
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _autoUpdateIntervalController = TextEditingController(text: '0');
  final _coreCfgController = TextEditingController(text: '{}');
  final _coreCfgFmtController = TextEditingController(text: 'json');
  List<CoreTypeData> _coreTypeDataList = [];
  List<ProfileGroupData> _profileGroupDataList = [];
  ProfileType _profileType = ProfileType.remote;
  int _coreTypeId = CoreTypeDefault.v2ray.index;
  int _profileGroupId = 1;

  Future<void> _loadField() async {
    _coreTypeDataList = await (db.select(db.coreType).get());
    _profileGroupDataList = await (db.select(db.profileGroup).get());
    if (mounted) {
      setState(() {
        _coreTypeDataList = _coreTypeDataList;
        _profileGroupDataList = _profileGroupDataList;
      });
    }
  }

  Future<void> _loadProfile() async {
    if (widget.profile != null) {
      _nameController.text = widget.profile!.name;
      _profileType = widget.profile!.type;
      final coreCfgFmt = widget.profile!.coreCfgFmt;
      _coreCfgFmtController.text = coreCfgFmt;
      if (coreCfgFmt == "json") {
        _coreCfgController.text = prettyPrintJson(widget.profile!.coreCfg);
      } else {
        _coreCfgController.text = widget.profile!.coreCfg;
      }
      _coreTypeId = widget.profile!.coreTypeId;
      _profileGroupId = widget.profile!.profileGroupId;
      final profileId = widget.profile!.id;
      switch (_profileType) {
        case ProfileType.remote:
          final profileRemote = await (db.select(db.profileRemote)
                ..where((p) => p.profileId.equals(profileId)))
              .getSingle();
          _urlController.text = profileRemote.url;
          _autoUpdateIntervalController.text =
              profileRemote.autoUpdateInterval.toString();
        case ProfileType.local:
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadField();
    _loadProfile();
  }

  // Method to handle form submission
  void _submitForm() async {
    setState(() {
      _isSubmitting = true;
    });
    bool ok = false;

    try {
      if (_formKey.currentState?.validate() ?? false) {
        await updateProfile(
          oldProfile: widget.profile,
          name: _nameController.text,
          profileType: _profileType,
          url: _urlController.text,
          autoUpdateInterval: int.parse(_autoUpdateIntervalController.text),
          coreTypeId: _coreTypeId,
          coreCfg: _coreCfgFmtController.text == "json"
              ? minifyJson(_coreCfgController.text)
              : _coreCfgController.text,
          coreCfgFmt: _coreCfgFmtController.text,
          profileGroupId: _profileGroupId,
        );
      }
      ok = true;
    } catch (e) {
      logger.e("_submitForm: $e");
      if (mounted) showSnackBarNow(context, Text("_submitForm: $e"));
    }

    setState(() {
      _isSubmitting = false;
    });

    if (ok) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context, {'ok': true});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fields = [
      DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: context.loc.profile_group,
          border: OutlineInputBorder(),
        ),
        items: _profileGroupDataList.map((ProfileGroupData t) {
          final name = t.name == "" ? context.loc.standalone : t.name;
          return DropdownMenuItem<int>(value: t.id, child: Text(name));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _profileGroupId = value!;
          });
        },
        value: _profileGroupId,
      ),
      TextFormField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: context.loc.name,
          border: OutlineInputBorder(),
        ),
      ),
      DropdownButtonFormField<int>(
        decoration: InputDecoration(
          labelText: context.loc.core_type,
          border: OutlineInputBorder(),
        ),
        items: _coreTypeDataList.map((e) {
          return DropdownMenuItem<int>(value: e.id, child: Text(e.name));
        }).toList(),
        onChanged: (value) {
          setState(() {
            _coreTypeId = value!;
          });
        },
        value: _coreTypeId,
      ),
      DropdownButtonFormField<ProfileType>(
        decoration: InputDecoration(
          labelText: context.loc.profile_type,
          border: OutlineInputBorder(),
        ),
        items: ProfileType.values.map((ProfileType t) {
          return DropdownMenuItem<ProfileType>(value: t, child: Text(t.name));
        }).toList(),
        onChanged: widget.profile != null
            ? null
            : (value) {
                setState(() {
                  _profileType = value!;
                });
              },
        value: _profileType,
      ),
      TextFormField(
        controller: _coreCfgFmtController,
        decoration: InputDecoration(
          labelText: context.loc.core_config_format,
          border: OutlineInputBorder(),
        ),
      ),
      if (_profileType == ProfileType.remote)
        TextFormField(
          controller: _urlController,
          decoration: InputDecoration(
            labelText: context.loc.url,
            hintText: 'https://url/to/config/json/',
            border: OutlineInputBorder(),
          ),
        ),
      if (_profileType == ProfileType.remote)
        TextFormField(
          controller: _autoUpdateIntervalController,
          decoration: InputDecoration(
            labelText: context.loc.auto_update_interval_seconds_0_to_disable,
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
      if (_profileType == ProfileType.local)
        TextFormField(
          controller: _coreCfgController,
          decoration: InputDecoration(
            labelText: context.loc.core_config,
            border: OutlineInputBorder(),
          ),
          maxLines: 16,
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
        title: Text(context.loc.edit_profile),
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
