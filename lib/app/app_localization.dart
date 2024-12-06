import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutterquiz/features/settings/settingsLocalDataSource.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalization {
  String locale = SettingsLocalDataSource().languageCode;
  static var localizedValues = <String, String>{};
  bool isRTL = false;

  static const String dataKey = 'language_data';
  static const String versionKey = 'language_version';
  static const String rtlKey = 'language_rtl';
  static const String apiUrl = '${baseUrl}get_system_language_json';

  Future<void> loadLanguage() async {
    try {
      final file = await getLanguageFile();
      final prefs = await SharedPreferences.getInstance();
      final storedVersion = prefs.getString(versionKey);
      isRTL = prefs.getBool(rtlKey) ?? false;

      if (file.existsSync()) {
        final jsonString = await file.readAsString();
        final decodedData = jsonDecode(jsonString) as Map<String, dynamic>;
        localizedValues =
            decodedData.map((key, value) => MapEntry(key, value.toString()));

        final newVersion = await fetchVersionFromAPI();
        if (newVersion != storedVersion) {
          if (kDebugMode) {
            print('Version changed. Fetching new data from API.');
          }
          await fetchAndStoreLanguageData();
        } else {
          if (kDebugMode) {
            print('Language data loaded from local file: $localizedValues');
          }
        }
      } else {
        await fetchAndStoreLanguageData();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading language: $e');
      }
      await loadFromAsset();
    }
  }

  Future<String?> fetchVersionFromAPI() async {
    try {
      final requestBody = {
        'from': '1',
        'language': locale,
      };
      final response = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
        headers: await ApiUtils.getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonData['error'] == false && jsonData['version'] != null) {
          return jsonData['version'] as String?;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching version from API: $e');
      }
    }
    return null;
  }

  Future<void> changeLanguage(String languageName) async {
    final (:version, :isRTL, :languageData) =
        await fetchLanguageData(languageName);

    localizedValues = languageData;
    locale = languageName;
    await storeLanguageData(localizedValues, version, isRTL: isRTL);
    await saveLanguageToFile(languageData);
  }

  Future<
      ({
        String version,
        bool isRTL,
        Map<String, String> languageData,
      })> fetchLanguageData(String languageName) async {
    try {
      final body = {
        'from': '1',
        'language': languageName,
      };

      final response = await http.post(Uri.parse(apiUrl), body: body);

      if (response.statusCode != 200) {
        throw Exception(response.reasonPhrase);
      }

      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

      if (jsonData['error'] as bool) {
        throw Exception(jsonData['message'] as String);
      }

      final version = jsonData['version'] as String;
      final isRTL = (jsonData['rtl_support'] as String) == '1';
      final languageData = (jsonData['data'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v.toString()));

      return (version: version, isRTL: isRTL, languageData: languageData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchAndStoreLanguageData() async {
    try {
      final requestBody = {
        'from': '1',
        'language': locale,
      };
      final response = await http.post(
        Uri.parse(apiUrl),
        body: requestBody,
        headers: await ApiUtils.getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        if (jsonData['error'] == false && jsonData['data'] != null) {
          final languageData = (jsonData['data'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, v.toString()));
          final newVersion = jsonData['version'] as String;
          final isRTL = (jsonData['rtl_support'] as String) == '1';

          localizedValues = languageData;

          await storeLanguageData(localizedValues, newVersion, isRTL: isRTL);
          await saveLanguageToFile(languageData);
          if (kDebugMode) {
            print('Language data saved to file and preferences');
          }
        } else {
          throw Exception(
            'Failed to load language data from API: ${jsonData['message']}',
          );
        }
      } else {
        throw Exception(
          'Failed to load language data from API: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching language data from API: $e');
      }
      await loadFromAsset();
    }
  }

  Future<void> loadFromAsset() async {
    final jsonStringValues =
        await rootBundle.loadString('assets/languages/$locale.json');

    localizedValues = (jsonDecode(jsonStringValues) as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> storeLanguageData(
    Map<String, String> data,
    String version, {
    required bool isRTL,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dataKey, jsonEncode(data));
    await prefs.setString(versionKey, version); // Store the version
    await prefs.setBool(rtlKey, isRTL);
    if (kDebugMode) {
      print('Language data and version stored in SharedPreferences');
    }
  }

  Future<void> saveLanguageToFile(Map<String, dynamic> data) async {
    try {
      final file = await getLanguageFile();
      final jsonString = jsonEncode(data);

      // Overwrite file with new data
      await file.writeAsString(jsonString);
      if (kDebugMode) {
        print('Language data saved to file: ${file.path}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving language to file: $e');
      }
    }
  }

  Future<File> getLanguageFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$locale.json';
    return File(filePath);
  }

  static String? tr(String? key) {
    return localizedValues[key];
  }
}
