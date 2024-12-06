import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/app_localization.dart';
import 'package:flutterquiz/features/localization/appLocalizationCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

Future<void> showLanguageSelectorSheet(
  BuildContext context,
  VoidCallback onChange,
) async {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: UiUtils.bottomSheetTopRadius,
    ),
    builder: (_) => _LanguageSelectorWidget(onChange),
  );
}

class _LanguageSelectorWidget extends StatelessWidget {
  const _LanguageSelectorWidget(this.onChange);

  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final supportedLanguages =
        context.read<SystemConfigCubit>().getSupportedLanguageList();

    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      padding: EdgeInsets.only(top: size.height * .02),
      child: BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
        bloc: context.read<AppLocalizationCubit>(),
        builder: (context, state) {
          final textStyle = TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onTertiary,
          );

          var currLang = state.language;

          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * UiUtils.hzMarginPct,
            ),
            child: Column(
              children: [
                /// Title
                Text(context.tr('language')!, style: textStyle),
                const Divider(),

                /// Supported Languages
                Container(
                  margin: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minHeight: size.height * .2,
                    maxHeight: size.height * .4,
                  ),
                  child: ListView.separated(
                    itemBuilder: (_, i) {
                      final supportedLanguage = supportedLanguages[i];

                      final locale = supportedLanguage.name;

                      final colorScheme = Theme.of(context).colorScheme;

                      return Container(
                        decoration: BoxDecoration(
                          color: currLang == locale
                              ? Theme.of(context).primaryColor
                              : colorScheme.onTertiary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: RadioListTile(
                          toggleable: true,
                          activeColor: Colors.white,
                          value: locale,
                          title: Text(
                            supportedLanguage.name,
                            style: textStyle.copyWith(
                              color: currLang == locale
                                  ? Colors.white
                                  : colorScheme.onTertiary,
                            ),
                          ),
                          groupValue: currLang,
                          onChanged: (value) async {
                            if (value == null) return;

                            currLang = value;

                            if (state.language != locale) {
                              await AppLocalization().changeLanguage(currLang);
                              context
                                  .read<AppLocalizationCubit>()
                                  .changeLanguage(
                                    supportedLanguage.name,
                                    isRTL: supportedLanguage.isRTL,
                                  );
                              onChange();
                            }
                          },
                        ),
                      );
                    },
                    separatorBuilder: (_, i) => const SizedBox(height: 12),
                    itemCount: supportedLanguages.length,
                  ),
                ),

                ///
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
