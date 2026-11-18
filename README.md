# Dentify · Frontend Flutter

Aplicación multiplataforma (Web y Móvil) de **Dentify** orientada a odontólogos y personal de consultorios dentales: autenticación, control de pacientes, historias clínicas odontológicas, agenda interactiva de citas, gestión de insumos e inventario, registro de facturas y dashboard gerencial.

**Tecnologías:**
- Flutter 3.27+ (Dart SDK `>=3.6.0 <4.0.0`)
- State Management: Flutter Riverpod
- HTTP & REST: `http` package, `Dio` y `Retrofit`
- Almacenamiento seguro de credenciales: `TokenStorage` (SharedPreferences / Web Storage)
- Arquitectura limpia por capas: `data` (DTOs, datasources, repositories), `domain` (models, use cases), `presentation` (viewmodels, views, widgets).

---

## 🚀 Requisitos Previos

1. **Flutter SDK** (versión 3.27.x o superior) instalado y accesible desde tu terminal (`flutter --version`).
2. **Google Chrome** (para ejecución en Web) o **Android Studio con Emulador** (para ejecución Móvil).
3. **Backend de Dentify** activo en `http://localhost:8080` (ver guía en la carpeta `Backend/`).

---

## ⚙️ Configuración de Conexión al Backend

La URL del servicio está centralizada en `lib/core/network/api_constants.dart`. Por defecto apunta a:
```
http://localhost:8080/api/
```

Si deseas apuntar a otra URL en tiempo de ejecución o compilación, puedes sobreescribirla con `--dart-define`:
```bash
--dart-define=API_BASE_URL=http://tu-servidor:8080/api/
```

---

## ▶️ Instrucciones de Ejecución

### 1. Obtener dependencias
Abre una terminal en la carpeta `FrontFlutter`:
```bash
flutter pub get
```

### 2. Ejecutar en Navegador Web (Google Chrome)
Para ejecutar la aplicación en el puerto recomendado `8081`:
```bash
flutter run -d chrome --web-port=8081
```

La app se abrirá automáticamente en: **`http://localhost:8081`**

### 3. Ejecutar en Emulador Android o Dispositivo Físico
*Nota: En el emulador Android de Google, `localhost` del host se accede como `10.0.2.2`.*
```bash
flutter run -d <id_del_dispositivo> --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/
```

---

## 📱 Módulos de la Aplicación

- **Login y Registro:** Permite iniciar sesión o crear una cuenta nueva de consultorio (con guardado inmediato de token para navegación fluida).
- **Dashboard (`/home`):** Visualización de métricas de insumos con stock bajo, pagos recientes y próximas citas.
- **Pacientes (`/patients`):** Lista y búsqueda de pacientes, creación y edición con validación de DNI de 8 dígitos, email y fecha de nacimiento.
- **Historial Médico:** Acceso desde la tarjeta de cada paciente para registrar diagnósticos, antecedentes, tratamientos y medicación.
- **Citas (`/appointments`):** Programación y gestión de citas con selector de paciente, fecha, hora y duración en minutos, con detección de solapamiento de horarios.
- **Inventario (`/inventory`):** Catálogo de insumos clasificados por categoría clínica con alertas de stock y control de precios.
- **Facturación / Pagos (`/payments`):** Generación de facturas vinculadas a citas pendientes y selección de medio de pago (Efectivo, Tarjeta, Transferencia).
- **Perfil (`/profile`):** Edición de información de la clínica y cambio de contraseña.

---

## 🧪 Pruebas y Análisis de Código

```bash
flutter test        # Ejecuta pruebas unitarias de Flutter
flutter analyze     # Analiza calidad y estilo de código
```
