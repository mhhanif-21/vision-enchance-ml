class ModelLoadException implements Exception {
  final String message;
  const ModelLoadException(this.message);

  @override
  String toString() => 'ModelLoadException: $message';
}

class InferenceException implements Exception {
  final String message;
  const InferenceException(this.message);

  @override
  String toString() => 'InferenceException: $message';
}

class InsufficientMemoryException implements Exception {
  final String message;
  const InsufficientMemoryException(this.message);

  @override
  String toString() => 'InsufficientMemoryException: $message';
}

class ImageProcessingException implements Exception {
  final String message;
  const ImageProcessingException(this.message);

  @override
  String toString() => 'ImageProcessingException: $message';
}
