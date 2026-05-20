import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ModelLoadFailure extends Failure {
  const ModelLoadFailure(super.message);
}

class InferenceFailure extends Failure {
  const InferenceFailure(super.message);
}

class InsufficientMemoryFailure extends Failure {
  const InsufficientMemoryFailure(super.message);
}

class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure(super.message);
}

class FileStorageFailure extends Failure {
  const FileStorageFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
