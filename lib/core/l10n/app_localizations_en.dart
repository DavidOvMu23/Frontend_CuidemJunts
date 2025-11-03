// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get selectLanguage => 'Select a language:';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageCatalan => 'Catalan';

  @override
  String get languageEnglish => 'English';

  @override
  String get welcome => 'Welcome to CuidemJunts';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Log in';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get forgotPasswordSnackbar =>
      'Contact a supervisor to recover your password.';
}
