# E2-07 · Video opcional y formatos permitidos

Decisión posterior de Ronel: el siguiente paso reemplazará adjuntar video por grabarlo directamente en la app, opcional y de hasta 30 segundos. **Pendiente de implementar**; ver [criterios de grabación](PENDIENTE-GRABACION-EN-APP.md). La descripción siguiente conserva el historial de E2-07.

8 de septiembre de 2026 · Desarrollo con contenido ficticio

## Decisión y experiencia

Ronel confirma que el paciente puede adjuntar un video breve explicando su consulta, pero nunca será obligatorio. Se muestra separado de los estudios, tanto en Preferencias como en Revisión. No sustituye el formulario ni la documentación. No se agrega grabación con cámara, reproducción en la interfaz ni transcripción.

| Tipo | Formatos admitidos | Límite provisional de desarrollo |
| --- | --- | --- |
| Estudios y documentación | JPG/JPEG, PNG, DOC, XLS y PDF | 20 documentos, hasta 5 MiB cada uno |
| Explicación opcional | MP4 o MOV compatible con el reproductor del dispositivo | Un video, duración mayor que cero y hasta 30 segundos, hasta 20 MiB |
| Conjunto | Documentos y video | Hasta 50 MiB entre todos |

JPG y JPEG representan el mismo formato. DOCX/XLSX no se incorporan implícitamente: se rechazan junto con GIF, SVG, ejecutables y cualquier extensión no permitida. El selector explica los formatos; valida sin distinguir mayúsculas y no acepta sufijos dobles como `archivo.pdf.exe`. Cada nombre admite hasta 255 unidades UTF-16. Las extensiones y tamaños se vuelven a comprobar en el controller y el adaptador privado.

Un selector independiente permite elegir un solo video. Se lee su duración real mediante el reproductor local antes de aceptarlo; si no puede decodificarse, excede 30 segundos o supera el tamaño permitido, se rechaza sin perder los otros documentos. La tarjeta muestra nombre, duración y estado pendiente, y permite quitarlo. El total de documentos no cuenta el video. La ausencia de video nunca impide avanzar ni guardar.

## Implementación y seguridad

`AttachmentPolicy` concentra extensiones, MIME y límites en dominio Dart puro. `PendingDocument` incorpora duración opcional. El controller mantiene los dos tipos en una selección común para conservarlos entre pasos y limpiarlos al salir de la sesión, pero los presenta por separado. El widget `OptionalVideoPanel` no usa Firebase ni reproduce contenido.

El adaptador local usa [video_player de Flutter](https://pub.dev/packages/video_player), inicializa el recurso sin reproducirlo y libera el reproductor al terminar. En web solo admite una URL `blob:` del archivo elegido; no envía el video a un servicio de análisis. Las URLs temporales de todos los archivos seleccionados se revocan tras leerlos o rechazarlos. Los bytes aceptados permanecen únicamente en memoria hasta una carga explícita en emuladores.

Las reglas locales de Firestore añaden correspondencia extensión–MIME, duración declarada para videos y contador de reservas de video. Se conserva compatibilidad con reservas antiguas sin contador, interpretadas como cero videos. Se permiten hasta 20 reservas de documentos y una de video, con listado máximo de 21 registros y el mismo límite combinado de 50 MiB. La reserva y los metadatos siguen siendo inmutables; borrar bytes no libera cuota y solo se puede reintentar el mismo contenido. Cambiar a otro video después de reservar requiere resolver la limpieza confiable del entorno, no reiniciar contadores desde Flutter.

Storage comprueba propietario, reserva, tipo, tamaño, checksum declarado y ruta; mantiene la prohibición de listar y sobrescribir objetos. El adaptador conserva duración en metadatos Firestore, no como dato del formulario clínico. DOC y XLS usan respectivamente `application/msword` y `application/vnd.ms-excel`; MP4/MOV usan `video/mp4` y `video/quicktime`.

**Límite de confianza:** las reglas solo comprueban MIME y duración declarados, no inspeccionan los bytes ni miden la duración real. Un cliente modificado podría mentir. La comprobación del reproductor protege el flujo normal, no equivale a validación de servidor ni antivirus. DOC/XLS pueden contener macros; no se ejecutan ni se abren automáticamente. La inspección confiable de contenido, cuarentena, análisis de malware y validación de video en servidor deben resolverse antes del uso real. No se habilita una API nueva para anticiparlos.

## Verificación

- 119 pruebas Flutter: formatos, límites exactos, duración faltante/excesiva, archivo ilegible, cuota combinada, video único/opcional, conservación y limpieza de sesión; widgets a 320 y 1440 px.
- 95 pruebas de reglas Firestore/Storage: formatos concordantes, extensiones rechazadas, cuota y ausencia de reseteo, límites declarados de video y aislamiento entre cuentas.
- Prueba integrada de adaptadores Flutter en Chrome: reserva/carga/lectura de DOC, XLS y video ficticios, además del recorrido anterior PDF; rechazo de un segundo video y de acceso sin sesión. Estas muestras verifican transporte y metadatos, no formatos binarios ni duración real.
- Prueba independiente del reproductor web con videos sintéticos negros: acepta 2 segundos, rechaza 31 segundos y bytes ilegibles. Sin cámara, micrófono ni contenido personal.
- Análisis y compilación web desde limpio. La revisión visual manual de esta nueva sección quedó pendiente porque el Mac estaba bloqueado; no se confunde con las pruebas automatizadas de widgets y Chrome.

La prueba de adaptadores se ejecuta con el comando documentado en E2-06. Para `test/integration/video_metadata_browser.dart`, preparar dos MP4 sintéticos de 2 y 31 segundos, llamados `2daopinion-qa-video-2s.mp4` y `2daopinion-qa-video-31s.mp4`, servidos exclusivamente en loopback con CORS habilitado para el servidor del test. El servidor no debe exponer otros archivos. Por defecto usa `http://127.0.0.1:8773`; puede indicarse otro origen local mediante `--dart-define=VIDEO_FIXTURE_BASE=...`.

```sh
flutter test --platform chrome test/integration/video_metadata_browser.dart --reporter expanded
```

Ambas pruebas de integración son explícitas, fuera de `flutter test` sin argumentos. El soporte nativo tiene adaptador de archivo, pero la reproducción/decodificación se verificó en Chrome, no todavía en Android/iOS.

## Despliegue y siguiente paso

No se crea bucket ni se publican reglas o servicios. La app normal solo selecciona archivos en memoria: **guardar borrador no los sube**. La carga privada sigue exclusivamente en emuladores debug; la autorización pendiente de Storage remoto no se infiere de esta petición. El presupuesto USD 10 permanece como alerta, no límite duro.

Esta entrega prevalece sobre la lista histórica PDF/JPG/PNG de E2-05/E2-06. Los límites de tamaño y formatos del video son conservadores y configurables para desarrollo; compresión automática, otros codecs/formatos y captura desde cámara quedan pendientes. El video no cambia precio ni modalidad médica. Google continúa apagado; no se habilitan atención, pagos ni recetas reales.
