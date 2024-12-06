import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/settings/settingsLocalDataSource.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

class QuizLanguageState {
  QuizLanguageState(this.languageCode);
  final Locale languageCode;
}

class QuizLanguageCubit extends Cubit<QuizLanguageState> {
  QuizLanguageCubit(this.settingsLocalDataSource)
      : super(
          QuizLanguageState(
            UiUtils.getQuizLocaleFromLanguageCode(quizLanguageCodeKey),
          ),
        ) {
    changeQuizLanguage(settingsLocalDataSource.quizLanguageCode);
  }
  final SettingsLocalDataSource settingsLocalDataSource;

  void changeQuizLanguage(String languageCode) {
    settingsLocalDataSource.quizLanguageCode = languageCode;
    emit(
      QuizLanguageState(UiUtils.getQuizLocaleFromLanguageCode(languageCode)),
    );
  }
}
