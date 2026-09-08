# E1-03 · Identidad y perfil de desarrollo

Fecha: 08/09/2026. Entrega parcial de E1; no equivale a lanzamiento clínico.

## Implementado

- Correo/contraseña con Firebase Authentication, recuperación por enlace, verificación solicitada explícitamente y cierre de sesión.
- Registro exige checkbox inicialmente vacío y versión `dev-access-2026-09-08` antes de crear una cuenta. Los textos son condiciones provisionales del entorno de pruebas, NO términos clínicos aprobados.
- Una transacción Firestore crea perfil y aceptación. Si Auth se crea y el perfil falla, el usuario puede completar su perfil al volver a ingresar, sin crear otra cuenta.
- Perfil básico editable; puerta de acceso exige perfil y correo verificado. Rutas privadas bloqueadas en carga/error/sesión ausente. Logout limpia perfil en memoria y la pila de navegación.
- Acerca de, privacidad provisional y footer reutilizable. Widgets/vistas/controllers/dominio/repositorios separados. Firebase limitado al adaptador y composición.
- Persistencia de sesión web durante la pestaña, no una opción «recordarme». Perfil remoto sobrevive al logout; Firestore sin caché persistente en disco. Borradores de consultas todavía NO persisten.

## Contrato de datos

`profiles/{authUserId}`: `id` independiente de 20 caracteres; `authUserId`; `firstName`; `lastName`; `countryCode`; `locale`; `policyVersion`; `createdAt`; `updatedAt`.

`profiles/{authUserId}/consents/{policyVersion}`: `authUserId`, `policyVersion`, `context=development-registration`, `accepted=true`, `acceptedAt` del servidor.

Para una futura migración, el ID de dominio no cambia si se reemplaza Auth; consentimientos se exportan como filas con relación al perfil. Tipos de Firebase no salen del adaptador. País y locale se inyectan separadamente; las reglas iniciales aceptan únicamente CL/es. Agregar países/versiones requiere actualizar configuración, reglas, textos y pruebas; no basta cambiar la interfaz. No existe aún un flujo de reaceptación de versiones futuras.

## Seguridad y límites

Cada paciente solo obtiene su propio perfil y consentimiento; no puede listar perfiles, cambiar IDs/país/versión, autoconcederse roles, alterar fechas ni borrar aceptación. Solo puede editar nombres. Perfil y aceptación inicial se escriben juntos con hora del servidor.

El propio perfil puede completarse antes de verificar el correo. Eso NO concede permisos sobre casos, documentos, pagos o recetas: esas colecciones siguen denegadas para todos los clientes. No hay roles administrativos provisionados, auditoría clínica completa, App Check obligatorio, carga de archivos o API propia en esta entrega.

No registrar contraseñas, tokens o información clínica. Mensajes de acceso/recuperación no afirman si una cuenta existe. Textos legales definitivos, responsable y contacto de privacidad, retención/borrado y consentimiento clínico requieren definición antes de producción.

## Validación

- 41 pruebas Flutter aprobadas: arquitectura, controllers, validación, responsive y widgets; incluye cierre desde perfil a 375/1440 px y descarte de respuestas tardías tras logout.
- 21 pruebas Firestore aprobadas en proyecto ficticio `demo-2daopinion`: anonimato, aislamiento, escritura atómica, campos permitidos, datos inmutables, consentimiento y bloqueo clínico/financiero.
- Análisis Flutter sin incidencias; compilación web correcta.
- La comprobación del build conectado detectó un registro generado de plugins obsoleto en la caché de Flutter. Se regeneró con limpieza, resolución de dependencias y compilación completa, sin modificar el SDK ni registrar plugins manualmente. Los artefactos generados no se versionan.
- Prueba de navegador con Auth y Firestore emulados: rechazo sin aceptación, creación atómica, enlace de verificación, ingreso, edición persistida y sesión conservada al recargar en debug/localhost. Sin correos externos ni usuarios clínicos reales.
- Restricción del SDK Auth web detectada al recargar una compilación release con emuladores: el emulador debe restaurarse antes de la identidad. Se utiliza debug/localhost, combinación soportada por el SDK; se bloquea iniciar una compilación release con `USE_FIREBASE_EMULATORS=true`.

## Infraestructura y pendientes

Proyecto remoto de desarrollo: `segundaopinion-ea0c8`; Authentication correo/contraseña habilitado. Reglas de perfiles compiladas/publicadas mediante despliegue limitado a `firestore:rules`; lectura remota anónima de perfil rechazada con HTTP 403. Fuente de reglas e índices: repositorio panel. Hosting público, dominio propio, Storage y producción limpia pendientes; no se publica en un subdominio Firebase sin cambiar la decisión de Ronel.

Presupuesto existente: alertas de USD 10 mensuales, NO límite duro de gasto. Esta entrega no cambia facturación ni PetHostelApp.

Próximo bloque: solicitud persistente con aceptación clínica separada, home con casos activos y avisos. Receta sigue comprometida en MVP, sujeta a implementación y requisitos profesionales/legales; no se emite automáticamente.
