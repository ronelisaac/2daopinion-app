// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get optionalVideoTitle => 'Cuéntanos en un video · Opcional';

  @override
  String get optionalVideoHint =>
      'Si quieres, adjunta un video explicando tu consulta en hasta 30 segundos. No es obligatorio ni reemplaza el formulario o los estudios. Un video MP4 o MOV de hasta 20 MB; recomendamos MP4. No se graba desde la app. Usa solo contenido ficticio en desarrollo.';

  @override
  String get selectOptionalVideo => 'ADJUNTAR VIDEO OPCIONAL';

  @override
  String get noOptionalVideo =>
      'No hay video pendiente de subir. Puedes continuar sin adjuntar uno.';

  @override
  String get removeVideo => 'Quitar video';

  @override
  String videoDurationLabel(int seconds) {
    return '$seconds segundos · Video opcional';
  }

  @override
  String get videoInvalid =>
      'Elige un video MP4 o MOV reproducible, de hasta 30 segundos y 20 MB. Si no podemos comprobar su duración, prueba con un MP4 compatible con tu dispositivo.';

  @override
  String get videoLimit =>
      'Solo puedes adjuntar un video opcional. Quita el anterior para elegir otro.';

  @override
  String get privateDocumentsTitle => 'Archivos privados · Pruebas locales';

  @override
  String get localUploadNotice =>
      'Este módulo usa emuladores locales, no el proyecto remoto. Los archivos se guardan por separado del formulario. Cuota acumulada: 20 documentos y un video opcional, 50 MB entre todos. Borrar no libera reservas. No hay revisión médica ni validación confiable de contenido en el servidor.';

  @override
  String get saveBeforeUpload =>
      'Guarda primero el borrador con tu cuenta verificada para habilitar la carga.';

  @override
  String get fileConsent =>
      'Acepto almacenar únicamente archivos ficticios en las pruebas locales (dev-files-2026-09-08). Esta aceptación no es un consentimiento clínico.';

  @override
  String get uploadPrivateFiles => 'SUBIR ARCHIVOS AL EMULADOR';

  @override
  String get cancelTransfer => 'CANCELAR SUBIDA';

  @override
  String get reloadPrivateFiles => 'ACTUALIZAR ARCHIVOS GUARDADOS';

  @override
  String get privateFileStored => 'Archivo guardado · Sin revisión médica';

  @override
  String get privateFileMissing =>
      'Reserva sin archivo. Para reintentar, selecciona nuevamente el mismo archivo.';

  @override
  String get deletePrivateFile => 'BORRAR ARCHIVO DE PRUEBA';

  @override
  String get deletePrivateFileNotice =>
      'Se borrarán los bytes del emulador. El título, la aceptación y la reserva permanecerán; la cuota no se libera automáticamente.';

  @override
  String get transferCancelled =>
      'Subida cancelada. Los archivos ya confirmados se conservan; revisa el listado antes de reintentar.';

  @override
  String get privateQuotaReached =>
      'Se alcanzó la cuota acumulada de pruebas. Reutiliza la reserva del mismo archivo o solicita limpieza del entorno local.';

  @override
  String get fileSessionRequired =>
      'Necesitas una sesión vigente con correo verificado.';

  @override
  String get filePermissionDenied =>
      'No se autorizó la operación. Revisa tu sesión, aceptación y permisos.';

  @override
  String get fileInvalid =>
      'El archivo o su reserva no cumplen los requisitos. No se confirmó la carga.';

  @override
  String get fileServiceUnavailable =>
      'No se confirmó la operación. Actualiza el listado antes de reintentar; tus archivos locales no confirmados se conservan.';

  @override
  String get birthDate => 'Fecha de nacimiento';

  @override
  String get selectBirthDate => 'Seleccionar fecha';

  @override
  String get clearBirthDate => 'Quitar fecha de nacimiento';

  @override
  String get chipInstruction =>
      'Escribe un elemento y pulsa coma, Enter o + para agregarlo. Puedes quitarlo con la ×.';

  @override
  String get addItem => 'Agregar elemento';

  @override
  String get removeItem => 'Quitar elemento';

  @override
  String get textLimitReached =>
      'Llegaste al límite de este campo (4000). Reduce el contenido para agregar más.';

  @override
  String get multipleDocumentsHint =>
      'Puedes seleccionar VARIOS archivos a la vez y seguir agregando más. Solo imágenes JPG/JPEG o PNG, documentos DOC, planillas XLS y PDF. Máximo 5 MB por documento. Puedes cambiar el título de cada archivo después de seleccionarlo.';

  @override
  String documentsSelected(int count) {
    return '$count de 20 archivos seleccionados';
  }

  @override
  String get addMoreDocuments => 'AGREGAR MÁS ARCHIVOS';

  @override
  String get editDocumentTitle => 'Editar título';

  @override
  String get applyDocumentTitle => 'APLICAR TÍTULO';

  @override
  String get documentTotalLimit =>
      'Los archivos seleccionados superan el límite total de 50 MB. Selecciona un grupo más pequeño.';

  @override
  String get pendingDocumentsNotice =>
      'Solo archivos ficticios: hasta 20 documentos de 5 MB y un video opcional de 30 segundos y 20 MB. Máximo 50 MB entre todos. Quedan en memoria: guardar el borrador NO guarda archivos. Se pierden al recargar, cerrar la pestaña o cerrar sesión. La carga privada todavía no está habilitada.';

  @override
  String get pendingEmulatorDocumentsNotice =>
      'Los archivos seleccionados están en memoria y se pierden al recargar o cerrar sesión. Guardar el borrador no los sube. En Revisión podrás subirlos por separado al emulador local, después de guardar el borrador y aceptar las condiciones de archivos de prueba.';

  @override
  String get pendingUpload => 'Pendiente de subir';

  @override
  String get documentTitle => 'Título del estudio o documento';

  @override
  String get selectDocument => 'SELECCIONAR VARIOS ARCHIVOS';

  @override
  String get documentTitleRequired =>
      'Escribe un título de entre 1 y 120 caracteres.';

  @override
  String get documentCountLimit =>
      'Puedes seleccionar hasta 20 archivos. Elige menos o quita alguno del listado.';

  @override
  String get documentFileLimit =>
      'Elige un archivo JPG/JPEG, PNG, DOC, XLS o PDF no vacío, de hasta 5 MB y con nombre de hasta 255 caracteres. No se admiten otros formatos, incluidos DOCX y XLSX.';

  @override
  String get documentSelectionFailed =>
      'No pudimos leer el archivo. Intenta seleccionarlo de nuevo.';

  @override
  String get legacyStudySummary =>
      'Descripción de estudios del borrador anterior';

  @override
  String get consultationStep => 'Consulta';

  @override
  String get contextStep => 'Antecedentes';

  @override
  String get goalsStep => 'Preferencias';

  @override
  String get reviewStep => 'Revisión';

  @override
  String get reviewTitle => 'Revisa tu borrador';

  @override
  String get reviewNotice =>
      'Comprueba lo que escribiste. Puedes volver a editar cualquier sección o guardar un borrador incompleto. Esta revisión no valida la suficiencia clínica y no envía el caso al médico.';

  @override
  String get notProvided => 'No informado';

  @override
  String get nextStep => 'SIGUIENTE PASO';

  @override
  String get previousStep => 'PASO ANTERIOR';

  @override
  String get saveProgress => 'REVISAR PARA GUARDAR';

  @override
  String consultationProgress(int step, String label) {
    return 'Paso $step de 4 · $label';
  }

  @override
  String editSection(String section) {
    return 'Editar $section';
  }

  @override
  String get googleCancelled =>
      'Cerraste el acceso con Google. Puedes intentarlo de nuevo o usar tu correo.';

  @override
  String get googlePopupBlocked =>
      'El navegador bloqueó la ventana de Google. Permite la ventana emergente para este sitio o ingresa con tu correo.';

  @override
  String get googleAccountConflict =>
      'No pudimos completar el acceso con Google. Ingresa con el método que utilizaste al crear tu cuenta; no vincularemos cuentas sin tu confirmación.';

  @override
  String get googleSetupPending =>
      'Google estará disponible cuando activemos el proveedor. Por ahora, continúa con tu correo.';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get continueAsGuest => 'Continuar sin iniciar sesión';

  @override
  String get guestContinue => 'CONTINUAR CON MI CUENTA';

  @override
  String get guestRequestNotice =>
      'Puedes empezar sin registrarte. Lo escrito se conserva solo mientras esta app siga abierta; recargar o cerrar la pestaña puede perderlo. Al ingresar o crear tu cuenta podrás revisarlo y guardarlo. En desarrollo usa únicamente datos ficticios.';

  @override
  String get noEmergencyNotice =>
      'Este servicio no atiende urgencias ni reemplaza la atención de tu equipo médico. Si necesitas atención inmediata, acude a un servicio de urgencias de tu localidad.';

  @override
  String get guestHomeTitle => 'Empieza a preparar tu segunda opinión';

  @override
  String get guestHomeSteps =>
      '1. Cuéntanos tu caso sin crear una cuenta.\n\n2. Ingresa con tu correo o regístrate para continuar con lo que escribiste.\n\n3. Revisa y guarda tu borrador privado. El envío al médico aún no está habilitado en esta versión de desarrollo.';

  @override
  String get accessOrRegister => 'INGRESAR O CREAR CUENTA';

  @override
  String get clinicalContextTitle => 'Contexto para el especialista';

  @override
  String get clinicalOptionalNotice =>
      'Estos datos son opcionales al preparar un borrador. Completa lo que conozcas; dejar un campo vacío significa «no informado», no ausencia de antecedentes. No incluyas documentos de identidad ni datos de contacto aquí.';

  @override
  String get patientContext => 'Contexto adicional del paciente';

  @override
  String get patientContextHint =>
      'Información adicional que quieras compartir. La fecha de nacimiento se indica por separado; no incluyas identificación ni contacto.';

  @override
  String get knownDiagnosis => 'Diagnóstico conocido o sospechado';

  @override
  String get knownDiagnosisHint =>
      '¿Qué te han explicado? Si tienes un diagnóstico, indica quién lo informó y cuándo. Puedes escribir «aún no tengo diagnóstico».';

  @override
  String get symptomEvolution => 'Síntomas';

  @override
  String get symptomEvolutionHint =>
      'Ej.: dolor de cabeza desde el lunes. Agrega cada síntoma por separado; puedes indicar cuándo empezó.';

  @override
  String get medicalHistory => 'Antecedentes relevantes';

  @override
  String get medicalHistoryHint =>
      'Enfermedades previas, cirugías, hospitalizaciones o antecedentes familiares relacionados. Si no lo sabes, indícalo.';

  @override
  String get allergies => 'Alergias y reacciones';

  @override
  String get allergiesHint =>
      'Medicamentos u otras sustancias y qué reacción te produjeron. Indica «no conozco» o «ninguna conocida» solo si corresponde.';

  @override
  String get clinicalGoalsTitle => 'Qué necesitas resolver';

  @override
  String get questions => 'Preguntas al especialista';

  @override
  String get questionsHint =>
      'Escribe tus dudas principales sobre el diagnóstico, tratamiento propuesto u otras decisiones. Puedes enumerarlas.';

  @override
  String get studySummary => 'Estudios y documentación disponible';

  @override
  String get studySummaryHint =>
      'Tipo de estudio, fecha aproximada y si tienes su informe. No hace falta transcribir todo el resultado.';

  @override
  String get documentsNotEnabled =>
      'La carga de archivos privados se habilitará en una próxima entrega. Por ahora solo puedes describir qué estudios tienes.';

  @override
  String get specialty => 'Especialidad solicitada';

  @override
  String get specialtyHint =>
      'Si la conoces, escríbela; si no, indica «No sé qué especialidad necesito». La clasificación será revisada por el equipo.';

  @override
  String get preferredModality => 'Modalidad de tu preferencia';

  @override
  String get modalityUnsure => 'Necesito orientación';

  @override
  String get modalityDocument => 'Revisión documental';

  @override
  String get modalityConsultation => 'Revisión + consulta';

  @override
  String get modalityNotice =>
      'Es una preferencia, no una contratación. Canales de consulta, disponibilidad y precio se confirmarán antes de cualquier pago.';

  @override
  String get guestExistingTitle => 'Ya tienes un borrador guardado';

  @override
  String get guestExistingBody =>
      'También traes un formulario iniciado sin sesión. ¿Quieres revisar el nuevo contenido o conservar el que ya está guardado? Nada se sobrescribirá hasta que guardes explícitamente. Elegir el guardado descarta lo escrito como visitante.';

  @override
  String get guestKeepSaved => 'CONSERVAR GUARDADO';

  @override
  String get guestUseNew => 'REVISAR NUEVO';

  @override
  String onboardingProgress(int step) {
    return 'Paso $step de 3 · Acceso, datos y verificación';
  }

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
  String get details => 'Detalles de la consulta';

  @override
  String get detailsHint => 'Describe tu consulta y tus preguntas';

  @override
  String get medicines => 'Tratamiento con medicamentos';

  @override
  String get medicinesHint =>
      'Nombre, dosis, frecuencia y desde cuándo los usas. Incluye suplementos si corresponde; no cambies tu tratamiento por completar este formulario.';

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
  String get overviewTitle => 'Tu solicitud en preparación';

  @override
  String get overviewPreviewTitle => 'Ejemplo de solicitud en preparación';

  @override
  String get overviewPreviewNotice =>
      'Ejemplo visual · No corresponde a una solicitud real ni a tu cuenta.';

  @override
  String get overviewRefresh => 'Actualizar resumen';

  @override
  String get overviewLoading => 'Consultando tu borrador guardado…';

  @override
  String get overviewFailed =>
      'No pudimos consultar tu borrador. Esto no significa que no exista. Reintenta para comprobar su estado.';

  @override
  String get overviewEmpty => 'Aún no tienes un borrador guardado';

  @override
  String get overviewEmptyBody =>
      'Empieza con datos ficticios y guarda tu avance para retomarlo después. No se enviará a un médico.';

  @override
  String get overviewStart => 'PREPARAR BORRADOR';

  @override
  String get overviewResume => 'RETOMAR BORRADOR';

  @override
  String get overviewExplore => 'VER FORMULARIO DE EJEMPLO';

  @override
  String get overviewDraftStatus => 'Borrador · Sin enviar';

  @override
  String get overviewRequiredComplete =>
      'Motivo y detalles completados. Puedes seguir revisándolos.';

  @override
  String get overviewRequiredPending =>
      'Falta completar el motivo o los detalles de tu solicitud.';

  @override
  String get overviewNotSent =>
      'No hay médico asignado ni cobros. El envío clínico todavía no está habilitado.';

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
