import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../../../core/constants/model_config.dart';

enum RestorePhase { preprocessing, inference, postprocessing }

abstract class RestoreState extends Equatable {
  const RestoreState();
  @override
  List<Object?> get props => [];
}

class RestoreInitial extends RestoreState {
  const RestoreInitial();
}

class RestoreImageReady extends RestoreState {
  final String imagePath;
  final ModelType modelType;
  const RestoreImageReady({required this.imagePath, required this.modelType});
  @override
  List<Object?> get props => [imagePath, modelType];
}

class RestoreProcessing extends RestoreState {
  final RestorePhase phase;
  final String message;
  const RestoreProcessing({required this.phase, required this.message});
  @override
  List<Object?> get props => [phase, message];
}

class RestoreSuccess extends RestoreState {
  final Uint8List originalBytes;
  final Uint8List restoredBytes;
  final ModelType modelType;
  final int processingTimeMs;
  final int inputWidth;
  final int inputHeight;
  const RestoreSuccess({
    required this.originalBytes,
    required this.restoredBytes,
    required this.modelType,
    required this.processingTimeMs,
    required this.inputWidth,
    required this.inputHeight,
  });
  @override
  List<Object?> get props => [processingTimeMs, modelType];
}

class RestoreFailure extends RestoreState {
  final String message;
  final String? actionLabel;
  const RestoreFailure({required this.message, this.actionLabel});
  @override
  List<Object?> get props => [message];
}
