# E2-02 · Home y resumen del borrador

08/09/2026 · Desarrollo únicamente. Avance parcial de la home con solicitudes; no habilita consultas enviadas ni atención clínica.

## Entrega

- Segunda fila reutilizable debajo de los servicios del inicio. Conserva colores, tipografía, adaptación responsive y footer inferior sin superposición.
- Estados distintos: consultando, sin borrador, borrador guardado y error de lectura. Un error no se presenta como ausencia de datos.
- Resumen de un borrador por cuenta: fecha del último guardado, estado «Borrador · Sin enviar», indicación de motivo/detalles completos o pendientes y botón para retomarlo. Completar esos campos no significa estar listo para atención médica.
- La home no muestra motivo, detalles, medicamentos ni otros textos del formulario. El adaptador existente lee el documento propio y el controller conserva únicamente fecha e indicador de campos principales; no se trata de una proyección del servidor.
- Tanto el servicio Consulta médica como el botón del resumen abren el mismo formulario conectado. Al regresar, se consulta de nuevo la versión guardada, también si se abandonaron cambios locales.
- Actualización puntual al montar la home, regresar del formulario y pulsar Actualizar. Sin sondeo, listeners continuos, nueva caché ni escrituras de resumen. Las actualizaciones de otra pestaña se consultan manualmente.
- En `/preview`, el ejemplo está identificado como ficticio y abre exclusivamente `/preview/request`; no lee ni escribe borradores de cuentas.

## Capas y permisos

`PatientHomeScreen` compone y navega; `DraftOverviewCard` presenta; `DraftOverviewController` coordina estados; `DraftOverview` contiene metadatos de dominio. Se reutiliza `ConsultationDraftRepository` inyectado con su adaptador Firebase existente. No se añade una API propia ni se acopla la vista a Firestore.

La home privada conserva los requisitos de identidad verificada y perfil. Al desmontarla por cierre/cambio de sesión, el controller descarta respuestas tardías; las cargas anteriores tampoco pueden reemplazar una consulta más reciente. No se cambian reglas, índices, estructura de datos, versiones de aceptación ni servicios remotos.

Cada actualización solicita una lectura puntual del borrador al servidor; pueden existir lecturas de reglas y costos asociados. No se promete costo cero ni un límite duro de facturación.

## Validación

Análisis sin incidencias, 64 pruebas Flutter aprobadas y compilación web correcta. Comprobación del build local en navegador: resumen visible, enlace al formulario de ejemplo y retorno, adaptación a 375 px y footer sin superposición. No se crearon usuarios ni se usaron datos clínicos reales; las pruebas del flujo conectado usan repositorios falsos y conservan el adaptador/permisos de la entrega anterior.

Las pruebas cubren estados vacío/guardado/error/carga, respuestas fuera de orden, descarte tras dispose, navegación y actualización al volver, actualización manual, cierre de sesión, aislamiento del ejemplo y ausencia de campos privados en el resumen. Widgets verificados en 375/1440 px con texto normal y ampliado al doble, preservando el footer fuera del contenido.

## Pendiente

Listado de casos activos reales, estados clínicos, consentimiento definitivo, envío y asignación médica, archivos privados, notificaciones/alertas, pagos e informes/recetas. El resumen actual no debe contabilizarse como consulta activa ni caso enviado en los KPIs. Próxima entrega: definir e implementar el flujo de casos con sus permisos; no cambiar solo una etiqueta de borrador a enviado.
