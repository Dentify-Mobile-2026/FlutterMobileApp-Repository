# 📋 Guía de Ejecución y Plan de Evolución · Dentify Flutter (Front-End)

Esta guía contiene:
1. Las instrucciones paso a paso para ejecutar la aplicación Flutter en tu entorno local.
2. El **Plan de Evolución por Fases y Justificación de Diseño/Arquitectura**, listo para documentar los cambios en el informe del proyecto.

---

## Parte I: Ejecución Local del Front-End

### 1. Requisitos
- **Flutter SDK 3.27+** (`flutter doctor`)
- **Google Chrome** instalado
- **Backend de Dentify** activo en `http://localhost:8080`

### 2. Pasos para Iniciar

1. Abre una terminal en la carpeta del proyecto:
   ```bash
   cd FrontFlutter
   ```
2. Descarga las dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecuta en Chrome en el puerto `8081`:
   ```bash
   flutter run -d chrome --web-port=8081
   ```
4. Accede desde tu navegador a: **`http://localhost:8081`**

### 3. Credenciales de Prueba (Con Datos Clínicos Sembrados)
- **Usuario:** `dentist1`
- **Contraseña:** `password123`

---

## Parte II: Justificación Funcional, UI/UX y Plan de Fases

### 🔍 ¿Por qué se rediseñó y amplió el alcance del Front-End?

Al evaluar la versión inicial de la aplicación, se identificaron tres limitaciones importantes que justifican la actualización del documento de diseño:
1. **Datos clínicos insuficientes en la vista de Pacientes:** Un odontólogo necesita visualizar de inmediato si el paciente es **alérgico a la penicilina, anestesia (lidocaína) o látex**, o si padece **hipertensión, diabetes o problemas de coagulación** antes de iniciar cualquier intervención. Además, se requería teléfono/WhatsApp y contacto de emergencia.
2. **Falta de Catálogo de Tratamientos Dentales:** Al agendar una cita, el usuario debía escribir manualmente el motivo y calcular la duración sin referencia a un catálogo estandarizado de procedimientos odontológicos.
3. **Flujo de Citas estático:** Las tarjetas de cita solo mostraban un texto `Completed: true/false` sin permitir gestionar estados reales de atención (`Agendada`, `Confirmada`, `En Atención`, `Atendida`, `Cancelada`, `No Asistió`) ni registrar las **notas de evolución clínica** de la sesión.

---

### 🗺️ Plan de Evolución en 3 Fases

| Fase | Estado | Mejoras en FrontFlutter y Arquitectura | Valor Agregado |
|---|---|---|---|
| **Fase 1: Flujo Clínico y Diseño Renovado** | ✅ **Implementada (Rama `dev`)** | **1. Módulo de Pacientes Pro:** Indicadores superiores de pacientes con alerta médica, filtro rápido *"Solo Alertas"*, chips interactivos de alergias/condiciones en el formulario y badges visuales de riesgo clínico en cada tarjeta.<br>**2. Nuevo Módulo de Tratamientos (`/treatments`):** Arquitectura limpia completa (`data`/`domain`/`presentation` con Riverpod), filtro por especialidad odontológica, arancel en `S/.` y duración en minutos.<br>**3. Agenda Clínica con Estados y Evolución:** Selector de tratamiento que autocompleta motivo y duración al crear citas, filtros por estado con contadores en vivo y diálogo de **Estado y Evolución Clínica**. | Flujo odontológico completo, interfaz moderna basada en `AppColors` / Material 3 y código 100% desacoplado. |
| **Fase 2: Presupuestos y Pagos por Cuotas** | 📋 Planificada | **1. Planes de Tratamiento por Paciente:** Cotización de múltiples tratamientos y seguimiento de avance.<br>**2. Control de Abonos y Saldos:** Registro de pagos parciales vinculados al presupuesto. | Gestión financiera completa del paciente. |
| **Fase 3: Calendario Visual y WhatsApp** | 📋 Planificada | **1. Vista Calendario Semanal/Diario:** Bloques horarios interactivos.<br>**2. Botón directo a WhatsApp:** Envío de recordatorio de cita con plantilla automática. | Experiencia de usuario lista para producción. |

---

### 🏛️ Arquitectura Mantenida en FrontFlutter (Fase 1)

Todos los cambios respetan estrictamente la separación en 3 capas y inyección de dependencias con **Riverpod**:

1. **Módulo `patients` (`lib/patientAttention/patients/`):**
   - `domain/model/patient.dart`: Modelo enriquecido con getters calculados (`fullName`, `initials`, `age`, `hasAllergies`, `hasSystemicConditions`, `hasMedicalAlerts`).
   - `data/model/patient_response.dart` & `data/remote/dto/`: Mapeo JSON completo de `phone`, `allergies`, `systemicConditions`, `emergencyContactName`, `emergencyContactPhone`.
   - `presentation/`: `PatientsView`, `PatientCard` y `PatientForm` rediseñados con `AppColors`.

2. **Nuevo Módulo `treatments` (`lib/patientAttention/treatments/`):**
   - `domain/model/treatment_category.dart`: Enum tipado `TreatmentCategory` con código backend, nombre legible en español, ícono e identidad cromática desde `AppColors`.
   - `domain/model/treatment.dart`, `domain/repositories/treatment_repository.dart` y 4 casos de uso (`GetAllTreatmentsUseCase`, `AddTreatmentUseCase`, `UpdateTreatmentUseCase`, `DeleteTreatmentUseCase`).
   - `data/`: `TreatmentResponse`, `TreatmentRequest`, `TreatmentService` (`/api/v1/treatments`), `TreatmentRepositoryImpl` y `dependency_injection.dart`.
   - `presentation/`: `TreatmentViewModel`, `TreatmentsView`, `TreatmentCard` y `TreatmentForm`.

3. **Módulo `appointments` (`lib/patientAttention/appointments/`):**
   - `domain/model/appointment_status.dart`: Enum tipado `AppointmentStatus` (`SCHEDULED`, `CONFIRMED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`, `NO_SHOW`).
   - `domain/usecases/update_appointment_status_use_case.dart`: Caso de uso para transición de estado y registro de notas clínicas.
   - `presentation/widgets/appointment_status_dialog.dart`: Diálogo clínico para cambiar el estado y guardar la evolución de la sesión.
   - `presentation/widgets/add_appointment_form.dart`: Integrado con `treatmentsViewModelProvider` para autocompletar motivo y duración al elegir un tratamiento del catálogo.
