import 'package:flutter/foundation.dart';
import '../../domain/entities/xai_preset_benchmark.dart';
import '../../domain/entities/xai_result_model.dart';

class XaiResultController extends ChangeNotifier {
  late XaiResultModel _currentResult;
  final XaiResultModel? _customResult;
  bool _isSimplifiedMode = true; // Non-technical user friendly by default
  int _selectedPresetIndex = -1;

  XaiResultController({XaiResultModel? initialResult})
      : _customResult = initialResult {
    if (initialResult != null) {
      _currentResult = initialResult;
      _selectedPresetIndex = -1; // -1 represents the user's submitted analyzed target
    } else {
      _currentResult = XaiPresetBenchmark.presets.first;
      _selectedPresetIndex = 0;
    }
  }

  // Getters
  XaiResultModel get result => _currentResult;
  XaiResultModel? get customResult => _customResult;
  bool get hasCustomResult => _customResult != null;
  bool get isSimplifiedMode => _isSimplifiedMode;
  int get selectedPresetIndex => _selectedPresetIndex;
  List<XaiResultModel> get presets => XaiPresetBenchmark.presets;

  void selectCustomResult() {
    final custom = _customResult;
    if (custom != null) {
      _selectedPresetIndex = -1;
      _currentResult = custom;
      notifyListeners();
    }
  }

  void setResult(XaiResultModel newResult) {
    _currentResult = newResult;
    notifyListeners();
  }

  void toggleMode() {
    _isSimplifiedMode = !_isSimplifiedMode;
    notifyListeners();
  }

  void setSimplifiedMode(bool value) {
    _isSimplifiedMode = value;
    notifyListeners();
  }

  void selectPreset(int index) {
    if (index >= 0 && index < XaiPresetBenchmark.presets.length) {
      _selectedPresetIndex = index;
      _currentResult = XaiPresetBenchmark.presets[index];
      notifyListeners();
    }
  }
}
