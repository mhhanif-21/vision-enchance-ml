// Utilitas untuk deteksi RAM perangkat secara real menggunakan system_info2.
import 'package:system_info2/system_info2.dart';
import '../constants/model_config.dart';

class MemoryUtils {
  // Mengambil RAM yang tersedia dalam satuan MB dari sistem operasi.
  static Future<int> getAvailableRAM() async {
    try {
      final freeRam = SysInfo.getFreePhysicalMemory();
      // Konversi dari byte ke MB, minimal 0.
      return (freeRam / 1024 / 1024).floor().clamp(0, 999999);
    } catch (_) {
      // Fallback konservatif jika gagal membaca info sistem.
      return 512;
    }
  }

  // Mengambil total RAM fisik perangkat dalam satuan MB.
  static int getTotalRAM() {
    try {
      return (SysInfo.getTotalPhysicalMemory() / 1024 / 1024).floor();
    } catch (_) {
      return 2048;
    }
  }

  // Menentukan tier perangkat berdasarkan total RAM.
  static DeviceTier getDeviceTier(int totalRamMB) {
    if (totalRamMB < 3072) return DeviceTier.low;
    if (totalRamMB <= 6144) return DeviceTier.mid;
    return DeviceTier.high;
  }
}
