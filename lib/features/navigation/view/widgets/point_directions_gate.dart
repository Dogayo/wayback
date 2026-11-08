import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayback/features/navigation/view/bloc/point_directions_bloc.dart';

/// Keeps [PointDirectionsBloc] listening only while its route is on top and
/// the app is in the foreground: the route stays alive under other screens,
/// the compass must not (mvp-scope.md §5).
class PointDirectionsGate extends StatefulWidget {
  const PointDirectionsGate({required this.child, super.key});

  final Widget child;

  @override
  State<PointDirectionsGate> createState() => _PointDirectionsGateState();
}

class _PointDirectionsGateState extends State<PointDirectionsGate>
    with WidgetsBindingObserver {
  var _onTop = false;
  var _foreground = true;
  var _listening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onTop = ModalRoute.isCurrentOf(context) ?? true;
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground =
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    _sync();
  }

  void _sync() {
    final listen = _onTop && _foreground;
    if (listen == _listening) return;
    _listening = listen;
    final bloc = context.read<PointDirectionsBloc>();
    listen ? bloc.refresh() : bloc.stop();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
