# 2daOpinion · Pacientes

Base Flutter web responsive con identidad Firebase para desarrollo y vista previa del diseño propio de Figma. No es una aplicación clínica operativa.

## Estado

Actualización E1-04/E2-03: home y formulario públicos, continuación por correo/registro conservando lo escrito en memoria, onboarding de cuenta y formulario ampliado con antecedentes, evolución, alergias, preguntas, estudios, especialidad y modalidad. Google preparado pero desactivado por decisión de Ronel; Facebook retirado. [Detalle y límites](docs/E1-04-ACCESO-Y-FORMULARIO.md). Recargar la pestaña puede perder el formulario del visitante; no se guardan datos remotos hasta autenticarse y aceptar el almacenamiento de pruebas. Esta actualización prevalece sobre las referencias históricas siguientes.

Actualización E2-01: solicitud de prueba guardada como borrador privado, recuperable al volver a entrar, con aceptación independiente y protección contra conflictos entre pestañas. Un borrador por cuenta y guardado manual. No envía atención clínica. Ver [entrega de borrador](docs/E2-01-BORRADOR-PERSISTENTE.md); prevalece sobre las referencias históricas de vista previa de solicitudes.

- Proyecto Firebase real: `segundaopinion-ea0c8`.
- App web registrada: `1:638989286509:web:29bbf8428c2ba4c5ec5364`.
- Firebase Core se inicializa al abrir la app; los fallos muestran una opción de reintento.
- Pantallas de carga, acceso, ingreso/creación de cuenta, inicio y solicitud.
- Registro e ingreso reales por correo/contraseña, verificación por enlace, recuperación de contraseña y cierre de sesión. Perfil básico y aceptación versionada de condiciones de desarrollo guardados en Firestore; no sube documentos ni envía o guarda casos.
- Authentication conserva la sesión al recargar la pestaña (SESSION); se requiere ingresar nuevamente después de cerrarla. El perfil remoto permanece. Caché persistente de Firestore desactivada.
- «Explorar el diseño» permite revisar el inicio sin simular una autenticación. Todas las pantallas operativas llevan un aviso de vista previa.
- Sin Analytics, API propia, Functions, pagos ni despliegue público en esta entrega.

## Ejecutar

Requiere Flutter 3.41.7 / Dart 3.11.5 o una versión compatible.

```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
flutter build web
```

En este equipo, usar `FLUTTER_SUPPRESS_ANALYTICS=true DART_SUPPRESS_ANALYTICS=true` delante de cada comando evita escrituras de telemetría fuera del proyecto.

Después de agregar o cambiar plugins Firebase, ejecutar `flutter clean` y `flutter pub get` antes de compilar web. Se detectó que una compilación incremental conservaba el registro antiguo de plugins (solo Core), aunque el análisis y los tests pasaban; por eso es obligatoria la comprobación del build final en navegador.

## Organización

- `lib/views`: pantallas y navegación visual.
- `lib/widgets`: widgets reutilizables en archivos separados.
- `lib/controllers`: coordinación de casos de uso y estados.
- `lib/domain/repositories`: contratos de repositorio en Dart puro.
- `lib/repositories`: adaptadores Firebase de identidad/perfil y borradores, más adaptadores explícitos de vista previa para casos.
- `lib/l10n/app_es.arb`: todos los textos de la interfaz, traducibles.
- `lib/core/app_theme.dart`: colores y tipografía.
- `lib/domain`: objetos Dart sin tipos ni referencias de Firebase.
- `lib/firebase_options.dart`: configuración pública web, no credenciales de servicio.
- `assets`: logo, fondo e iconos originales exportados de Figma; Montserrat local y su licencia OFL.

El país comercial y la moneda están separados del idioma: `CountryConfig` no contiene un locale. Se inyectan país y locale por separado al adaptador Firebase. Los controllers dependen de contratos; identidad devuelve resultados reales y casos permanecen en vista previa. El perfil tiene ID de dominio independiente del UID de Auth. No se implementa anticipadamente una API ni PostgreSQL. `connected_app.dart` compone la app conectada; `app.dart` conserva la vista previa aislada para pruebas.

Compatibilidad: `firebase_core 4.13.0` y `firebase_core_web 3.10.0` quedan fijados para esta entrega. La combinación 4.14.0/3.11.0 falló en dart2js con el SDK instalado por una llamada a `Object.isA`. No se modificó Flutter global ni la caché de paquetes. Revisar las versiones al actualizar el SDK y repetir análisis, pruebas y compilación.

## Diseño y ajustes

Inicio actualizado el 08/09/2026: segunda fila con resumen del borrador guardado, fecha, campos principales pendientes y acceso para retomarlo. Se actualiza al entrar, regresar del formulario o pulsar Actualizar; no muestra el texto clínico ni simula consultas enviadas. La vista previa incluye un ejemplo claramente identificado y no consulta borradores de cuentas. Ver [E2-02 Home y resumen](docs/E2-02-HOME-Y-RESUMEN.md).

Footer actualizado el 08/09/2026: Acerca de, Términos y condiciones y Privacidad se ubican en el pie inferior de inicio/vista previa, registro conectado y páginas informativas. Ocupa todo el ancho, sin tarjeta flotante entre los servicios; Scaffold reserva su espacio para no cubrir el contenido desplazable. Los enlaces se distribuyen en varias líneas en pantallas pequeñas. Pruebas de posición inferior, navegación y formularios con teclado incluidas.

Referencia: [Figma 2daOpinion](https://www.figma.com/design/g5clOtGxXBf5VETTbi4WAU/2daOpinion?node-id=0-1).

Se conserva el verde #03A68B, Montserrat, el logo y la fotografía originales. La app es web responsive: móvil, tablet y escritorio. Ya no se limita toda la aplicación a 480 px. Cambios explícitos respecto del boceto: textos corregidos a español neutro, contraste de campos mejorado, controles de ingreso/registro separados sin revelar si existe una cuenta, aviso permanente de vista previa y estados de validación. Los campos adicionales de la solicitud son una propuesta provisional sobre la pantalla incompleta.

Los componentes `ResponsiveLayout` y `ResponsiveContent` centralizan la adaptación por ancho disponible. Breakpoints: compacto <600 px, medio 600–1023 px y expandido ≥1024 px. El acceso usa dos columnas en escritorio; el inicio incorpora navegación lateral y servicios en columnas según el espacio disponible. Formularios y carga conservan anchos de lectura cómodos, sin estirar los inputs a todo el monitor. El cambio de tamaño no descarta lo escrito en el formulario abierto; esto no significa persistencia al recargar o cerrar la página.

Es una aplicación de navegador, no un sitio público todavía. `flutter build web --no-web-resources-cdn` genera la versión web; Hosting, dominio y publicación de un entorno de pruebas se configurarán aparte. El enlace 127.0.0.1 solo funciona en este equipo, mientras el servidor esté activo.

La marca gráfica «2nd opinion» se conserva como en Figma; su unificación con «2daOpinion» sigue pendiente (A17). «Receta médica» está dentro del MVP y pendiente de implementación y validación profesional/legal, no es un servicio operativo. La pantalla de carga usa un indicador nativo provisional; no se fuerza una espera artificial.

## Siguiente entrega

1. Ambiente acordado: `segundaopinion-ea0c8` para desarrollo/pruebas (alias `dev`). Producción tendrá un proyecto nuevo y limpio, todavía no creado. Replicar código y configuración revisada; no copiar usuarios, casos, archivos ni pagos de pruebas.
2. Acceso por correo implementado para pruebas; proveedores sociales no habilitados. Ver [entrega de identidad](docs/E1-03-IDENTIDAD-Y-PERFIL.md).
3. Cerrar consentimientos y textos legales antes de admitir pacientes reales; la aceptación actual es exclusivamente de desarrollo.
4. Firestore dev en Santiago con permisos privados de perfil; definir Storage y permisos clínicos por caso antes de almacenar documentación.
5. Borrador persistente, aceptación de almacenamiento de prueba y resumen en home implementados. Próximo bloque: estados/envío de casos y consentimiento clínico definitivo; posteriormente documentación privada por caso.
6. Integración del panel y permisos. Aún no hay backend de panel ni repositorio compartido.
7. Registrar Android/iOS después de acordar identificadores definitivos.

Nunca usar datos clínicos reales en este entorno. Authentication por correo habilitado y reglas de perfiles verificadas; Storage todavía no implementado ni validado. Acerca de, términos provisionales y footer informativo disponibles; home con casos activos, notificaciones y recetas siguen pendientes.

## Pruebas aisladas

Ejecutar emuladores Auth/Firestore desde el repositorio del panel con proyecto `demo-2daopinion`. Luego ejecutar esta app con `flutter run -d chrome --web-hostname localhost --dart-define=USE_FIREBASE_EMULATORS=true`. Este modo usa un proyecto ficticio y puertos locales 9099/8080; no reutiliza datos ni credenciales del proyecto remoto. Usar debug y hostname `localhost`: el SDK Auth web restaura el emulador antes de la sesión solo en esa combinación. Las compilaciones release con esta opción se bloquean; no distribuir una compilación con emuladores.

Las reglas e índices compartidos tienen fuente única en `../2daopinion-panel/firebase/`. La suite del panel comprueba denegación entre pacientes, anonimato, manipulación de consentimientos y colecciones clínicas/financieras. Java 21+, Node y Firebase CLI son necesarios para esas pruebas. Los tests Flutter usan contratos falsos sin red.

Configuración siguiendo la [guía oficial de Firebase para Flutter](https://firebase.google.com/docs/flutter/setup). Los parámetros del SDK web son [identificadores públicos](https://firebase.google.com/docs/projects/learn-more#config-files-objects); la seguridad depende de identidad, reglas y controles del servidor, no de ocultarlos.
