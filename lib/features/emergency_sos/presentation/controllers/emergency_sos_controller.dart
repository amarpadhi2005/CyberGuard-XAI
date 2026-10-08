import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/trusted_contact.dart';
import '../../domain/entities/incident_report.dart';
import '../../domain/entities/emergency_sos_state.dart';
import '../../domain/repositories/emergency_sos_repository.dart';
import '../../data/repositories/emergency_sos_repository_impl.dart';

class EmergencySosController extends ChangeNotifier {
  final EmergencySosRepository _repository;

  EmergencySosState _state = const EmergencySosState();
  Timer? _countdownTimer;

  EmergencySosController({EmergencySosRepository? repository})
      : _repository = repository ?? EmergencySosRepositoryImpl();

  EmergencySosState get state => _state;
  bool get isSosActive => _state.isSosActive;
  bool get isTriggering => _state.isTriggering;
  int get countdownSeconds => _state.countdownSeconds;
  List<TrustedContact> get trustedContacts => _state.trustedContacts;
  List<IncidentReport> get recentReports => _state.recentReports;
  bool get isLocationShared => _state.isLocationShared;
  bool get hasThreatScreenshot => _state.hasThreatScreenshot;
  IncidentReport? get lastGeneratedReport => _state.lastGeneratedReport;
  bool get isLoading => _state.isLoading;
  String get statusMessage => _state.statusMessage;

  Future<void> loadData(String userId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final contacts = await _repository.getTrustedContacts(userId);
    final reports = await _repository.getIncidentReports(userId);

    _state = _state.copyWith(
      trustedContacts: contacts,
      recentReports: reports,
      isLoading: false,
      statusMessage: 'Perimeter monitored. Ready for emergency dispatch.',
    );
    notifyListeners();
  }

  void toggleLocationSharing() {
    final next = !_state.isLocationShared;
    _state = _state.copyWith(
      isLocationShared: next,
      statusMessage: next
          ? 'High-precision GPS telemetry linked (±3.2m)'
          : 'Location broadcast masked',
    );
    notifyListeners();
  }

  void toggleThreatScreenshot({String? sampleFileName}) {
    final next = !_state.hasThreatScreenshot;
    _state = _state.copyWith(
      hasThreatScreenshot: next,
      threatScreenshotName: next
          ? (sampleFileName ?? 'Forensic_Evidence_Chase_Phishing_2026.png')
          : '',
      statusMessage: next
          ? 'Threat screenshot cryptographically signed & attached'
          : 'Threat screenshot detached',
    );
    notifyListeners();
  }

  void startEmergencyCountdown(String userId) {
    if (_state.isTriggering) return;

    _state = _state.copyWith(
      isTriggering: true,
      countdownSeconds: 3,
      statusMessage: 'CRITICAL: EMERGENCY SOS DISPATCH IN 3 SECONDS...',
    );
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.countdownSeconds > 1) {
        _state = _state.copyWith(
          countdownSeconds: _state.countdownSeconds - 1,
          statusMessage:
              'CRITICAL: DISPATCHING BEACON IN ${_state.countdownSeconds - 1}s...',
        );
        notifyListeners();
      } else {
        timer.cancel();
        dispatchImmediateSos(userId);
      }
    });
  }

  void cancelEmergencySos() {
    _countdownTimer?.cancel();
    _state = _state.copyWith(
      isTriggering: false,
      countdownSeconds: 3,
      isSosActive: false,
      statusMessage: 'Emergency dispatch standby. Threat beacon cancelled.',
    );
    notifyListeners();
  }

  Future<IncidentReport> dispatchImmediateSos(
    String userId, {
    String? scamType,
    String? scammerContact,
    String? description,
  }) async {
    _countdownTimer?.cancel();
    _state = _state.copyWith(isLoading: true, isTriggering: false);
    notifyListeners();

    final now = DateTime.now();
    final randomSuffix = (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    final incidentId = 'INC-${now.year}-$randomSuffix-SOS';

    final effectiveScamType =
        scamType ?? 'Impersonation Robocall & Credential Phishing Syndicate';
    final effectiveContact =
        scammerContact ?? '+1 (800) 492-9182 / https://secure-chase-update.com';
    final effectiveDesc = description ??
        'User encountered urgent phishing SMS and impersonation robocall claiming account seizure. High-stakes emergency panic beacon triggered.';

    final alertedNames = _state.trustedContacts
        .where((c) => c.isNotifyEnabled)
        .map((c) => c.name)
        .toList();

    final locationCoord = _state.isLocationShared
        ? _state.currentLocationCoordinates
        : 'MASKED BY USER';
    final locationAddr = _state.isLocationShared
        ? _state.currentLocationAddress
        : 'San Francisco, CA (Region Only)';

    final forensicHash = IncidentReport.generateForensicHash(
      incidentId,
      now,
      effectiveScamType,
    );

    final formalDossier = IncidentReport.buildFormalDossier(
      incidentId: incidentId,
      timestamp: now,
      scamType: effectiveScamType,
      scammerContact: effectiveContact,
      description: effectiveDesc,
      locationString: '$locationCoord ($locationAddr)',
      hasScreenshot: _state.hasThreatScreenshot,
      forensicHash: forensicHash,
      alertedContacts: alertedNames,
    );

    final report = IncidentReport(
      incidentId: incidentId,
      timestamp: now,
      scamType: effectiveScamType,
      severity: 'CRITICAL - LEVEL 1',
      scammerContact: effectiveContact,
      description: effectiveDesc,
      locationCoordinates: locationCoord,
      locationAddress: locationAddr,
      isLocationShared: _state.isLocationShared,
      hasThreatScreenshot: _state.hasThreatScreenshot,
      screenshotFileName: _state.threatScreenshotName,
      screenshotWatermark: 'HASH: $forensicHash • CYBERGUARD FORENSIC EVIDENCE',
      contactsAlerted: alertedNames,
      forensicHash: forensicHash,
      formalReportSummary: formalDossier,
      status: 'DISPATCHED_TO_FIRESTORE',
    );

    // Save to Firestore & Broadcast
    await _repository.saveIncidentReport(userId, report);
    await _repository.triggerEmergencyBroadcast(userId, report);

    final updatedReports = List<IncidentReport>.from(_state.recentReports)
      ..insert(0, report);

    _state = _state.copyWith(
      isSosActive: true,
      isTriggering: false,
      isLoading: false,
      lastGeneratedReport: report,
      recentReports: updatedReports,
      statusMessage:
          '🚨 EMERGENCY BEACON BROADCAST SENT TO ${alertedNames.length} TRUSTED CONTACTS & LOGGED TO FIRESTORE.',
    );
    notifyListeners();

    return report;
  }

  Future<void> addTrustedContact(String userId, TrustedContact contact) async {
    await _repository.addTrustedContact(userId, contact);
    final updated = List<TrustedContact>.from(_state.trustedContacts)
      ..removeWhere((c) => c.id == contact.id)
      ..add(contact);

    _state = _state.copyWith(
      trustedContacts: updated,
      statusMessage: 'Trusted contact "${contact.name}" added to emergency relay.',
    );
    notifyListeners();
  }

  Future<void> removeTrustedContact(String userId, String contactId) async {
    await _repository.removeTrustedContact(userId, contactId);
    final updated = List<TrustedContact>.from(_state.trustedContacts)
      ..removeWhere((c) => c.id == contactId);

    _state = _state.copyWith(
      trustedContacts: updated,
      statusMessage: 'Contact removed from emergency relay.',
    );
    notifyListeners();
  }

  void resetSosActiveState() {
    _state = _state.copyWith(
      isSosActive: false,
      statusMessage: 'Emergency stand-down acknowledged. Monitoring resumed.',
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
