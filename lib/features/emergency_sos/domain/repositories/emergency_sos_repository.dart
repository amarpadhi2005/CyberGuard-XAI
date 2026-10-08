import '../entities/trusted_contact.dart';
import '../entities/incident_report.dart';

abstract class EmergencySosRepository {
  Future<List<TrustedContact>> getTrustedContacts(String userId);

  Future<void> addTrustedContact(String userId, TrustedContact contact);

  Future<void> removeTrustedContact(String userId, String contactId);

  Future<IncidentReport> saveIncidentReport(String userId, IncidentReport report);

  Future<List<IncidentReport>> getIncidentReports(String userId);

  Future<void> triggerEmergencyBroadcast(String userId, IncidentReport report);
}
