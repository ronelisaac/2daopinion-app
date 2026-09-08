# E1-04 / E2-03 · Acceso progresivo y formulario ampliado

08/09/2026 · Entorno de desarrollo. Esta entrega combina las tres prioridades indicadas por Ronel: acceso/onboarding, recorrido de visitante y más contexto para el médico.

## Decisiones vigentes

| Decisión | Implementación y límite |
| --- | --- |
| Únicos métodos previstos: correo y Google | Facebook retirado de los botones. Correo operativo; Google preparado y **desactivado**, por confirmación posterior de Ronel. |
| Home y preparación del formulario públicas | `/`, `/home` y entrada de visitante a `/request`. No equivalen a abrir Firestore a usuarios anónimos. |
| Acceso solicitado al continuar | Permite ingresar o crear cuenta y retomar el contenido en la misma ejecución de la app. No hay escritura automática ni envío. |
| Onboarding de cuenta | Registro por correo con nombres, contraseña y aceptación; completar perfil cuando falta, y verificación de correo antes de guardar. Indicador visual de etapas; el correo recopila datos en el mismo formulario, Google utilizará el paso de perfil. |
| Formulario más completo | Campos adicionales opcionales, sujetos a validación de dirección médica antes del uso real. |

## Recorrido y privacidad

1. El visitante entra a la home y comienza el formulario sin cuenta.
2. `GuestDraftController` mantiene el contenido exclusivamente en memoria de esta instancia de la app. No usa Firestore, Auth anónimo, cookies, localStorage, sessionStorage, URL ni Analytics para el formulario.
3. Al pulsar Continuar con mi cuenta, conserva todos los campos y abre acceso. Cancelar el acceso no borra el formulario.
4. Tras correo/registro, la continuación espera perfil y correo verificado. La transición de sesión muestra carga antes de montar el formulario privado; los eventos de identidad sin cambios se deduplican.
5. Si ya existe un borrador remoto, se solicita elegir qué contenido revisar. El remoto solo cambia después de guardar explícitamente, manteniendo la revisión esperada. Elegir conservar el remoto descarta expresamente el contenido de visitante.
6. El primer guardado requiere la aceptación independiente de almacenamiento de pruebas. No se supone aceptada por iniciar sesión, crear cuenta ni completar campos.

**Límite explícito:** recargar/cerrar la pestaña, reiniciar la app o abrir el flujo en otra pestaña puede perder el formulario del visitante. La memoria no es persistencia durable. Logout/cambio de usuario limpia el traspaso pendiente; no se reutiliza para otra cuenta. Se mantiene SESSION para Auth web y caché persistente de Firestore desactivada. El texto del borrador nunca aparece en el resumen de home.

Las pantallas `/preview` y `/preview/request` conservan el ejemplo visual histórico aislado. El recorrido nuevo se prueba desde `/home`, no desde ese formulario demostrativo.

## Campos del formulario

Se conservan motivo, detalles, medicamentos, tratamientos especiales y propuestas previas. Los nuevos campos se agrupan en Contexto para el especialista y Qué necesitas resolver:

| Campo | Finalidad |
| --- | --- |
| Edad y contexto del paciente | Edad aproximada y contexto relevante, sin pedir identidad ni contacto en texto libre |
| Diagnóstico conocido o sospechado | Lo informado previamente y su referencia temporal |
| Síntomas y evolución | Inicio, cambios, frecuencia e impacto cotidiano |
| Antecedentes relevantes | Enfermedades, cirugías, hospitalizaciones o historia familiar relacionada |
| Alergias y reacciones | Sustancia y reacción conocida; no asumir ausencia si está vacío |
| Preguntas al especialista | Dudas y decisiones que se desean revisar |
| Estudios disponibles | Tipo y fecha aproximada de estudios e informes; no carga de archivos |
| Especialidad solicitada | Texto libre o «No sé qué especialidad necesito», pendiente de clasificación humana |
| Modalidad preferida | Orientación, revisión documental o revisión + consulta; no implica contratación |

Cada texto admite hasta 4.000 caracteres. Se permiten borradores incompletos. Un campo vacío significa no informado. El formulario no hace diagnóstico, triage automatizado, recomendaciones terapéuticas ni comprobación de suficiencia clínica. Informa que no atiende urgencias. La admisión por especialidad, representación de familiares/menores, mínimos para envío y revisión clínica siguen pendientes.

Base funcional: plan maestro, secciones 6, 8 y 21. Apoyo general para preparar antecedentes y preguntas: [Mayo Clinic — preparación de una consulta](https://www.mayoclinic.org/patient-visitor-guide/how-to-make-the-most-of-your-appointment). Esta referencia no valida el formulario como instrumento clínico.

## Modelo portable y reglas

`ConsultationDraft.clinicalContext` es un objeto Dart puro con los campos anteriores. El adaptador lo serializa como `clinicalContext`, un mapa con `schemaVersion: 1`, ocho strings y `modality` con códigos estables: vacío, `document_review`, `review_and_consultation`. No contiene tipos Firebase.

Los borradores antiguos sin mapa siguen siendo legibles/editables. Al guardar desde la nueva app se agrega el mapa; una actualización parcial de un cliente anterior conserva el mapa existente. En PostgreSQL puede convertirse en columnas o una tabla relacionada mediante el ID estable del borrador, sin rehacer las vistas.

La fuente única de reglas es el panel. Valida versión, claves exactas, tipos, tamaños, modalidad, propietario verificado, perfil, revisión y aceptación atómica. No se permiten lecturas/escrituras anónimas, listados globales, modificaciones de propietario ni estados clínicos. Reglas de desarrollo ampliadas y publicadas únicamente mediante `firestore:rules`; no se cambia facturación, Hosting ni Storage.

Revisión compatible de reglas del panel: `532649c` (publicada en desarrollo y subida a GitHub antes de esta entrega de pacientes).

## Google preparado, no activo

Contrato `AccountRepository.signInWithGoogle`, coordinación en controller y adaptador Firebase web con ventana emergente. No se agregan permisos de contactos, calendarios u otros servicios. Maneja cancelación, bloqueo de ventana, configuración pendiente y conflictos sin vincular cuentas manualmente ni sobrescribir perfiles.

Por defecto `ENABLE_GOOGLE_SIGN_IN` es false. El adaptador rechaza localmente antes de llamar al SDK. Para activarlo más adelante: confirmar autorización, habilitar Google y dominios permitidos del proyecto Firebase, revisar nombre/correo de soporte y construir con la opción habilitada. **No basta con cambiar la opción de compilación.** La consola se inspeccionó sin guardar cambios. No se probó un acceso real con Google ni se solicitan credenciales.

Referencia técnica: [Firebase — acceso federado en Flutter](https://firebase.google.com/docs/auth/flutter/federated-auth). La integración implementada es web; configuración y validación nativas Android/iOS siguen pendientes.

## Diseño y validación

Verificación final: análisis sin incidencias, 75 pruebas Flutter y 61 pruebas de reglas aprobadas; compilación web correcta. Revisión del build local en navegador: home pública, formulario ampliado, acceso solicitado al continuar, registro con aceptación y aviso local de Google desactivado. No se realizó un login Google real ni un alta remota durante la revisión.

Se reutilizan fotografía, logos, Montserrat, colores, botones, campos y footer del proyecto. Se revisó Figma `1:42` para el registro; ampliaciones sobre el boceto: selección clara de acceso/registro, mostrar/ocultar contraseña, progreso de onboarding, explicación para visitantes y contexto clínico adicional. Widgets y vistas separados, controllers sin BuildContext y adaptadores fuera del dominio.

Las pruebas cubren conservación por login/registro/verificación, cancelación de acceso y resize, conflicto con borrador existente sin sobrescritura automática, compatibilidad del mapa y límites, privacidad y desactivación de Google. Las pruebas del recorrido conectado usan contratos falsos; las reglas se verifican con emulador. No se registraron pacientes ni se usaron datos clínicos reales.

Pendientes: textos legales definitivos y validación clínica, carga privada de documentos, envío/asignación, pagos, notificaciones, informes y recetas profesionales. Receta continúa dentro del MVP, no operativa aún.
