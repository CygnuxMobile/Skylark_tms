import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class FirebaseConfigService extends GetxService {
  late FirebaseRemoteConfig _remoteConfig;
  
  // Default value
  final isRegisterEnabled = false.obs;

  Future<FirebaseConfigService> init() async {
    // Only initialize on iOS, as Android doesn't have google-services.json
    if (Platform.isIOS) {
      try {
        await Firebase.initializeApp();
        
        _remoteConfig = FirebaseRemoteConfig.instance;
        
        await _remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1), // Decrease during testing
        ));

        // Set default value
        await _remoteConfig.setDefaults(const {
          "registration_enabled": false,
        });

        // Fetch and activate
        await _remoteConfig.fetchAndActivate();
        
        // Update observable
        isRegisterEnabled.value = _remoteConfig.getBool("registration_enabled");
        
        debugPrint("Firebase Remote Config registration_enabled: ${isRegisterEnabled.value}");
      } catch (e) {
        debugPrint("Failed to initialize Firebase on iOS: $e");
      }
    }
    
    return this;
  }
}
