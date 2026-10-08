import '../entities/call_scan_result.dart';

abstract class ScamCallRepository {
  /// Evaluates phone number reputation using local demo signatures and Gemini API
  Future<CallScanResult> analyzePhoneNumber(String phoneNumber);

  /// Stores every scan record in Cloud Firestore
  Future<void> saveCallScan(CallScanResult scan, String userId);

  /// Retrieves persisted call scan history from Cloud Firestore
  Future<List<CallScanResult>> getScanHistory(String userId);

  /// Blocks number and persists rule in Firestore
  Future<void> blockPhoneNumber(String phoneNumber, String userId);
}
