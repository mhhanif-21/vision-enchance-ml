import 'package:equatable/equatable.dart';
import '../../../../core/constants/model_config.dart';

abstract class RestoreEvent extends Equatable {
  const RestoreEvent();
  @override
  List<Object?> get props => [];
}

class RestoreImageSelected extends RestoreEvent {
  final String imagePath;
  final ModelType modelType;
  const RestoreImageSelected({required this.imagePath, required this.modelType});
  @override
  List<Object?> get props => [imagePath, modelType];
}

class RestoreStarted extends RestoreEvent {
  const RestoreStarted();
}

class RestoreCancelled extends RestoreEvent {
  const RestoreCancelled();
}

class RestoreReset extends RestoreEvent {
  const RestoreReset();
}
