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

  /// No description provided for @noticesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis avisos'**
  String get noticesTitle;

  /// No description provided for @noticesExplore.
  ///
  /// In es, this message translates to:
  /// **'Explorar avisos de ejemplo'**
  String get noticesExplore;

  /// No description provided for @noticesPreviewNotice.
  ///
  /// In es, this message translates to:
  /// **'EJEMPLO · Estos avisos son ficticios, no provienen de tu cuenta. Los cambios quedan solo en esta pantalla y se reinician al volver a abrir el ejemplo.'**
  String get noticesPreviewNotice;

  /// No description provided for @noticesLocalNotice.
  ///
  /// In es, this message translates to:
  /// **'Centro privado en preparación. La persistencia se prueba únicamente con emuladores locales; no envía correos ni notificaciones push.'**
  String get noticesLocalNotice;

  /// No description provided for @noticesUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Los avisos de tu cuenta aún no están habilitados en este ambiente. Esto no significa que tengas cero avisos. Puedes explorar un ejemplo sin acceder a datos reales.'**
  String get noticesUnavailable;

  /// No description provided for @noticesCountUnknown.
  ///
  /// In es, this message translates to:
  /// **'Pendientes: sin confirmar'**
  String get noticesCountUnknown;

  /// No description provided for @noticesUnreadCount.
  ///
  /// In es, this message translates to:
  /// **'{count} sin leer'**
  String noticesUnreadCount(String count);

  /// No description provided for @noticesRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar avisos'**
  String get noticesRefresh;

  /// No description provided for @noticesFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar los avisos o su actualización. Revisa tu sesión y vuelve a intentar; no se muestra un cambio como guardado si falló.'**
  String get noticesFailed;

  /// No description provided for @noticesEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay avisos para mostrar.'**
  String get noticesEmpty;

  /// No description provided for @noticesMore.
  ///
  /// In es, this message translates to:
  /// **'CARGAR MÁS AVISOS'**
  String get noticesMore;

  /// No description provided for @noticeWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Conoce tu espacio personal'**
  String get noticeWelcomeTitle;

  /// No description provided for @noticeWelcomeBody.
  ///
  /// In es, this message translates to:
  /// **'Desde tu cuenta puedes revisar tu perfil y continuar un borrador de solicitud. En desarrollo utiliza únicamente información ficticia.'**
  String get noticeWelcomeBody;

  /// No description provided for @noticeDraftTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu borrador antes de continuar'**
  String get noticeDraftTitle;

  /// No description provided for @noticeDraftBody.
  ///
  /// In es, this message translates to:
  /// **'Guardar un borrador no envía una consulta al médico. Revisa los campos y los archivos pendientes antes de continuar.'**
  String get noticeDraftBody;

  /// No description provided for @noticeRead.
  ///
  /// In es, this message translates to:
  /// **'Leído'**
  String get noticeRead;

  /// No description provided for @noticeUnread.
  ///
  /// In es, this message translates to:
  /// **'Sin leer'**
  String get noticeUnread;

  /// No description provided for @noticeMarkRead.
  ///
  /// In es, this message translates to:
  /// **'MARCAR COMO LEÍDO'**
  String get noticeMarkRead;

  /// No description provided for @noticeMarkUnread.
  ///
  /// In es, this message translates to:
  /// **'MARCAR COMO NO LEÍDO'**
  String get noticeMarkUnread;

  /// No description provided for @optionalVideoTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos en un video · Opcional'**
  String get optionalVideoTitle;

  /// No description provided for @optionalVideoHint.
  ///
  /// In es, this message translates to:
  /// **'Si quieres, graba un video explicando tu consulta en hasta 30 segundos. Es opcional, no reemplaza el formulario ni los estudios. Máximo 20 MB; grabación MP4 en navegadores compatibles. Usa solo contenido ficticio en desarrollo.'**
  String get optionalVideoHint;

  /// No description provided for @selectOptionalVideo.
  ///
  /// In es, this message translates to:
  /// **'GRABAR VIDEO OPCIONAL'**
  String get selectOptionalVideo;

  /// No description provided for @recordVideoTitle.
  ///
  /// In es, this message translates to:
  /// **'Grabar video opcional'**
  String get recordVideoTitle;

  /// No description provided for @recordVideoPrivacy.
  ///
  /// In es, this message translates to:
  /// **'La cámara y el micrófono se activan solo cuando lo permitas. Después deberás iniciar la grabación. Puedes revisarla o descartarla antes de usarla. No se subirá automáticamente; utiliza solo contenido ficticio en desarrollo.'**
  String get recordVideoPrivacy;

  /// No description provided for @recordVideoPreparing.
  ///
  /// In es, this message translates to:
  /// **'Esperando permiso de cámara y micrófono…'**
  String get recordVideoPreparing;

  /// No description provided for @recordVideoFinishing.
  ///
  /// In es, this message translates to:
  /// **'Preparando y comprobando la grabación…'**
  String get recordVideoFinishing;

  /// No description provided for @recordVideoUnsupported.
  ///
  /// In es, this message translates to:
  /// **'La grabación MP4 no está disponible en este dispositivo o navegador. Usa un navegador compatible en HTTPS o continúa sin video. La captura en la app nativa todavía no está habilitada.'**
  String get recordVideoUnsupported;

  /// No description provided for @recordVideoPermission.
  ///
  /// In es, this message translates to:
  /// **'No pudimos acceder a la cámara y al micrófono. Revisa sus permisos y disponibilidad, o continúa sin video.'**
  String get recordVideoPermission;

  /// No description provided for @recordVideoInterrupted.
  ///
  /// In es, this message translates to:
  /// **'La captura se interrumpió y los dispositivos se apagaron. Vuelve al formulario para iniciar una nueva grabación si lo deseas.'**
  String get recordVideoInterrupted;

  /// No description provided for @recordVideoFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos grabar el video. Inténtalo nuevamente o continúa sin él.'**
  String get recordVideoFailed;

  /// No description provided for @recordVideoEnable.
  ///
  /// In es, this message translates to:
  /// **'ACTIVAR CÁMARA Y MICRÓFONO'**
  String get recordVideoEnable;

  /// No description provided for @recordVideoReady.
  ///
  /// In es, this message translates to:
  /// **'Cámara lista. Aún no estás grabando.'**
  String get recordVideoReady;

  /// No description provided for @recordVideoStart.
  ///
  /// In es, this message translates to:
  /// **'INICIAR GRABACIÓN'**
  String get recordVideoStart;

  /// No description provided for @recordVideoStop.
  ///
  /// In es, this message translates to:
  /// **'DETENER GRABACIÓN'**
  String get recordVideoStop;

  /// No description provided for @recordVideoTimer.
  ///
  /// In es, this message translates to:
  /// **'Grabando · {seconds} / 30 segundos'**
  String recordVideoTimer(int seconds);

  /// No description provided for @recordVideoReview.
  ///
  /// In es, this message translates to:
  /// **'Reproduce el video para revisarlo. La cámara y el micrófono ya están apagados.'**
  String get recordVideoReview;

  /// No description provided for @recordVideoUse.
  ///
  /// In es, this message translates to:
  /// **'USAR ESTE VIDEO'**
  String get recordVideoUse;

  /// No description provided for @recordVideoAgain.
  ///
  /// In es, this message translates to:
  /// **'Descartar y volver a grabar'**
  String get recordVideoAgain;

  /// No description provided for @recordVideoCancel.
  ///
  /// In es, this message translates to:
  /// **'Volver sin agregar video'**
  String get recordVideoCancel;

  /// No description provided for @noOptionalVideo.
  ///
  /// In es, this message translates to:
  /// **'No hay video pendiente de subir. Puedes continuar sin adjuntar uno.'**
  String get noOptionalVideo;

  /// No description provided for @removeVideo.
  ///
  /// In es, this message translates to:
  /// **'Quitar video'**
  String get removeVideo;

  /// No description provided for @videoDurationLabel.
  ///
  /// In es, this message translates to:
  /// **'{seconds} segundos · Video opcional'**
  String videoDurationLabel(int seconds);

  /// No description provided for @videoInvalid.
  ///
  /// In es, this message translates to:
  /// **'Elige un video MP4 o MOV reproducible, de hasta 30 segundos y 20 MB. Si no podemos comprobar su duración, prueba con un MP4 compatible con tu dispositivo.'**
  String get videoInvalid;

  /// No description provided for @videoLimit.
  ///
  /// In es, this message translates to:
  /// **'Solo puedes adjuntar un video opcional. Quita el anterior para elegir otro.'**
  String get videoLimit;

  /// No description provided for @privateDocumentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Archivos privados · Desarrollo'**
  String get privateDocumentsTitle;

  /// No description provided for @localUploadNotice.
  ///
  /// In es, this message translates to:
  /// **'Los archivos se guardan en el entorno de desarrollo, por separado del formulario. Usa únicamente datos ficticios. Cuota acumulada: 20 documentos y un video opcional, 50 MB entre todos. Borrar no libera reservas. No hay revisión médica ni validación confiable de contenido en el servidor.'**
  String get localUploadNotice;

  /// No description provided for @saveBeforeUpload.
  ///
  /// In es, this message translates to:
  /// **'Guarda primero el borrador con tu cuenta verificada para habilitar la carga.'**
  String get saveBeforeUpload;

  /// No description provided for @fileConsent.
  ///
  /// In es, this message translates to:
  /// **'Acepto almacenar únicamente archivos ficticios en el entorno de desarrollo (dev-files-2026-09-08). Esta aceptación no es un consentimiento clínico.'**
  String get fileConsent;

  /// No description provided for @uploadPrivateFiles.
  ///
  /// In es, this message translates to:
  /// **'SUBIR ARCHIVOS PRIVADOS'**
  String get uploadPrivateFiles;

  /// No description provided for @cancelTransfer.
  ///
  /// In es, this message translates to:
  /// **'CANCELAR SUBIDA'**
  String get cancelTransfer;

  /// No description provided for @reloadPrivateFiles.
  ///
  /// In es, this message translates to:
  /// **'ACTUALIZAR ARCHIVOS GUARDADOS'**
  String get reloadPrivateFiles;

  /// No description provided for @privateFileStored.
  ///
  /// In es, this message translates to:
  /// **'Archivo guardado · Sin revisión médica'**
  String get privateFileStored;

  /// No description provided for @privateFileMissing.
  ///
  /// In es, this message translates to:
  /// **'Reserva sin archivo. Para reintentar, selecciona nuevamente el mismo archivo.'**
  String get privateFileMissing;

  /// No description provided for @deletePrivateFile.
  ///
  /// In es, this message translates to:
  /// **'BORRAR ARCHIVO DE PRUEBA'**
  String get deletePrivateFile;

  /// No description provided for @deletePrivateFileNotice.
  ///
  /// In es, this message translates to:
  /// **'Se borrará el archivo del almacenamiento de desarrollo. El título, la aceptación y la reserva permanecerán; la cuota no se libera automáticamente.'**
  String get deletePrivateFileNotice;

  /// No description provided for @transferCancelled.
  ///
  /// In es, this message translates to:
  /// **'Subida cancelada. Los archivos ya confirmados se conservan; revisa el listado antes de reintentar.'**
  String get transferCancelled;

  /// No description provided for @privateQuotaReached.
  ///
  /// In es, this message translates to:
  /// **'Se alcanzó la cuota acumulada de pruebas. Reutiliza la reserva del mismo archivo o solicita una revisión del almacenamiento de desarrollo.'**
  String get privateQuotaReached;

  /// No description provided for @fileSessionRequired.
  ///
  /// In es, this message translates to:
  /// **'Necesitas una sesión vigente con correo verificado.'**
  String get fileSessionRequired;

  /// No description provided for @filePermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'No se autorizó la operación. Revisa tu sesión, aceptación y permisos.'**
  String get filePermissionDenied;

  /// No description provided for @fileInvalid.
  ///
  /// In es, this message translates to:
  /// **'El archivo o su reserva no cumplen los requisitos. No se confirmó la carga.'**
  String get fileInvalid;

  /// No description provided for @fileServiceUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No se confirmó la operación. Actualiza el listado antes de reintentar; tus archivos locales no confirmados se conservan.'**
  String get fileServiceUnavailable;

  /// No description provided for @birthDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get birthDate;

  /// No description provided for @selectBirthDate.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fecha'**
  String get selectBirthDate;

  /// No description provided for @clearBirthDate.
  ///
  /// In es, this message translates to:
  /// **'Quitar fecha de nacimiento'**
  String get clearBirthDate;

  /// No description provided for @chipInstruction.
  ///
  /// In es, this message translates to:
  /// **'Escribe un elemento y pulsa coma, Enter o + para agregarlo. Puedes quitarlo con la ×.'**
  String get chipInstruction;

  /// No description provided for @addItem.
  ///
  /// In es, this message translates to:
  /// **'Agregar elemento'**
  String get addItem;

  /// No description provided for @removeItem.
  ///
  /// In es, this message translates to:
  /// **'Quitar elemento'**
  String get removeItem;

  /// No description provided for @textLimitReached.
  ///
  /// In es, this message translates to:
  /// **'Llegaste al límite de este campo (4000). Reduce el contenido para agregar más.'**
  String get textLimitReached;

  /// No description provided for @multipleDocumentsHint.
  ///
  /// In es, this message translates to:
  /// **'Puedes seleccionar VARIOS archivos a la vez y seguir agregando más. Solo imágenes JPG/JPEG o PNG, documentos DOC, planillas XLS y PDF. Máximo 5 MB por documento. Puedes cambiar el título de cada archivo después de seleccionarlo.'**
  String get multipleDocumentsHint;

  /// No description provided for @documentsSelected.
  ///
  /// In es, this message translates to:
  /// **'{count} de 20 archivos seleccionados'**
  String documentsSelected(int count);

  /// No description provided for @addMoreDocuments.
  ///
  /// In es, this message translates to:
  /// **'AGREGAR MÁS ARCHIVOS'**
  String get addMoreDocuments;

  /// No description provided for @editDocumentTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar título'**
  String get editDocumentTitle;

  /// No description provided for @applyDocumentTitle.
  ///
  /// In es, this message translates to:
  /// **'APLICAR TÍTULO'**
  String get applyDocumentTitle;

  /// No description provided for @documentTotalLimit.
  ///
  /// In es, this message translates to:
  /// **'Los archivos seleccionados superan el límite total de 50 MB. Selecciona un grupo más pequeño.'**
  String get documentTotalLimit;

  /// No description provided for @pendingDocumentsNotice.
  ///
  /// In es, this message translates to:
  /// **'Solo archivos ficticios: hasta 20 documentos de 5 MB y un video opcional de 30 segundos y 20 MB. Máximo 50 MB entre todos. Quedan en memoria: guardar el borrador NO guarda archivos. Se pierden al recargar, cerrar la pestaña o cerrar sesión. La carga privada todavía no está habilitada.'**
  String get pendingDocumentsNotice;

  /// No description provided for @pendingEmulatorDocumentsNotice.
  ///
  /// In es, this message translates to:
  /// **'Los archivos seleccionados están en memoria y se pierden al recargar o cerrar sesión. Guardar el borrador no los sube. En Revisión podrás subirlos por separado al almacenamiento privado de desarrollo, después de guardar el borrador y aceptar las condiciones de archivos de prueba.'**
  String get pendingEmulatorDocumentsNotice;

  /// No description provided for @pendingUpload.
  ///
  /// In es, this message translates to:
  /// **'Pendiente de subir'**
  String get pendingUpload;

  /// No description provided for @documentTitle.
  ///
  /// In es, this message translates to:
  /// **'Título del estudio o documento'**
  String get documentTitle;

  /// No description provided for @selectDocument.
  ///
  /// In es, this message translates to:
  /// **'SELECCIONAR VARIOS ARCHIVOS'**
  String get selectDocument;

  /// No description provided for @documentTitleRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe un título de entre 1 y 120 caracteres.'**
  String get documentTitleRequired;

  /// No description provided for @documentCountLimit.
  ///
  /// In es, this message translates to:
  /// **'Puedes seleccionar hasta 20 archivos. Elige menos o quita alguno del listado.'**
  String get documentCountLimit;

  /// No description provided for @documentFileLimit.
  ///
  /// In es, this message translates to:
  /// **'Elige un archivo JPG/JPEG, PNG, DOC, XLS o PDF no vacío, de hasta 5 MB y con nombre de hasta 255 caracteres. No se admiten otros formatos, incluidos DOCX y XLSX.'**
  String get documentFileLimit;

  /// No description provided for @documentSelectionFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer el archivo. Intenta seleccionarlo de nuevo.'**
  String get documentSelectionFailed;

  /// No description provided for @legacyStudySummary.
  ///
  /// In es, this message translates to:
  /// **'Descripción de estudios del borrador anterior'**
  String get legacyStudySummary;

  /// No description provided for @consultationStep.
  ///
  /// In es, this message translates to:
  /// **'Consulta'**
  String get consultationStep;

  /// No description provided for @contextStep.
  ///
  /// In es, this message translates to:
  /// **'Antecedentes'**
  String get contextStep;

  /// No description provided for @goalsStep.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get goalsStep;

  /// No description provided for @reviewStep.
  ///
  /// In es, this message translates to:
  /// **'Revisión'**
  String get reviewStep;

  /// No description provided for @reviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu borrador'**
  String get reviewTitle;

  /// No description provided for @requiredForSubmission.
  ///
  /// In es, this message translates to:
  /// **'Requerido para enviar; puedes guardar el borrador sin completarlo.'**
  String get requiredForSubmission;

  /// No description provided for @reasonRequiredError.
  ///
  /// In es, this message translates to:
  /// **'Escribe el motivo de tu consulta; no puede contener solo espacios.'**
  String get reasonRequiredError;

  /// No description provided for @detailsRequiredError.
  ///
  /// In es, this message translates to:
  /// **'Describe tu consulta; no puede contener solo espacios.'**
  String get detailsRequiredError;

  /// No description provided for @modalityRequiredError.
  ///
  /// In es, this message translates to:
  /// **'Elige revisión documental o revisión + consulta antes de enviar.'**
  String get modalityRequiredError;

  /// No description provided for @requiredChecklistTitle.
  ///
  /// In es, this message translates to:
  /// **'Antes de enviar'**
  String get requiredChecklistTitle;

  /// No description provided for @requiredChecklistNotice.
  ///
  /// In es, this message translates to:
  /// **'Completa estos tres campos. Los demás datos del formulario son opcionales en esta etapa. También tendrás que guardar los cambios, resolver los archivos pendientes y aceptar las condiciones de envío. Esto no confirma una revisión médica.'**
  String get requiredChecklistNotice;

  /// No description provided for @requiredPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente · completar'**
  String get requiredPending;

  /// No description provided for @requiredProvided.
  ///
  /// In es, this message translates to:
  /// **'Informado · editar'**
  String get requiredProvided;

  /// No description provided for @requestLimitsError.
  ///
  /// In es, this message translates to:
  /// **'Revisa los límites de texto, la fecha de nacimiento y los valores seleccionados antes de guardar o enviar.'**
  String get requestLimitsError;

  /// No description provided for @reviewNotice.
  ///
  /// In es, this message translates to:
  /// **'Comprueba lo que escribiste. Puedes volver a editar cualquier sección o guardar un borrador incompleto. Esta revisión no valida la suficiencia clínica y no envía el caso al médico.'**
  String get reviewNotice;

  /// No description provided for @notProvided.
  ///
  /// In es, this message translates to:
  /// **'No informado'**
  String get notProvided;

  /// No description provided for @nextStep.
  ///
  /// In es, this message translates to:
  /// **'SIGUIENTE PASO'**
  String get nextStep;

  /// No description provided for @previousStep.
  ///
  /// In es, this message translates to:
  /// **'PASO ANTERIOR'**
  String get previousStep;

  /// No description provided for @saveProgress.
  ///
  /// In es, this message translates to:
  /// **'REVISAR PARA GUARDAR'**
  String get saveProgress;

  /// No description provided for @consultationProgress.
  ///
  /// In es, this message translates to:
  /// **'Paso {step} de 4 · {label}'**
  String consultationProgress(int step, String label);

  /// No description provided for @editSection.
  ///
  /// In es, this message translates to:
  /// **'Editar {section}'**
  String editSection(String section);

  /// No description provided for @googleCancelled.
  ///
  /// In es, this message translates to:
  /// **'Cerraste el acceso con Google. Puedes intentarlo de nuevo o usar tu correo.'**
  String get googleCancelled;

  /// No description provided for @googlePopupBlocked.
  ///
  /// In es, this message translates to:
  /// **'El navegador bloqueó la ventana de Google. Permite la ventana emergente para este sitio o ingresa con tu correo.'**
  String get googlePopupBlocked;

  /// No description provided for @googleAccountConflict.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar el acceso con Google. Ingresa con el método que utilizaste al crear tu cuenta; no vincularemos cuentas sin tu confirmación.'**
  String get googleAccountConflict;

  /// No description provided for @googleSetupPending.
  ///
  /// In es, this message translates to:
  /// **'Google estará disponible cuando activemos el proveedor. Por ahora, continúa con tu correo.'**
  String get googleSetupPending;

  /// No description provided for @showPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get hidePassword;

  /// No description provided for @continueAsGuest.
  ///
  /// In es, this message translates to:
  /// **'Continuar sin iniciar sesión'**
  String get continueAsGuest;

  /// No description provided for @guestContinue.
  ///
  /// In es, this message translates to:
  /// **'CONTINUAR CON MI CUENTA'**
  String get guestContinue;

  /// No description provided for @guestRequestNotice.
  ///
  /// In es, this message translates to:
  /// **'Puedes empezar sin registrarte. Lo escrito se conserva solo mientras esta app siga abierta; recargar o cerrar la pestaña puede perderlo. Al ingresar o crear tu cuenta podrás revisarlo y guardarlo. En desarrollo usa únicamente datos ficticios.'**
  String get guestRequestNotice;

  /// No description provided for @noEmergencyNotice.
  ///
  /// In es, this message translates to:
  /// **'Este servicio no atiende urgencias ni reemplaza la atención de tu equipo médico. Si necesitas atención inmediata, acude a un servicio de urgencias de tu localidad.'**
  String get noEmergencyNotice;

  /// No description provided for @guestHomeTitle.
  ///
  /// In es, this message translates to:
  /// **'Empieza a preparar tu segunda opinión'**
  String get guestHomeTitle;

  /// No description provided for @guestHomeSteps.
  ///
  /// In es, this message translates to:
  /// **'1. Cuéntanos tu caso sin crear una cuenta.\n\n2. Ingresa con tu correo o regístrate para continuar con lo que escribiste.\n\n3. Revisa y guarda tu borrador privado. El envío al médico aún no está habilitado en esta versión de desarrollo.'**
  String get guestHomeSteps;

  /// No description provided for @accessOrRegister.
  ///
  /// In es, this message translates to:
  /// **'INGRESAR O CREAR CUENTA'**
  String get accessOrRegister;

  /// No description provided for @clinicalContextTitle.
  ///
  /// In es, this message translates to:
  /// **'Contexto para el especialista'**
  String get clinicalContextTitle;

  /// No description provided for @clinicalOptionalNotice.
  ///
  /// In es, this message translates to:
  /// **'Estos datos son opcionales al preparar un borrador. Completa lo que conozcas; dejar un campo vacío significa «no informado», no ausencia de antecedentes. No incluyas documentos de identidad ni datos de contacto aquí.'**
  String get clinicalOptionalNotice;

  /// No description provided for @patientContext.
  ///
  /// In es, this message translates to:
  /// **'Contexto adicional del paciente'**
  String get patientContext;

  /// No description provided for @patientContextHint.
  ///
  /// In es, this message translates to:
  /// **'Información adicional que quieras compartir. La fecha de nacimiento se indica por separado; no incluyas identificación ni contacto.'**
  String get patientContextHint;

  /// No description provided for @knownDiagnosis.
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico conocido o sospechado'**
  String get knownDiagnosis;

  /// No description provided for @knownDiagnosisHint.
  ///
  /// In es, this message translates to:
  /// **'¿Qué te han explicado? Si tienes un diagnóstico, indica quién lo informó y cuándo. Puedes escribir «aún no tengo diagnóstico».'**
  String get knownDiagnosisHint;

  /// No description provided for @symptomEvolution.
  ///
  /// In es, this message translates to:
  /// **'Síntomas'**
  String get symptomEvolution;

  /// No description provided for @symptomEvolutionHint.
  ///
  /// In es, this message translates to:
  /// **'Ej.: dolor de cabeza desde el lunes. Agrega cada síntoma por separado; puedes indicar cuándo empezó.'**
  String get symptomEvolutionHint;

  /// No description provided for @medicalHistory.
  ///
  /// In es, this message translates to:
  /// **'Antecedentes relevantes'**
  String get medicalHistory;

  /// No description provided for @medicalHistoryHint.
  ///
  /// In es, this message translates to:
  /// **'Enfermedades previas, cirugías, hospitalizaciones o antecedentes familiares relacionados. Si no lo sabes, indícalo.'**
  String get medicalHistoryHint;

  /// No description provided for @allergies.
  ///
  /// In es, this message translates to:
  /// **'Alergias y reacciones'**
  String get allergies;

  /// No description provided for @allergiesHint.
  ///
  /// In es, this message translates to:
  /// **'Medicamentos u otras sustancias y qué reacción te produjeron. Indica «no conozco» o «ninguna conocida» solo si corresponde.'**
  String get allergiesHint;

  /// No description provided for @clinicalGoalsTitle.
  ///
  /// In es, this message translates to:
  /// **'Qué necesitas resolver'**
  String get clinicalGoalsTitle;

  /// No description provided for @questions.
  ///
  /// In es, this message translates to:
  /// **'Preguntas al especialista'**
  String get questions;

  /// No description provided for @questionsHint.
  ///
  /// In es, this message translates to:
  /// **'Escribe tus dudas principales sobre el diagnóstico, tratamiento propuesto u otras decisiones. Puedes enumerarlas.'**
  String get questionsHint;

  /// No description provided for @studySummary.
  ///
  /// In es, this message translates to:
  /// **'Estudios y documentación disponible'**
  String get studySummary;

  /// No description provided for @studySummaryHint.
  ///
  /// In es, this message translates to:
  /// **'Tipo de estudio, fecha aproximada y si tienes su informe. No hace falta transcribir todo el resultado.'**
  String get studySummaryHint;

  /// No description provided for @documentsNotEnabled.
  ///
  /// In es, this message translates to:
  /// **'La carga de archivos privados se habilitará en una próxima entrega. Por ahora solo puedes describir qué estudios tienes.'**
  String get documentsNotEnabled;

  /// No description provided for @specialty.
  ///
  /// In es, this message translates to:
  /// **'Especialidad solicitada'**
  String get specialty;

  /// No description provided for @specialtyHint.
  ///
  /// In es, this message translates to:
  /// **'Si la conoces, escríbela; si no, indica «No sé qué especialidad necesito». La clasificación será revisada por el equipo.'**
  String get specialtyHint;

  /// No description provided for @preferredModality.
  ///
  /// In es, this message translates to:
  /// **'Modalidad de tu preferencia'**
  String get preferredModality;

  /// No description provided for @modalityUnsure.
  ///
  /// In es, this message translates to:
  /// **'Necesito orientación'**
  String get modalityUnsure;

  /// No description provided for @modalityDocument.
  ///
  /// In es, this message translates to:
  /// **'Revisión documental'**
  String get modalityDocument;

  /// No description provided for @modalityConsultation.
  ///
  /// In es, this message translates to:
  /// **'Revisión + consulta'**
  String get modalityConsultation;

  /// No description provided for @modalityNotice.
  ///
  /// In es, this message translates to:
  /// **'Es una preferencia, no una contratación. Canales de consulta, disponibilidad y precio se confirmarán antes de cualquier pago.'**
  String get modalityNotice;

  /// No description provided for @guestExistingTitle.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes un borrador guardado'**
  String get guestExistingTitle;

  /// No description provided for @guestExistingBody.
  ///
  /// In es, this message translates to:
  /// **'También traes un formulario iniciado sin sesión. ¿Quieres revisar el nuevo contenido o conservar el que ya está guardado? Nada se sobrescribirá hasta que guardes explícitamente. Elegir el guardado descarta lo escrito como visitante.'**
  String get guestExistingBody;

  /// No description provided for @guestKeepSaved.
  ///
  /// In es, this message translates to:
  /// **'CONSERVAR GUARDADO'**
  String get guestKeepSaved;

  /// No description provided for @guestUseNew.
  ///
  /// In es, this message translates to:
  /// **'REVISAR NUEVO'**
  String get guestUseNew;

  /// No description provided for @onboardingProgress.
  ///
  /// In es, this message translates to:
  /// **'Paso {step} de 3 · Acceso, datos y verificación'**
  String onboardingProgress(int step);

  /// No description provided for @submissionTitle.
  ///
  /// In es, this message translates to:
  /// **'Enviar a recepción · Desarrollo'**
  String get submissionTitle;

  /// No description provided for @submissionNotice.
  ///
  /// In es, this message translates to:
  /// **'Envía la copia guardada junto con todos los documentos y el video que ya cargaste. Completa las cargas antes de confirmar; no se omitirán archivos pendientes. Operación verá código, país, modalidad, fecha y cantidades, no nombres de archivos ni contenido clínico. Usa únicamente información ficticia: todavía no hay pagos ni atención médica. Una solicitud por cuenta en esta etapa.'**
  String get submissionNotice;

  /// No description provided for @submissionTerms.
  ///
  /// In es, this message translates to:
  /// **'Acepto enviar esta copia y vincular todos sus adjuntos con la política de pruebas dev-submission-2026-09-09. Los archivos vinculados quedarán bloqueados para edición y borrado desde la app. Entiendo que recibir la solicitud no valida los archivos ni contrata una consulta. Esta aceptación es independiente del registro y del guardado del borrador.'**
  String get submissionTerms;

  /// No description provided for @submissionSend.
  ///
  /// In es, this message translates to:
  /// **'Confirmar envío de prueba'**
  String get submissionSend;

  /// No description provided for @submissionReceipt.
  ///
  /// In es, this message translates to:
  /// **'Recepción confirmada: {reference}'**
  String submissionReceipt(String reference);

  /// No description provided for @submissionImmutable.
  ///
  /// In es, this message translates to:
  /// **'Tu comprobante se conserva al volver a entrar. La copia enviada no cambia si editas el borrador; aún no se pueden enviar nuevas solicitudes desde esta cuenta. No hay médico asignado ni pago realizado.'**
  String get submissionImmutable;

  /// No description provided for @submissionConsentError.
  ///
  /// In es, this message translates to:
  /// **'Acepta las condiciones de este envío de prueba.'**
  String get submissionConsentError;

  /// No description provided for @submissionUnsavedError.
  ///
  /// In es, this message translates to:
  /// **'Guarda los cambios del borrador antes de enviarlo.'**
  String get submissionUnsavedError;

  /// No description provided for @submissionInvalidError.
  ///
  /// In es, this message translates to:
  /// **'Completa motivo, detalle y modalidad, respetando los límites de texto.'**
  String get submissionInvalidError;

  /// No description provided for @submissionAttachmentsError.
  ///
  /// In es, this message translates to:
  /// **'Hay archivos pendientes, faltantes o que no pudimos comprobar. Termina las cargas y actualiza la lista antes de enviar. Si borraste un archivo reservado, vuelve a cargar el mismo archivo; la reserva no se elimina. Nada se omitirá automáticamente.'**
  String get submissionAttachmentsError;

  /// No description provided for @submissionFilesLocked.
  ///
  /// In es, this message translates to:
  /// **'Adjuntos vinculados a la solicitud. Puedes consultar su estado, pero no añadir, reemplazar ni borrar archivos desde la app. Las correcciones requerirán el flujo autorizado de una próxima entrega.'**
  String get submissionFilesLocked;

  /// No description provided for @submissionDocuments.
  ///
  /// In es, this message translates to:
  /// **'Documentos vinculados: {count}'**
  String submissionDocuments(int count);

  /// No description provided for @submissionVideoLinked.
  ///
  /// In es, this message translates to:
  /// **'Video explicativo vinculado · Opcional'**
  String get submissionVideoLinked;

  /// No description provided for @submissionValidationPending.
  ///
  /// In es, this message translates to:
  /// **'Adjuntos pendientes de verificación. El registro no certifica su contenido, ausencia de malware, duración real del video ni validez clínica.'**
  String get submissionValidationPending;

  /// No description provided for @submissionSessionError.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu sesión, correo y permisos antes de enviar.'**
  String get submissionSessionError;

  /// No description provided for @submissionConflictError.
  ///
  /// In es, this message translates to:
  /// **'El borrador cambió en otra sesión. Recupera la versión guardada y vuelve a revisarla antes de enviar.'**
  String get submissionConflictError;

  /// No description provided for @submissionUnavailableError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar el envío. Reintenta: una recepción ya registrada no se duplica.'**
  String get submissionUnavailableError;

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
  /// **'Detalles de la consulta'**
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
  /// **'Nombre, dosis, frecuencia y desde cuándo los usas. Incluye suplementos si corresponde; no cambies tu tratamiento por completar este formulario.'**
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
  /// **'AVISO DE PRIVACIDAD DEL ENTORNO DE PRUEBAS\n\nEste aviso provisional no sustituye una política de privacidad aprobada para producción.\n\nEl entorno de desarrollo utiliza Firebase Authentication para la cuenta y Firestore en Santiago para el perfil básico y la aceptación de condiciones. Si aceptas las condiciones específicas de un borrador, también se guardan sus campos ficticios, identificadores, revisión, país y fechas, junto a una aceptación vinculada al borrador. Esa aceptación es independiente del registro y no autoriza atención médica. No se solicita ni admite documentación clínica real. Los metadatos de aceptación incluyen usuario, versión y fecha del servidor. No se incluye Analytics.\n\nLa app no guarda contraseñas en Firestore ni habilita caché persistente de Firestore en el navegador. Cerrar sesión elimina el estado visible de la cuenta, pero no borra los registros remotos. No guardes datos sensibles en los formularios de demostración.\n\nResponsable legal, contacto formal de privacidad, conservación, ejercicio de derechos y condiciones de transferencias deben definirse antes de producción. Si no estás participando en las pruebas autorizadas del proyecto, no crees una cuenta aquí.'**
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

  /// No description provided for @draftTitle.
  ///
  /// In es, this message translates to:
  /// **'Borrador de segunda opinión'**
  String get draftTitle;

  /// No description provided for @overviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu solicitud en preparación'**
  String get overviewTitle;

  /// No description provided for @overviewPreviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Ejemplo de solicitud en preparación'**
  String get overviewPreviewTitle;

  /// No description provided for @overviewPreviewNotice.
  ///
  /// In es, this message translates to:
  /// **'Ejemplo visual · No corresponde a una solicitud real ni a tu cuenta.'**
  String get overviewPreviewNotice;

  /// No description provided for @overviewRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar resumen'**
  String get overviewRefresh;

  /// No description provided for @overviewLoading.
  ///
  /// In es, this message translates to:
  /// **'Consultando tu borrador guardado…'**
  String get overviewLoading;

  /// No description provided for @overviewFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos consultar tu borrador. Esto no significa que no exista. Reintenta para comprobar su estado.'**
  String get overviewFailed;

  /// No description provided for @overviewEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes un borrador guardado'**
  String get overviewEmpty;

  /// No description provided for @overviewEmptyBody.
  ///
  /// In es, this message translates to:
  /// **'Empieza con datos ficticios y guarda tu avance para retomarlo después. No se enviará a un médico.'**
  String get overviewEmptyBody;

  /// No description provided for @overviewStart.
  ///
  /// In es, this message translates to:
  /// **'PREPARAR BORRADOR'**
  String get overviewStart;

  /// No description provided for @overviewResume.
  ///
  /// In es, this message translates to:
  /// **'RETOMAR BORRADOR'**
  String get overviewResume;

  /// No description provided for @overviewExplore.
  ///
  /// In es, this message translates to:
  /// **'VER FORMULARIO DE EJEMPLO'**
  String get overviewExplore;

  /// No description provided for @overviewDraftStatus.
  ///
  /// In es, this message translates to:
  /// **'Borrador · Sin enviar'**
  String get overviewDraftStatus;

  /// No description provided for @overviewRequiredComplete.
  ///
  /// In es, this message translates to:
  /// **'Motivo y detalles completados. Puedes seguir revisándolos.'**
  String get overviewRequiredComplete;

  /// No description provided for @overviewRequiredPending.
  ///
  /// In es, this message translates to:
  /// **'Falta completar el motivo o los detalles de tu solicitud.'**
  String get overviewRequiredPending;

  /// No description provided for @overviewNotSent.
  ///
  /// In es, this message translates to:
  /// **'No hay médico asignado ni cobros. El envío clínico todavía no está habilitado.'**
  String get overviewNotSent;

  /// No description provided for @draftServiceSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea o retoma tu borrador de prueba'**
  String get draftServiceSubtitle;

  /// No description provided for @saveDraft.
  ///
  /// In es, this message translates to:
  /// **'GUARDAR BORRADOR'**
  String get saveDraft;

  /// No description provided for @draftNotice.
  ///
  /// In es, this message translates to:
  /// **'Solo datos ficticios. Puedes completar este borrador por partes y retomarlo desde Consulta médica. Guarda antes de salir: no hay guardado automático, ni almacenamiento sin conexión. Un borrador por cuenta en esta etapa.'**
  String get draftNotice;

  /// No description provided for @draftSaved.
  ///
  /// In es, this message translates to:
  /// **'Borrador guardado. No se ha enviado a un médico ni generado un cobro.'**
  String get draftSaved;

  /// No description provided for @draftSavedDate.
  ///
  /// In es, this message translates to:
  /// **'Último guardado: {date}'**
  String draftSavedDate(String date);

  /// No description provided for @draftReadTerms.
  ///
  /// In es, this message translates to:
  /// **'Condiciones para guardar este borrador'**
  String get draftReadTerms;

  /// No description provided for @draftConsentLabel.
  ///
  /// In es, this message translates to:
  /// **'Acepto guardar únicamente contenido ficticio de este borrador conforme a las condiciones de prueba. Esta aceptación es independiente del registro.'**
  String get draftConsentLabel;

  /// No description provided for @draftConsentRecorded.
  ///
  /// In es, this message translates to:
  /// **'Aceptación para guardar este borrador registrada. No es consentimiento clínico ni autorización de envío.'**
  String get draftConsentRecorded;

  /// No description provided for @draftTermsBody.
  ///
  /// In es, this message translates to:
  /// **'CONDICIONES DEL BORRADOR DE PRUEBA\nVersión: dev-draft-storage-2026-09-08\n\nEsta aceptación es independiente de la del registro y se vincula a tu borrador. Autoriza únicamente el almacenamiento de contenido ficticio durante las pruebas de desarrollo. NO constituye un consentimiento clínico ni términos definitivos del servicio médico.\n\nAl guardar, Firestore conserva los campos del formulario, tu identificador de cuenta y de paciente, país, versión del borrador y fechas del servidor. Una aceptación separada e inmutable conserva la versión de estas condiciones, el ID del borrador, el usuario y la fecha del servidor. Solo se mantiene un borrador editable por cuenta en esta etapa.\n\nTu cuenta con correo verificado puede leer y editar su borrador. No se comparte con médicos, no se envía como caso y no genera pagos. Los operadores autorizados del proyecto pueden administrarlo.\n\nEl borrador queda guardado remotamente al presionar Guardar; cerrar sesión no lo borra. No hay guardado automático ni caché persistente de Firestore. No ingreses diagnósticos, tratamientos, medicamentos ni documentos de personas reales.\n\nLa entidad responsable, contacto de privacidad, conservación y mecanismo de borrado para producción siguen pendientes de aprobación. El envío futuro de una solicitud requerirá condiciones y consentimiento clínico específicos aprobados; esta aceptación no los sustituye.'**
  String get draftTermsBody;

  /// No description provided for @draftConsentRequired.
  ///
  /// In es, this message translates to:
  /// **'Acepta las condiciones específicas del borrador antes de guardarlo por primera vez.'**
  String get draftConsentRequired;

  /// No description provided for @draftPermissionError.
  ///
  /// In es, this message translates to:
  /// **'No tienes acceso al borrador. Verifica tu correo y vuelve a ingresar; no se confirmó el guardado.'**
  String get draftPermissionError;

  /// No description provided for @draftConflict.
  ///
  /// In es, this message translates to:
  /// **'El borrador cambió en otra pestaña o se guardó antes de perder la conexión. Tu texto sigue aquí. Recarga la versión guardada para revisarla; no sobrescribimos cambios automáticamente.'**
  String get draftConflict;

  /// No description provided for @draftUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos comprobar el borrador en el servidor. Conserva esta página y reintenta. No se confirmó el guardado.'**
  String get draftUnavailable;

  /// No description provided for @draftInvalid.
  ///
  /// In es, this message translates to:
  /// **'Revisa los campos: máximo 4.000 caracteres por campo y país configurado para este entorno.'**
  String get draftInvalid;

  /// No description provided for @draftReload.
  ///
  /// In es, this message translates to:
  /// **'RECARGAR VERSIÓN GUARDADA'**
  String get draftReload;

  /// No description provided for @draftUnsavedStatus.
  ///
  /// In es, this message translates to:
  /// **'Cambios sin guardar'**
  String get draftUnsavedStatus;

  /// No description provided for @draftUnsavedTitle.
  ///
  /// In es, this message translates to:
  /// **'Tienes cambios sin guardar'**
  String get draftUnsavedTitle;

  /// No description provided for @draftUnsavedBody.
  ///
  /// In es, this message translates to:
  /// **'Al continuar se descarta lo que aún no guardaste en esta página. El borrador guardado en Firebase no se borra.'**
  String get draftUnsavedBody;

  /// No description provided for @draftKeepEditing.
  ///
  /// In es, this message translates to:
  /// **'SEGUIR EDITANDO'**
  String get draftKeepEditing;

  /// No description provided for @draftDiscardChanges.
  ///
  /// In es, this message translates to:
  /// **'DESCARTAR CAMBIOS LOCALES'**
  String get draftDiscardChanges;

  /// No description provided for @draftNoSubmission.
  ///
  /// In es, this message translates to:
  /// **'Envío clínico y documentos aún no habilitados. Este botón solo guarda el borrador de prueba; no solicita atención médica.'**
  String get draftNoSubmission;
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
