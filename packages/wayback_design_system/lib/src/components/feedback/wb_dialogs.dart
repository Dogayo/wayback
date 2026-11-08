import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wayback_design_system/src/components/feedback/wb_state_switcher.dart';
import 'package:wayback_design_system/src/foundations/app_motion.dart';
import 'package:wayback_design_system/src/foundations/app_spacing.dart';
import 'package:wayback_design_system/src/theme/app_theme_extensions.dart';

abstract final class WbDialogs {
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Готово',
    String cancelLabel = 'Отмена',
    bool destructive = false,
  }) {
    final platform = Theme.of(context).platform;
    final isApple =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    if (isApple) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelLabel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: destructive,
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );
    }
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: destructive
                ? TextButton.styleFrom(
                    foregroundColor: context.wbColors.negative,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  /// Asks for one line of text, e.g. a new point name. Returns the trimmed
  /// text, or `null` when cancelled or left empty.
  ///
  /// [validator] gets the trimmed text on confirm; what it returns is shown
  /// as the error and keeps the dialog open. Typing stops at [maxLength].
  static Future<String?> prompt(
    BuildContext context, {
    required String title,
    String initialValue = '',
    String? label,
    String confirmLabel = 'Готово',
    String cancelLabel = 'Отмена',
    String? Function(String value)? validator,
    int? maxLength,
  }) async {
    final platform = Theme.of(context).platform;
    final isApple =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final dialog = _PromptDialog(
      title: title,
      initialValue: initialValue,
      label: label,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isApple: isApple,
      validator: validator,
      maxLength: maxLength,
    );
    final result = isApple
        ? await showCupertinoDialog<String>(
            context: context,
            builder: (_) => dialog,
          )
        : await showDialog<String>(context: context, builder: (_) => dialog);
    return result == null || result.isEmpty ? null : result;
  }
}

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({
    required this.title,
    required this.initialValue,
    required this.label,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isApple,
    required this.validator,
    required this.maxLength,
  });
  final String title;
  final String initialValue;
  final String? label;
  final String confirmLabel;
  final String cancelLabel;
  final bool isApple;
  final String? Function(String value)? validator;
  final int? maxLength;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);

  String? _error;

  late final _formatters = [
    if (widget.maxLength case final limit?) _LengthLimit(limit),
  ];

  void _submit() {
    final value = _controller.text.trim();
    final error = widget.validator?.call(value);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, value);
  }

  /// Rebuilds for the counter and takes the error away once typing resumes.
  void _onChanged(String _) => setState(() => _error = null);

  /// `38/40`, once the limit is close enough to matter.
  String? get _counter {
    final limit = widget.maxLength;
    if (limit == null) return null;
    final length = _controller.text.characters.length;
    return length < limit * _counterFrom ? null : '$length/$limit';
  }

  /// Replaces the default, which hides the keyboard: after a refused
  /// name the next thing to do is type.
  static void _keepKeyboard() {}

  void _cancel() => Navigator.pop(context);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.isApple
      ? CupertinoAlertDialog(
          title: Text(widget.title),
          content: Padding(
            padding: const EdgeInsets.only(top: WbSpacing.sm),
            child: _withNote(
              CupertinoTextField(
                controller: _controller,
                autofocus: true,
                placeholder: widget.label,
                inputFormatters: _formatters,
                onChanged: _onChanged,
                onEditingComplete: _keepKeyboard,
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: _cancel,
              child: Text(widget.cancelLabel),
            ),
            CupertinoDialogAction(
              onPressed: _submit,
              child: Text(widget.confirmLabel),
            ),
          ],
        )
      : AlertDialog(
          title: Text(widget.title),
          content: TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: widget.label,
              errorText: _error,
              counterText: _counter,
            ),
            inputFormatters: _formatters,
            onChanged: _onChanged,
            onEditingComplete: _keepKeyboard,
            onSubmitted: (_) => _submit(),
          ),
          actions: [
            TextButton(onPressed: _cancel, child: Text(widget.cancelLabel)),
            TextButton(onPressed: _submit, child: Text(widget.confirmLabel)),
          ],
        );

  /// Under a Cupertino field, which has no error or counter of its own.
  Widget _withNote(Widget field) {
    final error = _error;
    final counter = _counter;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        field,
        WbStateSwitcher(
          state: (error == null, counter == null),
          duration: WbMotion.fast,
          animateSize: true,
          child: error != null
              ? _Note(error, color: context.wbColors.negative, liveRegion: true)
              : counter != null
              ? _Note(
                  counter,
                  color: context.wbColors.contentSecondary,
                  align: TextAlign.end,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Share of the limit from which the counter is shown.
const double _counterFrom = .75;

class _Note extends StatelessWidget {
  const _Note(
    this.text, {
    required this.color,
    this.align = TextAlign.start,
    this.liveRegion = false,
  });

  final String text;
  final Color color;
  final TextAlign align;
  final bool liveRegion;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: liveRegion,
    child: Padding(
      padding: const EdgeInsets.only(top: WbSpacing.xxs),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          textAlign: align,
          style: context.wbText.bodySmall?.copyWith(color: color),
        ),
      ),
    ),
  );
}

/// Stops typing at [limit]. A longer text saved before the limit existed is
/// left alone and can only get shorter, unlike with the framework's
/// formatter, which would cut it at the first keystroke.
class _LengthLimit extends TextInputFormatter {
  _LengthLimit(this.limit);

  final int limit;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final length = newValue.text.characters.length;
    if (length <= limit) return newValue;
    final before = oldValue.text.characters.length;
    if (before > limit) return length < before ? newValue : oldValue;
    return LengthLimitingTextInputFormatter(
      limit,
    ).formatEditUpdate(oldValue, newValue);
  }
}
