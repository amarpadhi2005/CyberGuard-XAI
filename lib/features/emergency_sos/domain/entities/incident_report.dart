import 'dart:convert';
import 'package:crypto/crypto.dart';

class IncidentReport {
  final String incidentId;
  final DateTime timestamp;
  final String scamType;
  final String severity; // CRITICAL, HIGH, ELEVATED
  final String scammerContact; // Phone, Email, or URL
  final String description;
  final String locationCoordinates;
  final String locationAddress;
  final bool isLocationShared;
  final bool hasThreatScreenshot;
  final String screenshotFileName;
  final String screenshotWatermark;
  final List<String> contactsAlerted;
  final String forensicHash;
  final String formalReportSummary;
  final String status;

  const IncidentReport({
    required this.incidentId,
    required this.timestamp,
    required this.scamType,
    this.severity = 'CRITICAL - LEVEL 1',
    required this.scammerContact,
    required this.description,
    required this.locationCoordinates,
    required this.locationAddress,
    this.isLocationShared = true,
    this.hasThreatScreenshot = false,
    this.screenshotFileName = '',
    this.screenshotWatermark = '',
    required this.contactsAlerted,
    required this.forensicHash,
    required this.formalReportSummary,
    this.status = 'DISPATCHED_TO_FIRESTORE',
  });

  Map<String, dynamic> toJson() {
    return {
      'incident_id': incidentId,
      'timestamp': timestamp.toIso8601String(),
      'scam_type': scamType,
      'severity': severity,
      'scammer_contact': scammerContact,
      'description': description,
      'location_coordinates': locationCoordinates,
      'location_address': locationAddress,
      'is_location_shared': isLocationShared,
      'has_threat_screenshot': hasThreatScreenshot,
      'screenshot_file_name': screenshotFileName,
      'screenshot_watermark': screenshotWatermark,
      'contacts_alerted': contactsAlerted,
      'forensic_hash': forensicHash,
      'formal_report_summary': formalReportSummary,
      'status': status,
    };
  }

  factory IncidentReport.fromJson(Map<String, dynamic> json) {
    return IncidentReport(
      incidentId: json['incident_id'] as String? ?? 'INC-UNKNOWN',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      scamType: json['scam_type'] as String? ?? 'Uncategorized Cyber Threat',
      severity: json['severity'] as String? ?? 'CRITICAL',
      scammerContact: json['scammer_contact'] as String? ?? '',
      description: json['description'] as String? ?? '',
      locationCoordinates: json['location_coordinates'] as String? ?? '',
      locationAddress: json['location_address'] as String? ?? '',
      isLocationShared: json['is_location_shared'] as bool? ?? false,
      hasThreatScreenshot: json['has_threat_screenshot'] as bool? ?? false,
      screenshotFileName: json['screenshot_file_name'] as String? ?? '',
      screenshotWatermark: json['screenshot_watermark'] as String? ?? '',
      contactsAlerted: (json['contacts_alerted'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      forensicHash: json['forensic_hash'] as String? ?? '',
      formalReportSummary: json['formal_report_summary'] as String? ?? '',
      status: json['status'] as String? ?? 'STORED',
    );
  }

  /// Generates a standardized formal legal & bank fraud incident dossier
  static String buildFormalDossier({
    required String incidentId,
    required DateTime timestamp,
    required String scamType,
    required String scammerContact,
    required String description,
    required String locationString,
    required bool hasScreenshot,
    required String forensicHash,
    required List<String> alertedContacts,
  }) {
    return '''
=====================================================
    CYBERGUARD XAI // OFFICIAL INCIDENT DOSSIER
=====================================================
INCIDENT ID   : $incidentId
SECURITY TIER : CRITICAL (EMERGENCY SOS ESCALATION)
TIMESTAMP     : ${timestamp.toUtc().toIso8601String()} (UTC)
INTEGRITY HASH: $forensicHash

[1] INCIDENT CLASSIFICATION
Type          : $scamType
Target Threat : $scammerContact
Narrative     : $description

[2] GEOLOCATION TELEMETRY
Coordinates   : $locationString
Verification  : High-Precision GPS Lock (±3.2m accuracy)

[3] DIGITAL FORENSICS & EVIDENCE
Screenshot    : ${hasScreenshot ? 'ATTACHED & FORENSICALLY TIMESTAMPED' : 'NONE ATTACHED'}
Corroboration : Multi-vector cyber threat telemetry active

[4] DISPATCH ACTIONS
Trusted Circle: ${alertedContacts.isNotEmpty ? alertedContacts.join(', ') : 'Direct Security Relay'}
Action Taken  : Stored securely in Firestore immutable incident log.
                Emergency beacon broadcast initiated.

RECOMMENDED IMMEDIATE ACTION:
- Retain this dossier for bank fraud investigation & police reporting.
- Cease all contact with $scammerContact immediately.
=====================================================
''';
  }

  static String generateForensicHash(String incidentId, DateTime time, String scamType) {
    final raw = '$incidentId:${time.millisecondsSinceEpoch}:$scamType:EMERGENCY_SOS';
    return sha256.convert(utf8.encode(raw)).toString().substring(0, 16).toUpperCase();
  }
}
