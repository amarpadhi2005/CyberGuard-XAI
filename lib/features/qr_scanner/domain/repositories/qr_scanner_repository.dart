import '../entities/qr_scan_result.dart';

abstract class QrScannerRepository {
  /// Extracts URL from raw QR payload and evaluates safety with Gemini API
  Future<QrScanResult> processQrPayload(String rawPayload);

  /// Retrieves cached previous QR scans
  Future<List<QrScanResult>> getRecentQrScans();
}
