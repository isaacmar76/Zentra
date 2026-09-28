# 07-STACK-TECNICO.md
## TECNOLOGÍA - ZENTRA V1.2

### 1. FRONTEND - APP MÓVIL
**Framework**: Flutter 3.22
**Lenguaje**: Dart
**Estado**: Provider o Riverpod
**Paquetes clave**:
- supabase_flutter: para base de datos
- image_picker: para tomar foto de gastos
- pdf: para generar cotizaciones
- intl: para fechas en español
- shared_preferences: para modo offline

### 2. BACKEND Y BASE DE DATOS
**BaaS**: Supabase
**Base de datos**: PostgreSQL
**Auth**: Supabase Auth con Email/Contraseña
**Storage**: Supabase Storage para fotos de gastos
**Seguridad**: RLS - Row Level Security activado

### 3. ARQUITECTURA
**Patrón**: Feature First
Carpetas: /features/login, /features/projects, /features/catalog
**Offline**: Guardar en SQLite local y sincronizar cuando hay internet

### 4. PLATAFORMAS
**Android**: Min SDK 21
**iOS**: Min iOS 13
**Idioma**: Solo Español Colombia

### 5. REGLAS PARA LA IA
1.  Todo el código comentado en español
2.  Usar nombres de variables claros: `projectName` no `pn`
3.  Manejar errores: si falla internet mostrar "Se guardó localmente"
4.  No usar librerías de pago. Solo gratis.