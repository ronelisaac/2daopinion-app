# E2-01 · Borrador persistente de solicitud

08/09/2026 · Desarrollo únicamente. Avance parcial de DEV-010/034/039; no habilita atención clínica.

## Entrega

- Desde Consulta médica, una cuenta con perfil y correo verificado puede crear, guardar y retomar un borrador. Se permiten campos incompletos; el guardado no equivale a envío.
- Un único borrador por cuenta en esta etapa; cinco campos de hasta 4.000 caracteres cada uno. Sin autosave, sin caché persistente de Firestore, sin archivos ni pagos.
- Primera escritura requiere aceptación independiente `dev-draft-storage-2026-09-08`, vinculada al ID del borrador. Perfil/registro y borrador tienen registros de aceptación distintos. Esta aceptación autoriza solo almacenamiento ficticio de pruebas, no consentimiento clínico ni términos comerciales aprobados.
- Guardar informa éxito solo después de confirmar la escritura en el servidor. Errores mantienen el texto local; una respuesta perdida puede significar que el servidor guardó, por lo que se ofrece recarga explícita y no se promete que la operación se revirtió.
- Revisión incremental y transacción previenen sobrescrituras silenciosas entre pestañas. Ante conflicto, se conserva lo escrito y se pide revisar la versión guardada. Recargar o salir mediante navegación interna solicita confirmación si hay cambios locales.
- Recargar/cerrar el navegador no garantiza conservar cambios NO guardados. El aviso del formulario lo aclara. Logout elimina contenido visible y la ruta privada; no borra el borrador remoto.

## Modelo portable

`consultationDrafts/{authUserId}`: `id` de dominio generado independientemente; `authUserId`; `patientId` del perfil; `countryCode`; `status=draft`; `environment=development`; `policyVersion`; `reason`; `details`; `medicines`; `specialTreatments`; `previousProposals`; `revision`; fechas `createdAt/updatedAt` del servidor.

`consultationDrafts/{authUserId}/consents/{policyVersion}`: `draftId`, `authUserId`, `policyVersion`, `context=development-draft-storage`, `accepted=true`, `acceptedAt` del servidor.

El UID en la ubicación impone un borrador por cuenta, no define su ID de dominio. En una migración se exportan borradores y aceptaciones a tablas relacionadas por IDs estables. Dominio usa strings/DateTime/int; Firestore Timestamp y transacciones quedan en el adaptador. Se inyectan contratos; no se crea una API propia.

## Permisos y costos

Solo el propietario verificado con perfil puede leer o editar. No puede listar borradores, modificar propietario/ID/paciente/país/estado/aceptación, saltar revisiones, borrar el borrador o escribir colecciones de casos, pagos, recetas o documentos. Creación de borrador y aceptación es atómica. Se mantiene CL como país inicial.

No hay búsqueda ni listeners continuos: lecturas puntuales y guardado manual. Una transacción lee borrador/perfil y hace sus escrituras; la confirmación añade una lectura. Reintentos y reglas también pueden generar consumo. El presupuesto USD 10 sigue siendo de alertas, no un corte duro.

La limitación a contenido ficticio es una condición de uso: las reglas validan campos/permisos, no pueden determinar si un texto corresponde a una persona real. No utilizar este desarrollo con pacientes reales.

## Validación

- 50 pruebas Flutter: capas, límites, aceptación, persistencia con contrato falso, carga fallida, concurrencia, errores, cierre de sesión y diseño 375/1440 px; suites anteriores conservadas.
- 50 pruebas de reglas en emulador: 21 de perfil y 29 de borrador, con aislamiento entre usuarios, correo verificado, escritura atómica, invariantes y límites.
- Recorrido de navegador contra emuladores de Auth/Firestore con identidad ficticia: guardado de borrador incompleto, recuperación tras recargar, escritura concurrente desde otro cliente, aviso de conflicto conservando texto local y confirmación antes de recargar. Datos reales no utilizados.
- Los conflictos de dominio se devuelven como resultado dentro de la transacción y se traducen fuera de ella: evita que el adaptador web transforme una excepción propia en un error genérico de red.
- Compilación web y análisis revisados antes de publicar. Reglas compiladas y publicadas en `segundaopinion-ea0c8` mediante `firestore:rules`. Fuente única en repositorio panel; no se desplegó Hosting ni se modificaron otros servicios.

## Pendiente

Consentimiento clínico y términos definitivos, envío/transiciones de caso, asignación profesional, documentos privados, listado de casos activos, notificaciones y recetas. No hay borrado remoto desde UI ni historial completo de revisiones; la revisión actual es control de concurrencia, no auditoría clínica completa. Nuevas versiones de aceptación requerirán un flujo explícito, no reemplazar textos aceptados silenciosamente.

Siguiente entrega sugerida: resumen de borrador/casos en home y diseño de estados; carga documental solo después de configurar Storage privado y requisitos de uso.
