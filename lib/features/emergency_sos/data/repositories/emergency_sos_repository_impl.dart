import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/trusted_contact.dart';
import '../../domain/entities/incident_report.dart';
import '../../domain/repositories/emergency_sos_repository.dart';

class EmergencySosRepositoryImpl implements EmergencySosRepository {
  FirebaseFirestore? _firestore;

  EmergencySosRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore? get _db {
    if (_firestore != null) return _firestore;
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (_) {}
    return _firestore;
  }

  // Local in-memory fallback list of trusted contacts
  static final List<TrustedContact> _fallbackContacts = [
    const TrustedContact(
      id: 'TC-01',
      name: 'Cyber Crime Response Unit',
      relationship: 'National Cyber Security Center',
      phoneNumber: '+1 (800) 225-5324',
      email: 'incident-response@ic3.gov',
      isNotifyEnabled: true,
      isAutoBeacon: true,
    ),
    const TrustedContact(
      id: 'TC-02',
      name: 'Alex Vance (Primary Guardian)',
      relationship: 'Immediate Family',
      phoneNumber: '+1 (415) 892-1049',
      email: 'alex.vance@securemail.io',
      isNotifyEnabled: true,
      isAutoBeacon: true,
    ),
    const TrustedContact(
      id: 'TC-03',
      name: 'Bank Fraud Rapid Response',
      relationship: 'Chase Bank Security Desk',
      phoneNumber: '+1 (800) 935-9935',
      email: 'fraud.operations@chase.com',
      isNotifyEnabled: true,
      isAutoBeacon: false,
    ),
  ];

  static final List<IncidentReport> _fallbackReports = [];

  @override
  Future<List<TrustedContact>> getTrustedContacts(String userId) async {
    try {
      final db = _db;
      if (db != null) {
        final snapshot = await db
          .collection('users')
          .doc(userId)
          .collection('trusted_contacts')
          .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => TrustedContact.fromJson(doc.data()))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Firestore getTrustedContacts fallback: $e');
    }

    return List.from(_fallbackContacts);
  }

  @override
  Future<void> addTrustedContact(String userId, TrustedContact contact) async {
    _fallbackContacts.removeWhere((c) => c.id == contact.id);
    _fallbackContacts.add(contact);

    try {
      final db = _db;
      if (db != null) {
        await db
            .collection('users')
            .doc(userId)
            .collection('trusted_contacts')
            .doc(contact.id)
            .set(contact.toJson(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore addTrustedContact fallback: $e');
    }
  }

  @override
  Future<void> removeTrustedContact(String userId, String contactId) async {
    _fallbackContacts.removeWhere((c) => c.id == contactId);

    try {
      final db = _db;
      if (db != null) {
        await db
            .collection('users')
            .doc(userId)
            .collection('trusted_contacts')
            .doc(contactId)
            .delete();
      }
    } catch (e) {
      debugPrint('Firestore removeTrustedContact fallback: $e');
    }
  }

  @override
  Future<IncidentReport> saveIncidentReport(
    String userId,
    IncidentReport report,
  ) async {
    _fallbackReports.insert(0, report);

    try {
      final db = _db;
      if (db != null) {
        await db
            .collection('users')
            .doc(userId)
            .collection('sos_incidents')
            .doc(report.incidentId)
            .set({
          ...report.toJson(),
          'created_at': FieldValue.serverTimestamp(),
        });
        debugPrint('Incident report successfully stored in Firestore: ${report.incidentId}');
      }
    } catch (e) {
      debugPrint('Firestore saveIncidentReport fallback: $e');
    }

    return report;
  }

  @override
  Future<List<IncidentReport>> getIncidentReports(String userId) async {
    try {
      final db = _db;
      if (db != null) {
        final snapshot = await db
            .collection('users')
            .doc(userId)
            .collection('sos_incidents')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => IncidentReport.fromJson(doc.data()))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Firestore getIncidentReports fallback: $e');
    }

    return List.from(_fallbackReports);
  }

  @override
  Future<void> triggerEmergencyBroadcast(
    String userId,
    IncidentReport report,
  ) async {
    try {
      final db = _db;
      if (db != null) {
        await db
            .collection('users')
            .doc(userId)
            .collection('emergency_beacons')
            .doc(report.incidentId)
            .set({
          'incident_id': report.incidentId,
          'broadcast_time': FieldValue.serverTimestamp(),
          'contacts_alerted': report.contactsAlerted,
          'coordinates': report.locationCoordinates,
          'status': 'BEACON_BROADCAST_TRANSMITTED',
        });
      }
    } catch (e) {
      debugPrint('Firestore triggerEmergencyBroadcast fallback: $e');
    }
  }
}
