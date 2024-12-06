import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/localization/quizLocalizationCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizzone_category_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

Future<void> showQuizLanguageSelectorSheet(BuildContext context) async {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: UiUtils.bottomSheetTopRadius,
    ),
    builder: (_) => const _QuizLanguageSelectorWidget(),
  );
}

class _QuizLanguageSelectorWidget extends StatelessWidget {
  const _QuizLanguageSelectorWidget();

  @override
  Widget build(BuildContext context) {
    final supportedLanguages =
        context.read<SystemConfigCubit>().getSupportedLanguages();

    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      padding: EdgeInsets.only(top: size.height * .02),
      child: BlocConsumer<QuizLanguageCubit, QuizLanguageState>(
        listener: (context, state) {
          final currLanguageId = UiUtils.getCurrentQuizLanguageId(context);

          context.read<QuizCategoryCubit>().getQuizCategoryWithUserId(
                languageId: currLanguageId,
                type: UiUtils.getCategoryTypeNumberFromQuizType(
                  QuizTypes.quizZone,
                ),
              );
          context
              .read<QuizoneCategoryCubit>()
              .getQuizCategoryWithUserId(languageId: currLanguageId);

          context.read<ContestCubit>().getContest(languageId: currLanguageId);
        },
        builder: (context, state) {
          final textStyle = TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onTertiary,
          );

          var currLang = state.languageCode;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * UiUtils.hzMarginPct,
            ),
            child: Column(
              children: [
                Text(
                  context.tr('quizLanguage') ?? 'quizLanguage',
                  style: textStyle,
                ),
                const Divider(),
                Container(
                  margin: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minHeight: size.height * .2,
                    maxHeight: size.height * .4,
                  ),
                  child: ListView.separated(
                    itemBuilder: (_, i) {
                      final supportedLanguage = supportedLanguages[i];
                      final languageCode =
                          UiUtils.getQuizLocaleFromLanguageCode(
                        supportedLanguage.languageCode,
                      );

                      final colorScheme = Theme.of(context).colorScheme;

                      return Container(
                        decoration: BoxDecoration(
                          color: currLang == languageCode
                              ? Theme.of(context).primaryColor
                              : colorScheme.onTertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RadioListTile(
                          toggleable: true,
                          activeColor: Colors.white,
                          value: languageCode,
                          title: Text(
                            supportedLanguage.language,
                            style: textStyle.copyWith(
                              color: currLang == languageCode
                                  ? Colors.white
                                  : colorScheme.onTertiary,
                            ),
                          ),
                          groupValue: currLang,
                          onChanged: (value) {
                            currLang = value!;

                            if (state.languageCode != languageCode) {
                              context
                                  .read<QuizLanguageCubit>()
                                  .changeQuizLanguage(
                                    supportedLanguage.languageCode,
                                  );
                            }
                          },
                        ),
                      );
                    },
                    separatorBuilder: (_, i) => const SizedBox(height: 12),
                    itemCount: supportedLanguages.length,
                  ),
                ),
                const Spacer(),
                CustomRoundedButton(
                  onTap: Navigator.of(context).pop,
                  widthPercentage: 1,
                  backgroundColor: Theme.of(context).primaryColor,
                  buttonTitle: context.tr('save'),
                  radius: 8,
                  showBorder: false,
                  height: 45,
                ),
                const Expanded(child: SizedBox(height: 20)),
              ],
            ),
          );
        },
      ),
    );
  }
}
