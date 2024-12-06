class SupportedLanguage {
  SupportedLanguage({
    required this.id,
    required this.language,
    required this.languageCode,
  });

  factory SupportedLanguage.fromJson(Map<String, dynamic> json) {
    return SupportedLanguage(
      id: json['id'] as String,
      language: json['language'] as String,
      languageCode: json['code'] as String,
    );
  }

  final String id;
  final String language;
  final String languageCode;
}

class SupportedAppLanguage {
  const SupportedAppLanguage({
    required this.name,
    required this.isRTL,
    required this.version,
  });

  SupportedAppLanguage.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        isRTL = (json['app_rtl_support'] as String) == '1',
        version = json['app_version'] as String;

  final String name;
  final bool isRTL;
  final String version;
}
