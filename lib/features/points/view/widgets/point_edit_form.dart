import 'package:flutter/material.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/localization/point_type_l10n.dart';
import 'package:wayback/features/points/domain/entities/point_naming.dart';
import 'package:wayback/features/points/domain/entities/point_type.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// Name and type of a saved point, in a sheet.
class PointEditForm extends StatefulWidget {
  const PointEditForm({required this.point, required this.onSave, super.key});

  final SavedPoint point;
  final void Function(String name, PointType type) onSave;

  @override
  State<PointEditForm> createState() => _PointEditFormState();
}

class _PointEditFormState extends State<PointEditForm> {
  late final _name = TextEditingController(text: widget.point.name);
  late var _type = widget.point.type;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      WbHaptics.play(context, WbHaptic.warning);
      setState(() => _error = context.l10n.pointNameRequired);
      return;
    }
    widget.onSave(name, _type);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        WbSpacing.md,
        0,
        WbSpacing.md,
        WbSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: WbSpacing.sm,
        children: [
          WbTextField(
            controller: _name,
            label: l10n.pointNameLabel,
            maxLength: pointNameMaxLength,
            error: _error,
            onChanged: (_) => setState(() => _error = null),
          ),
          Text(
            l10n.pointTypeLabel,
            style: context.wbText.labelMedium?.copyWith(
              color: context.wbColors.contentSecondary,
            ),
          ),
          WbTypePicker(
            value: _type.design,
            labelOf: l10n.pointType,
            onChanged: (type) => setState(() => _type = type.domain),
          ),
          WbButton(label: l10n.actionSave, onPressed: _save),
        ],
      ),
    );
  }
}
