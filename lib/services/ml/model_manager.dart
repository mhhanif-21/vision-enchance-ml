import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import '../../core/constants/model_config.dart';
import '../../core/errors/exceptions.dart';

class ModelManager {
  final OnnxRuntime _runtime = OnnxRuntime();
  OnnxRuntimeSession? _activeSession;
  ModelType? _loadedModel;

  ModelType? get loadedModel => _loadedModel;
  bool get hasActiveSession => _activeSession != null;

  Future<OnnxRuntimeSession> getSession(ModelType type) async {
    if (_loadedModel == type && _activeSession != null) {
      return _activeSession!;
    }
    await _unloadCurrent();
    _activeSession = await _loadModel(type);
    _loadedModel = type;
    return _activeSession!;
  }

  Future<OnnxRuntimeSession> _loadModel(ModelType type) async {
    try {
      final modelBytes = await rootBundle.load(type.assetPath);
      final session = await _runtime.createSessionFromBuffer(
        modelBytes.buffer.asUint8List(),
      );
      return session;
    } catch (e) {
      throw ModelLoadException(
        'Failed to load ${type.displayName} model: $e',
      );
    }
  }

  Future<void> _unloadCurrent() async {
    if (_activeSession != null) {
      try {
        await _activeSession!.close();
      } catch (_) {}
      _activeSession = null;
      _loadedModel = null;
    }
  }

  Future<void> dispose() async {
    await _unloadCurrent();
  }
}
