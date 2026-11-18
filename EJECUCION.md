# 📋 Guía Rápida de Ejecución · Dentify Flutter (Front-End)

Esta guía explica cómo ejecutar la aplicación Flutter de Dentify en tu entorno local.

---

## 1. Requisitos
- **Flutter SDK 3.27+** instalado (`flutter doctor`)
- **Navegador Google Chrome** instalado
- **Backend de Dentify** activo en `http://localhost:8080`

---

## 2. Pasos para Iniciar

1. Abre tu terminal y ubícate en la carpeta del proyecto:
   ```bash
   cd FrontFlutter
   ```

2. Descarga todas las dependencias:
   ```bash
   flutter pub get
   ```

3. Levanta la aplicación en Chrome:
   ```bash
   flutter run -d chrome --web-port=8081
   ```

4. Abre en tu navegador:
   👉 **`http://localhost:8081`**

---

## 3. Acceso y Pruebas
Puedes iniciar sesión inmediatamente con el usuario de pruebas:
- **Usuario:** `dentist1`
- **Contraseña:** `password123`

O puedes hacer clic en **"Register"** para registrar una cuenta nueva y empezar a registrar pacientes, citas e inventario.

---

## 4. Notas Importantes
- **Creación de Pacientes:** Asegúrate de ingresar un DNI de exactamente 8 dígitos y hacer clic en el ícono del calendario para elegir la fecha de nacimiento.
- **Creación de Citas:** Primero debes tener al menos un paciente registrado para poder seleccionarlo en el combo desplegable.
- **Facturas:** Requieren seleccionar una cita que no haya sido completada previamente.
