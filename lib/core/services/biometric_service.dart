import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _tokenKey = 'biometric_access_token';
  static const String _clientEnabledKey = 'biometric_enabled_for_client';

  static const String _bcoTokenKey = 'biometric_access_token_bco';
  static const String _bcoEnabledKey = 'biometric_enabled_for_bco';

  static const String _proTokenKey = 'biometric_access_token_pro';
  static const String _proEnabledKey = 'biometric_enabled_for_pro';

  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to login',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  // --- Client Portal Methods ---

  Future<void> enableClientBiometric(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clientEnabledKey, true);
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> updateSecureTokenIfEnabled(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_clientEnabledKey) ?? false;
    if (isEnabled) {
      await _secureStorage.write(key: _tokenKey, value: token);
    }
  }

  Future<void> disableClientBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clientEnabledKey, false);
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<bool> isClientBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_clientEnabledKey) ?? false;
  }

  Future<String?> getSecureToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // --- BCO Portal Methods ---

  Future<void> enableBcoBiometric(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bcoEnabledKey, true);
    await _secureStorage.write(key: _bcoTokenKey, value: token);
  }

  Future<void> updateBcoSecureTokenIfEnabled(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_bcoEnabledKey) ?? false;
    if (isEnabled) {
      await _secureStorage.write(key: _bcoTokenKey, value: token);
    }
  }

  Future<void> disableBcoBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bcoEnabledKey, false);
    await _secureStorage.delete(key: _bcoTokenKey);
  }

  Future<bool> isBcoBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_bcoEnabledKey) ?? false;
  }

  Future<String?> getBcoSecureToken() async {
    return await _secureStorage.read(key: _bcoTokenKey);
  }

  // --- Professional Portal Methods ---

  Future<void> enableProBiometric(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proEnabledKey, true);
    await _secureStorage.write(key: _proTokenKey, value: token);
  }

  Future<void> updateProSecureTokenIfEnabled(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_proEnabledKey) ?? false;
    if (isEnabled) {
      await _secureStorage.write(key: _proTokenKey, value: token);
    }
  }

  Future<void> disableProBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proEnabledKey, false);
    await _secureStorage.delete(key: _proTokenKey);
  }

  Future<bool> isProBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_proEnabledKey) ?? false;
  }

  Future<String?> getProSecureToken() async {
    return await _secureStorage.read(key: _proTokenKey);
  }
}
