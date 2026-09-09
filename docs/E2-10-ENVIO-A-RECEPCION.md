# E2-10 · Envío a recepción

Implementación local con Firebase emulado: copia privada del borrador guardado, aceptación independiente, envío atómico con resumen administrativo y comprobante recuperable. Widgets, controller, contrato y adaptador separados.

Solo USE_FIREBASE_EMULATORS=true en debug; el build normal no activa nuevos envíos. Una recepción por cuenta en esta etapa, solo texto. Archivos seleccionados o reservas de adjuntos impiden enviar para evitar omisiones silenciosas. No hay médico asignado, pagos, atención ni consentimiento clínico definitivo. Editar el borrador no cambia lo enviado.

Fuente única de esquema, permisos, límites, activación pendiente y pruebas: [E2-10 en panel](../../2daopinion-panel/docs/E2-10-RECEPCION-DE-SOLICITUDES.md). Las pruebas conjuntas corren sobre ambos adaptadores con Auth/Firestore emulados, no simuladores de usuarios en el producto.
