import 'package:flutter/foundation.dart';
import '../../domain/entities/threat_history_item.dart';
import '../../domain/repositories/threat_history_repository.dart';
import '../../data/repositories/threat_history_repository_impl.dart';
import '../../data/services/threat_history_sync_service.dart';

class ThreatHistoryController extends ChangeNotifier {
  final ThreatHistoryRepository _repository;
  final ThreatHistorySyncService _syncService;

  List<ThreatHistoryItem> _items = [];
  bool _isLoading = false;
  bool _isEmailAnalyzing = false;
  String _searchQuery = '';
  ThreatCategory? _selectedCategory; // null = ALL
  ThreatSeverity? _selectedSeverity; // null = ALL
  String? _errorMessage;

  ThreatHistoryController({
    ThreatHistoryRepository? repository,
    ThreatHistorySyncService? syncService,
  })  : _repository = repository ?? ThreatHistoryRepositoryImpl(),
        _syncService = syncService ?? ThreatHistorySyncService();

  // Getters
  bool get isLoading => _isLoading;
  bool get isEmailAnalyzing => _isEmailAnalyzing;
  String get searchQuery => _searchQuery;
  ThreatCategory? get selectedCategory => _selectedCategory;
  ThreatSeverity? get selectedSeverity => _selectedSeverity;
  String? get errorMessage => _errorMessage;

  int get totalScans => _items.length;
  int get criticalThreatsCount =>
      _items.where((i) => i.riskScore >= 75).length;
  int get safeScansCount =>
      _items.where((i) => i.riskScore < 40).length;

  /// Filtered items based on Category, Severity, and Search Query
  List<ThreatHistoryItem> get filteredItems {
    return _items.where((item) {
      // 1. Category Filter
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }

      // 2. Severity Filter
      if (_selectedSeverity != null && item.severity != _selectedSeverity) {
        return false;
      }

      // 3. Search Query Filter
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final matchesTitle = item.title.toLowerCase().contains(q);
        final matchesType = item.threatType.toLowerCase().contains(q);
        final matchesReason = item.reason.toLowerCase().contains(q);
        final matchesCategory = item.category.label.toLowerCase().contains(q);
        final matchesAction = item.recommendedAction.toLowerCase().contains(q);

        if (!matchesTitle &&
            !matchesType &&
            !matchesReason &&
            !matchesCategory &&
            !matchesAction) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Groups filtered items by chronological timeline buckets:
  /// 'TODAY', 'YESTERDAY', 'THIS WEEK', 'OLDER AUDITS'
  Map<String, List<ThreatHistoryItem>> get timelineGroups {
    final Map<String, List<ThreatHistoryItem>> groups = {};
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final weekStart = todayStart.subtract(const Duration(days: 7));

    for (final item in filteredItems) {
      final String groupKey;
      if (item.timestamp.isAfter(todayStart)) {
        groupKey = 'TODAY';
      } else if (item.timestamp.isAfter(yesterdayStart)) {
        groupKey = 'YESTERDAY';
      } else if (item.timestamp.isAfter(weekStart)) {
        groupKey = 'THIS WEEK';
      } else {
        groupKey = 'HISTORICAL AUDITS';
      }

      groups.putIfAbsent(groupKey, () => []).add(item);
    }

    return groups;
  }

  /// Loads scan history from Firestore
  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getThreatHistory(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Updates search query filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Sets or clears category filter
  void setCategoryFilter(ThreatCategory? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null; // Toggle off if already active
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
  }

  /// Sets or clears severity filter
  void setSeverityFilter(ThreatSeverity? severity) {
    if (_selectedSeverity == severity) {
      _selectedSeverity = null;
    } else {
      _selectedSeverity = severity;
    }
    notifyListeners();
  }

  /// Resets all filters
  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedSeverity = null;
    notifyListeners();
  }

  /// Deletes an item from Firestore and local cache
  Future<void> deleteItem(String itemId, String userId) async {
    _items.removeWhere((i) => i.id == itemId);
    notifyListeners();
    await _repository.deleteThreatItem(itemId, userId);
  }

  /// Clears all history from Firestore and local cache
  Future<void> clearAll(String userId) async {
    _items.clear();
    notifyListeners();
    await _repository.clearThreatHistory(userId);
  }

  /// Re-seeds demo benchmarks
  Future<void> reseedDemo(String userId) async {
    _isLoading = true;
    notifyListeners();
    _items = await _repository.seedInitialDemoThreats(userId);
    _isLoading = false;
    notifyListeners();
  }

  /// Analyzes an email and saves it to Firestore threat history
  Future<ThreatHistoryItem?> analyzeEmail({
    required String subject,
    required String sender,
    required String body,
    required String userId,
  }) async {
    _isEmailAnalyzing = true;
    notifyListeners();

    try {
      final item = await _syncService.analyzeAndRecordEmail(
        subject: subject,
        sender: sender,
        body: body,
        userId: userId,
      );
      _items.insert(0, item);
      _isEmailAnalyzing = false;
      notifyListeners();
      return item;
    } catch (e) {
      _isEmailAnalyzing = false;
      _errorMessage = 'Email analysis error: $e';
      notifyListeners();
      return null;
    }
  }

  /// Directly records a threat scan item (e.g. from Demo Mode or automated probes)
  Future<void> recordThreatItem(ThreatHistoryItem item, String userId) async {
    _items.removeWhere((i) => i.id == item.id);
    _items.insert(0, item);
    notifyListeners();

    try {
      await _repository.saveThreatItem(item, userId);
    } catch (e) {
      debugPrint('ThreatHistoryController.recordThreatItem warning: $e');
    }
  }
}
