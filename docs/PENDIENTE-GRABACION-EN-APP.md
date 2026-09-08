# Próximo paso · Grabar el video dentro de la aplicación

8 de septiembre de 2026 · Solicitud de Ronel · Parcial: grabación web implementada en [E2-09](E2-09-GRABACION-WEB.md); captura nativa y validación con hardware real pendientes. Los criterios siguientes conservan la decisión original.

## Decisión

Reemplazar adjuntar un video existente por grabación directa dentro de la aplicación. Sigue siendo opcional y de hasta 30 segundos. No reemplaza el formulario ni los estudios. La documentación permitida continúa siendo JPG/JPEG, PNG, DOC, XLS y PDF.

## Criterios de aceptación

- Botón «Grabar video» separado de los estudios; reemplaza «Adjuntar video», sin conservar ese mecanismo como alternativa por inferencia.
- Explicación y permisos de cámara/micrófono únicamente tras pulsar el botón, nunca al entrar en la página.
- Vista de cámara, inicio explícito, contador visible, detener y corte automático a los 30 segundos.
- Revisar la grabación, descartar, volver a grabar y confirmar su uso antes de incorporarla a la solicitud.
- Permisos denegados, cámara ausente o navegador incompatible: explicar el problema y permitir continuar sin video.
- Liberar cámara, micrófono y recursos al cancelar, salir o cerrar sesión. No guardar bytes en almacenamiento local del navegador ni subirlos automáticamente.
- Mantener límites de tamaño/cuota, capas separadas y contrato de captura con adaptadores por plataforma.
- Verificar compatibilidad web y móvil: no asumir que todos graban MP4/MOV. Resolver contenedor/MIME antes de conectar con las reglas actuales; no habilitar formatos nuevos ni conversiones remotas silenciosamente.
- Probar denegación, interrupción, duración máxima, regrabación, tamaño, limpieza de dispositivos y conservación del formulario.

## Estado

E2-09 reemplaza el selector visible de E2-07 por grabación en navegadores web compatibles con MP4. La carga remota sigue apagada y las pruebas de captura real requieren el permiso correspondiente. La captura nativa y la validación completa por plataforma siguen pendientes; no se declara DEV-044 terminado.
