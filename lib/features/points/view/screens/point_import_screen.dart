import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wayback/app/extensions/navigation_context.dart';
import 'package:wayback/app/localization/error_l10n.dart';
import 'package:wayback/app/localization/localization.dart';
import 'package:wayback/app/localization/point_type_l10n.dart';
import 'package:wayback/core/utils/geo/geo_format.dart';
import 'package:wayback/features/points/domain/entities/point_draft.dart';
import 'package:wayback/features/points/domain/entities/point_naming.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/view/bloc/point_form_bloc.dart';
import 'package:wayback/features/points/view/bloc/point_import_bloc.dart';
import 'package:wayback/features/points/view/bloc/save_point_bloc.dart';
import 'package:wayback/features/points/view/point_type_view.dart';
import 'package:wayback/features/points/view/widgets/bottom_action_bar.dart';
import 'package:wayback/features/points/view/widgets/point_import_notes.dart';
import 'package:wayback_design_system/wayback_design_system.dart';

/// A point at coordinates typed, pasted or received from someone else
/// (SCREENS.md §4.2a). Nothing is saved until the user confirms.
///
/// Needs [PointFormBloc], [PointImportBloc] and [SavePointBloc] above it.
class PointImportScreen extends StatefulWidget {
  const PointImportScreen({required this.received, super.key});

  /// Opened with a point already filled in.
  final bool received;

  @override
  State<PointImportScreen> createState() => _PointImportScreenState();
}

class _PointImportScreenState extends State<PointImportScreen> {
  late final TextEditingController _coordinates;
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    final import = context.read<PointImportBloc>().state;
    _coordinates = TextEditingController(text: import.text);
    _name = TextEditingController(
      text: context.read<PointFormBloc>().state.name,
    );
    if (import.draft case final draft?) _showCoordinatesOf(import.text, draft);
  }

  @override
  void dispose() {
    _coordinates.dispose();
    _name.dispose();
    super.dispose();
  }

  /// A link or a whole message in the field reads worse than the coordinates
  /// it holds.
  void _showCoordinatesOf(String text, PointDraft draft) {
    if (!text.contains('://') && !text.contains('\n')) return;
    final shown = formatShortCoordinates(draft.position);
    _coordinates.text = shown;
    context.read<PointImportBloc>().add(PointImportTextEdited(shown));
  }

  /// Takes the name and the type a pasted message brought along.
  void _fillForm(PointDraft draft) {
    final form = context.read<PointFormBloc>();
    if (draft.name case final name?) {
      _name.text = name;
      form.add(PointFormNameEdited(name));
    }
    if (draft.type case final type?) form.add(PointFormTypeSelected(type));
  }

  Future<void> _paste() async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    if (text == null || text.trim().isEmpty || !mounted) return;
    _coordinates.text = text;
    context.read<PointImportBloc>().add(PointImportTextEdited(text));
    if (parsePointText(text) case final draft?) {
      _showCoordinatesOf(text, draft);
      _fillForm(draft);
    }
  }

  void _save(PointFormState form, PointImportState import) {
    final draft = import.draft;
    if (draft == null) {
      context.read<PointImportBloc>().add(const PointImportRejected());
      return;
    }
    context.read<SavePointBloc>().run((
      name: form.resolvedName,
      type: form.type,
      position: draft.position,
      altitudeMeters: null,
    ));
  }

  void _onSaved(BuildContext context, ActionState<SavedPoint> state) =>
      state.mapOrNull(
        success: (s) {
          WbSnackbar.show(
            context,
            context.l10n.pointSavedSnackbar(s.result.name),
          );
          context.pop();
        },
        failure: (s) =>
            WbSnackbar.show(context, context.l10n.error(s.failure.code).title),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final form = context.watch<PointFormBloc>().state;
    final import = context.watch<PointImportBloc>().state;
    final saving = context.watch<SavePointBloc>().state.isInProgress;
    final draft = import.draft;
    return MultiBlocListener(
      listeners: [
        BlocListener<PointFormBloc, PointFormState>(
          // A default name follows the chosen type until the user edits it.
          listener: (_, state) {
            if (!state.nameEdited && _name.text != state.name) {
              _name.text = state.name;
            }
          },
        ),
        BlocListener<SavePointBloc, ActionState<SavedPoint>>(
          listener: _onSaved,
        ),
      ],
      child: Scaffold(
        appBar: WbAppBar(
          title: widget.received
              ? l10n.pointCreateTitle
              : l10n.pointImportTitle,
          onBack: context.back,
        ),
        body: ListView(
          padding: const EdgeInsets.all(WbSpacing.screenPadding),
          children: [
            WbTextField(
              controller: _coordinates,
              autofocus: !widget.received,
              label: l10n.pointCoordinatesLabel,
              hint: l10n.pointCoordinatesHint,
              helper: draft == null
                  ? l10n.pointCoordinatesHelper
                  : l10n.pointCoordinatesRead(
                      formatDegrees(draft.position.latitude),
                      formatDegrees(draft.position.longitude),
                    ),
              error: import.errorVisible ? l10n.pointCoordinatesInvalid : null,
              trailing: WbButton(
                label: l10n.pointCoordinatesPaste,
                variant: WbButtonVariant.tertiary,
                size: WbButtonSize.small,
                onPressed: _paste,
              ),
              onChanged: (text) => context.read<PointImportBloc>().add(
                PointImportTextEdited(text),
              ),
            ),
            const SizedBox(height: WbSpacing.lg),
            WbTextField(
              controller: _name,
              label: l10n.pointNameLabel,
              helper: l10n.pointNameHelper,
              maxLength: pointNameMaxLength,
              onChanged: (name) =>
                  context.read<PointFormBloc>().add(PointFormNameEdited(name)),
            ),
            const SizedBox(height: WbSpacing.lg),
            Text(
              l10n.pointTypeLabel,
              style: context.wbText.labelMedium?.copyWith(
                color: context.wbColors.contentSecondary,
              ),
            ),
            const SizedBox(height: WbSpacing.xs),
            WbTypePicker(
              value: form.type.design,
              labelOf: l10n.pointType,
              onChanged: (type) => context.read<PointFormBloc>().add(
                PointFormTypeSelected(type.domain),
              ),
            ),
            WbStateSwitcher(
              state: (draft?.isPrecise, import.nearby?.name),
              animateSize: true,
              child: PointImportNotes(import),
            ),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          children: [
            WbButton(
              label: l10n.actionSave,
              loading: saving,
              onPressed: () => _save(form, import),
            ),
            WbButton(
              label: l10n.actionCancel,
              variant: WbButtonVariant.tertiary,
              onPressed: context.back,
            ),
          ],
        ),
      ),
    );
  }
}
