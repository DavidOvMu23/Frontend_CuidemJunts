// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get selectLanguage => 'Seleccione un idioma:';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageCatalan => 'Catalán';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get welcome => 'Bienvenido a CuidemJunts';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordSnackbar =>
      'Contacta a un supervisor para recuperar tu contraseña.';

  @override
  String get preferences => 'Preferencias';

  @override
  String get mainPage => 'Página principal';

  @override
  String get appPreferences => 'Preferencias de la app';

  @override
  String get mainMenu => 'Menu Principal';

  @override
  String get lenguagePreferences => 'Idioma de preferencia';

  @override
  String get theme => 'Tema';
}
