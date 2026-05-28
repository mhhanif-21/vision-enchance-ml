import '../constants/model_config.dart';

class MemoryUtils {
  static DeviceTier getDeviceTier(int totalRamMB) {
    if (totalRamMB < 3072) return DeviceTier.low;
    if (totalRamMB <= 6144) return DeviceTier.mid;
    return DeviceTier.high;
  }

  static Future<int> getAvailableRAM() async {
    // Return dummy 4096MB (4GB) for now. In production, use a native channel plugin like 'system_info2'
    return 4096;
  }

  static int getMaxWidth(DeviceTier tier, ModelType type) {
    if (type == ModelType.lowLight) {
      return switch (tier) {
        DeviceTier.low => 720,
        DeviceTier.mid => 1080,
        DeviceTier.high => 1440,
      };
    }
    return switch (tier) {
      DeviceTier.low => 720,
      DeviceTier.mid => 1080,
      DeviceTier.high => 1440,
    };
  }

  static int getTileSize(DeviceTier tier) {
    return switch (tier) {
      DeviceTier.low => 256,
      DeviceTier.mid => 512,
      DeviceTier.high => 512,
    };
  }

  static bool needsTiling(ModelType type, int w, int h, DeviceTier tier) {
    if (type == ModelType.lowLight) return false;
    final ts = getTileSize(tier);
    return w > ts || h > ts;
  }
}
