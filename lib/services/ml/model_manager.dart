import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import '../../core/constants/model_config.dart';
import '../../core/errors/exceptions.dart';

class ModelManager {
  final OnnxRuntime _runtime = OnnxRuntime();
  OrtSession? _activeSession;
  ModelType? _loadedModel;

  ModelType? get loadedModel => _loadedModel;
  bool get hasActiveSession => _activeSession != null;

  Future<OrtSession> getSession(ModelType type) async {
    if (_loadedModel == type && _activeSession != null) {
      return _activeSession!;
    }
    await _unloadCurrent();
    _activeSession = await _loadModel(type);
    _loadedModel = type;
    return _activeSession!;
  }

  Future<OrtSession> _loadModel(ModelType type) async {
    try {
      final session = await _runtime.createSessionFromAsset(type.assetPath);
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
