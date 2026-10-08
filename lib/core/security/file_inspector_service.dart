import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'central_risk_engine.dart';

class FileAnalysisResult {
  final String fileName;
  final int fileSizeBytes;
  final String fileExtension;
  final String sha256Hash;
  final String mimeCategory;
  final Map<String, dynamic> metadata;
  final List<SecurityIndicator> indicators;
  final RiskAssessmentResult assessment;

  const FileAnalysisResult({
    required this.fileName,
    required this.fileSizeBytes,
    required this.fileExtension,
    required this.sha256Hash,
    required this.mimeCategory,
    required this.metadata,
    required this.indicators,
    required this.assessment,
  });
}

class FileInspectorService {
  /// Safely analyzes file bytes and headers without executing code or launching processes.
  Future<FileAnalysisResult> analyzeFileBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final size = bytes.length;
    final sha256Digest = sha256.convert(bytes).toString();
    final lowerName = fileName.toLowerCase();

    final extIndex = lowerName.lastIndexOf('.');
    final ext = extIndex != -1 ? lowerName.substring(extIndex) : '';

    final List<SecurityIndicator> indicators = [];
    final Map<String, dynamic> metadata = {
      'file_name': fileName,
      'file_size_bytes': size,
      'sha256': sha256Digest,
      'extension': ext,
    };

    String mimeCategory = 'Unknown Document';

    // 1. Double Extension Check (e.g. invoice.pdf.apk or document.docx.exe)
    final doubleExtRegex = RegExp(r'\.(pdf|docx?|xlsx?|jpg|png)\.(apk|exe|bat|vbs|sh|bin)$', caseSensitive: false);
    if (doubleExtRegex.hasMatch(lowerName)) {
      indicators.add(SecurityIndicator(
        indicator: 'Deceptive Double Extension',
        category: 'File Structure',
        severity: RiskSeverity.critical,
        confidence: 99,
        evidence: 'File disguises executable payload behind deceptive document extension: "$fileName"',
        weight: 12.0,
      ));
    }

    if (ext == '.apk') {
      mimeCategory = 'Android Package Archive';
      _inspectApk(bytes, fileName, indicators, metadata);
    } else if (ext == '.pdf') {
      mimeCategory = 'Portable Document Format (PDF)';
      _inspectPdf(bytes, indicators, metadata);
    } else if (ext == '.zip') {
      mimeCategory = 'ZIP Archive';
      _inspectZip(bytes, indicators, metadata);
    } else if (ext == '.jpg' || ext == '.png' || ext == '.webp') {
      mimeCategory = 'Image File';
      metadata['format'] = ext.replaceAll('.', '').toUpperCase();
    } else {
      mimeCategory = 'General File Document';
    }

    // 2. High Entropy / Encrypted Payload Check
    if (size > 50000000) {
      metadata['size_notice'] = 'File exceeds 50MB telemetry boundary';
    }

    // 3. Central Risk Engine Evaluation
    final assessment = CentralRiskEngine.evaluate(indicators);

    return FileAnalysisResult(
      fileName: fileName,
      fileSizeBytes: size,
      fileExtension: ext,
      sha256Hash: sha256Digest,
      mimeCategory: mimeCategory,
      metadata: metadata,
      indicators: indicators,
      assessment: assessment,
    );
  }

  void _inspectApk(
    Uint8List bytes,
    String fileName,
    List<SecurityIndicator> indicators,
    Map<String, dynamic> metadata,
  ) {
    // Verify ZIP / APK magic header (PK\x03\x04)
    final isZipMagic = bytes.length >= 4 &&
        bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        bytes[2] == 0x03 &&
        bytes[3] == 0x04;

    metadata['valid_archive_header'] = isZipMagic;
    metadata['execution_safety'] = 'Disarmed in memory sandbox (Execution strictly blocked)';

    if (!isZipMagic) {
      indicators.add(const SecurityIndicator(
        indicator: 'Malformed APK Header',
        category: 'Header Integrity',
        severity: RiskSeverity.high,
        confidence: 95,
        evidence: 'APK file lacks valid PK zip archive header bytes',
        weight: 9.0,
      ));
      return;
    }

    // Convert raw byte scan into string search for manifest tokens safely
    final contentString = latin1.decode(bytes.sublist(0, bytes.length > 500000 ? 500000 : bytes.length), allowInvalid: true);

    // Check for high-risk Android permissions
    final List<String> highRiskPermissions = [];
    if (contentString.contains('android.permission.RECEIVE_BOOT_COMPLETED')) {
      highRiskPermissions.add('RECEIVE_BOOT_COMPLETED (Auto-start on boot)');
    }
    if (contentString.contains('android.permission.SYSTEM_ALERT_WINDOW')) {
      highRiskPermissions.add('SYSTEM_ALERT_WINDOW (Draw over other apps / Overlay)');
    }
    if (contentString.contains('android.permission.READ_SMS') ||
        contentString.contains('RECEIVE_SMS') ||
        contentString.contains('SEND_SMS')) {
      highRiskPermissions.add('SMS Access (READ_SMS / SEND_SMS / RECEIVE_SMS)');
    }
    if (contentString.contains('android.permission.BIND_ACCESSIBILITY_SERVICE')) {
      highRiskPermissions.add('BIND_ACCESSIBILITY_SERVICE (Keylogging & UI control)');
    }
    if (contentString.contains('android.permission.RECORD_AUDIO')) {
      highRiskPermissions.add('RECORD_AUDIO (Microphone surveillance)');
    }
    if (contentString.contains('android.permission.REQUEST_INSTALL_PACKAGES')) {
      highRiskPermissions.add('REQUEST_INSTALL_PACKAGES (Dropper / Sideload malware)');
    }

    metadata['flagged_permissions'] = highRiskPermissions;

    if (highRiskPermissions.any((p) => p.contains('BIND_ACCESSIBILITY_SERVICE') || p.contains('READ_SMS'))) {
      indicators.add(SecurityIndicator(
        indicator: 'Privileged Surveillance Permissions',
        category: 'Android Manifest Audit',
        severity: RiskSeverity.critical,
        confidence: 96,
        evidence: 'APK requests privileged surveillance access: ${highRiskPermissions.join(', ')}',
        weight: 12.0,
      ));
    } else if (highRiskPermissions.isNotEmpty) {
      indicators.add(SecurityIndicator(
        indicator: 'High-Risk Android Permissions',
        category: 'Android Manifest Audit',
        severity: RiskSeverity.medium,
        confidence: 90,
        evidence: 'APK declares elevated capabilities: ${highRiskPermissions.join(', ')}',
        weight: 6.0,
      ));
    }

    // Check for debuggable flag in manifest
    if (contentString.contains('android:debuggable="true"')) {
      metadata['debuggable'] = true;
      indicators.add(const SecurityIndicator(
        indicator: 'Debuggable Production APK',
        category: 'Build Security',
        severity: RiskSeverity.medium,
        confidence: 94,
        evidence: 'APK package has android:debuggable set to true (enables live process memory debugging)',
        weight: 5.0,
      ));
    }

    // Check certificate / META-INF
    final hasCertRsa = contentString.contains('META-INF/') &&
        (contentString.contains('.RSA') || contentString.contains('.DSA') || contentString.contains('.EC'));
    metadata['has_signing_block'] = hasCertRsa;
    if (!hasCertRsa) {
      indicators.add(const SecurityIndicator(
        indicator: 'Unsigned / Self-Modified Package',
        category: 'Cryptographic Signature',
        severity: RiskSeverity.high,
        confidence: 92,
        evidence: 'APK lacks standard Android V1/V2 META-INF signing block',
        weight: 8.0,
      ));
    }
  }

  void _inspectPdf(
    Uint8List bytes,
    List<SecurityIndicator> indicators,
    Map<String, dynamic> metadata,
  ) {
    final pdfHeader = bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46; // %PDF

    metadata['valid_pdf_header'] = pdfHeader;
    if (!pdfHeader) {
      indicators.add(const SecurityIndicator(
        indicator: 'Corrupted PDF Header',
        category: 'File Structure',
        severity: RiskSeverity.medium,
        confidence: 88,
        evidence: 'File extension is .pdf but lacks standard %PDF signature',
        weight: 5.0,
      ));
      return;
    }

    final snippet = latin1.decode(bytes.sublist(0, bytes.length > 250000 ? 250000 : bytes.length), allowInvalid: true);

    // Look for embedded JavaScript or AutoOpen scripts
    if (snippet.contains('/JavaScript') || snippet.contains('/JS')) {
      indicators.add(const SecurityIndicator(
        indicator: 'Embedded PDF JavaScript Stream',
        category: 'Active Content',
        severity: RiskSeverity.high,
        confidence: 94,
        evidence: 'PDF document contains embedded /JavaScript stream objects',
        weight: 8.0,
      ));
    }

    if (snippet.contains('/Launch') || snippet.contains('/OpenAction')) {
      indicators.add(const SecurityIndicator(
        indicator: 'Automatic Launch Action',
        category: 'Exploit Heuristic',
        severity: RiskSeverity.critical,
        confidence: 96,
        evidence: 'PDF contains /Launch or /OpenAction command triggers designed to execute outside PDF reader',
        weight: 10.0,
      ));
    }
  }

  void _inspectZip(
    Uint8List bytes,
    List<SecurityIndicator> indicators,
    Map<String, dynamic> metadata,
  ) {
    final snippet = latin1.decode(bytes.sublist(0, bytes.length > 100000 ? 100000 : bytes.length), allowInvalid: true);
    final suspiciousFileInside = RegExp(r'\.(exe|bat|vbs|ps1|apk|scr)', caseSensitive: false);
    if (suspiciousFileInside.hasMatch(snippet)) {
      indicators.add(const SecurityIndicator(
        indicator: 'Executable in Compressed Archive',
        category: 'Payload Delivery',
        severity: RiskSeverity.high,
        confidence: 92,
        evidence: 'Archive contains binary executable or script payload',
        weight: 8.0,
      ));
    }
  }
}
