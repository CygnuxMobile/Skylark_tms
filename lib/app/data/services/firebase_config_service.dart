import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class FirebaseConfigService extends GetxService {
  late FirebaseRemoteConfig _remoteConfig;
  
  // Default values
  final isRegisterEnabled = false.obs;
  final isDeleteEnabled = false.obs;

  Future<FirebaseConfigService> init() async {
    // Only initialize on iOS, as Android doesn't have google-services.json
    if (Platform.isIOS) {
      isRegisterEnabled.value = true;
      isDeleteEnabled.value = true;
      try {
        await Firebase.initializeApp();
        
        _remoteConfig = FirebaseRemoteConfig.instance;
        
        await _remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Duration.zero, // Set to zero to fetch latest changes immediately
        ));

        // Set default values
        await _remoteConfig.setDefaults(const {
          "registration_enabled": true,
          "delete_account_enabled": true,
        });

        // Fetch and activate
        await _remoteConfig.fetchAndActivate();
        
        // Update observables
        isRegisterEnabled.value = _remoteConfig.getBool("registration_enabled");
        isDeleteEnabled.value = _remoteConfig.getBool("delete_account_enabled");
        
        debugPrint("Firebase Remote Config: registration_enabled=${isRegisterEnabled.value}, delete_account_enabled=${isDeleteEnabled.value}");
      } catch (e) {
        debugPrint("Failed to initialize Firebase on iOS: $e");
      }
    }
    
    return this;
  }
}
