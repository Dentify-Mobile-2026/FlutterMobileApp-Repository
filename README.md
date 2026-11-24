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

La URL del servicio está centralizada en `lib/core/network/api_constants.dart`. Por defecto apunta en local a:
```
http://localhost:8080/api/
```

**Backend en producción (Azure + Aiven MySQL):**
```
https://dentify-api-upc.azurewebsites.net/api/
```
*(Health check: `https://dentify-api-upc.azurewebsites.net/health`)*

Si deseas apuntar a otra URL en tiempo de ejecución o compilación, pásala siempre con `--dart-define`:
```bash
--dart-define=API_BASE_URL=https://dentify-api-upc.azurewebsites.net/api/
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
- **Pacientes (`/patients`):** Directorio clínico con indicadores de pacientes con alerta médica, filtro rápido *"Solo Alertas"*, registro de alergias (Penicilina, Anestesia, Látex, AINEs), condiciones sistémicas, teléfono y contacto de emergencia.
- **Historial Médico:** Acceso desde la tarjeta de cada paciente para registrar diagnósticos, antecedentes, tratamientos y medicación.
- **Catálogo de Tratamientos (`/treatments`):** Gestión de procedimientos odontológicos por especialidad (`Prevención`, `Operatoria`, `Endodoncia`, `Periodoncia`, `Ortodoncia`, `Cirugía`, `Prótesis`, `Estética`), con arancel en `S/.` y duración estimada en minutos.
- **Citas (`/appointments`):** Agenda clínica con selección de tratamiento del catálogo (autocompletado de motivo y duración), filtros por estado (`Agendada`, `Confirmada`, `En Atención`, `Atendida`, `Cancelada`, `No Asistió`) y diálogo de evolución clínica.
- **Inventario (`/inventory`):** Catálogo de insumos clasificados por categoría clínica con alertas de stock y control de precios.
- **Facturación / Pagos (`/payments`):** Generación de facturas vinculadas a citas pendientes y selección de medio de pago (Efectivo, Tarjeta, Transferencia).
- **Perfil (`/profile`):** Edición de información de la clínica y cambio de contraseña.

---

## 🧪 Pruebas y Análisis de Código

```bash
flutter test        # Ejecuta pruebas unitarias de Flutter
flutter analyze     # Analiza calidad y estilo de código
```

---

## 📦 Compilación Móvil y Distribución (Android APK & iOS IPA)

### 1. Generar APK Android (Windows) y subir a Firebase App Distribution

**Firebase App ID configurado (`google-services.json`):** `1:474750754642:android:b32b78d61c18bdd47da48b` (`com.dentify.agile`)

#### A) Firma Release (opcional pero recomendada)
1. Genera tu keystore fuera del repositorio:
   ```powershell
   & "C:\Program Files\Java\jdk-17.0.12\bin\keytool.exe" -genkey -v -keystore C:\Users\user\dentify-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dentify
   ```
2. Crea `android/key.properties` (ignorado en `.gitignore`):
   ```properties
   storePassword=TU_PASSWORD
   keyPassword=TU_PASSWORD
   keyAlias=dentify
   storeFile=C:\\Users\\user\\dentify-release.jks
   ```
   *(Si omites este paso, Gradle compilará usando firma debug válida para Firebase App Distribution).*

#### B) Compilar APK apuntando a Azure y distribuir
Con el script incluido `build-apk.ps1`:
```powershell
cd Front-Flutter

# Opción 1: Solo generar el APK release conectado a Azure
.\build-apk.ps1 -ApiBaseUrl "https://dentify-api-upc.azurewebsites.net/api/"

# Opción 2: Generar APK y subirlo directo a Firebase App Distribution (requiere `firebase login` previo)
.\build-apk.ps1 `
  -ApiBaseUrl "https://dentify-api-upc.azurewebsites.net/api/" `
  -FirebaseAppId "1:474750754642:android:b32b78d61c18bdd47da48b" `
  -TestersGroup "equipo-dentify"
```
El archivo generado queda en: `build/app/outputs/flutter-apk/app-release.apk`.

*(Sin script, el comando manual equivalente es:)*
```powershell
flutter clean
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=https://dentify-api-upc.azurewebsites.net/api/
```

---

### 2. Compilar e Instalar en iOS / Generar `.ipa` (desde macOS)

> La compilación de iOS requiere **macOS + Xcode + CocoaPods**.

#### A) Preparar proyecto en tu Mac
```bash
git clone https://github.com/Dentify-Mobile-2026/FlutterMobileApp-Repository.git
cd FlutterMobileApp-Repository
git checkout main
flutter pub get
cd ios
pod install
cd ..
```

#### B) Configurar firma en Xcode
1. Abre el workspace (siempre `.xcworkspace`, no `.xcodeproj`):
   ```bash
   open ios/Runner.xcworkspace
   ```
2. En el panel izquierdo selecciona **Runner -> Targets: Runner -> Signing & Capabilities**:
   - Activa **Automatically manage signing**.
   - En **Team**, selecciona tu cuenta Apple (Apple ID gratuito o cuenta Apple Developer).
   - Si aparece error de *Bundle Identifier* duplicado (`upc.edu.pe.dentify_flutter`), cámbialo temporalmente a uno único tuyo (ej. `com.tunombre.dentify`).

#### C) Instalar directo en tu iPhone (sin pagar Apple Developer)
Conecta el iPhone por USB al Mac, confía en la computadora y ejecuta:
```bash
flutter run --release --dart-define=API_BASE_URL=https://dentify-api-upc.azurewebsites.net/api/
```
*(En el iPhone: **Ajustes -> General -> Gestión de dispositivos y VPN -> Confiar** en tu Apple ID).*

#### D) Exportar archivo `.ipa` (requiere cuenta Apple Developer paga para Ad Hoc / TestFlight / Firebase)
1. Registra los **UDID** de los iPhone de prueba en Apple Developer Portal (**Certificates, Identifiers & Profiles -> Devices**) si usarás **Ad Hoc / Firebase App Distribution**.
2. Genera el `.ipa` conectado a Azure:
   ```bash
   flutter build ipa --export-method ad-hoc --dart-define=API_BASE_URL=https://dentify-api-upc.azurewebsites.net/api/
   ```
   *(Para App Store / TestFlight usa `--export-method app-store`)*.
3. El paquete se generará en `build/ios/ipa/*.ipa` listo para subir a **Firebase App Distribution** (agregando la app iOS en Firebase Console) o **Transporter / TestFlight**.
4. *(Alternativa visual si falla el CLI)*: ejecuta `flutter build ios --release --dart-define=API_BASE_URL=https://dentify-api-upc.azurewebsites.net/api/`, abre `ios/Runner.xcworkspace` en Xcode, elige **Any iOS Device (arm64)** y ve a **Product -> Archive -> Distribute App**.
