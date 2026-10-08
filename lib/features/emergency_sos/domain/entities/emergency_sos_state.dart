import 'trusted_contact.dart';
import 'incident_report.dart';

class EmergencySosState {
  final bool isSosActive;
  final bool isTriggering;
  final int countdownSeconds;
  final List<TrustedContact> trustedContacts;
  final List<IncidentReport> recentReports;
  final bool isLocationShared;
  final String currentLocationCoordinates;
  final String currentLocationAddress;
  final bool hasThreatScreenshot;
  final String threatScreenshotName;
  final IncidentReport? lastGeneratedReport;
  final bool isLoading;
  final String statusMessage;

  const EmergencySosState({
    this.isSosActive = false,
    this.isTriggering = false,
    this.countdownSeconds = 3,
    this.trustedContacts = const [],
    this.recentReports = const [],
    this.isLocationShared = true,
    this.currentLocationCoordinates = '37.7749° N, 122.4194° W',
    this.currentLocationAddress = 'Financial Center, San Francisco, CA',
    this.hasThreatScreenshot = false,
    this.threatScreenshotName = '',
    this.lastGeneratedReport,
    this.isLoading = false,
    this.statusMessage = 'Emergency SOS Sentinel Standby',
  });

  EmergencySosState copyWith({
    bool? isSosActive,
    bool? isTriggering,
    int? countdownSeconds,
    List<TrustedContact>? trustedContacts,
    List<IncidentReport>? recentReports,
    bool? isLocationShared,
    String? currentLocationCoordinates,
    String? currentLocationAddress,
    bool? hasThreatScreenshot,
    String? threatScreenshotName,
    IncidentReport? lastGeneratedReport,
    bool? isLoading,
    String? statusMessage,
  }) {
    return EmergencySosState(
      isSosActive: isSosActive ?? this.isSosActive,
      isTriggering: isTriggering ?? this.isTriggering,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      trustedContacts: trustedContacts ?? this.trustedContacts,
      recentReports: recentReports ?? this.recentReports,
      isLocationShared: isLocationShared ?? this.isLocationShared,
      currentLocationCoordinates:
          currentLocationCoordinates ?? this.currentLocationCoordinates,
      currentLocationAddress:
          currentLocationAddress ?? this.currentLocationAddress,
      hasThreatScreenshot: hasThreatScreenshot ?? this.hasThreatScreenshot,
      threatScreenshotName: threatScreenshotName ?? this.threatScreenshotName,
      lastGeneratedReport: lastGeneratedReport ?? this.lastGeneratedReport,
      isLoading: isLoading ?? this.isLoading,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
