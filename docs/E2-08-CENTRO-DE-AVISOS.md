# E2-08 · Centro de avisos

8 de septiembre de 2026 · DEV-037 parcial · Desarrollo, no operación clínica

## Entrega

- Campana reutilizable en home, bandeja adaptable, contador, actualizar, paginación y marcar leído/no leído.
- Estados diferenciados de carga, vacío, error y función no habilitada. Un fallo o servicio desactivado nunca equivale a cero avisos.
- `/preview/notifications` es un ejemplo público, rotulado como tal, con dos avisos ficticios en memoria. El estado se reinicia al abrir una nueva vista previa.
- `/notifications` requiere sesión verificada y perfil. El adaptador persistente solo se inyecta en debug con `USE_FIREBASE_EMULATORS=true`; en la aplicación normal aparece como no habilitado, con acceso al ejemplo.
- Contrato y entidades Dart independientes; adaptador Firebase, controller, vista, campana y tarjeta en archivos separados. Textos ARB, tema y footer compartidos; sin dependencias nuevas.

## Datos y permisos

Colección privada `patientNotices/{uid}/items/{noticeId}`. Registro cerrado de seis campos: `id`, `recipientId`, `schemaVersion` (1), `templateCode`, `createdAt` y `readAt`. ID hexadecimal de 64 caracteres; fechas se convierten a Dart dentro del adaptador, sin tipos Firebase en dominio.

Solo se muestran plantillas localizadas `welcome` y `draft_reminder`. No se aceptan textos libres, enlaces, nombres, diagnósticos, archivos ni contenido clínico. No se simulan informes, citas o pagos reales.

Las reglas candidatas permiten leer al propietario verificado con perfil y modificar únicamente `readAt`, usando hora del servidor o null. Deniegan creación y borrado por clientes, cambios de destinatario/contenido y consultas sin límite o superiores a 100. El acceso administrativo depende de IAM y es independiente de las reglas de clientes. Las pruebas insertan datos ficticios mediante administración de emuladores; no se incorporan credenciales ni mecanismos administrativos a Flutter.

El cambio leído/no leído es transaccional e idempotente: repetir el mismo estado no reescribe la fecha. La interfaz confirma el cambio solo después de la respuesta del repositorio. Se comprueba la sesión antes y después de operaciones; al perder sesión se limpia el estado, y una cuenta no reutiliza el cursor de otra.

## Consultas y costo

Página de 20 elementos con lectura de hasta 21 para detectar continuación, ordenada por fecha descendente e ID descendente. El cursor conserva segundos y nanosegundos del timestamp devuelto por Firestore; la base almacena precisión de microsegundos. El desempate por ID evita omitir elementos con la misma fecha. El controller combina páginas por ID.

El contador consulta como máximo 100 no leídos y muestra `99+` desde 100; no calcula un total ilimitado. Se actualiza al abrir, volver de la bandeja, refrescar o cambiar el estado, sin listeners ni sondeos continuos. Una carga de página puede consultar hasta 21 registros más 100 para el contador; estas consultas están habilitadas solo localmente. Este límite por consulta no es un tope monetario: la alerta USD 10 no detiene consumo.

## Verificación

- Formato, análisis y compilación web aprobados; 129 pruebas Flutter aprobadas.
- 102 pruebas de reglas Firestore/Storage aprobadas (7 nuevas para avisos).
- Integración real del SDK Flutter web con Auth/Firestore locales: 23 avisos con igual fecha, páginas sin duplicados/omisiones, estado conservado al recrear repositorio, escritura idempotente, contador acotado y aislamiento entre cuentas.
- Tests de widgets a 320 y 1440 px, estados, navegación protegida y conservación del controller al reconstruir la ruta. El controller se crea una vez por pantalla y se libera al salir; esto corrige una bandeja sin cargar al abrir la URL directamente durante la inicialización de sesión.
- Build final revisado en navegador a 1280×720 y 375×812: carga automática, cambio leído/no leído, contador, desplazamiento hasta el último aviso y footer. Estado conservado al redimensionar, sin errores/avisos en consola. Se restauró el tamaño habitual y no se recargó la pestaña del formulario del usuario.

Desde el repositorio de pacientes, con Java, Firebase CLI y Chrome disponibles:

```sh
flutter analyze
flutter test
firebase emulators:exec --config ../2daopinion-panel/firebase.json --only auth,firestore --project demo-2daopinion "flutter test --platform chrome test/integration/notices_emulators.dart --reporter expanded"
flutter build web
```

Para reglas, desde el repositorio del panel: `npm run test:rules`.

## Pendiente / activación

DEV-037 no está completo: faltan productor confiable de avisos, deduplicación de eventos en origen, vinculación a transiciones reales y detalle/enlaces autorizados. La deduplicación de páginas no sustituye la de eventos. DEV-013 y canales A21 siguen abiertos. No hay emisión automática, push, email, avisos en segundo plano ni solicitudes adicionales de permisos al dispositivo.

No se desplegaron reglas, Hosting, Functions ni Storage; no se crearon recursos ni cambió facturación. Google sigue apagado. No publicar todas las reglas locales por inercia: contienen también cambios de archivos E2-06/E2-07 aún no autorizados para remoto. Antes de activar avisos: resolver productor/IAM, migración de esquemas, eventos, política de retención, permisos y verificación aislada en desarrollo. No habilita atención clínica ni recetas reales.
