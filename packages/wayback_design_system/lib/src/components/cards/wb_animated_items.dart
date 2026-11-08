import 'package:flutter/widgets.dart';

import 'package:wayback_design_system/src/foundations/app_motion.dart';

/// A column of [items] that fades and folds a row that left and unfolds one
/// that arrived, working out which is which from [keyOf].
///
/// [items] can come straight from a stream: nothing has to announce a
/// change. A row that left keeps its place, showing its last data, until it
/// has folded away. Every row is built, so keep it for short lists.
class WbAnimatedItems<T> extends StatefulWidget {
  const WbAnimatedItems({
    required this.items,
    required this.keyOf,
    required this.itemBuilder,
    super.key,
  });

  final List<T> items;
  final Object Function(T item) keyOf;

  /// Builds a row; `isLast` is true for the last row that is staying.
  final Widget Function(BuildContext context, T item, bool isLast) itemBuilder;

  @override
  State<WbAnimatedItems<T>> createState() => _WbAnimatedItemsState<T>();
}

class _Entry<T> {
  _Entry(this.key, this.item, this.controller);

  final Object key;
  final AnimationController controller;
  T item;
  bool leaving = false;
}

class _WbAnimatedItemsState<T> extends State<WbAnimatedItems<T>>
    with TickerProviderStateMixin {
  late List<_Entry<T>> _entries = [
    for (final item in widget.items) _newEntry(item, shown: true),
  ];

  _Entry<T> _newEntry(T item, {required bool shown}) => _Entry(
    widget.keyOf(item),
    item,
    AnimationController(vsync: this, value: shown ? 1 : 0),
  );

  @override
  void didUpdateWidget(WbAnimatedItems<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final time = WbMotion.of(context, WbMotion.base);
    final previous = {for (final entry in _entries) entry.key: entry};
    final merged = [
      for (final item in widget.items) _stay(item, previous, time),
    ];
    final staying = {for (final entry in merged) entry.key};
    // A row that left stays right after the row it used to follow.
    Object? before;
    for (final entry in _entries) {
      if (!staying.contains(entry.key)) {
        if (time == Duration.zero) {
          // Disposed after this frame: the row still listens to it now.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => entry.controller.dispose(),
          );
          continue;
        }
        _leave(entry, time);
        final index = before == null
            ? 0
            : merged.indexWhere((other) => other.key == before) + 1;
        merged.insert(index, entry);
      }
      before = entry.key;
    }
    _entries = merged;
  }

  _Entry<T> _stay(T item, Map<Object, _Entry<T>> previous, Duration time) {
    final known = previous[widget.keyOf(item)];
    if (known == null) {
      final entry = _newEntry(item, shown: time == Duration.zero);
      if (time != Duration.zero) {
        entry.controller.animateTo(1, duration: time, curve: WbMotion.easeOut);
      }
      return entry;
    }
    known.item = item;
    if (known.leaving) {
      known.leaving = false;
      known.controller.animateTo(1, duration: time, curve: WbMotion.easeOut);
    }
    return known;
  }

  void _leave(_Entry<T> entry, Duration time) {
    if (entry.leaving) return;
    entry.leaving = true;
    entry.controller
        .animateBack(0, duration: time, curve: WbMotion.standard)
        .then((_) {
          if (!mounted || !entry.leaving) return;
          setState(() => _entries.remove(entry));
          entry.controller.dispose();
        });
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _entries.lastWhereOrNull((entry) => !entry.leaving);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in _entries)
          IgnorePointer(
            key: ValueKey(entry.key),
            ignoring: entry.leaving,
            child: FadeTransition(
              opacity: entry.controller,
              child: SizeTransition(
                sizeFactor: entry.controller,
                alignment: Alignment.topCenter,
                child: widget.itemBuilder(
                  context,
                  entry.item,
                  identical(entry, last),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

extension<E> on List<E> {
  E? lastWhereOrNull(bool Function(E element) test) {
    for (final element in reversed) {
      if (test(element)) return element;
    }
    return null;
  }
}
