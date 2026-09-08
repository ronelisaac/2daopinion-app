import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'2daOpinion'**
  String get appTitle;

  /// No description provided for @designWordmark.
  ///
  /// In es, this message translates to:
  /// **'2nd opinion'**
  String get designWordmark;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Iniciando tu segunda opinión médica'**
  String get loading;

  /// No description provided for @initializationFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos iniciar la aplicación. Comprueba tu conexión e inténtalo de nuevo.'**
  String get initializationFailed;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'REINTENTAR'**
  String get retry;

  /// No description provided for @welcome.
  ///
  /// In es, this message translates to:
  /// **'¡Estás a un paso de\nunirte a 2nd opinion!'**
  String get welcome;

  /// No description provided for @facebook.
  ///
  /// In es, this message translates to:
  /// **'Ingresar con Facebook'**
  String get facebook;

  /// No description provided for @google.
  ///
  /// In es, this message translates to:
  /// **'Ingresar con Google'**
  String get google;

  /// No description provided for @emailAccess.
  ///
  /// In es, this message translates to:
  /// **'Usa tu correo electrónico'**
  String get emailAccess;

  /// No description provided for @terms.
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get terms;

  /// No description provided for @termsPending.
  ///
  /// In es, this message translates to:
  /// **'Los términos definitivos y los consentimientos clínicos están pendientes de aprobación. Este entorno admite únicamente pruebas; no envíes información clínica.'**
  String get termsPending;

  /// No description provided for @preview.
  ///
  /// In es, this message translates to:
  /// **'Vista previa · Usa solo datos ficticios'**
  String get preview;

  /// No description provided for @explore.
  ///
  /// In es, this message translates to:
  /// **'Explorar el diseño'**
  String get explore;

  /// No description provided for @accountTitle.
  ///
  /// In es, this message translates to:
  /// **'Regístrate o ingresa'**
  String get accountTitle;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'nombre@ejemplo.com'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// No description provided for @firstName.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In es, this message translates to:
  /// **'Tu apellido'**
  String get lastName;

  /// No description provided for @choosePassword.
  ///
  /// In es, this message translates to:
  /// **'Elige tu contraseña'**
  String get choosePassword;

  /// No description provided for @repeatPassword.
  ///
  /// In es, this message translates to:
  /// **'Repite tu contraseña'**
  String get repeatPassword;

  /// No description provided for @continueAction.
  ///
  /// In es, this message translates to:
  /// **'CONTINUAR'**
  String get continueAction;

  /// No description provided for @signIn.
  ///
  /// In es, this message translates to:
  /// **'Ingresar'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccount;

  /// No description provided for @requiredField.
  ///
  /// In es, this message translates to:
  /// **'Completa este campo.'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido.'**
  String get invalidEmail;

  /// No description provided for @shortPassword.
  ///
  /// In es, this message translates to:
  /// **'Usa al menos 8 caracteres.'**
  String get shortPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get passwordMismatch;

  /// No description provided for @previewTitle.
  ///
  /// In es, this message translates to:
  /// **'Solo vista previa'**
  String get previewTitle;

  /// No description provided for @accountPreview.
  ///
  /// In es, this message translates to:
  /// **'El formulario es válido. No se ha creado una cuenta ni iniciado una sesión. La autenticación es la siguiente entrega.'**
  String get accountPreview;

  /// No description provided for @pendingFeature.
  ///
  /// In es, this message translates to:
  /// **'Esta función todavía no está habilitada. No se ha enviado ni guardado información.'**
  String get pendingFeature;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'ENTENDIDO'**
  String get close;

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'¿En qué te podemos\nayudar?'**
  String get homeTitle;

  /// No description provided for @consultation.
  ///
  /// In es, this message translates to:
  /// **'Consulta médica'**
  String get consultation;

  /// No description provided for @consultationSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Solicita un médico para una segunda opinión'**
  String get consultationSubtitle;

  /// No description provided for @prescription.
  ///
  /// In es, this message translates to:
  /// **'Receta médica'**
  String get prescription;

  /// No description provided for @prescriptionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Dentro del MVP · Próximamente'**
  String get prescriptionSubtitle;

  /// No description provided for @requestTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva solicitud de consulta'**
  String get requestTitle;

  /// No description provided for @reason.
  ///
  /// In es, this message translates to:
  /// **'Motivo de tu consulta'**
  String get reason;

  /// No description provided for @reasonHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe el motivo de tu consulta'**
  String get reasonHint;

  /// No description provided for @details.
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico o detalles de la consulta'**
  String get details;

  /// No description provided for @detailsHint.
  ///
  /// In es, this message translates to:
  /// **'Describe tu consulta y tus preguntas'**
  String get detailsHint;

  /// No description provided for @medicines.
  ///
  /// In es, this message translates to:
  /// **'Tratamiento con medicamentos'**
  String get medicines;

  /// No description provided for @medicinesHint.
  ///
  /// In es, this message translates to:
  /// **'Agrega medicamentos y horarios'**
  String get medicinesHint;

  /// No description provided for @specialTreatments.
  ///
  /// In es, this message translates to:
  /// **'Tratamientos especiales'**
  String get specialTreatments;

  /// No description provided for @specialTreatmentsHint.
  ///
  /// In es, this message translates to:
  /// **'Agrega otros tratamientos'**
  String get specialTreatmentsHint;

  /// No description provided for @documents.
  ///
  /// In es, this message translates to:
  /// **'Exámenes y documentos'**
  String get documents;

  /// No description provided for @documentsHint.
  ///
  /// In es, this message translates to:
  /// **'Adjuntar exámenes médicos'**
  String get documentsHint;

  /// No description provided for @previousProposals.
  ///
  /// In es, this message translates to:
  /// **'Propuestas terapéuticas previas'**
  String get previousProposals;

  /// No description provided for @previousProposalsHint.
  ///
  /// In es, this message translates to:
  /// **'Agrega las propuestas recibidas'**
  String get previousProposalsHint;

  /// No description provided for @sendRequest.
  ///
  /// In es, this message translates to:
  /// **'ENVIAR SOLICITUD'**
  String get sendRequest;

  /// No description provided for @requestPreview.
  ///
  /// In es, this message translates to:
  /// **'Revisión local completada. Esta solicitud NO se ha enviado ni guardado. La carga privada de documentos y el envío real se implementarán con los permisos por caso.'**
  String get requestPreview;

  /// No description provided for @menu.
  ///
  /// In es, this message translates to:
  /// **'Menú'**
  String get menu;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// No description provided for @loadingPreview.
  ///
  /// In es, this message translates to:
  /// **'Ver pantalla de carga'**
  String get loadingPreview;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @backToWelcome.
  ///
  /// In es, this message translates to:
  /// **'Volver al acceso'**
  String get backToWelcome;

  /// No description provided for @previewLoadingNote.
  ///
  /// In es, this message translates to:
  /// **'Vista previa de la pantalla de carga'**
  String get previewLoadingNote;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'EDITAR'**
  String get edit;

  /// No description provided for @actionFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar la operación. Inténtalo de nuevo.'**
  String get actionFailed;

  /// No description provided for @actionCompleted.
  ///
  /// In es, this message translates to:
  /// **'Operación completada.'**
  String get actionCompleted;

  /// No description provided for @brandTagline.
  ///
  /// In es, this message translates to:
  /// **'Tu segunda opinión médica, desde donde estés.'**
  String get brandTagline;

  /// No description provided for @credentialsError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar el acceso. Revisa los datos; si ya tienes cuenta, ingresa o recupera tu contraseña.'**
  String get credentialsError;

  /// No description provided for @networkError.
  ///
  /// In es, this message translates to:
  /// **'No hay conexión con el servicio. Comprueba tu conexión y vuelve a intentarlo.'**
  String get networkError;

  /// No description provided for @throttledError.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera unos minutos antes de volver a intentarlo.'**
  String get throttledError;

  /// No description provided for @identityUnavailable.
  ///
  /// In es, this message translates to:
  /// **'El acceso por correo no está disponible en este momento.'**
  String get identityUnavailable;

  /// No description provided for @profileAccessError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos acceder a tu perfil. Inténtalo de nuevo; no se confirmó el guardado.'**
  String get profileAccessError;

  /// No description provided for @termsRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar las condiciones de este entorno de pruebas para continuar.'**
  String get termsRequired;

  /// No description provided for @profilePending.
  ///
  /// In es, this message translates to:
  /// **'Tu sesión está iniciada, pero falta completar y guardar tu perfil. No necesitas crear otra cuenta.'**
  String get profilePending;

  /// No description provided for @sessionExpired.
  ///
  /// In es, this message translates to:
  /// **'La sesión dejó de ser válida. Cierra sesión e ingresa nuevamente.'**
  String get sessionExpired;

  /// No description provided for @sessionLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos comprobar tu sesión o cargar el perfil. Reintenta o cierra sesión; no mostraremos datos sin verificarlos.'**
  String get sessionLoadFailed;

  /// No description provided for @developmentTermsNotice.
  ///
  /// In es, this message translates to:
  /// **'Solo pruebas de desarrollo. Los términos legales definitivos aún no están aprobados. No ingreses datos clínicos reales.'**
  String get developmentTermsNotice;

  /// No description provided for @readTerms.
  ///
  /// In es, this message translates to:
  /// **'Leer condiciones de prueba y privacidad'**
  String get readTerms;

  /// No description provided for @acceptDevelopmentTerms.
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto las condiciones del entorno de pruebas y su aviso de privacidad.'**
  String get acceptDevelopmentTerms;

  /// No description provided for @developmentTermsBody.
  ///
  /// In es, this message translates to:
  /// **'CONDICIONES DE ACCESO AL ENTORNO DE DESARROLLO\nVersión: dev-access-2026-09-08\n\nEsta aplicación está en desarrollo. Este texto es una condición de uso del entorno de pruebas, no los términos definitivos del servicio médico ni un consentimiento clínico aprobado.\n\nUsa únicamente identidades de prueba y tu correo de pruebas autorizado. No ingreses antecedentes, diagnósticos, exámenes ni otros datos clínicos reales. No hay atención médica, emisión de recetas, pagos ni envío real de solicitudes en esta versión.\n\nAl crear una cuenta se registran sus credenciales en Firebase Authentication y un perfil básico (nombre de prueba, apellido, país comercial e idioma) en Firestore. La contraseña no se guarda en el perfil. Se conserva la versión aceptada, el identificador de cuenta y la fecha de aceptación.\n\nLa sesión web se conserva durante la sesión del navegador; puedes cerrarla desde el menú. Los registros remotos permanecen para continuar las pruebas. El acceso al propio perfil está restringido por reglas; los operadores autorizados del proyecto pueden administrarlo.\n\nLa entidad responsable, canales formales de privacidad, plazos de conservación y términos comerciales definitivos están pendientes de aprobación antes de admitir pacientes reales. No uses este entorno para recibir servicios de salud. La aceptación de estas condiciones no sustituye la futura aceptación específica de cada consulta.'**
  String get developmentTermsBody;

  /// No description provided for @developmentPrivacyBody.
  ///
  /// In es, this message translates to:
  /// **'AVISO DE PRIVACIDAD DEL ENTORNO DE PRUEBAS\n\nEste aviso provisional no sustituye una política de privacidad aprobada para producción.\n\nEl entorno de desarrollo utiliza Firebase Authentication para la cuenta y Firestore en Santiago para el perfil básico y la aceptación de condiciones. No se solicita ni admite documentación clínica real. Los metadatos de aceptación incluyen usuario, versión y fecha del servidor. No se incluye Analytics.\n\nLa app no guarda contraseñas en Firestore ni habilita caché persistente de Firestore en el navegador. Cerrar sesión elimina el estado visible de la cuenta, pero no borra los registros remotos. No guardes datos sensibles en los formularios de demostración.\n\nResponsable legal, contacto formal de privacidad, conservación, ejercicio de derechos y condiciones de transferencias deben definirse antes de producción. Si no estás participando en las pruebas autorizadas del proyecto, no crees una cuenta aquí.'**
  String get developmentPrivacyBody;

  /// No description provided for @about.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get about;

  /// No description provided for @privacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get privacy;

  /// No description provided for @aboutBody.
  ///
  /// In es, this message translates to:
  /// **'2daOpinion\n\nUna plataforma en desarrollo para solicitar una segunda opinión médica documentada, con profesionales verificados y opciones de consulta online.\n\nComenzaremos en Chile con una arquitectura preparada para LATAM. Pacientes y administración compartirán una identidad visual propia y experiencias adaptadas a cada rol.\n\nEsta versión es un entorno de pruebas, no un servicio de atención médica ni de urgencias. Registro y perfil se están validando; las solicitudes, pagos, consultas y recetas aún no están operativos. Los datos legales y canales oficiales se publicarán una vez aprobados.'**
  String get aboutBody;

  /// No description provided for @resetPassword.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get resetPassword;

  /// No description provided for @sendReset.
  ///
  /// In es, this message translates to:
  /// **'ENVIAR ENLACE'**
  String get sendReset;

  /// No description provided for @resetSent.
  ///
  /// In es, this message translates to:
  /// **'Si el correo corresponde a una cuenta habilitada, recibirás instrucciones para recuperar el acceso. Revisa también spam.'**
  String get resetSent;

  /// No description provided for @completeProfile.
  ///
  /// In es, this message translates to:
  /// **'Completa tu perfil de prueba'**
  String get completeProfile;

  /// No description provided for @myProfile.
  ///
  /// In es, this message translates to:
  /// **'Mi perfil'**
  String get myProfile;

  /// No description provided for @saveProfile.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR PERFIL'**
  String get saveProfile;

  /// No description provided for @nameLength.
  ///
  /// In es, this message translates to:
  /// **'Ingresa entre 1 y 80 caracteres.'**
  String get nameLength;

  /// No description provided for @signOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOut;

  /// No description provided for @verifyEmail.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu correo'**
  String get verifyEmail;

  /// No description provided for @verificationInstructions.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil está guardado. Solicita el enlace de verificación, abre el correo y luego vuelve para comprobarlo. No habilitaremos el acceso a tu inicio hasta verificarlo.'**
  String get verificationInstructions;

  /// No description provided for @sendVerification.
  ///
  /// In es, this message translates to:
  /// **'ENVIAR CORREO DE VERIFICACIÓN'**
  String get sendVerification;

  /// No description provided for @checkVerification.
  ///
  /// In es, this message translates to:
  /// **'YA VERIFIQUÉ MI CORREO'**
  String get checkVerification;

  /// No description provided for @verificationPending.
  ///
  /// In es, this message translates to:
  /// **'El correo todavía no figura como verificado. Abre el enlace recibido y vuelve a comprobarlo.'**
  String get verificationPending;

  /// No description provided for @verificationSent.
  ///
  /// In es, this message translates to:
  /// **'Solicitamos el envío del correo de verificación. Revisa tu bandeja y spam.'**
  String get verificationSent;
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
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
