# E2-12 · Revisión y validación de la solicitud

9 de septiembre de 2026 · Mejora implementada del formulario; sección de solicitudes aún parcial.

## Comportamiento

- Bloque «Antes de enviar» con motivo, detalle y modalidad: cada elemento indica pendiente/informado y permite volver a su sección.
- Los campos explican que son requeridos para enviar, pero no para guardar un borrador. Después de visitar Revisión, se muestran errores junto a campos vacíos o compuestos solo por espacios. Se actualizan al corregir.
- Elegir «Necesito orientación» en modalidad sigue permitido al preparar un borrador, pero no habilita su envío. No se agregaron nuevos requisitos clínicos: se hacen visibles las restricciones de envío existentes.
- El visitante puede continuar con su cuenta aunque el borrador esté incompleto. No se agrega almacenamiento local ni escritura anónima. Usuarios verificados conservan el guardado explícito mediante el adaptador Firebase existente.
- Dominio, controller y adaptador comparten readyForSubmission; el adaptador también rechaza modalidad pendiente antes de acceder a Firebase. Las reglas existentes siguen siendo la protección independiente contra clientes manipulados.

## Campos y tipos

| Campo | Tipo persistido | Requerido para enviar | Validación |
| --- | --- | --- | --- |
| Motivo y detalle | string | Sí, ambos | No vacíos ni solo espacios; hasta 4000 por campo; detalle multilinea |
| Modalidad | string de catálogo | Sí | document_review o review_and_consultation; vacío solo en borrador |
| Fecha de nacimiento | Mapa year/month/day de enteros, omitido si falta | No en esta etapa | Fecha real desde 1900, no futura; selector de calendario, no edad numérica ni fecha en texto |
| Diagnóstico, contexto, antecedentes, tratamientos, especialidad y resumen anterior de estudios | string | No | Hasta 4000 por campo, sin interpretar vacío como ausencia de enfermedad |
| Medicamentos, síntomas, alergias y preguntas | string compatible con el modelo actual | No | Chips de edición y texto agregado hasta 4000; no se migran a arreglos en esta entrega |
| Documentos/video | Reservas privadas separadas del texto | Opcionales | Selección y reservas pendientes no se omiten; título, formato, tamaño y cuota conservan E2-07/11 |
| Aceptaciones | boolean más versión/fecha según contexto | Según acción | Registro, guardado inicial y envío son aceptaciones independientes, no un único checkbox reutilizado |

El país sigue siendo configuración comercial, no locale. No se cambian colecciones, tipos almacenados, reglas, permisos ni políticas de aceptación.

## Evidencia

- 151 pruebas Flutter de pacientes aprobadas y análisis sin incidencias; build web actualizado.
- 126 pruebas de reglas Firestore/Storage aprobadas sin modificar las reglas: aislamiento, tipos, límites y restricciones de envío conservados.
- Dos integraciones web con Firebase emulado: guardar y recuperar borrador incompleto, rechazar envío, guardar datos completos, recuperar fecha como enteros y conservar envío idempotente y recepción administrativa. Datos ficticios; no fue una prueba con la cuenta remota de Ronel.
- Inspección visual real en Chrome aislado a 320, 768 y 1440 px: formulario público, revisión vacía, enlaces de corrección, errores de campos y desaparición al escribir datos. Textos sin desbordamiento en estas vistas y footer separado. También hay tests de widgets en esos tres anchos.
- Capturas ficticias guardadas localmente en Documents/2daOpinion/docs/desarrollo/evidencia/E2-12. No contienen información de pacientes ni se publican en GitHub.

Reproducción: flutter analyze, flutter test y flutter build web en pacientes; integración mediante scripts/test-reception.sh desde panel con emuladores auth,firestore,storage y proyecto demo-2daopinion, como E2-11. Para inspección visual del build normal usar /#/request; entrar en Revisión, pulsar un campo pendiente y corregirlo. No usar datos clínicos reales.

## Pendiente para cerrar la sección

El build normal conserva Firebase de desarrollo para identidad/perfil/borrador, pero este turno no hizo una nueva escritura remota. Envío y adjuntos siguen limitados a emuladores; todavía faltan activación remota autorizada, múltiples solicitudes, validación confiable/correcciones de archivos y prueba visual del recorrido privado completo, incluidos carga, error y comprobante. No se declara terminada la sección por esta mejora visual. No se desplegaron reglas, Storage, Functions o Hosting; no se modificaron cuentas, IAM, roles o facturación.
