import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  static Future<String?> prompt(
    BuildContext context, {
    required String title,
    String initialValue = '',
    String? label,
    String confirmLabel = 'Готово',
    String cancelLabel = 'Отмена',
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
  });
  final String title;
  final String initialValue;
  final String? label;
  final String confirmLabel;
  final String cancelLabel;
  final bool isApple;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);

  void _submit() => Navigator.pop(context, _controller.text.trim());

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
            child: CupertinoTextField(
              controller: _controller,
              autofocus: true,
              placeholder: widget.label,
              onSubmitted: (_) => _submit(),
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
            decoration: InputDecoration(labelText: widget.label),
            onSubmitted: (_) => _submit(),
          ),
          actions: [
            TextButton(onPressed: _cancel, child: Text(widget.cancelLabel)),
            TextButton(onPressed: _submit, child: Text(widget.confirmLabel)),
          ],
        );
}
