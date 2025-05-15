// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:readify/bloc/language/language_bloc.dart';
import 'package:readify/bloc/language/language_event.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = context.watch<LanguageBloc>().state.locale;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'en',
          child: Text('English', 
              style: TextStyle(
                color: currentLocale.languageCode == 'en' 
                    ? Colors.blue 
                    : null)),
        ),
        PopupMenuItem(
          value: 'ru',
          child: Text('Русский',
              style: TextStyle(
                color: currentLocale.languageCode == 'ru' 
                    ? Colors.blue 
                    : null)),
        ),
        PopupMenuItem(
          value: 'kk',
          child: Text('Қазақша',
              style: TextStyle(
                color: currentLocale.languageCode == 'kk' 
                    ? Colors.blue 
                    : null)),
        ),
      ],
      onSelected: (languageCode) {
        context.read<LanguageBloc>().add(ChangeLanguage(languageCode));
      },
    );
  }
}