# Flujo clínico del integrante 1

Desde **Pacientes → Planes de tratamiento**, crear un presupuesto con al menos dos ítems. Cada ítem permite elegir un tratamiento activo, indicar una pieza FDI opcional y ajustar el precio sugerido. El cotizador suma céntimos enteros y envía precios decimales exactos al backend.

El presupuesto se crea como borrador. Pulsar **Aprobar presupuesto** para registrar sesiones pendientes, en curso o realizadas. La respuesta del servidor actualiza inmediatamente total, contador y estado del plan. Cancelar conserva el presupuesto y el avance registrado.

Desde el diálogo de estado de una cita, elegir **Atendida** y activar **Registrar automáticamente en el Historial Médico**. Se requiere un tratamiento vinculado. El indicador está apagado por defecto; el backend evita duplicados al repetir la operación.

**Historial médico** muestra la fecha de la cita para las entradas automáticas y la fecha de creación para las entradas manuales. El botón **Nueva evolución** está en la cabecera; **Actualizar historial** permite recargarlo. Al volver a abrir la pantalla se consulta de nuevo el historial.

El módulo `lib/patientAttention/treatment_plans/` separa modelos y casos de uso de dominio, servicio/DTO/repositorio/DI de datos y vistas/viewmodel/widgets de presentación. Reutiliza la paleta `AppColors` y la autenticación existente, sin dependencias adicionales.

## Verificación

Usar Flutter 3.47.9, la versión fijada por CI:

```text
flutter pub get
flutter analyze --no-fatal-infos --no-fatal-warnings
flutter test
```

Las pruebas clínicas verifican importes y serialización, errores de la API, el interruptor de historial y el cotizador a 375 y 1280 píxeles. Para comprobar el recorrido completo se necesita el backend con datos del catálogo y un usuario autenticado.
