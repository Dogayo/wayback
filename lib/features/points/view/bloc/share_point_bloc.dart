import 'package:wayback/core/bloc/action/action_bloc.dart';
import 'package:wayback/core/result/result.dart';
import 'package:wayback/features/points/domain/entities/point_draft.dart';
import 'package:wayback/features/points/domain/entities/saved_point.dart';
import 'package:wayback/features/points/domain/repositories/point_share_repository.dart';

export 'package:wayback/core/bloc/action/action_bloc.dart';

/// Sends a point to another app, as a message anyone can read.
final class SharePointBloc extends ActionBloc<SavedPoint, void> {
  SharePointBloc(this._share);

  final PointShareRepository _share;

  @override
  Future<Result<void>> perform(SavedPoint params) =>
      _share.shareText(pointShareText(params));
}
