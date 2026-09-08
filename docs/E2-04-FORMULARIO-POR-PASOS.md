# E2-04 · Formulario por pasos y revisión

8 de septiembre de 2026 · Desarrollo con datos ficticios

## Resultado

La solicitud pública y el borrador privado comparten un recorrido de cuatro pasos:

1. **Consulta:** motivo, detalles, medicamentos, tratamientos especiales y propuestas previas.
2. **Antecedentes:** edad/contexto, diagnóstico conocido o sospechado, síntomas/evolución, antecedentes y alergias.
3. **Preferencias:** preguntas, estudios disponibles, especialidad y modalidad orientativa.
4. **Revisión:** resumen por secciones con acceso para editar cada una.

Se puede avanzar, retroceder o seleccionar un paso directamente. La barra indica la posición del recorrido, no suficiencia clínica ni porcentaje de campos completos. Los campos vacíos se muestran como «No informado»; nunca se interpreta un campo de alergias vacío como ausencia de alergias. La modalidad sin selección conserva «Necesito orientación».

Es una adaptación de la solicitud incompleta de Figma. Conserva el tema, la tipografía, los componentes adaptables y el footer inferior, con espacio reservado para no tapar las acciones. La vista previa histórica aislada en `/preview/request` no usa este recorrido conectado.

## Continuidad y guardado

- El visitante conserva los campos en memoria al cambiar de paso. «Continuar con mi cuenta» solicita acceso; después de completar el acceso y perfil puede revisar el contenido antes de guardarlo.
- Si existe un borrador remoto, se mantiene la elección explícita entre ese borrador y el contenido del visitante, sin sobrescritura automática.
- La cuenta verificada puede ir directamente a «Revisar para guardar» y guardar un borrador incompleto. El primer guardado exige la aceptación de almacenamiento de desarrollo ya existente.
- Durante el guardado se bloquean los cambios de paso y las ediciones. Solo una confirmación del repositorio permite mostrar el resultado guardado.
- Recargar la versión guardada conserva la confirmación de descarte de cambios locales y reinicia el recorrido con los valores recuperados.
- Cambiar de paso no consulta ni escribe en Firebase. No hay guardado automático. Recargar o cerrar la pestaña puede perder los cambios sin guardar y todo el formulario del visitante.

## Capas

- `ConsultationStepsController`: posición, límites y notificación de cambios; sin acceso a repositorios ni navegación visual.
- `GuestRequestScreen` / `DraftRequestScreen`: composición, ciclo de vida, foco y desplazamiento.
- `ConsultationWizard`: pasos, progreso, acciones y conservación de los widgets ocultos sin foco.
- `ClinicalContextFields`: una única instancia conserva los controladores de ambas secciones clínicas.
- `ConsultationReview`: presentación reutilizable del contenido de dominio y accesos de edición.

Modelos, adaptadores, permisos y esquema Firestore no cambian. Los textos nuevos se localizan en ARB. No se crean APIs, funciones, índices ni recursos remotos.

## Verificación

Se incorporan pruebas del controller, conservación de todos los campos y modalidad en anchos de 320 y 1440 px, edición desde la revisión, campos vacíos, bloqueo durante guardado y recarga de una versión remota. Se adaptan las pruebas existentes de continuidad del visitante y borradores al recorrido por pasos.

Resultado: formato y análisis sin incidencias, 81 pruebas Flutter aprobadas y compilación web correcta. Recorrido público inspeccionado en el navegador local: pasos, revisión, edición y footer. No se ejecutan de nuevo ni se despliegan reglas Firebase porque esta entrega no modifica datos, permisos ni infraestructura.

## Límites y siguiente bloque

Esta revisión no envía un caso, valida su suficiencia clínica ni habilita atención. Google permanece preparado y desactivado. Documentos, asignación, pagos y emisión de recetas no se habilitan aquí; receta sigue dentro del MVP pendiente de sus requisitos profesionales y legales.

Siguiente bloque: revisar el formulario con dirección médica y definir el consentimiento de solicitud, estados y permisos del envío antes de habilitar el circuito paciente–panel. Hosting público continúa pendiente; la compilación local no equivale a un despliegue.
