import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'Seleccione un idioma:'**
  String get selectLanguage;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageCatalan.
  ///
  /// In es, this message translates to:
  /// **'Catalán'**
  String get languageCatalan;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get languageEnglish;

  /// No description provided for @welcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a CuidemJunts'**
  String get welcome;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu cuenta?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Contacta a un supervisor para recuperar tu cuenta.'**
  String get forgotPasswordSnackbar;

  /// No description provided for @preferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferences;

  /// No description provided for @mainPage.
  ///
  /// In es, this message translates to:
  /// **'Página principal'**
  String get mainPage;

  /// No description provided for @appPreferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias de la app'**
  String get appPreferences;

  /// No description provided for @mainMenu.
  ///
  /// In es, this message translates to:
  /// **'Menu Principal'**
  String get mainMenu;

  /// No description provided for @lenguagePreferences.
  ///
  /// In es, this message translates to:
  /// **'Idioma de preferencia'**
  String get lenguagePreferences;

  /// No description provided for @theme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @supervisonPanel.
  ///
  /// In es, this message translates to:
  /// **'Panel de Supervisión'**
  String get supervisonPanel;

  /// No description provided for @programedCalls.
  ///
  /// In es, this message translates to:
  /// **'Llamadas programadas hoy'**
  String get programedCalls;

  /// No description provided for @completedCalls.
  ///
  /// In es, this message translates to:
  /// **'Completadas hoy'**
  String get completedCalls;

  /// No description provided for @todayCalls.
  ///
  /// In es, this message translates to:
  /// **'Llamadas de hoy'**
  String get todayCalls;

  /// No description provided for @nothingTodayCalls.
  ///
  /// In es, this message translates to:
  /// **'No hay llamadas programadas para hoy'**
  String get nothingTodayCalls;

  /// No description provided for @activityRecent.
  ///
  /// In es, this message translates to:
  /// **'Actividad reciente'**
  String get activityRecent;

  /// No description provided for @supervison.
  ///
  /// In es, this message translates to:
  /// **'Supervisión'**
  String get supervison;

  /// No description provided for @users.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get users;

  /// No description provided for @telemarketers.
  ///
  /// In es, this message translates to:
  /// **'Teleoperadores'**
  String get telemarketers;

  /// No description provided for @notifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notifications;

  /// No description provided for @logOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logOut;

  /// No description provided for @superviseCalls.
  ///
  /// In es, this message translates to:
  /// **'Supervisa todas las llamadas de los teleoperadores'**
  String get superviseCalls;

  /// No description provided for @searchUsers.
  ///
  /// In es, this message translates to:
  /// **'Buscar usuarios'**
  String get searchUsers;

  /// No description provided for @searchWorkers.
  ///
  /// In es, this message translates to:
  /// **'Buscar trabajador'**
  String get searchWorkers;

  /// No description provided for @all.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get all;

  /// No description provided for @filterDate.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por fecha'**
  String get filterDate;

  /// No description provided for @initDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha desde'**
  String get initDate;

  /// No description provided for @endDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha hasta'**
  String get endDate;

  /// No description provided for @completed.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get completed;

  /// No description provided for @noAnswer.
  ///
  /// In es, this message translates to:
  /// **'No contestó'**
  String get noAnswer;

  /// No description provided for @pending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get pending;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// No description provided for @duration.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get duration;

  /// No description provided for @comments.
  ///
  /// In es, this message translates to:
  /// **'Observaciones'**
  String get comments;

  /// No description provided for @topicsCovered.
  ///
  /// In es, this message translates to:
  /// **'Temas tratados'**
  String get topicsCovered;

  /// No description provided for @manageUsers.
  ///
  /// In es, this message translates to:
  /// **'Gestiona los perfiles de las personas'**
  String get manageUsers;

  /// No description provided for @newUser.
  ///
  /// In es, this message translates to:
  /// **'Nuevo usuario'**
  String get newUser;

  /// No description provided for @mild.
  ///
  /// In es, this message translates to:
  /// **'Leve'**
  String get mild;

  /// No description provided for @moderate.
  ///
  /// In es, this message translates to:
  /// **'Moderada'**
  String get moderate;

  /// No description provided for @grave.
  ///
  /// In es, this message translates to:
  /// **'Grave'**
  String get grave;

  /// No description provided for @active.
  ///
  /// In es, this message translates to:
  /// **'Activo'**
  String get active;

  /// No description provided for @workers.
  ///
  /// In es, this message translates to:
  /// **'Trabajadores'**
  String get workers;

  /// No description provided for @manageWorkers.
  ///
  /// In es, this message translates to:
  /// **'Gestiona los perfiles de los trabajadores y sus permisos'**
  String get manageWorkers;

  /// No description provided for @newWorker.
  ///
  /// In es, this message translates to:
  /// **'Nuevo trabajador'**
  String get newWorker;

  /// No description provided for @usersAsigned.
  ///
  /// In es, this message translates to:
  /// **'Usuarios asignados'**
  String get usersAsigned;

  /// No description provided for @add.
  ///
  /// In es, this message translates to:
  /// **'Añadir'**
  String get add;

  /// No description provided for @activeSince.
  ///
  /// In es, this message translates to:
  /// **'Activo desde:'**
  String get activeSince;

  /// No description provided for @unread.
  ///
  /// In es, this message translates to:
  /// **'Sin leer'**
  String get unread;

  /// No description provided for @read.
  ///
  /// In es, this message translates to:
  /// **'Leído'**
  String get read;

  /// No description provided for @calls.
  ///
  /// In es, this message translates to:
  /// **'Llamadas'**
  String get calls;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirmLogOut.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas cerrar sesión?'**
  String get confirmLogOut;

  /// No description provided for @supervisor.
  ///
  /// In es, this message translates to:
  /// **'Supervisor'**
  String get supervisor;

  /// No description provided for @enero.
  ///
  /// In es, this message translates to:
  /// **'enero'**
  String get enero;

  /// No description provided for @febrero.
  ///
  /// In es, this message translates to:
  /// **'febrero'**
  String get febrero;

  /// No description provided for @marzo.
  ///
  /// In es, this message translates to:
  /// **'marzo'**
  String get marzo;

  /// No description provided for @abril.
  ///
  /// In es, this message translates to:
  /// **'abril'**
  String get abril;

  /// No description provided for @mayo.
  ///
  /// In es, this message translates to:
  /// **'mayo'**
  String get mayo;

  /// No description provided for @junio.
  ///
  /// In es, this message translates to:
  /// **'junio'**
  String get junio;

  /// No description provided for @julio.
  ///
  /// In es, this message translates to:
  /// **'julio'**
  String get julio;

  /// No description provided for @agosto.
  ///
  /// In es, this message translates to:
  /// **'agosto'**
  String get agosto;

  /// No description provided for @septiembre.
  ///
  /// In es, this message translates to:
  /// **'septiembre'**
  String get septiembre;

  /// No description provided for @octubre.
  ///
  /// In es, this message translates to:
  /// **'octubre'**
  String get octubre;

  /// No description provided for @noviembre.
  ///
  /// In es, this message translates to:
  /// **'noviembre'**
  String get noviembre;

  /// No description provided for @diciembre.
  ///
  /// In es, this message translates to:
  /// **'diciembre'**
  String get diciembre;

  /// No description provided for @lunes.
  ///
  /// In es, this message translates to:
  /// **'lunes'**
  String get lunes;

  /// No description provided for @martes.
  ///
  /// In es, this message translates to:
  /// **'martes'**
  String get martes;

  /// No description provided for @miercoles.
  ///
  /// In es, this message translates to:
  /// **'miércoles'**
  String get miercoles;

  /// No description provided for @jueves.
  ///
  /// In es, this message translates to:
  /// **'jueves'**
  String get jueves;

  /// No description provided for @viernes.
  ///
  /// In es, this message translates to:
  /// **'viernes'**
  String get viernes;

  /// No description provided for @sabado.
  ///
  /// In es, this message translates to:
  /// **'sábado'**
  String get sabado;

  /// No description provided for @domingo.
  ///
  /// In es, this message translates to:
  /// **'domingo'**
  String get domingo;

  /// No description provided for @nothingActivityRecent.
  ///
  /// In es, this message translates to:
  /// **'No hay actividad reciente'**
  String get nothingActivityRecent;

  /// No description provided for @searchUser.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o teléfono'**
  String get searchUser;

  /// No description provided for @searchAllUsers.
  ///
  /// In es, this message translates to:
  /// **'Todos los usuarios'**
  String get searchAllUsers;

  /// No description provided for @searchAllWorkers.
  ///
  /// In es, this message translates to:
  /// **'Todos los trabajadores'**
  String get searchAllWorkers;

  /// No description provided for @searchActiveUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios activos'**
  String get searchActiveUsers;

  /// No description provided for @searchInactiveUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios inactivos'**
  String get searchInactiveUsers;

  /// No description provided for @searchModerateDependency.
  ///
  /// In es, this message translates to:
  /// **'Dep. moderada (Grado I)'**
  String get searchModerateDependency;

  /// No description provided for @searchSevereDependency.
  ///
  /// In es, this message translates to:
  /// **'Dep. severa (Grado II)'**
  String get searchSevereDependency;

  /// No description provided for @searchHighDependency.
  ///
  /// In es, this message translates to:
  /// **'Gran dependencia (Grado III)'**
  String get searchHighDependency;

  /// No description provided for @sortNameZA.
  ///
  /// In es, this message translates to:
  /// **'Nombre Z-A'**
  String get sortNameZA;

  /// No description provided for @sortNameAZ.
  ///
  /// In es, this message translates to:
  /// **'Nombre A-Z'**
  String get sortNameAZ;

  /// No description provided for @sortBirthdateYoungOld.
  ///
  /// In es, this message translates to:
  /// **'Por fecha de nacimiento (más joven a mayor)'**
  String get sortBirthdateYoungOld;

  /// No description provided for @sortBirthdateOldYoung.
  ///
  /// In es, this message translates to:
  /// **'Por fecha de nacimiento (más mayor a joven)'**
  String get sortBirthdateOldYoung;

  /// No description provided for @sortDependencyLowHigh.
  ///
  /// In es, this message translates to:
  /// **'Por nivel de dependencia (bajo a alto)'**
  String get sortDependencyLowHigh;

  /// No description provided for @sortDependencyHighLow.
  ///
  /// In es, this message translates to:
  /// **'Por nivel de dependencia (alto a bajo)'**
  String get sortDependencyHighLow;

  /// No description provided for @usersFound.
  ///
  /// In es, this message translates to:
  /// **'Usuarios encontrados:'**
  String get usersFound;

  /// No description provided for @workersFound.
  ///
  /// In es, this message translates to:
  /// **'Trabajadores encontrados:'**
  String get workersFound;

  /// No description provided for @noUsersFound.
  ///
  /// In es, this message translates to:
  /// **'Usuarios no encontrado'**
  String get noUsersFound;

  /// No description provided for @totalUsers.
  ///
  /// In es, this message translates to:
  /// **'Total de usuarios'**
  String get totalUsers;

  /// No description provided for @totalWorkers.
  ///
  /// In es, this message translates to:
  /// **'Total de trabajadores'**
  String get totalWorkers;

  /// No description provided for @sortType.
  ///
  /// In es, this message translates to:
  /// **'Mostrar por orden'**
  String get sortType;

  /// No description provided for @noSortedUsers.
  ///
  /// In es, this message translates to:
  /// **'Ordenación predeterminada (Nombre A-Z)'**
  String get noSortedUsers;

  /// No description provided for @noSortedCalls.
  ///
  /// In es, this message translates to:
  /// **'Ordenación predeterminada (más recientes primero)'**
  String get noSortedCalls;

  /// No description provided for @sortedZASnackbar.
  ///
  /// In es, this message translates to:
  /// **'Usuarios ordenados por nombre Z-A.'**
  String get sortedZASnackbar;

  /// No description provided for @sortedAZSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Usuarios ordenados por nombre A-Z.'**
  String get sortedAZSnackbar;

  /// No description provided for @sortedDependencyLevelHighLow.
  ///
  /// In es, this message translates to:
  /// **'Usuarios ordenados por nivel de dependencia (alto a bajo).'**
  String get sortedDependencyLevelHighLow;

  /// No description provided for @sortedDependencyLevelLowHigh.
  ///
  /// In es, this message translates to:
  /// **'Usuarios ordenados por nivel de dependencia (bajo a alto).'**
  String get sortedDependencyLevelLowHigh;

  /// No description provided for @sortedStatusAccount.
  ///
  /// In es, this message translates to:
  /// **'Usuarios ordenados por estado de cuenta (activos a inactivos).'**
  String get sortedStatusAccount;

  /// No description provided for @callCompleted.
  ///
  /// In es, this message translates to:
  /// **'Completada'**
  String get callCompleted;

  /// No description provided for @callNoAnswer.
  ///
  /// In es, this message translates to:
  /// **'No contestó'**
  String get callNoAnswer;

  /// No description provided for @callPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get callPending;

  /// No description provided for @sortCallDurationLongShort.
  ///
  /// In es, this message translates to:
  /// **'Duración de llamada (larga a corta)'**
  String get sortCallDurationLongShort;

  /// No description provided for @sortCallDurationShortLong.
  ///
  /// In es, this message translates to:
  /// **'Duración de llamada (corta a larga)'**
  String get sortCallDurationShortLong;

  /// No description provided for @searchCalls.
  ///
  /// In es, this message translates to:
  /// **'Buscar por usuario, teleoperador o número de teléfono'**
  String get searchCalls;

  /// No description provided for @allCalls.
  ///
  /// In es, this message translates to:
  /// **'Todas las llamadas'**
  String get allCalls;

  /// No description provided for @totalCalls.
  ///
  /// In es, this message translates to:
  /// **'Total de llamadas'**
  String get totalCalls;

  /// No description provided for @callsFound.
  ///
  /// In es, this message translates to:
  /// **'Llamadas encontradas:'**
  String get callsFound;

  /// No description provided for @errorUsersLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar los usuarios. Por favor, inténtalo de nuevo más tarde.'**
  String get errorUsersLoading;

  /// No description provided for @errorWorkersLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar los trabajadores. Por favor, inténtalo de nuevo más tarde.'**
  String get errorWorkersLoading;

  /// No description provided for @errorCallsLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar las llamadas. Por favor, inténtalo de nuevo más tarde.'**
  String get errorCallsLoading;

  /// No description provided for @errorNotificationsLoading.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar las notificaciones. Por favor, inténtalo de nuevo más tarde.'**
  String get errorNotificationsLoading;

  /// No description provided for @loginError.
  ///
  /// In es, this message translates to:
  /// **'Error de inicio de sesión. El correo electrónico o la contraseña son incorrectos.'**
  String get loginError;

  /// No description provided for @searchNoDependency.
  ///
  /// In es, this message translates to:
  /// **'Sin dependencia'**
  String get searchNoDependency;

  /// No description provided for @sortDateBirthNewest.
  ///
  /// In es, this message translates to:
  /// **'Por fecha de nacimiento (más joven a mayor)'**
  String get sortDateBirthNewest;

  /// No description provided for @sortDateBirthOldest.
  ///
  /// In es, this message translates to:
  /// **'Por fecha de nacimiento (más mayor a joven)'**
  String get sortDateBirthOldest;

  /// No description provided for @sortedDateBirthNewest.
  ///
  /// In es, this message translates to:
  /// **'Usuarios ordenados por fecha de nacimiento (más joven a mayor).'**
  String get sortedDateBirthNewest;

  /// No description provided for @sortedDateBirthOldest.
  ///
  /// In es, this message translates to:
  /// **'Usuarios ordenados por fecha de nacimiento (más mayor a joven).'**
  String get sortedDateBirthOldest;

  /// No description provided for @createUser.
  ///
  /// In es, this message translates to:
  /// **'Crear usuario'**
  String get createUser;

  /// No description provided for @createUserDescription.
  ///
  /// In es, this message translates to:
  /// **'Rellena el siguiente formulario para crear un nuevo usuario.'**
  String get createUserDescription;

  /// No description provided for @errorCrateUserBirthday.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario. La fecha de nacimiento no puede estar vacía'**
  String get errorCrateUserBirthday;

  /// No description provided for @errorCreateUSerBurthdayFuture.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario. La fecha de nacimiento no puede estar en el futuro.'**
  String get errorCreateUSerBurthdayFuture;

  /// No description provided for @errorCreateUserDNI.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario. El DNI no puede estar vacío.'**
  String get errorCreateUserDNI;

  /// No description provided for @errorCreateUSerDNILength.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario. El DNI debe tener 9 caracteres.'**
  String get errorCreateUSerDNILength;

  /// No description provided for @errorCreateUserName.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario. El nombre no puede estar vacío.'**
  String get errorCreateUserName;

  /// No description provided for @errorCreateUserLastName.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario. Los apellidos no pueden estar vacíos.'**
  String get errorCreateUserLastName;

  /// No description provided for @errorCreateUserPhone.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario. El teléfono no puede estar vacío.'**
  String get errorCreateUserPhone;

  /// No description provided for @errorCreateUserPhoneLength.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario. El teléfono debe tener 9 dígitos.'**
  String get errorCreateUserPhoneLength;

  /// No description provided for @errorCreateUserInformation.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario. La información no puede estar vacía.'**
  String get errorCreateUserInformation;

  /// No description provided for @errorCreateUserDependency.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario. Debes seleccionar un nivel de dependencia.'**
  String get errorCreateUserDependency;

  /// No description provided for @userCreatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Usuario creado con éxito.'**
  String get userCreatedSuccess;

  /// No description provided for @userCreatedError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario.'**
  String get userCreatedError;

  /// No description provided for @userUpdatedSuccess.
  ///
  /// In es, this message translates to:
  /// **'Usuario actualizado con éxito.'**
  String get userUpdatedSuccess;

  /// No description provided for @userUpdatedError.
  ///
  /// In es, this message translates to:
  /// **'Error al actualizar el usuario.'**
  String get userUpdatedError;

  /// No description provided for @userErrorDNiExists.
  ///
  /// In es, this message translates to:
  /// **'Error al crear el usuario. El DNI ya existe.'**
  String get userErrorDNiExists;

  /// No description provided for @dni.
  ///
  /// In es, this message translates to:
  /// **'DNI'**
  String get dni;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get name;

  /// No description provided for @lastName.
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get lastName;

  /// No description provided for @birthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get birthDate;

  /// No description provided for @selectBirthDate.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la fecha de nacimiento'**
  String get selectBirthDate;

  /// No description provided for @information.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get information;

  /// No description provided for @dependencyLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel de dependencia'**
  String get dependencyLevel;

  /// No description provided for @medicalData.
  ///
  /// In es, this message translates to:
  /// **'Datos médicos / dolencias (opcional)'**
  String get medicalData;

  /// No description provided for @medication.
  ///
  /// In es, this message translates to:
  /// **'Medicación (opcional)'**
  String get medication;

  /// No description provided for @telephone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get telephone;

  /// No description provided for @direction.
  ///
  /// In es, this message translates to:
  /// **'Dirección (opcional)'**
  String get direction;

  /// No description provided for @createUserButton.
  ///
  /// In es, this message translates to:
  /// **'Crear usuario'**
  String get createUserButton;

  /// No description provided for @none.
  ///
  /// In es, this message translates to:
  /// **'Ninguna'**
  String get none;

  /// No description provided for @optionalData.
  ///
  /// In es, this message translates to:
  /// **'Datos opcionales'**
  String get optionalData;

  /// No description provided for @noUsersFounds.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron usuarios'**
  String get noUsersFounds;

  /// No description provided for @usersPreliminarView.
  ///
  /// In es, this message translates to:
  /// **'Vista preliminar: toca un usuario para ver toda su información.'**
  String get usersPreliminarView;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
