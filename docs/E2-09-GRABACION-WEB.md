# E2-09 · Grabación opcional dentro de la web

8 de septiembre de 2026 · DEV-044 parcial · Sin carga remota

Confirmación posterior del usuario: Ronel informa «graba perfecto» y pide continuar. Se registra como prueba manual satisfactoria en su entorno, sin inferir modelo de dispositivo, navegador, versión ni cobertura de toda la matriz móvil. La captura nativa sigue pendiente; no cambia permisos ni habilita carga remota.

## Recorrido implementado

En el formulario, «Grabar video opcional» reemplaza la acción de adjuntar un video existente. Abre una pantalla independiente sin activar dispositivos. El usuario debe pulsar «Activar cámara y micrófono», resolver los permisos del navegador y luego «Iniciar grabación».

Incluye vista de cámara, contador, detener, reproducción de la grabación, descartar/regrabar y «Usar este video». Solo esta confirmación devuelve los bytes al formulario. Cancelar no añade contenido, no borra estudios ni envía la solicitud. El video sigue siendo opcional; una incompatibilidad o un permiso denegado permite continuar sin él.

Una sola grabación, hasta 30 segundos, 20 MiB y cuota combinada vigente de 50 MiB. El adaptador inicia la parada a los 29,5 s para dejar margen de cierre; el controller tiene además un temporizador de 30 s. Se comprueba la duración decodificada y se rechaza cualquier resultado superior a 30 s, vacío o demasiado grande, sin reinterpretarlo como válido. Los temporizadores del navegador no son garantías en tiempo real; la validación posterior es obligatoria.

## Arquitectura y privacidad

- `VideoCaptureRepository`: contrato Dart puro, separado de la selección de documentos. Estados y errores de captura en dominio/controller.
- `WebVideoCaptureRepository`: MediaRecorder, permisos y dispositivos web; acumulación de bytes limitada, parada y liberación de tracks, lectura de duración y URL temporal para reproducción.
- `VideoRecordingScreen`: vista y ciclo de vida; `ui/` compone adaptador y superficie de video web mediante imports condicionales. Widgets del formulario no invocan APIs del navegador.
- La pantalla mantiene una instancia de controller por ruta; cambios de sesión reconstruyen navegación y limpian la selección. Una confirmación tardía tras limpiar la sesión se rechaza.
- Parar grabación apaga cámara/micrófono antes de revisar. Cancelar, salir, ocultar la app o cerrar sesión cancela captura y libera recursos. Si el permiso llega después de cancelar, los tracks también se detienen inmediatamente.
- Bytes y URL temporal solo en memoria. Sin transcripción, procesamiento remoto, caché clínica persistente, subida automática ni cambios de Firebase. La revisión de video no equivale a validación clínica.

## Compatibilidad y límites

Se negocia MP4 mediante `MediaRecorder.isTypeSupported`; no se admite WebM ni se cambia la extensión para simular otro formato. Si el entorno no puede grabar MP4, muestra una alternativa para continuar sin video. Se requiere un contexto seguro HTTPS o localhost. Fuentes técnicas: [formatos de MediaRecorder](https://developer.mozilla.org/en-US/docs/Web/API/MediaRecorder/isTypeSupported_static), [parada y entrega de datos](https://developer.mozilla.org/en-US/docs/Web/API/MediaRecorder/dataavailable_event).

La implementación funciona en la web cuando el navegador soporta las APIs y permisos necesarios. **La grabación en binarios nativos Android/iOS sigue pendiente**, con adaptador explícito de no disponibilidad; no se presenta como funcional. También falta validación en dispositivos físicos/navegadores móviles y captura con cámara/micrófono reales. No se activaron dispositivos personales del usuario para probar.

El selector de video antiguo permanece interno para compatibilidad de pruebas/datos anteriores, pero ya no es la acción visible del formulario. JPG/JPEG, PNG, DOC, XLS y PDF continúan usando carga de documentos. Las reglas de Storage/Firestore no cambian; carga privada únicamente en emuladores. La regrabación es libre antes de confirmar/reservar; no reinicia cuotas de reservas privadas ya consumidas.

## Verificación reproducible

Formato, análisis, 138 pruebas Flutter y build web aprobados. Cuatro pruebas de integración Chrome aprobadas. Widgets de captura a 320, 768 y 1440 px; entrada/confirmación/quitar en el formulario, duración inválida, cancelación, permiso denegado, corte del controller, descarte y limpieza de sesión. No se modificaron reglas, por lo que esta entrega no vuelve a declarar su despliegue ni una nueva validación remota.

Prueba explícita de navegador con canvas sintético, sin cámara/micrófono, archivos personales ni servicios remotos:

```sh
flutter test --platform chrome test/integration/video_capture_browser.dart --reporter expanded
```

Comprueba grabación MP4 decodificable, revisión, regrabación, corte automático real, tracks detenidos, cancelación activa y permiso tardío/denegado simulado. Los fixtures actuales son de video sintético sin pista de micrófono; esto no acredita captura audiovisual en hardware real.

Revisión visual del flujo previo al permiso en navegador de escritorio y viewport móvil: instrucciones, botón explícito y salida sin agregar video. No se declara recorrido manual completo con cámara real. No hay despliegue ni activación de costos; el código del panel iniciado anteriormente permanece pendiente y fuera de esta entrega.
