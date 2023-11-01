import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spend_sense/globalData.dart';

class StorageService {
  static const _keyAccounts = 'accounts';

  // Save the list of accounts to local storage
  static Future<void> saveAccounts(List<Account> accounts) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accountsJson = accounts.map((account) => account.toJson()).toList();
    await sharedPreferences.setString(_keyAccounts, jsonEncode(accountsJson));
  }

  // Load the list of accounts from local storage
  static Future<List<Account>?> loadAccounts() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accountsJson = sharedPreferences.getString(_keyAccounts);
    if (accountsJson != null) {
      final List<dynamic> decodedJson = jsonDecode(accountsJson);
      final List<Account> accounts = decodedJson
          .map((json) => Account.fromJson(json))
          .toList();
      return accounts;
    }
    return null; // Return null if no accounts are found in storage.
  }
}
