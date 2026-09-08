// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => '2daOpinion';

  @override
  String get designWordmark => '2nd opinion';

  @override
  String get loading => 'Iniciando tu segunda opinión médica';

  @override
  String get initializationFailed =>
      'No pudimos iniciar la aplicación. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get retry => 'REINTENTAR';

  @override
  String get welcome => '¡Estás a un paso de\nunirte a 2nd opinion!';

  @override
  String get facebook => 'Ingresar con Facebook';

  @override
  String get google => 'Ingresar con Google';

  @override
  String get emailAccess => 'Usa tu correo electrónico';

  @override
  String get terms => 'Términos y condiciones';

  @override
  String get termsPending =>
      'Los términos definitivos y los consentimientos clínicos están pendientes de aprobación. Este entorno admite únicamente pruebas; no envíes información clínica.';

  @override
  String get preview => 'Vista previa · Usa solo datos ficticios';

  @override
  String get explore => 'Explorar el diseño';

  @override
  String get accountTitle => 'Regístrate o ingresa';

  @override
  String get email => 'Correo electrónico';

  @override
  String get emailHint => 'nombre@ejemplo.com';

  @override
  String get password => 'Contraseña';

  @override
  String get firstName => 'Tu nombre';

  @override
  String get lastName => 'Tu apellido';

  @override
  String get choosePassword => 'Elige tu contraseña';

  @override
  String get repeatPassword => 'Repite tu contraseña';

  @override
  String get continueAction => 'CONTINUAR';

  @override
  String get signIn => 'Ingresar';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get requiredField => 'Completa este campo.';

  @override
  String get invalidEmail => 'Ingresa un correo válido.';

  @override
  String get shortPassword => 'Usa al menos 8 caracteres.';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get previewTitle => 'Solo vista previa';

  @override
  String get accountPreview =>
      'El formulario es válido. No se ha creado una cuenta ni iniciado una sesión. La autenticación es la siguiente entrega.';

  @override
  String get pendingFeature =>
      'Esta función todavía no está habilitada. No se ha enviado ni guardado información.';

  @override
  String get close => 'ENTENDIDO';

  @override
  String get homeTitle => '¿En qué te podemos\nayudar?';

  @override
  String get consultation => 'Consulta médica';

  @override
  String get consultationSubtitle =>
      'Solicita un médico para una segunda opinión';

  @override
  String get prescription => 'Receta médica';

  @override
  String get prescriptionSubtitle => 'Dentro del MVP · Próximamente';

  @override
  String get requestTitle => 'Nueva solicitud de consulta';

  @override
  String get reason => 'Motivo de tu consulta';

  @override
  String get reasonHint => 'Escribe el motivo de tu consulta';

  @override
  String get details => 'Diagnóstico o detalles de la consulta';

  @override
  String get detailsHint => 'Describe tu consulta y tus preguntas';

  @override
  String get medicines => 'Tratamiento con medicamentos';

  @override
  String get medicinesHint => 'Agrega medicamentos y horarios';

  @override
  String get specialTreatments => 'Tratamientos especiales';

  @override
  String get specialTreatmentsHint => 'Agrega otros tratamientos';

  @override
  String get documents => 'Exámenes y documentos';

  @override
  String get documentsHint => 'Adjuntar exámenes médicos';

  @override
  String get previousProposals => 'Propuestas terapéuticas previas';

  @override
  String get previousProposalsHint => 'Agrega las propuestas recibidas';

  @override
  String get sendRequest => 'ENVIAR SOLICITUD';

  @override
  String get requestPreview =>
      'Revisión local completada. Esta solicitud NO se ha enviado ni guardado. La carga privada de documentos y el envío real se implementarán con los permisos por caso.';

  @override
  String get menu => 'Menú';

  @override
  String get home => 'Inicio';

  @override
  String get loadingPreview => 'Ver pantalla de carga';

  @override
  String get back => 'Volver';

  @override
  String get backToWelcome => 'Volver al acceso';

  @override
  String get previewLoadingNote => 'Vista previa de la pantalla de carga';

  @override
  String get edit => 'EDITAR';

  @override
  String get actionFailed =>
      'No pudimos completar la operación. Inténtalo de nuevo.';

  @override
  String get actionCompleted => 'Operación completada.';

  @override
  String get brandTagline => 'Tu segunda opinión médica, desde donde estés.';

  @override
  String get credentialsError =>
      'No pudimos completar el acceso. Revisa los datos; si ya tienes cuenta, ingresa o recupera tu contraseña.';

  @override
  String get networkError =>
      'No hay conexión con el servicio. Comprueba tu conexión y vuelve a intentarlo.';

  @override
  String get throttledError =>
      'Demasiados intentos. Espera unos minutos antes de volver a intentarlo.';

  @override
  String get identityUnavailable =>
      'El acceso por correo no está disponible en este momento.';

  @override
  String get profileAccessError =>
      'No pudimos acceder a tu perfil. Inténtalo de nuevo; no se confirmó el guardado.';

  @override
  String get termsRequired =>
      'Debes aceptar las condiciones de este entorno de pruebas para continuar.';

  @override
  String get profilePending =>
      'Tu sesión está iniciada, pero falta completar y guardar tu perfil. No necesitas crear otra cuenta.';

  @override
  String get sessionExpired =>
      'La sesión dejó de ser válida. Cierra sesión e ingresa nuevamente.';

  @override
  String get sessionLoadFailed =>
      'No pudimos comprobar tu sesión o cargar el perfil. Reintenta o cierra sesión; no mostraremos datos sin verificarlos.';

  @override
  String get developmentTermsNotice =>
      'Solo pruebas de desarrollo. Los términos legales definitivos aún no están aprobados. No ingreses datos clínicos reales.';

  @override
  String get readTerms => 'Leer condiciones de prueba y privacidad';

  @override
  String get acceptDevelopmentTerms =>
      'He leído y acepto las condiciones del entorno de pruebas y su aviso de privacidad.';

  @override
  String get developmentTermsBody =>
      'CONDICIONES DE ACCESO AL ENTORNO DE DESARROLLO\nVersión: dev-access-2026-09-08\n\nEsta aplicación está en desarrollo. Este texto es una condición de uso del entorno de pruebas, no los términos definitivos del servicio médico ni un consentimiento clínico aprobado.\n\nUsa únicamente identidades de prueba y tu correo de pruebas autorizado. No ingreses antecedentes, diagnósticos, exámenes ni otros datos clínicos reales. No hay atención médica, emisión de recetas, pagos ni envío real de solicitudes en esta versión.\n\nAl crear una cuenta se registran sus credenciales en Firebase Authentication y un perfil básico (nombre de prueba, apellido, país comercial e idioma) en Firestore. La contraseña no se guarda en el perfil. Se conserva la versión aceptada, el identificador de cuenta y la fecha de aceptación.\n\nLa sesión web se conserva durante la sesión del navegador; puedes cerrarla desde el menú. Los registros remotos permanecen para continuar las pruebas. El acceso al propio perfil está restringido por reglas; los operadores autorizados del proyecto pueden administrarlo.\n\nLa entidad responsable, canales formales de privacidad, plazos de conservación y términos comerciales definitivos están pendientes de aprobación antes de admitir pacientes reales. No uses este entorno para recibir servicios de salud. La aceptación de estas condiciones no sustituye la futura aceptación específica de cada consulta.';

  @override
  String get developmentPrivacyBody =>
      'AVISO DE PRIVACIDAD DEL ENTORNO DE PRUEBAS\n\nEste aviso provisional no sustituye una política de privacidad aprobada para producción.\n\nEl entorno de desarrollo utiliza Firebase Authentication para la cuenta y Firestore en Santiago para el perfil básico y la aceptación de condiciones. Si aceptas las condiciones específicas de un borrador, también se guardan sus campos ficticios, identificadores, revisión, país y fechas, junto a una aceptación vinculada al borrador. Esa aceptación es independiente del registro y no autoriza atención médica. No se solicita ni admite documentación clínica real. Los metadatos de aceptación incluyen usuario, versión y fecha del servidor. No se incluye Analytics.\n\nLa app no guarda contraseñas en Firestore ni habilita caché persistente de Firestore en el navegador. Cerrar sesión elimina el estado visible de la cuenta, pero no borra los registros remotos. No guardes datos sensibles en los formularios de demostración.\n\nResponsable legal, contacto formal de privacidad, conservación, ejercicio de derechos y condiciones de transferencias deben definirse antes de producción. Si no estás participando en las pruebas autorizadas del proyecto, no crees una cuenta aquí.';

  @override
  String get about => 'Acerca de';

  @override
  String get privacy => 'Privacidad';

  @override
  String get aboutBody =>
      '2daOpinion\n\nUna plataforma en desarrollo para solicitar una segunda opinión médica documentada, con profesionales verificados y opciones de consulta online.\n\nComenzaremos en Chile con una arquitectura preparada para LATAM. Pacientes y administración compartirán una identidad visual propia y experiencias adaptadas a cada rol.\n\nEsta versión es un entorno de pruebas, no un servicio de atención médica ni de urgencias. Registro y perfil se están validando; las solicitudes, pagos, consultas y recetas aún no están operativos. Los datos legales y canales oficiales se publicarán una vez aprobados.';

  @override
  String get resetPassword => 'Recuperar contraseña';

  @override
  String get sendReset => 'ENVIAR ENLACE';

  @override
  String get resetSent =>
      'Si el correo corresponde a una cuenta habilitada, recibirás instrucciones para recuperar el acceso. Revisa también spam.';

  @override
  String get completeProfile => 'Completa tu perfil de prueba';

  @override
  String get myProfile => 'Mi perfil';

  @override
  String get saveProfile => 'GUARDAR PERFIL';

  @override
  String get nameLength => 'Ingresa entre 1 y 80 caracteres.';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get verifyEmail => 'Verifica tu correo';

  @override
  String get verificationInstructions =>
      'Tu perfil está guardado. Solicita el enlace de verificación, abre el correo y luego vuelve para comprobarlo. No habilitaremos el acceso a tu inicio hasta verificarlo.';

  @override
  String get sendVerification => 'ENVIAR CORREO DE VERIFICACIÓN';

  @override
  String get checkVerification => 'YA VERIFIQUÉ MI CORREO';

  @override
  String get verificationPending =>
      'El correo todavía no figura como verificado. Abre el enlace recibido y vuelve a comprobarlo.';

  @override
  String get verificationSent =>
      'Solicitamos el envío del correo de verificación. Revisa tu bandeja y spam.';

  @override
  String get draftTitle => 'Borrador de segunda opinión';

  @override
  String get draftServiceSubtitle => 'Crea o retoma tu borrador de prueba';

  @override
  String get saveDraft => 'GUARDAR BORRADOR';

  @override
  String get draftNotice =>
      'Solo datos ficticios. Puedes completar este borrador por partes y retomarlo desde Consulta médica. Guarda antes de salir: no hay guardado automático, ni almacenamiento sin conexión. Un borrador por cuenta en esta etapa.';

  @override
  String get draftSaved =>
      'Borrador guardado. No se ha enviado a un médico ni generado un cobro.';

  @override
  String draftSavedDate(String date) {
    return 'Último guardado: $date';
  }

  @override
  String get draftReadTerms => 'Condiciones para guardar este borrador';

  @override
  String get draftConsentLabel =>
      'Acepto guardar únicamente contenido ficticio de este borrador conforme a las condiciones de prueba. Esta aceptación es independiente del registro.';

  @override
  String get draftConsentRecorded =>
      'Aceptación para guardar este borrador registrada. No es consentimiento clínico ni autorización de envío.';

  @override
  String get draftTermsBody =>
      'CONDICIONES DEL BORRADOR DE PRUEBA\nVersión: dev-draft-storage-2026-09-08\n\nEsta aceptación es independiente de la del registro y se vincula a tu borrador. Autoriza únicamente el almacenamiento de contenido ficticio durante las pruebas de desarrollo. NO constituye un consentimiento clínico ni términos definitivos del servicio médico.\n\nAl guardar, Firestore conserva los campos del formulario, tu identificador de cuenta y de paciente, país, versión del borrador y fechas del servidor. Una aceptación separada e inmutable conserva la versión de estas condiciones, el ID del borrador, el usuario y la fecha del servidor. Solo se mantiene un borrador editable por cuenta en esta etapa.\n\nTu cuenta con correo verificado puede leer y editar su borrador. No se comparte con médicos, no se envía como caso y no genera pagos. Los operadores autorizados del proyecto pueden administrarlo.\n\nEl borrador queda guardado remotamente al presionar Guardar; cerrar sesión no lo borra. No hay guardado automático ni caché persistente de Firestore. No ingreses diagnósticos, tratamientos, medicamentos ni documentos de personas reales.\n\nLa entidad responsable, contacto de privacidad, conservación y mecanismo de borrado para producción siguen pendientes de aprobación. El envío futuro de una solicitud requerirá condiciones y consentimiento clínico específicos aprobados; esta aceptación no los sustituye.';

  @override
  String get draftConsentRequired =>
      'Acepta las condiciones específicas del borrador antes de guardarlo por primera vez.';

  @override
  String get draftPermissionError =>
      'No tienes acceso al borrador. Verifica tu correo y vuelve a ingresar; no se confirmó el guardado.';

  @override
  String get draftConflict =>
      'El borrador cambió en otra pestaña o se guardó antes de perder la conexión. Tu texto sigue aquí. Recarga la versión guardada para revisarla; no sobrescribimos cambios automáticamente.';

  @override
  String get draftUnavailable =>
      'No pudimos comprobar el borrador en el servidor. Conserva esta página y reintenta. No se confirmó el guardado.';

  @override
  String get draftInvalid =>
      'Revisa los campos: máximo 4.000 caracteres por campo y país configurado para este entorno.';

  @override
  String get draftReload => 'RECARGAR VERSIÓN GUARDADA';

  @override
  String get draftUnsavedStatus => 'Cambios sin guardar';

  @override
  String get draftUnsavedTitle => 'Tienes cambios sin guardar';

  @override
  String get draftUnsavedBody =>
      'Al continuar se descarta lo que aún no guardaste en esta página. El borrador guardado en Firebase no se borra.';

  @override
  String get draftKeepEditing => 'SEGUIR EDITANDO';

  @override
  String get draftDiscardChanges => 'DESCARTAR CAMBIOS LOCALES';

  @override
  String get draftNoSubmission =>
      'Envío clínico y documentos aún no habilitados. Este botón solo guarda el borrador de prueba; no solicita atención médica.';
}
