import 'package:shared_preferences/shared_preferences.dart';

/// Persists which help tours the user has already seen.
///
/// Each screen uses a unique [tourKey] (e.g. `'tour_client_dashboard'`).
/// Call [hasSeenTour] to check, and [markTourSeen] once the tour starts.
class HelpPreferences {
  HelpPreferences._();

  static const String _prefix = 'help_tour_seen_';

  /// Returns `true` if the user has already seen the tour for [tourKey].
  static Future<bool> hasSeenTour(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$tourKey') ?? false;
  }

  /// Marks the tour for [tourKey] as seen so it won't auto-open again.
  static Future<void> markTourSeen(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$tourKey', true);
  }

  /// Resets the tour for [tourKey] — useful for testing or a "replay tour"
  /// option in settings.
  static Future<void> resetTour(String tourKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$tourKey');
  }

  /// Resets ALL tour flags — useful for a global "reset all tours" action.
  static Future<void> resetAllTours() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
