import 'package:flutter/material.dart';
import 'help_step.dart';

/// Manages the state of an in-app help tour.
/// Add as a [ChangeNotifier] to your widget tree or create one per screen.
class HelpController extends ChangeNotifier {
  List<HelpStep> _steps = [];
  int _currentIndex = -1;
  bool _isActive = false;

  bool get isActive => _isActive;
  int get currentIndex => _currentIndex;
  int get totalSteps => _steps.length;
  bool get isLastStep => _currentIndex >= _steps.length - 1;
  bool get isFirstStep => _currentIndex == 0;

  HelpStep? get currentStep {
    if (!_isActive || _currentIndex < 0 || _currentIndex >= _steps.length) {
      return null;
    }
    return _steps[_currentIndex];
  }

  /// Start the tour with the given [steps].
  void start(List<HelpStep> steps) {
    if (steps.isEmpty) return;
    _steps = steps;
    _currentIndex = 0;
    _isActive = true;
    notifyListeners();
  }

  /// Advance to the next step, or dismiss if on the last step.
  void next() {
    if (!_isActive) return;
    if (isLastStep) {
      dismiss();
    } else {
      _currentIndex++;
      notifyListeners();
    }
  }

  /// Go back to the previous step.
  void previous() {
    if (!_isActive || isFirstStep) return;
    _currentIndex--;
    notifyListeners();
  }

  /// Skip to a specific step by index.
  void goTo(int index) {
    if (!_isActive || index < 0 || index >= _steps.length) return;
    _currentIndex = index;
    notifyListeners();
  }

  /// End the tour.
  void dismiss() {
    _isActive = false;
    _currentIndex = -1;
    notifyListeners();
  }
}
