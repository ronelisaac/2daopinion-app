# E2-11 · Adjuntos en la solicitud

9 de septiembre de 2026 · Implementado y probado solo con Firebase emulado.

La solicitud permite enviar el borrador guardado junto con los documentos y el video ya cargados. No es necesario seleccionar nuevamente archivos ni moverlos a otra carpeta. Los archivos seleccionados pendientes de subir y las reservas sin bytes bloquean el flujo normal; no se omiten silenciosamente.

El adaptador comprueba existencia y metadatos antes de enviar. Si aparece una nueva reserva mientras comprueba archivos, pide resolver los adjuntos y reintentar. La aceptación independiente se reinicia al cambiar revisión, cantidad de adjuntos o pendientes. El comprobante recuperado muestra documentos vinculados y video; la app oculta carga/borrado después del envío y bloquea estas acciones durante su comprobación.

No equivale a validación confiable: Firestore no comprueba atómicamente los bytes de Storage; un cliente manipulado puede vincular reservas sin archivo. Contenido, malware, duración real, correcciones y acceso médico siguen pendientes. La interfaz y el panel indican vínculos pendientes de validación, no estudios aprobados.

Continúan una recepción por cuenta, datos ficticios y adaptadores únicamente con USE_FIREBASE_EMULATORS=true en debug. No se activó carga remota, bucket, acceso clínico, Hosting ni servicio nuevo.

Pruebas: 146 Flutter de pacientes, 26 del panel, 126 de reglas y dos integraciones web; análisis sin incidencias y compilaciones web correctas. Recorrido con dos documentos y un video, archivo faltante/restaurado, reserva concurrente, doble envío, comprobante recuperado y borrado posterior denegado. La prueba de video usa bytes ficticios y no acredita validez multimedia.

Fuente única de esquema, reglas, reproducción y pendientes: [E2-11 en panel](../../2daopinion-panel/docs/E2-11-ADJUNTOS-EN-RECEPCION.md).
