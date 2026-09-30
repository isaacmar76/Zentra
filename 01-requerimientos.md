# 01-REQUERIMIENTOS.md
## PROYECTO: ZENTRA V1.2

### 1. OBJETIVO
App móvil y web para micronegocios y emprendedores en Colombia. Sin facturación electrónica ni complejidades contables.
Reemplazar cuadernos y Excel. Enfoque: Simple, visual, financiero y rápido.

### 2. MODALIDADES DE NEGOCIO
A. **RETAIL**: Tiendas, minimercados, abarrotes, papelerías tradicionales (POS rápido + caja).
B. **SERVICIOS**: Papelería creativa, salones, catering, personalizaciones (Proyectos + cotizaciones + checklist).

### 3. ROLES Y PERFILES DE USUARIO
1. **DUEÑO / ADMINISTRADOR (`OWNER`)**:
   - Acceso total e irrestricto al negocio.
   - Visibilidad completa de costos, ganancias netas reales y márgenes.
   - Configuración del negocio (cuentas Nequi, Daviplata, Bancolombia).
   - CRUD de usuarios: crear colaboradores, editar accesos, asignar/cambiar PINs de 4 dígitos.
2. **COLABORADOR / VENDEDOR (`COLLABORATOR`)**:
   - Acceso operativo para ventas en mostrador (POS), registro de nuevos pedidos y proyectos.
   - Consulta de catálogo de productos e inventario.
   - Gestión de tareas y compras en checklist del proyecto.
   - **Privacidad y Seguridad Financiera:** Las métricas de ganancia neta consolidada y márgenes confidenciales permanecen enmascaradas (`••••••`).

### 4. GESTIÓN DE PROYECTOS Y CATÁLOGO
- **Catálogo Multimedia**: Carga de fotos desde galería o captura directa con cámara del celular (compresión automática).
- **Proyectos Multi-Ítem**: Dentro de un mismo proyecto (ej. "Cumpleaños 15 Años"), se seleccionan múltiples productos del catálogo (toppers, portaplatos, dulces, invitaciones) con cantidades, subtotales y ad-hoc personalizados.
- **Cotizador WhatsApp**: Generación automática de resumen desglosado con cuentas bancarias listo para enviar al cliente.

### 5. MÓDULOS PRINCIPALES
1.  Login multi-usuario con PIN y Selección de Modo
2.  Dashboard Adaptativo con métricas según el rol
3.  Catálogo e Inventario (fotos, stock, precios)
4.  Clientes y Cuentas por Cobrar
5.  FLUJO RETAIL: Venta Rápida + Caja + Carrito POS
6.  FLUJO SERVICIOS: Proyectos Multi-Producto + Compras + Checklist + Abonos
7.  Tareas y Alertas de Vencimiento
8.  CRUD de Usuarios y Roles
9.  Configuración y Temas Visuales (Zentra Neutral / TM Diseños)

### 6. REGLAS CLAVE
1.  Offline-first: Todo funciona sin conexión mediante almacenamiento local persistente.
2.  Sin IVA, sin DIAN. Cálculos transparentes.
3.  Diseño limpio sobre fondos claros/blancos, evitando saturación estridente.
4.  Botón extra: VER PEDIDOS PRONTO A VENCER para modo Servicios.

### 7. TECNOLOGÍA
Flutter + Web SPA (Vercel) + Supabase + Almacenamiento local persistente