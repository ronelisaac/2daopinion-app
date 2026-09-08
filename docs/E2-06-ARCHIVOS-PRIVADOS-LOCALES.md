# E2-06 · Archivos privados en emuladores

8 de septiembre de 2026 · Solo datos ficticios · Sin activación remota

## Estado y alcance

Se implementa la carga privada de los documentos seleccionados en E2-05, exclusivamente para pruebas locales con los emuladores de Authentication, Firestore y Storage. La consulta de infraestructura de esta entrega devolvió cero buckets en `segundaopinion-ea0c8`. No se creó ninguno ni se desplegaron estas reglas nuevas.

La aplicación normal y la compilación web local de desarrollo mantienen la selección de archivos en memoria: **todavía no suben archivos a Firebase remoto**. La nueva sección aparece únicamente con `USE_FIREBASE_EMULATORS=true` en una ejecución debug. Ese modo usa el proyecto ficticio `demo-2daopinion`; una compilación no debug rechaza su inicialización.

La decisión de crear Storage remoto sigue pendiente de confirmación de costos. El presupuesto de USD 10 genera alertas, no un corte de consumo. Ni los límites de archivos ni estas reglas garantizan ese máximo de facturación.

## Recorrido disponible en pruebas

1. Ingresar con una cuenta ficticia de correo verificado y perfil propio en los emuladores.
2. Completar y guardar explícitamente el borrador de prueba; guardar campos no sube documentos.
3. Seleccionar varios archivos PDF/JPG/PNG y revisar sus títulos.
4. En Revisión, aceptar por separado las condiciones de archivos ficticios y pulsar «Subir archivos al emulador».
5. Ver progreso del lote, cancelar y recuperar la lista al volver a abrir el borrador o actualizarla manualmente.
6. Un archivo confirmado sale de la selección pendiente. Un error conserva los pendientes y los archivos ya confirmados; no anuncia éxito del lote completo.
7. Se puede borrar el contenido de un archivo, previa confirmación. Su reserva y aceptación permanecen registradas. Volver a seleccionar los mismos bytes permite reintentar sin duplicar la reserva.

Cambiar de paso, recargar el borrador y salir mediante la navegación del formulario se bloquean mientras transfiere; cancelar permanece accesible. Cerrar la pestaña puede interrumpir la transferencia: no existe garantía de ejecución en segundo plano. Al cambiar/cerrar sesión se cancela la tarea y se evita publicar sus resultados en otra sesión.

La lectura autenticada de bytes está implementada y probada en el repositorio; todavía no se ofrece un visor ni un botón de descarga en la interfaz.

## Capas y portabilidad

- Dominio Dart puro: `PrivateDocument`, estados `stored`/`missing`, errores y contrato `PrivateDocumentRepository`; sin tipos Firebase.
- Controller independiente: lista, carga secuencial, progreso, cancelación, errores y confirmación individual.
- Widgets separados: selección local y panel de archivos privados. Textos en ARB y pruebas de ancho móvil/escritorio.
- Adaptador Firebase: transacción de reserva, transferencia Storage, lectura autenticada y borrado de bytes. Inyección desde `main.dart`/`ConnectedApp`.

Cada documento tiene un ID estable SHA-256 derivado del ID del borrador y del checksum de sus bytes. Seleccionar el mismo contenido para ese borrador reutiliza el registro; conserva el título y nombre de la primera reserva, aunque la nueva selección tenga otro título. La edición de metadatos ya reservados queda pendiente.

Firestore conserva metadatos, referencias por IDs y ubicación física separada (`storageBackendId` y `objectKey`), nunca archivos/Base64. Esto permite trasladar los objetos a otro proveedor conservando sus IDs y sustituir el adaptador sin incorporar ahora una API. No se llama a `getDownloadURL`, ni se generan, guardan o comparten URLs públicas desde la app.

## Permisos y consistencia local

Fuente única: `firebase/firestore.rules` y `firebase/storage.rules` en el repositorio del panel.

- Solo el propietario con correo verificado, perfil y borrador existente puede crear la reserva. No hay carga anónima ni acceso del médico/panel todavía.
- `draftAttachments/{uid}/files/{documentId}` tiene campos cerrados: identidad, borrador, país, título, nombre, tamaño, MIME, checksum, ubicación y aceptación versionada `dev-files-2026-09-08` con hora del servidor.
- Una transacción crea la reserva y aumenta el contador en `draftAttachments/{uid}`. Las reglas rechazan creaciones aisladas, contadores falsos, cambios de propiedad y cambios/borrados de metadatos.
- Storage permite crear solo el objeto reservado, con tamaño, MIME y metadatos concordantes. No permite sobrescribir ni listar objetos. Lectura y borrado requieren el propietario y el borrador correspondiente.
- La lista se obtiene desde Firestore con un máximo de 20 registros y comprueba cada objeto. Distingue contenido confirmado de reserva sin objeto, sin llamar «validado médicamente» a un archivo almacenado.
- Al leer bytes, el adaptador verifica SHA-256. MIME, extensión y checksum declarados no prueban inocuidad ni validez clínica; las reglas no inspeccionan el contenido ni calculan su hash.

Límites conservadores: 5 MiB por archivo, 20 reservas y 50 MiB reservados acumulados por cuenta en esta fase de un borrador. **Borrar o cancelar no devuelve cuota.** Una reserva fallida sigue consumiendo capacidad y se puede reintentar con los mismos bytes. Esto evita reinicios de cuota y carreras entre servicios, pero no es la política definitiva de producción. Firestore y Storage no forman una transacción atómica conjunta.

El adaptador solicita `Cache-Control: private, no-store`; esa propiedad no se impone mediante las reglas. La protección de acceso depende de autenticación y reglas, no de la caché ni de ocultar rutas.

## Ejecutar y verificar

Requiere Flutter compatible con el proyecto, Chrome, Firebase CLI, Node y Java compatible con los emuladores. Usar exclusivamente datos inventados. Los servicios de prueba escuchan en `127.0.0.1`: Auth 9099, Firestore 8080 y Storage 9199.

Desde el panel:

```sh
firebase emulators:start --only auth,firestore,storage --project demo-2daopinion
```

En otra terminal, desde pacientes:

```sh
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true
```

La cuenta de los emuladores es independiente de la de desarrollo remoto. Para verificar el correo ficticio, usar el enlace que imprime el emulador de Auth; no se envía correo real. Sin exportación explícita, detener los emuladores descarta sus datos.

Pruebas separadas, sin otro proceso usando esos puertos:

```sh
# Desde pacientes
flutter analyze
flutter test
flutter build web

# Desde el panel
npm run test:rules
firebase emulators:exec --only auth,firestore,storage --project demo-2daopinion "cd ../2daopinion-app && flutter test --platform chrome test/integration/private_document_emulators.dart --reporter expanded"
```

La prueba de integración no termina en `_test.dart`: se ejecuta explícitamente, no en la suite unitaria normal. Registra los plugins web antes de inicializar Firebase, crea una identidad ficticia local y prueba los adaptadores reales: reserva/carga, lectura, reintento sin duplicar cuota, recuperación, borrado, nueva carga y rechazo sin sesión. Chrome usa un perfil aislado.

Evidencia de cierre: 104 pruebas Flutter, 87 pruebas de reglas y una prueba de integración completa en Chrome/emuladores. Análisis y compilación web incluidos en la validación de entrega.

La compilación web se regeneró desde limpio y se comprobó el registro del plugin Storage. Tras desbloquear el Mac, se completó la revisión visual del formulario público en una pestaña nueva de `localhost:8765`, preservando el borrador abierto por Ronel. Se verificaron inicio de la compilación actual, navegación a Preferencias, selector múltiple real con dos archivos ficticios, contador «2 de 20», botón «Agregar más archivos», tarjetas individuales y footer inferior. Se revisaron escritorio y ancho móvil de 375 px; la selección se conservó al redimensionar. Se restauró el tamaño del navegador y se cerró la pestaña de prueba, sin subir archivos ni guardar datos remotos.

Esta comprobación visual corresponde al formulario público y su selección en memoria, no al panel privado de emuladores. Este último conserva la evidencia automatizada a 320/1440 px y la prueba integrada de adaptadores; no se presenta esa prueba como un recorrido visual manual del panel privado.

## Antes de habilitar remoto o producción

Confirmar costos y ubicación del bucket; revisar IAM para consultas de reglas Storage a Firestore, configuración web, CORS y aislamiento con una prueba remota ficticia antes de activar el adaptador. No ejecutar un despliegue general: estas reglas son candidatas locales, no la versión publicada de desarrollo.

Resolver retención, eliminación integral de metadatos/consentimientos según política aprobada, limpieza/reconciliación de reservas huérfanas, recuperación de cuota, protección contra abuso, límites de descarga, revisión de archivos y permisos por caso antes del uso clínico. Las operaciones confiables que resulten necesarias deberán diseñarse explícitamente; no se implementa ahora una API propia.

Google sigue desactivado. No se habilitan envío médico, pagos, recetas reales ni Hosting público. La receta continúa comprometida en el MVP, pendiente de sus requisitos.
