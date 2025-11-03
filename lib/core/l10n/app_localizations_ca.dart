// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get selectLanguage => 'Seleccioneu un idioma:';

  @override
  String get languageSpanish => 'Castellà';

  @override
  String get languageCatalan => 'Català';

  @override
  String get languageEnglish => 'Anglès';

  @override
  String get welcome => 'Benvinguts a CuidemJunts';

  @override
  String get email => 'Correu electrònic';

  @override
  String get password => 'Contrasenya';

  @override
  String get loginButton => 'Inicia sessió';

  @override
  String get forgotPassword => 'Has oblidat la teva contrasenya?';

  @override
  String get forgotPasswordSnackbar =>
      'Parla amb un supervisor per recuperar la teva contrasenya.';
}
