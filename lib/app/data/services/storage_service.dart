import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skylark/app/core/values/app_constants.dart';
import 'package:skylark/app/data/models/location_model.dart';
import 'package:skylark/app/data/models/login_response_model.dart';

class StorageService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  Future<void> saveUser(LoginData user) async {
    await _prefs.setString(AppConstants.userDataKey, jsonEncode(user.toJson()));
    await _prefs.setBool(AppConstants.isLoggedKey, true);
  }

  LoginData? getUser() {
    String? userStr = _prefs.getString(AppConstants.userDataKey);
    if (userStr != null) {
      return LoginData.fromJson(jsonDecode(userStr));
    }
    return null;
  }

  Future<void> saveLocation(LocationModel location) async {
    await _prefs.setString(AppConstants.selectedLocationKey, jsonEncode(location.toJson()));
  }

  LocationModel? getLocation() {
    String? locStr = _prefs.getString(AppConstants.selectedLocationKey);
    if (locStr != null) {
      return LocationModel.fromJson(jsonDecode(locStr));
    }
    return null;
  }

  Future<void> saveMenuAccess(List<dynamic> menuAccess) async {
    await _prefs.setString(AppConstants.menuAccessKey, jsonEncode(menuAccess));
  }

  List<dynamic> getMenuAccess() {
    String? menuStr = _prefs.getString(AppConstants.menuAccessKey);
    if (menuStr != null) {
      return jsonDecode(menuStr);
    }
    return [];
  }

  bool isLoggedIn() {
    return _prefs.getBool(AppConstants.isLoggedKey) ?? false;
  }

  Future<void> saveRegistrationData(Map<String, dynamic> data) async {
    List<dynamic> existingRegistrations = getLocalRegistrations();
    existingRegistrations.add(data);
    await _prefs.setString('registration_data_list', jsonEncode(existingRegistrations));
  }

  List<dynamic> getLocalRegistrations() {
    String? dataStr = _prefs.getString('registration_data_list');
    if (dataStr != null) {
      return jsonDecode(dataStr);
    }
    return [];
  }

  Future<void> saveLastTypedUsername(String username) async {
    await _prefs.setString('last_typed_username', username.toLowerCase());
  }

  String? getLastTypedUsername() {
    return _prefs.getString('last_typed_username');
  }

  Future<void> deleteAccount(String userId) async {
    final id = userId.toLowerCase();
    List<String> deletedAccounts = getDeletedAccounts();
    if (!deletedAccounts.contains(id)) {
      deletedAccounts.add(id);
      await _prefs.setStringList('deleted_accounts', deletedAccounts);
    }
  }

  List<String> getDeletedAccounts() {
    return _prefs.getStringList('deleted_accounts') ?? [];
  }

  bool isAccountDeleted(String userId) {
    return getDeletedAccounts().contains(userId.toLowerCase());
  }

  Future<void> clearStorage() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.userDataKey);
    await _prefs.remove(AppConstants.isLoggedKey);
    await _prefs.remove(AppConstants.selectedLocationKey);
    await _prefs.remove(AppConstants.menuAccessKey);
  }
}
