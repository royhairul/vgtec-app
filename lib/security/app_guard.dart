import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Security guard to prevent app cloning and unauthorized usage
class AppGuard {
  static const String _expectedPackageName = 'com.roaddetection.vgtec_app';
  static const String _expectedAppName = 'vgtec_app';

  static bool _isInitialized = false;
  static bool _isValid = false;

  /// Initialize app guard - call in main() before runApp()
  static Future<bool> initialize() async {
    if (_isInitialized) return _isValid;

    try {
      // Skip checks in debug mode for development
      if (kDebugMode) {
        print('🔓 AppGuard: Running in DEBUG mode - security checks disabled');
        _isValid = true;
        _isInitialized = true;
        return true;
      }

      print('🔒 AppGuard: Initializing security checks...');

      // Check 1: Verify package name (Android) / bundle ID (iOS)
      final packageInfo = await PackageInfo.fromPlatform();
      final isPackageValid = _validatePackage(packageInfo);

      if (!isPackageValid) {
        print('❌ AppGuard: Invalid package name detected!');
        print('   Expected: $_expectedPackageName');
        print('   Got: ${packageInfo.packageName}');
        _isValid = false;
        _isInitialized = true;
        return false;
      }

      // Check 2: Verify app is not running in emulator (production only)
      final isEmulator = await _isRunningOnEmulator();
      if (isEmulator && kReleaseMode) {
        print('⚠️ AppGuard: Running on emulator in RELEASE mode');
        // Uncomment to block emulators in production:
        // _isValid = false;
        // _isInitialized = true;
        // return false;
      }

      // Check 3: Verify app signature (Android only)
      if (Platform.isAndroid) {
        final isSignatureValid = await _validateSignature();
        if (!isSignatureValid) {
          print('❌ AppGuard: Invalid app signature!');
          _isValid = false;
          _isInitialized = true;
          return false;
        }
      }

      print('✅ AppGuard: All security checks passed');
      _isValid = true;
      _isInitialized = true;
      return true;
    } catch (e) {
      print('❌ AppGuard: Error during initialization: $e');
      // In case of error, allow app to run (fail-open)
      _isValid = true;
      _isInitialized = true;
      return true;
    }
  }

  /// Check if app is valid and authorized to run
  static bool get isValid => _isValid;

  /// Validate package name
  static bool _validatePackage(PackageInfo packageInfo) {
    // Check package name
    if (packageInfo.packageName != _expectedPackageName) {
      return false;
    }

    // Check app name
    if (packageInfo.appName != _expectedAppName) {
      return false;
    }

    return true;
  }

  /// Check if running on emulator/simulator
  static Future<bool> _isRunningOnEmulator() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;

      // Check multiple indicators of emulator
      final isEmulator =
          androidInfo.isPhysicalDevice == false ||
          androidInfo.model.toLowerCase().contains('emulator') ||
          androidInfo.model.toLowerCase().contains('sdk') ||
          androidInfo.manufacturer.toLowerCase().contains('google') &&
              androidInfo.model.toLowerCase().contains('sdk');

      return isEmulator;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.isPhysicalDevice == false;
    }

    return false;
  }

  /// Validate app signature (Android only)
  static Future<bool> _validateSignature() async {
    if (!Platform.isAndroid) return true;

    try {
      // Use MethodChannel to get Android signature
      const platform = MethodChannel('com.roaddetection.security');
      final String? signature = await platform.invokeMethod('getSignature');

      if (signature == null) {
        print('⚠️ AppGuard: Could not retrieve signature');
        return true; // Fail-open
      }

      // TODO: Replace with your actual release keystore signature
      // Get signature by running:
      // keytool -list -v -keystore release.keystore
      const List<String> expectedSignatures = [
        // Debug signature (for testing)
        'SHA1: YOUR_DEBUG_SIGNATURE_HERE',
        // Release signature (for production)
        'SHA1: YOUR_RELEASE_SIGNATURE_HERE',
      ];

      // In debug mode, accept any signature
      if (kDebugMode) return true;

      // In release mode, validate signature
      return expectedSignatures.any((expected) => signature.contains(expected));
    } catch (e) {
      print('⚠️ AppGuard: Error checking signature: $e');
      return true; // Fail-open
    }
  }

  /// Show security warning dialog
  static void showSecurityWarning() {
    print('⚠️⚠️⚠️ SECURITY WARNING ⚠️⚠️⚠️');
    print('This app appears to be cloned or modified!');
    print('Please download the official version.');
  }
}
