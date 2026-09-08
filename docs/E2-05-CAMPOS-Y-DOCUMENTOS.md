# E2-05 · Campos y selección múltiple de documentos

8 de septiembre de 2026 · Desarrollo exclusivamente con datos ficticios

## Cambios

- Medicamentos, síntomas, alergias y preguntas usan chips reutilizables. Coma, Enter o + agregan elementos; × los quita. Permite pegar varios separados por comas. El texto sin confirmar también se conserva entre pasos y al continuar con una cuenta.
- «Síntomas y evolución» pasa a «Síntomas», con una explicación sencilla que invita a indicar cuándo empezó cada síntoma.
- Fecha de nacimiento con calendario: fecha civil real desde 1900 hasta el día actual UTC; rechaza fechas futuras. Puede quedar vacía en el borrador. No se pide edad numérica libre.
- Detalles de consulta muestra inicialmente cuatro líneas y diagnóstico tres. Ambos permiten texto extenso. Contadores visibles y límite conservador de 4000 unidades UTF-16 por campo; en chips aplica al conjunto, incluidos separadores.
- Estudios usa selección múltiple real del dispositivo. El botón dice «Seleccionar varios archivos», luego «Agregar más archivos», con contador y lista de todos los seleccionados. Cada archivo toma su nombre como título inicial y permite editarlo o quitarlo individualmente.

## Archivos: selección local, NO carga remota

Límites provisionales de desarrollo: PDF/JPG/PNG, hasta 20 archivos, 5 MiB por archivo y 50 MiB en total. Título no vacío de hasta 120 unidades UTF-16. Estos límites protegen memoria del navegador; no son cuotas comerciales ni de Storage. El límite inicial de cinco archivos queda reemplazado tras la observación de Ronel de que un paciente puede aportar muchos estudios.

El adaptador verifica extensiones, cantidad y tamaños antes de leer bytes. El controller vuelve a validar los límites del lote y del conjunto. Un lote inválido se rechaza completo sin perder los archivos anteriores. Seleccionar otro grupo agrega, no reemplaza, el listado. La extensión no prueba seguridad ni validez clínica del archivo.

Los bytes permanecen solo en memoria y acompañan el recorrido y la continuación visitante–cuenta. Al cerrar sesión/cambiar de usuario se limpian y se descartan resultados de selectores anteriores. Al elegir el borrador remoto en vez del contenido visitante se descarta su selección local. Recargar o cerrar la pestaña pierde estos archivos.

**Guardar borrador guarda únicamente campos, NO los archivos seleccionados.** Preferencias y revisión lo indican junto al estado «Pendiente de subir». No hay cargas anónimas, URLs públicas, almacenamiento persistente local ni bytes/Base64 en Firestore. El título de un archivo local tampoco se guarda remotamente en esta entrega.

Carga privada en Storage sigue pendiente: contrato de documento con ID estable y ubicación independiente, permisos por caso, integridad, retención y reconciliación según ADR-004. No se crean buckets ni se cambia facturación. No se presenta una selección local como una carga exitosa.

## Compatibilidad y Firebase

Se preservan las cadenas existentes de medicamentos/síntomas/alergias/preguntas; los chips nuevos se serializan separados por salto de línea. El texto histórico con comas se conserva como un elemento, sin inferir divisiones clínicas. Una normalización futura podrá trasladarlos a registros relacionados sin interpretar de nuevo las comas del texto histórico.

`clinicalContext.birthDate` es opcional en el esquema 1: mapa con enteros `year`, `month`, `day`. El dominio usa una fecha civil Dart, no Timestamp ni edad calculada persistida. Reglas y dominio rechazan fechas inexistentes/futuras y el mapa no admite claves extra. Los borradores sin fecha siguen siendo válidos.

Se conserva el contexto libre anterior como «Contexto adicional del paciente», sin inferir nacimiento desde una edad escrita. Si había descripción de estudios, se mantiene visible/editable como descripción histórica y en revisión; no se inventa un archivo ni se elimina texto.

El límite de producto queda muy por debajo del máximo de documento de Firestore de 1 MiB. Los archivos permanecen separados de la base. [Cuotas oficiales de Firestore](https://firebase.google.com/docs/firestore/quotas), consultadas el 08/09/2026.

## Capas y verificación

Controllers separados para chips y selección de archivos; widgets reutilizables para chips, calendario, listado y diálogo de título. El controller de archivos recibe `DocumentSelectionRepository`; el adaptador local utiliza [file_selector de Flutter](https://pub.dev/packages/file_selector). `ConnectedApp` inyecta y limpia el estado. Vistas y dominio no acceden al SDK del selector ni Firebase.

96 pruebas Flutter y 71 pruebas de reglas aprobadas. Cubren Unicode/límites, pegado y eliminación de chips, conservación entre pasos, compatibilidad anterior, fechas bisiestas/futuras, lotes múltiples, rechazo atómico por cantidad/tamaño, edición individual de títulos, limpieza por sesión y aislamiento entre pacientes. Pruebas visuales automatizadas a 320/1440 px, junto al recorrido responsive existente.

Reglas Firestore publicadas exclusivamente en `segundaopinion-ea0c8` desde el panel; sin cambios de índices, Storage, Hosting o Functions. Google sigue desactivado. No se habilitan atención, pagos ni recetas reales; receta continúa dentro del MVP. La web sigue siendo una compilación local, no una publicación pública.
