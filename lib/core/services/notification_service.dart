import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../repositories/auxiliary_repository.dart';

/// Portals that can register an FCM token with the backend.
enum Portal { client, bco, professional }

/// Top-level handler required by Firebase for background / terminated messages.
/// Must be a top-level function annotated with @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // AuxiliaryRepository is not available in background isolate, so we only
  // handle the resync action when the app comes to the foreground.
  debugPrint('[FCM] Background message received: ${message.messageId}');
  debugPrint('[FCM] Background data: ${message.data}');
}

/// Centralized service for Firebase Cloud Messaging.
///
/// Usage:
///   - Call [initialize] once at app startup (after Firebase.initializeApp).
///   - Call [sendTokenToApi] from each auth BLoC on successful login.
///   - The [onTokenRefresh] listener automatically re-sends the token to all
///     portals where the user is currently authenticated.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  /// Global singleton accessor.
  static NotificationService get instance => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  AuxiliaryRepository? _auxiliaryRepository;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initialize the service. Call once in [main] after Firebase is set up.
  Future<void> initialize({required AuxiliaryRepository auxiliaryRepository}) async {
    _auxiliaryRepository = auxiliaryRepository;

    // 1. Request notification permissions (iOS / macOS / Web).
    await _requestPermission();

    // 2. Subscribe all users to the common broadcast topic.
    await _subscribeToTopic('nbrb_updates');

    // 3. Foreground message handler.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground message: ${message.messageId}');
      _handleMessage(message);
    });

    // 4. App opened from a notification in background state.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Notification opened app: ${message.messageId}');
      _handleMessage(message);
    });

    // 5. Check if the app was launched from a terminated-state notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] App launched from notification: ${initialMessage.messageId}');
      _handleMessage(initialMessage);
    }

    // 6. Re-send token to authenticated portals whenever Firebase rotates it.
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token refreshed, registering with authenticated portals.');
      await _sendTokenToAllAuthenticatedPortals(newToken);
    });
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Send the current FCM token to the given [portal]'s backend endpoint.
  ///
  /// Silently skips if:
  ///   - The user has no auth token for [portal] (not logged in).
  ///   - The FCM token cannot be retrieved.
  Future<void> sendTokenToApi({required Portal portal}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = _authTokenForPortal(prefs, portal);
      if (authToken == null) {
        debugPrint('[FCM] Skipping token registration for $portal — not authenticated.');
        return;
      }

      final fcmToken = await _messaging.getToken();
      if (fcmToken == null) {
        debugPrint('[FCM] FCM token unavailable, skipping registration for $portal.');
        return;
      }

      final dio = _dioForPortal(portal, authToken);
      await dio.post(
        ApiConstants.fcmToken,
        data: {'fcm_token': fcmToken},
      );

      debugPrint('[FCM] Token registered with $portal portal.');
    } catch (e) {
      debugPrint('[FCM] Failed to register token with $portal portal: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
  }

  Future<void> _subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('[FCM] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[FCM] Failed to subscribe to topic $topic: $e');
    }
  }

  /// Send the given [fcmToken] to every portal the user is currently logged in to.
  Future<void> _sendTokenToAllAuthenticatedPortals(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();

    for (final portal in Portal.values) {
      final authToken = _authTokenForPortal(prefs, portal);
      if (authToken == null) continue; // not logged in to this portal

      try {
        final dio = _dioForPortal(portal, authToken);
        await dio.post(
          ApiConstants.fcmToken,
          data: {'token': fcmToken},
        );
        debugPrint('[FCM] Token refreshed for $portal portal.');
      } catch (e) {
        debugPrint('[FCM] Failed to refresh token for $portal: $e');
      }
    }
  }

  /// Handle an incoming [RemoteMessage] by inspecting its data payload.
  void _handleMessage(RemoteMessage message) {
    final action = message.data['action'];
    if (action == null) return;

    debugPrint('[FCM] Handling action: $action');

    switch (action) {
      case 'resync-local-db':
        _handleResyncLocalDb();
        break;
      default:
        debugPrint('[FCM] Unknown action: $action');
    }
  }

  /// Clears the Hive sync timestamp and forces a full auxiliary data re-sync.
  void _handleResyncLocalDb() {
    try {
      final box = Hive.box('auxiliaryBox');
      box.delete('last_sync_timestamp');
      debugPrint('[FCM] Cleared local sync timestamp. Forcing auxiliary re-sync...');
      _auxiliaryRepository?.syncAuxiliaryData(forceSync: true);
    } catch (e) {
      debugPrint('[FCM] Error during resync-local-db: $e');
    }
  }

  /// Returns the saved auth token for [portal], or null if the user is not
  /// authenticated on that portal.
  String? _authTokenForPortal(SharedPreferences prefs, Portal portal) {
    switch (portal) {
      case Portal.client:
        return prefs.getString('access_token');
      case Portal.bco:
        return prefs.getString('bco_access_token');
      case Portal.professional:
        return prefs.getString('professional_access_token');
    }
  }

  /// Returns a minimal Dio instance pre-configured with the correct base URL
  /// and Bearer token for the given [portal].
  Dio _dioForPortal(Portal portal, String authToken) {
    final String baseUrl;
    switch (portal) {
      case Portal.client:
        baseUrl = ApiConstants.clientBaseUrl;
        break;
      case Portal.bco:
        baseUrl = ApiConstants.bcoBaseUrl;
        break;
      case Portal.professional:
        baseUrl = ApiConstants.professionalBaseUrl;
        break;
    }

    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
  }
}
