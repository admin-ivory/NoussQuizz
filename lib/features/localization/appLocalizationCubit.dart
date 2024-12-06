import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/settings/settingsLocalDataSource.dart';
import 'package:flutterquiz/utils/constants/constants.dart';

class AppLocalizationState {
  AppLocalizationState(this.language, {required this.isRTL});

  final String language;
  final bool isRTL;
}

class AppLocalizationCubit extends Cubit<AppLocalizationState> {
  AppLocalizationCubit(this.settingsLocalDataSource)
      : super(AppLocalizationState(defaultLanguageCode, isRTL: false)) {
    changeLanguage(
      settingsLocalDataSource.languageCode,
      isRTL: settingsLocalDataSource.languageRTL,
    );
  }

  final SettingsLocalDataSource settingsLocalDataSource;

  void changeLanguage(String languageCode, {required bool isRTL}) {
    settingsLocalDataSource
      ..languageCode = languageCode
      ..languageRTL = isRTL;

    emit(AppLocalizationState(languageCode, isRTL: isRTL));
  }
}
