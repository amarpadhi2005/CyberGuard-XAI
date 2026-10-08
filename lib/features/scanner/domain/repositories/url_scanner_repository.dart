import '../entities/url_scan_result.dart';

abstract class UrlScannerRepository {
  /// Analyzes the target URL using Gemini API and forensic heuristics
  Future<UrlScanResult> scanUrl(String url, {bool isQuickTest = false});

  /// Retrieves cached previous scan results
  Future<List<UrlScanResult>> getRecentScans();
}
