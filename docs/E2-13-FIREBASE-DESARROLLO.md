# E2-13 · Solicitud y archivos privados conectados

9 de septiembre de 2026. Activación autorizada de Firebase de desarrollo en `segundaopinion-ea0c8`. Este estado sustituye las restricciones exclusivamente locales de E2-06, E2-10, E2-11 y E2-12; no habilita uso clínico ni producción.

## Disponible

- Guardado explícito del borrador, carga privada de múltiples archivos y envío con aceptación independiente, usando los adaptadores existentes sin API propia.
- Comprobante recuperable al volver a entrar y dos documentos ficticios comprobados remotamente desde el navegador. La bandeja del panel muestra la misma recepción, sin contenido clínico ni acceso a los archivos.
- Textos actualizados a «Desarrollo» y botón «SUBIR ARCHIVOS PRIVADOS». Los archivos siguen sin subirse al seleccionar o guardar el formulario: se requiere una acción separada y consentimiento.
- Firestore sin caché persistente y sesión web SESSION. Dominio y controllers no dependen del proveedor; ubicación física de archivos separada de su ID.
- Google permanece preparado pero desactivado; avisos remotos, pagos y Hosting no se habilitan en esta entrega.

## Verificación

151 pruebas Flutter, análisis y build web correctos. 128 pruebas de reglas y 26 pruebas del panel aprobadas. Circuito real en Firebase con cuentas ficticias: guardar → seleccionar dos PDFs → subir → enviar → volver a entrar → recuperar comprobante → ver resumen desde operaciones CL.

Se comprueba aislamiento frente a otro paciente, operador y anónimo; bloqueo de borrado después del envío y rechazo remoto de tipos/campos/textos/fechas inválidos. Inspección visual del comprobante a 320, 768 y 1440 px; listado, detalle, vacío, carga y error del panel también revisados. Evidencia ficticia en la carpeta central `docs/desarrollo/evidencia/E2-13`.

Al finalizar se eliminaron las tres cuentas de QA, sus registros, los dos archivos remotos y las credenciales temporales. Reglas desplegadas, índices READY y privacidad comprobados; roles de Ronel sin cambios. La bandeja no conserva solicitudes ficticias de esta verificación.

## Precauciones vigentes

Solo datos ficticios, una recepción por cuenta y guardado manual. Máximo acumulado de 20 documentos y un video opcional, 50 MiB; borrar no libera reservas. Video hasta 30 segundos según comprobación cliente, no certificación del servidor. La prueba remota de esta entrega no utiliza cámara/micrófono físicos ni video. Los adjuntos enviados no pueden reemplazarse o borrarse desde la app; correcciones autorizadas pendientes.

El presupuesto USD 10 sigue siendo una alerta, no un corte de gasto. No hay atención médica, pagos, asignación, validación confiable de contenido/malware ni permisos clínicos para operaciones.

Configuración, permisos y despliegue selectivo se documentan en el repositorio `2daopinion-panel`, `docs/E2-13-FIREBASE-DESARROLLO.md`. Las reglas tienen una sola fuente allí; no duplicarlas en pacientes.
