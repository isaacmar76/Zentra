# 📖 ZENTRA • LÓGICA DE NEGOCIO Y BITÁCORA DE CAMBIOS

> **Documento Oficial de Arquitectura, Lógica y Registro de Modificaciones**  
> **Proyecto:** Zentra V1.2  
> **Repositorio Oficial:** [https://github.com/isaacmar76/Zentra.git](https://github.com/isaacmar76/Zentra.git)  
> **Rama Principal:** `main`  
> **Última Actualización:** 29 de Septiembre de 2026

---

## 1. Visión y Propósito del Producto

**Zentra** es una aplicación diseñada para empoderar a los micronegocios y trabajadores independientes en Colombia, eliminando la complejidad de los sistemas contables tradicionales, hojas de cálculo enredadas y cuadernos manuales.

### Principios Fundamentales:
1. **Sin burocracia fiscal:** Cero facturación electrónica obligatoria ni reportes DIAN innecesarios. Cálculos limpios, rápidos y directos en Pesos Colombianos (COP).
2. **Offline-First:** Capacidad de operar y registrar información sin depender de una conexión permanente a internet.
3. **Simplicidad visual:** Interfaz limpia, ágil, con paletas elegantes (Nude, Blush, Noche, Forest) que generan una experiencia premium adaptada al tipo de comercio.
4. **Modelo de Operación Definido al Crear el Negocio:** Al ingresar por primera vez, el usuario configura su negocio y selecciona su modelo operativo (**Servicios** o **Retail**). A partir de ese momento, la app siempre abre directamente en el modelo seleccionado, eliminando el intercambio accidental o innecesario entre modalidades durante el trabajo diario:
   - **Modo Servicios (Por Encargo / Proyecto):** Para negocios creativos, talleres, papelería personalizada, eventos, salones y catering. *Caso prototipo: TM Diseños Creativos (Tatiana Marín).*
   - **Modo Retail (Mostrador / POS):** Para tiendas de barrio, abarrotes, minimercados y papelerías de mostrador. *Caso prototipo: Tienda Don Pedro.*

---

## 2. Arquitectura de la Solución

El proyecto mantiene dos frentes de implementación sincronizados:

```
c:\Proyectos\MyBusiness\
│
├── preview.html              # Prototipo interactivo completo HTML5/CSS/JS (Vanilla)
│                             # Permite pruebas instantáneas en navegadores de PC y Celular
│
├── LOGICA_Y_BITACORA.md      # Este documento: lógica, reglas y bitácora de cambios
├── 01-requerimientos.md       # Especificaciones de origen
├── 02-flujo-modo-retail.md    # Especificaciones del flujo de retail
├── 03-flujo-modo-servicios.md # Especificaciones del flujo de servicios
├── 08-ajustes-tatiana.md      # Personalizaciones específicas para TM Diseños
│
└── zentra/                   # Código nativo en Flutter (Dart)
    ├── lib/
    │   ├── core/
    │   │   ├── layout/       # MainLayoutScreen y navegación
    │   │   └── theme/        # Temas visuales (Nude, Blush, Noche, Forest)
    │   └── features/
    │       ├── dashboard/    # Dashboards adaptativos (Servicios y Retail)
    │       ├── projects/     # Modelos, Providers y Pantallas de Proyectos (Tatiana)
    │       ├── retail/       # Punto de venta, carrito y caja (Don Pedro)
    │       ├── inventory/    # Catálogo de productos e inventario unificado
    │       └── login/        # Acceso y selección de modo
    └── pubspec.yaml
```

---

## 3. Lógica del Negocio (Core Business Rules)

### 3.1. Modo Servicios: TM Diseños Creativos (Tatiana Marín)

#### A. Concepto de "Proyecto / Pedido":
- **Un proyecto NO es una empresa nueva:** Es un **encargo específico de un cliente** (ejemplo: *"15 años Maria"*, *"Bautizo Santiago"*, *"Grados Prom 2026"*).
- El botón **"+ NUEVO PEDIDO / PROYECTO"** permite levantar un nuevo trabajo solicitando:
  - Nombre del encargo
  - Cliente y teléfono de WhatsApp
  - Descripción de servicios incluidos
  - Valor total cotizado
  - Abono inicial entregado por el cliente
  - Días proyectados para la entrega

#### B. Fases y Estados del Encargo:
Cada proyecto avanza por cuatro fases operativas consecutivas:
1. `🎨 Diseño`: Creación de propuestas digitales, paletas de color y bocetos.
2. `✂️ Producción`: Corte, impresión, ensamble manual y manufactura.
3. `📦 Empaque`: Empaque en cajas, lazos, sellos lacre y presentación final.
4. `✅ Entregado`: Pedido recibido satisfactoriamente por el cliente.

#### C. Checklist Interactivo con Compras Integradas:
Dentro de cada proyecto existe un checklist dinámico con dos naturalezas de ítems:
- **Tarea Operativa (Sin costo):** Ej. *"Diseño digital y paleta blush"*, *"Impresión de tarjetas"*. Al marcar check, indica avance del pedido.
- **Compra de Insumo / Material (Con costo asociado):** Ej. *"Comprar cartulinas blush ($50.000)"*, *"Comprar bases de madera ($30.000)"*.
  - Mientras la compra está desmarcada, figura como **"🛒 Compra pendiente"**.
  - Al marcar el check del ítem, el sistema asume inmediatamente la compra como **realizada** y **suma su costo al balance del proyecto en tiempo real**. Si se desmarca, se reversa.

#### D. Separación Contable Estricta:
Para evitar mezclar el dinero de encargos específicos con la operación global del negocio, se manejan tres niveles de cuentas:
1. **Compras del Proyecto (Específicas):** Insumos que pertenecen a ese encargo.
   $$\text{Compras Totales Proyecto} = \text{Compras Directas} + \sum \text{Compras Realizadas en Checklist}$$
   $$\text{Ganancia Real del Proyecto} = \text{Abonos Cobrados} - \text{Compras Totales Proyecto}$$
   $$\text{Saldo Pendiente Cliente} = \text{Total Cotizado} - \text{Abonos Cobrados}$$
2. **Gastos Generales del Negocio (Independientes):** Erogaciones del negocio que no pertenecen a ningún proyecto (ejemplo: Arriendo mensual del taller, recibo de energía, internet, telefonía).
3. **Otros Ingresos Generales:** Ingresos no atribuibles a proyectos específicos (ventas misceláneas, asesorías sueltas).
4. **Balance Consolidado del Negocio:**
   $$\text{Ingresos Globales} = \sum \text{Abonos de Todos los Proyectos} + \sum \text{Otros Ingresos Generales}$$
   $$\text{Egresos Globales} = \sum \text{Compras de Proyectos} + \sum \text{Gastos Generales}$$
   $$\text{Ganancia Neta Global Real} = \text{Ingresos Globales} - \text{Egresos Globales}$$

#### E. Perfil Comercial y Cotizaciones por WhatsApp:
- En **"🏢 Datos de Mi Negocio"** se configuran los datos de la marca:
  - Nombre del negocio (*TM Diseños Creativos*)
  - Titular (*Tatiana Marín*)
  - Teléfono WhatsApp
  - Cuentas de cobro digitales (*Nequi*, *Daviplata*, *Bancolombia*)
- Botón **"📱 COPIAR MENSAJE PARA WHATSAPP"**: Genera una cotización estructurada con formato profesional con un solo clic, lista para pegar en el chat del cliente:
  - Resumen del pedido y servicios
  - Total cotizado
  - Valor abonado
  - Saldo exacto pendiente
  - Cuentas Nequi/Bancolombia de cobro

#### F. Alertas de Urgencia:
- Botón **"⚠️ PEDIDOS PRONTO A VENCER"**: Detecta pedidos con 3 o menos días para entrega que no estén en estado "Entregado", permitiendo priorizar la producción inmediata.

---

### 3.2. Catálogo e Inventario Unificado (Para Ambos Modelos)

Tanto en negocios de servicios como de retail existe la necesidad de controlar inventario de productos terminados o insumos vendibles:
- **Para Tatiana (Modo Servicios):** Agendas personalizadas, Cake toppers, Cajas sorpresa, Cuadros en foil. Permite calcular el margen unitario:
  $$\text{Ganancia por Unidad} = \text{Precio de Venta} - \text{Costo de Elaboración}$$
- **Para Don Pedro (Modo Retail):** Arroz, Aceite, Leche, Huevos, Pan.
- **Acción Rápida de Venta:** Cada ítem tiene botón **"Vender 1"** que descuenta una unidad del stock e ingresa automáticamente el dinero en las cuentas.
- **Alerta de Stock Crítico:** Si el inventario es $\le 5$ unidades, resalta con advertencia visual `⚠️ X disp`.

---

### 3.3. Modo Retail: Tienda Don Pedro

1. **Punto de Venta (POS) Táctil:** Cuadrícula de productos con nombre, categoría, precio y stock.
2. **Carrito de Compras Ágil:** Toque para agregar, contador visual en la barra superior.
3. **Caja y Cobro en 1 Clic:** Registra la venta, vacía el carrito y confirma el recaudo instantáneo.

---

## 4. Estructuras de Datos (Data Models)

### `ProjectModel`
```dart
class ProjectModel {
  final String id;
  final String name;          // Ej: "15 años Maria"
  final String client;        // Ej: "Maria Rodriguez"
  final String phone;         // Ej: "312 456 7890"
  final String services;      // Ej: "50 Invitaciones + 10 Centros"
  final double totalBudget;   // Valor total cotizado
  final double advancePayment;// Total abonado a la fecha
  final double directExpenses;// Compras manuales directas
  final int daysLeft;         // Días restantes para entrega
  final ProjectStatus status; // diseno, produccion, empaque, entregado
  final List<ProjectTaskModel> tasks; // Checklist dinámico
}
```

### `ProjectTaskModel`
```dart
class ProjectTaskModel {
  final String id;
  final String title;         // Ej: "Comprar cartulinas blush"
  final bool isDone;          // Check realizado
  final bool isPurchase;      // ¿Es compra de material?
  final double cost;          // Valor de la compra (COP)
}
```

### `CatalogItemModel`
```dart
class CatalogItemModel {
  final String id;
  final String name;          // Ej: "Agendas 2026 Personalizadas"
  final double price;         // Precio venta al público
  final double cost;          // Costo de elaboración o compra
  final int stock;            // Existencias disponibles
  final String category;      // Categoría
  final String mode;          // 'servicios' o 'retail'
}
```

---

## 5. Bitácora Cronológica de Cambios (Changelog Activo)

| Fecha | Commit | Tipo | Resumen del Cambio | Estado |
|---|---|---|---|---|
| **2026-09-26** | `ac2499b` | Initial | Relanzamiento inicial Zentra V1.2 (Temas, Servicios y Retail) | ✅ Completado |
| **2026-09-26** | `0796bcb` | CI/CD | Configuración de GitHub Actions para builds automáticos | ✅ Completado |
| **2026-09-27** | `83bd619` | UI/UX | Vista móvil responsive nativa para pruebas en celular vía `preview.html` | ✅ Completado |
| **2026-09-27** | `935f364` | Feature | Modo Tatiana: tareas, persistencia local, cotización WhatsApp y cálculo de ganancia | ✅ Completado |
| **2026-09-28** | `1f2d6b2` | Accounting | Módulo de Perfil del Negocio y separación estricta: Compras Proyecto vs Gastos Generales | ✅ Completado |
| **2026-09-28** | `b373dfb` | Concept | Clarificación conceptual del botón "+ Nuevo Pedido / Proyecto" para encargos de clientes | ✅ Completado |
| **2026-09-28** | `95b1efa` | Feature | Estados de Proyecto (🎨✂️📦✅), compras en checklist con balance automático y Catálogo/Inventario | ✅ Completado |
| **2026-09-28** | `8d79e42` | Fix | Corrección en `preview.html`: restauración de modales de proyectos, checklist y flujo contable | ✅ Completado |
| **2026-09-29** | `13a7b9e` | Architecture | Creación de `LOGICA_Y_BITACORA.md` como fuente de verdad y registro continuo | ✅ Completado |
| **2026-09-29** | `9f31f41` | Core | Configuración fija de tipo de negocio al crear empresa, borrado total de datos demo y persistencia local | ✅ Completado |
| **2026-09-30** | `61041bb` | Feature / Auth / Multi-item | CRUD de Usuarios (Dueño vs Colaborador), Catálogo con Fotos (Cámara/Galería), Proyectos Multi-Producto y Cotizaciones WhatsApp | ✅ Completado |
| **2026-09-30** | `0c59e31` | UI / UX / Design System | Adopción de Sistema Visual Fintech Clarity (nuevo_diseño.md): Plus Jakarta Sans + Inter, Cockpit Hero con micro-gráfica SVG, Bento cards | ✅ Completado |
| **2026-10-01** | `e1d1f05` | Security / Multi-Tenant | Aislamiento estricto de productos y datos por negocio (multi-tenancy, registro central, llaves namespaced y control de acceso por PIN) | ✅ Completado |
| **2026-10-03** | `dd5f890` | Fix / Mobile UX | Blindaje de contraste total en inputs de Registro/Login (solución de texto invisible/blanco en celular y modo oscuro) | ✅ Completado |
| **2026-10-03** | `1090b4a` | Feature / POS / Facturación | Administración avanzada del propietario: Catálogo con costo y venta (márgenes), Carrito mostrador/retail, Pedidos multi-ítem a medida, y ciclo Cotización vs Factura | ✅ Completado |
| **2026-10-03** | `e151d1a` | UX / Sales Flow | Flujo rápido de ventas: Botón Tomar Pedido, Carrito permanente superior derecho, Acciones directas Cotizar (copia + WhatsApp) y Cobrar (factura) | ✅ Completado |
| **2026-10-03** | `321ec68` | Fix / Multi-Tenant Auth | Auto-recuperación de negocios, acceso directo 1-toque en login y búsqueda flexible por nombre de negocio | ✅ Completado |
| **2026-10-04** | `1ae5d84` | Feature / Catálogo / Facturación | Hito 19: Edición de catálogo con fotos/cámara, medios de pago con QR en perfil y formatos limpios de cotización y factura sin datos inventados | ✅ Completado |
| **2026-10-04** | `c81ec7e` | Feature / UI / Personalización | Hito 20: Personalización Dinámica de Pantalla de Inicio: Selector de 4 Layouts en vivo (Cockpit Operativo, POS Mostrador, Tablero Kanban y Híbrido Modular) con eliminación de paletas de colores previas | ✅ Completado |
| **2026-10-04** | `f36dfc0` | Feature / POS / CRM | Hito 21: Botones de Otros Ingresos y Módulo Completo de Seguimiento Comercial de Cotizaciones y Carritos Guardados (Caducidad 15 días, Retoma de Ventas y Extensión de Vigencia) | ✅ Completado |
| **2026-10-04** | `7bd2df4` | Feature / Catálogo / Móvil | Hito 22: Soporte completo para subir imágenes desde la galería y almacenamiento del teléfono en la edición de productos del catálogo | ✅ Completado |
| **2026-10-04** | `current` | UX / UI / Simplificación | Hito 23: Flujo Directo de Personalización, Tareas Pendientes en Inicio y Unificación a 1 Solo Botón de Mi Negocio en el Hero (eliminando duplicados de la barra inferior y badge de usuario) | ✅ Completado |

---

### Detalle de Hitos Importantes

#### Hito 1: Separación de Gastos y Compras (Commit `1f2d6b2`)
- **Problema previo:** Los abonos y gastos sumaban de forma global sin distinguir si un material pertenecía a un pedido o era un gasto común.
- **Solución implementada:** Las compras de insumos se aislaron por proyecto para obtener su margen unitario. Se crearon modales independientes para `Gasto General` (arriendo, servicios) y `Otro Ingreso` (no atado a proyectos).

#### Hito 2: Ciclo de Estados y Checklist con Compras (Commit `95b1efa`)
- **Problema previo:** Los proyectos tenían estados genéricos y las tareas no registraban costo financiero.
- **Solución implementada:** Se añadieron los estados exactos solicitados (*Diseño*, *Producción*, *Empaque*, *Entregado*). Cada ítem del checklist ahora puede declararse como compra con costo, sumándose automáticamente al costo al recibir check.

#### Hito 3: Catálogo e Inventario para ambos modelos (Commit `95b1efa`)
- **Problema previo:** No existía forma de gestionar inventario para productos terminados que Tatiana también vende además de sus servicios bajo pedido.
- **Solución implementada:** Se integró el módulo de catálogo con control de stock, margen de ganancia por unidad y venta rápida para ambos perfiles.

#### Hito 4: Selección Fija de Tipo de Negocio y Base Limpia (Pre-Release)
- **Problema previo:** La aplicación permitía cambiar entre Servicios y Retail libremente mediante un botón en el AppBar, y cargaba proyectos y transacciones de prueba prefabricadas ("15 años Maria", "Bautizo Santiago", etc.) que confundían a un usuario nuevo.
- **Solución implementada:**
  1. Se eliminó el botón de intercambio en caliente de las barras de navegación.
  2. En el primer ingreso o tras cerrar el negocio, el usuario pasa por una pantalla de configuración donde registra el nombre de su negocio, titular, teléfono de WhatsApp y **selecciona de manera fija su tipo de negocio** (Servicios o Retail).
  3. A partir de esa selección, la app abre directamente y siempre en el modelo correspondiente.
  4. Se vaciaron todas las listas de datos demo tanto en Flutter (`projects_provider`, `inventory_provider`, `retail_provider`) como en el prototipo interactivo (`preview.html`), arrancando en blanco ($0 y 0 proyectos) listo para producción/pruebas reales.
  5. Se implementó persistencia en `localStorage` en el prototipo web para conservar la información registrada en el teléfono o navegador.

#### Hito 5: Despliegue en Vercel y Experiencia PWA para Celular
- **Motivación:** Facilitar el acceso inmediato a la app desde cualquier celular mediante un enlace público de Vercel sin obligar a descargar APKs de desarrollo ni habilitar permisos de fuentes desconocidas.
- **Implementación:**
  1. Creación de `index.html` en la raíz como entrada principal para Vercel.
  2. Creación de `vercel.json` con enrutamiento limpio y soporte SPA.
  3. Configuración de `manifest.json` y meta-etiquetas PWA (`mobile-web-app-capable`, `theme-color`).
  4. Generación de íconos de aplicación de alta resolución en `img/` para instalación directa en pantalla de inicio de Android/iOS ("Añadir a pantalla de inicio").

#### Hito 6: Paleta Oficial de Marca TM Diseños Creativos (Commit `7a0420f`)
- **Especificación de Marca recibida:**
  - Fucsia vibrante: `#ff2b78`
  - Naranja vibrante: `#ff4400`
  - Rosa pastel suave (fondo): `#ffe3f4`
  - Gris carbón (texto y contraste): `#545454`
  - Blanco puro (tarjetas y superficies): `#ffffff`

#### Hito 7: Portal de Acceso Dual, Paleta Minimalista Blanca y Vistas Despejadas
- **Feedback del Cliente (Tatiana):**
  1. No saturar de fucsia la pantalla; a Tatiana le gustan los **fondos blancos**.
  2. Despejar las vistas para que no se vean abarrotadas de botones y cajas.
  3. Al entrar, permitir tanto **iniciar sesión** para quien ya tiene un negocio creado, como **crear negocio** para nuevos comercios.
- **Solución implementada:**
  1. **Portal de Acceso Dual:** Pestañas claras para `🔑 Iniciar Sesión` (con correo/teléfono y PIN/contraseña) y `✨ Crear Negocio` (con registro limpio y selección fija de modelo operativo).
  2. **Paleta Minimal White:** El fondo general pasó a ser blanco perla pulcro (`#F8F9FA` / `#FFFFFF`) con tarjetas blancas puras (`#FFFFFF`), bordes finos `#EAECEF` y textos en grafito `#1E2329`. El fucsia `#ff2b78` y naranja `#ff4400` se redistribuyeron como acentos editoriales y botones de acción limpios sin saturar.
  3. **Despeje de Vistas (Decluttering):**
     - Se reemplazó la cuadrícula pesada de 4 cajitas por una **Tarjeta Hero de Balance** limpia, con el monto principal grande y claro, más dos indicadores discretos de Entradas y Salidas.
     - Se incorporó un **control segmentado de 3 pestañas** (`Encargos`, `Cuentas & Gastos`, `Catálogo`), eliminando los 5 botones apilados que saturaban la pantalla principal.
     - Barra de navegación inferior limpia (`Inicio`, `Mi Negocio`, `Apariencia`).
  4. **Barra Superior / Status Bar Blanca:** Se cambió el meta tag `theme-color`, header y `manifest.json` a blanco puro (`#FFFFFF`), eliminando la barra fucsia superior en navegadores móviles de celular y app instalada.

#### Hito 8: Zentra como Marca Pública Neutral + Preservación de TM Diseños
- **Motivación:** Desvincular la identidad general de Zentra de un solo negocio, proyectándola como una solución integral para emprendedores y micronegocios colombianos.
- **Implementación:**
  - Definición de paletas visuales neutras (Minimal White / Púrpura Zentra, Nude & Blush, Esmeralda, Océano) y conservación de "TM Diseños Creativos" como preset personalizado para Tatiana.

#### Hito 9: CRUD de Usuarios y Roles (Dueño vs Colaborador), Catálogo con Fotos y Proyectos Multi-Ítem
- **Motivación:**
  1. Permitir que Tatiana o el dueño del negocio delegue el registro de ventas o pedidos a empleados o vendedores sin exponer las ganancias netas de la empresa.
  2. Subir o tomar fotos con la cámara para los productos del catálogo.
  3. Gestionar pedidos complejos (ej. un "Cumpleaños") donde se venden varios productos del catálogo (toppers, portaplatos, dulces, invitaciones) bajo un mismo proyecto con totales y cotización desglosada para WhatsApp.
- **Implementación Técnica:**
  1. **Sistema de Roles (2 Perfiles):**
     - **Dueño / Administrador (`OWNER`):** Visibilidad financiera completa (márgenes, costos, compras directas), administración de cuentas bancarias y panel CRUD de usuarios con asignación de PIN de 4 dígitos.
     - **Colaborador / Vendedor (`COLLABORATOR`):** Puede registrar ventas POS, pedidos y marcar checklists. El campo `Ganancia Neta` y desgloses contables se enmascaran automáticamente (`••••••`).
  2. **Catálogo Multimedia con Fotos:**
     - Selección de archivo o disparo directo de cámara móvil (`accept="image/*"`).
     - Compresión cliente en `<canvas>` a máx 320x320 px (JPEG 0.75) para evitar desbordar el almacenamiento local.
     - Miniaturas en catálogo, POS y selector de proyectos.
  3. **Proyectos Multi-Ítem / Multi-Producto:**
     - Selector directo del catálogo con filtro en tiempo real y contador de cantidades (+/-).
     - Soporte para agregar ítems a medida específicos.
     - Cálculo en tiempo real de subtotales y total del proyecto.
     - Botón para compartir cotización por WhatsApp con desglose estructurado producto a producto y cuentas de cobro (Nequi, Bancolombia).

#### Hito 10: Sistema de Diseño Fintech Clarity (Opción A - Adaptación de `nuevo_diseño.md`)
- **Motivación:** Elevar la experiencia visual de la aplicación operativa al nivel ejecutivo de las fintechs modernas globales, manteniendo la funcionalidad intacta y los fondos blancos pulcros.
- **Implementación Técnica:**
  1. **Tipografía Ejecutiva:** Migración de fuentes a **Plus Jakarta Sans** (para números grandes, métricas, titulares y precios) y **Inter** (para textos de lectura y etiquetas de interfaz).
  2. **Tema Oficial Zentra Clarity (Predeterminado):**
     - Fondo: Blanco perlado de alta gama (`#F8F9FF`) y tarjetas blancas puras (`#FFFFFF`).
     - Acentos principales: Verde Bosque / Esmeralda (`#006C46`) y Verde Menta Neón (`#00D68F`).
     - Textos de alto contraste: Midnight Graphite (`#0B1C30`) y Pizarra (`#596273`).
     - Conservación de "TM Diseños Creativos" de Tatiana (fucsia/naranja/blanco) y los demás temas en el selector de apariencia.
  3. **Cabina Financiera Hero (Fintech Cockpit):**
     - Rediseño de la tarjeta de balance con etiqueta superior en vivo (`En vivo • Flujo`), saldo en gran formato *Plus Jakarta Sans*, y **micro-gráfico vectorial SVG interactivo** con curva de degradado translúcido.
     - Cuadrícula bento inferior para desglose de *Ingresos / Abonos* y *Gastos / Compras*.
  4. **Tarjetas Bento de Proyectos:**
     - Tarjetas con bordes ultra-limpios `#E5EEFF`, micro-barra de progreso de cobro (`p.cobrado / p.total`), badges de productos incluidos y margen protegido para colaboradores.
  5. **Barra de Navegación y Header:**
     - Header ejecutivo con monograma `Z` en degradado menta/esmeralda e indicador de estado en vivo.
     - Iconografía Google Material Symbols Outlined en la barra inferior (`dashboard`, `storefront`, `palette`).
  6. **Alineación Flutter:** Inclusión de la paleta `zentraClarity` en `app_theme.dart` y establecimiento como tema por defecto en `ThemeProvider`.

#### Hito 11: Aislamiento Total de Datos y Catálogos por Negocio (Arquitectura Multi-Inquilino)
- **Problema previo:** El almacenamiento local utilizaba claves globales (`zentra_catalog`, `zentra_biz_profile`, `zentra_projects`, etc.). Cuando se creaba un nuevo negocio o se cambiaba de cuenta, se compartía el mismo catálogo o se sobreescribían los productos entre empresas creadas en el mismo dispositivo o navegador.
- **Solución implementada:**
  1. **Directorio Central de Negocios (`zentra_businesses_registry`):** Registro seguro de todas las marcas y negocios independientes creados en el dispositivo (`id`, `name`, `owner`, `phone`, `type`, `createdAt`).
  2. **Aislamiento Estricto por Namespace (`bizId`):** Cada negocio posee sus propias claves totalmente aisladas:
     - `zentra_biz_profile_${bizId}`: Perfil comercial y cuentas de pago.
     - `zentra_catalog_${bizId}`: Catálogo de productos 100% exclusivo (un negocio NUNCA ve ni comparte los productos de otro).
     - `zentra_projects_${bizId}`: Encargos y pedidos exclusivos.
     - `zentra_clients_${bizId}`: Directorio de clientes exclusivo.
     - `zentra_expenses_${bizId}` & `zentra_incomes_${bizId}`: Finanzas y caja exclusivas.
     - `zentra_users_${bizId}`: Usuarios autorizados y PIN de acceso específicos para ese negocio.
  3. **Barrera de Autenticación y Control de Acceso:**
     - Para entrar a un negocio se debe suministrar el usuario/teléfono/correo y el PIN secreto asignado a dicho negocio.
     - Desde un negocio activo NO es posible saltar a otro negocio sin antes **Cerrar Sesión**.
     - Al cerrar sesión se limpia la memoria volátil del dispositivo y se exige autenticación con PIN del negocio de destino.
  4. **Migración Transparente:** La información histórica de *TM Diseños Creativos* se encapsuló automáticamente bajo el espacio aislado `biz_tm_disenos`, preservando su inventario creativo y clientes sin contaminar ningún negocio nuevo.

#### Hito 12: Colección Zentra Fintech (Clarity, Midnight, Cobalt), Reubicación en Perfil y Limpieza de Header
- **Requerimiento del Usuario:**
  1. Adoptar el tema de `nuevo_diseño.md` como el tema principal y oficial de Zentra (`Zentra Clarity`), sin mezclarlo ni contaminarlo con las paletas de temas anteriores (como TM Diseños).
  2. Derivar dos temas fintech adicionales inspirados en `nuevo_diseño.md`:
     - **Zentra Midnight (Dark Mode Fintech):** Fondo azul medianoche profundo `#0B1C30`, tarjetas `#13233A`, bordes `#1E3555`, menta neón `#00D68F` y tipografía blanca perlada `#F8F9FF`.
     - **Zentra Cobalt (Azul Ejecutivo Fintech):** Azul cobalto financiero internacional `#0052FF`, cyan neón `#00D8FF`, fondo `#F8F9FF`, texto grafito `#0B192C`.
  3. Preservar los temas anteriores (`TM Diseños`, `Nude & Blush`, `Esmeralda`, `Lavanda`) como una colección secundaria de personalización.
  4. Retirar el botón de paleta del header y la barra inferior. La configuración de apariencia ahora vive de forma elegante dentro de **Datos de Mi Negocio / Perfil**, accesible cuando el usuario lo decida.
  5. Mantener en todos los temas el logo oficial de Zentra (`img/zentra-logo.png`).
- **Implementación Técnica:**
  - **CSS Themes:** Declaración limpia de `[data-theme="zentra_midnight"]` y `[data-theme="zentra_cobalt"]` en `index.html` y `preview.html`.
  - **Header & Bottom Bar:** Eliminación de `#btnThemePicker` del header; la navegación inferior ahora presenta un flujo despejado (`Inicio`, `Catálogo`, `Mi Negocio`).
  - **Configuración de Negocio (`#bizModal`):** Incorporación de la tarjeta "Tema y Apariencia Visual" con el nombre del tema activo y botón para abrir el selector.
  - **Modal de Selección (`#themeModal`):** Clasificación en dos grupos: *💎 Colección Zentra Fintech (Oficial)* y *🎨 Colección de Personalización*.
  - **Sincronización:** Actualización reactiva de `applyTheme` con soporte para meta `theme-color` adaptativo (`#0B1C30` en modo oscuro / `#FFFFFF` en claro) y persistencia en `localStorage`.

#### Hito 13: Blindaje de Contraste y Corrección de Campos de Texto en Registro/Login
- **Problema previo:** En dispositivos móviles o al tener activo un modo oscuro (como Zentra Midnight o el modo oscuro nativo de Android/iOS), las casillas de texto del formulario de Registro y Creación de Negocio (`setupNameInp`, `setupOwnerInp`, etc.) y Login se mostraban con texto blanco sobre fondo blanco, volviendo invisible lo que el usuario escribía.
- **Solución implementada:**
  1. Se forzó `color-scheme: light !important;` en `#authScreenModal` y todos sus inputs para prevenir que los navegadores móviles fuercen estilos oscuros automáticos en el formulario blanco.
  2. Se fijó el color del texto digitado a `#0F172A !important` (grafito oscuro profundo) y `-webkit-text-fill-color: #0F172A !important`, con fondo `#FFFFFF` y bordes `#CBD5E1`.
  3. Se aseguraron las etiquetas del formulario, títulos de las tarjetas operativas (`#txtSetupServiciosTitle`, `#txtSetupRetailTitle`) y botones de pestañas con colores de alto contraste.
  4. En Flutter (`app_theme.dart`, `login_screen.dart`, `mode_selection_screen.dart`), se vinculó explícitamente el color de los `TextField` a `theme.textDark` para mantener sincronía visual y legibilidad garantizada en todas las plataformas.

#### Hito 14: Eliminación Definitiva de Datos Demo en Retail y Purga de Referencias Cruzadas en Catálogo
- **Problema previo:**
  1. La vista Retail (`viewRetail`) conservaba cifras estáticas de maqueta en el HTML (`$84.500` en Ventas Hoy, `$184.500` en Caja y `2 con bajo stock`). Al crear un nuevo negocio de tipo Retail, el usuario veía estos saldos demo como si pertenecieran a su cuenta o a otro negocio.
  2. El modal de Catálogo e Inventario contenía pestañas estáticas tituladas `TM Diseños (Servicios)` y `Don Pedro (Retail)`. En negocios nuevos (incluso en Retail), abría por defecto en Servicios mostrando los nombres de otras empresas y diciendo erróneamente que no había productos registrados en esa modalidad.
- **Solución implementada:**
  1. Se eliminaron todas las cifras y etiquetas estáticas de `viewRetail`: `txtVentasHoy` y `txtCajaHoy` arrancan en `$0`, y la alerta de stock bajo arranca oculta.
  2. Se reprogramó `renderPos()` y `recalcularTodo()` para calcular las ventas del POS, la caja real y el stock bajo en tiempo real a partir de las transacciones efectivas del negocio activo.
  3. Se retiraron las pestañas con nombres de otros comercios del modal de catálogo. Ahora el catálogo es 100% exclusivo y adaptado automáticamente a la modalidad del negocio activo (`bizProfile.type`), sin filtros ajenos ni mención a terceras marcas.
  4. Se neutralizaron todos los placeholders del sistema (`usuario@minegocio.com`, `Mi Negocio`, etc.) y los segmentos de Flutter en `catalog_inventory_screen.dart` (`Servicios (Por Encargo)` y `Retail (Mostrador POS)`).

#### Hito 15: Administración Avanzada del Propietario (Catálogo con Costo/Venta, Carrito Mostrador/Retail, Pedidos a Medida y Flujo Cotización vs Factura)
- **Requerimiento del Usuario:**
  1. **Catálogo con Costos y Precios de Venta:** Permitir crear tanto productos físicos como servicios por encargo especificando valor de costo y valor de venta, visualizando el margen de ganancia real por unidad.
  2. **Toma de Pedidos como Carrito de Compras en Servicios / Proyectos:** Permitir agregar ítems de proyectos a elaborar a la medida (por ejemplo: "Tarjetas de invitación" personalizadas con cantidad, costo y precio unitario) y combinarlos libremente con otros productos o servicios del catálogo en un único pedido con valor total acumulado.
  3. **Toma de Pedidos como Carrito de Compras en Retail / Mostrador:** Permitir seleccionar productos del mostrador con cantidades deseadas `[-] [qty] [+]`, visualizando en tiempo real la barra flotante con total acumulado y conteo de artículos.
  4. **Generación de Comprobantes con Doble Estado para Ambos Modelos:**
     - **Estado "Presupuesto o Cotización" (`#COT-...`):** Documento formal previo al pago con validez de 15 días, desglose de ítems, cuentas bancarias registradas y opción de compartir directamente por WhatsApp o imprimir. No descuenta inventario ni registra entrada en caja.
     - **Estado "Facturado / Pagado" (`#FAC-...`):** Al confirmar el pago del cliente, se genera la Factura Oficial o Recibo de Pago con sello verde de cancelado, registrando automáticamente el ingreso en caja y descontando el stock físico correspondiente.
- **Implementación Técnica:**
  - **Catálogo Unificado:** En `newProductModal`, selector interactivo entre `📦 Producto Físico` (con control estricto de existencias) y `✂️ Servicio / Proyecto` (disponibilidad por encargo sin bloqueo de stock). Cálculo dinámico en vivo de Ganancia Neta (`precio - costo`) y Margen Comercial (`((precio - costo) / precio) * 100`). Filtros rápidos por chips en el catálogo (`Todos`, `📦 Productos`, `✂️ Servicios`).
  - **Motor POS de Carrito Retail (`retailCart`):**
    - Barra flotante inferior `#retailCartBar` con contador animado y total COP en tiempo real.
    - Modal de Carrito `#retailCartModal` con edición rápida de unidades, botón de remover, captura opcional de cliente y teléfono WhatsApp.
    - Botones de acción dual: `⚡ COBRAR Y FACTURAR` (descuenta existencias, registra ingreso y abre factura `#FAC-...`) y `📋 GENERAR COTIZACIÓN` (guarda cotización sin cobro ni alteración de existencias y abre presupuesto `#COT-...`).
  - **Módulo de Ítems a Medida para Proyectos (`customItemModal`):**
    - Captura de descripción del trabajo artesanal/gráfico, cantidad, costo unitario de materiales e insumos y precio de venta acordado.
    - Integración transparente en la lista de ítems del encargo y sumatoria automática del total del proyecto.
  - **Plantilla Unificada de Comprobantes (`invoiceReceiptModal`):**
    - Renderizador inteligente `abrirFacturaReciboConDatos(data)` y `abrirFacturaRecibo(mode)` que alterna diseño, títulos, numeración correlativa (`#COT-` vs `#FAC-`), avisos de validez comercial y texto preformateado para envío vía WhatsApp (`https://wa.me/...`).
    - Flujo de transición directa desde la pantalla del proyecto: botón `💳 CLIENTE PAGÓ -> REGISTRAR PAGO Y FACTURAR` que actualiza el estado de `Cotización` a `Facturado / En Producción`.
  - **Sincronización en Flutter (`catalog_item_model.dart`):**
    - Adición de `itemType` ('producto' | 'servicio'), getter `isService`, y persistencia en `toMap()` y `fromMap()`.

#### Hito 16: Flujo Rápido de Toma de Pedidos, Carrito Superior Derecho Permanente y Acciones Directas (Cotizar / Cobrar)
- **Requerimiento del Usuario:**
  1. **Botón Tomar Pedido:** Crear un botón directo en la pantalla principal para iniciar la toma de pedido, abriendo el catálogo interactivo para agregar artículos al carrito.
  2. **Ícono del Carrito Permanente Arriba a la Derecha:** Mantener visible en todo momento el carrito de compras en la esquina superior derecha con contador numérico animado, tanto en el header principal como dentro del catálogo al armar el pedido.
  3. **Dos Acciones Claras en el Carrito:**
     - **`📋 Cotizar`**: Genera la cotización comercial (`#COT-...`), copia de inmediato el texto preformateado al portapapeles y facilita el envío por WhatsApp con cuentas bancarias y validez de 15 días.
     - **`💳 Cobrar`**: Genera la factura oficial (`#FAC-...`), descuenta existencias físicas, registra el ingreso en la caja diaria y facilita el envío del recibo pagado al cliente.
- **Implementación Técnica:**
  - **Botón `⚡ TOMAR PEDIDO`:** Integrado en la vista principal de Servicios y en Mostrador Retail con acceso directo a `abrirTomarPedido()`.
  - **Carrito Permanente Superior Derecho:**
    - Botón `#btnHeaderCart` en `.header-actions` del app header con badge en vivo `#headerCartBadge`.
    - Botón `#btnModalCatCart` en la esquina superior derecha del modal de catálogo con badge `#modalCatCartCount`.
    - Barra flotante de carrito `#catalogModalBottomCart` al pie del catálogo cuando hay ítems acumulados.
  - **Soporte de Ítems a Medida:** Integración de `+ Ítem a Medida` dentro del catálogo y del carrito (`guardarItemMedida()` sincronizado con `retailCart`).
  - **Motor de Cotización y Copia WhatsApp:** Función `cotizarYCopiarWhatsApp()` con invocación a `navigator.clipboard.writeText()`, feedback toast y pre-llenado de enlace `https://wa.me/...`.
  - **Motor de Facturación Oficial:** Función `procesarCobroRetail()` con actualización contable, deducción de stock y generación de comprobante cancelado `#FAC-...`.

#### Hito 17: Auto-Recuperación de Negocios y Acceso Directo en Portal de Entrada
- **Problema previo:**
  - Al cerrar sesión en un negocio recién creado (por ejemplo, "Better Life"), el usuario quedaba bloqueado en la pantalla de inicio de sesión porque el formulario exigía exclusivamente el nombre del usuario o teléfono original. Si el usuario digitaba el nombre comercial del negocio ("Better Life"), el buscador interno no lo encontraba al comparar solo los nombres de usuario de los colaboradores.
- **Solución implementada:**
  1. **Auto-Descubrimiento y Recuperación:** `obtenerRegistroNegocios()` ahora escanea proactivamente todas las llaves `zentra_biz_profile_*` en `localStorage`, asegurando que cualquier negocio creado en el dispositivo se detecte y preserve automáticamente en el registro general.
  2. **Acceso Visual 1-Toque (`boxSavedBusinesses`):** El portal de entrada ahora lista automáticamente las tarjetas de todos los negocios presentes en el dispositivo con su nombre comercial, modalidad y propietario, permitiendo ingresar a "Better Life" con un solo clic en `[ Entrar ➔ ]`.
  3. **Búsqueda Flexible:** `iniciarSesionUsuario()` ahora busca coincidencias por nombre del negocio (ej: `Better Life`, `better life`, `betterlife`), nombre del propietario, teléfono o usuario, permitiendo el ingreso sin fricciones.
  4. **Visibilidad de PIN:** Se añadió botón de visualización de PIN (`👁️`) para verificar la clave digitada (con soporte para el PIN predeterminado `1234`).

#### Hito 18: Selector y Creación Express de Clientes en Carrito de Ventas / Cotización
- **Requerimiento del Usuario:**
  - En la cotización y factura se incluye el dato del cliente. Si no se escogió un cliente con anterioridad, se requirió una opción interactiva dentro del carrito que permita:
    1. **Escoger un cliente existente** del directorio registrado del negocio.
    2. **Crear un nuevo cliente** al vuelo desde el mismo carrito sin perder los productos seleccionados.
    3. Si no se escoge ni crea ningún cliente, mantener la experiencia de **cliente genérico ("Cliente Mostrador")** tal como funcionaba antes, sin bloqueos ni pasos innecesarios.
- **Implementación Técnica:**
  - **Selector Directo en Carrito (`cartClientSelect`):** Desplegable dinámico alimentado en tiempo real con los clientes pertenecientes exclusivamente al negocio activo (`clients`), mostrando nombre y WhatsApp.
  - **Creación Express (`abrirCrearClienteDesdeCarrito()`):**
    - Botón `➕ Nuevo` en la cabecera del cliente dentro del carrito que despliega el modal completo de cliente (`clientModal`, elevado a `z-index: 420` para superponerse con seguridad sobre el carrito).
    - Pre-llenado inteligente con cualquier nombre o teléfono que el usuario haya empezado a digitar en el carrito.
    - Al guardar, el cliente recién creado queda vinculado de inmediato a la orden (`selectedCartClientId`) y sus datos se reflejan automáticamente en el carrito.
  - **Indicadores Visuales y Desvinculación:**
    - Badge reactivo (`#lblCartClientBadge`): alterna entre `Cliente Genérico` (gris), `✓ Cliente Vinculado` (verde) y `Cliente Personalizado` (amarillo si se editan datos manualmente).
    - Botón `✕ Desvincular` para regresar con un toque al estado genérico ("Cliente Mostrador").
  - **Integración con Cotizaciones y Facturas:**
    - `cotizarYCopiarWhatsApp()` y `procesarCobroRetail()` incorporan automáticamente el nombre, WhatsApp y documento/NIT del cliente vinculado en el texto preformateado y en el comprobante oficial (`invoiceReceiptModal`), preservando la validez de 15 días y cuentas bancarias.
    - Si no se selecciona cliente, se genera de forma inmediata con "Cliente Mostrador" / "Consumidor Final" conservando la máxima agilidad en el punto de venta.

#### Hito 19: Edición de Catálogo con Fotos/Cámara, Medios de Pago con QR en Perfil y Formatos Simplificados de Cotización y Factura
- **Requerimiento del Usuario:**
  1. **Edición en Catálogo:** Al entrar al catálogo se debe poder editar cualquier producto o servicio existente (modificar nombre, precios, costos, existencias, categoría) y adjuntar una imagen o tomar una foto directamente desde la cámara del celular.
  2. **Perfil del Negocio:** Configurar medios de pago reales (Nequi, Daviplata, Bancolombia u otros canales como Bre-B / Llave) y permitir subir la imagen de un código QR de cobro para facilitar el proceso de pago al cliente.
  3. **Cero Datos Inventados:** En la cotización y factura se deben enviar **única y exclusivamente** los medios de pago configurados por el usuario. Eliminar números demo o textos ficticios de relleno (`"312 000 0000"`, `"Consultar"`, `"Cuenta registrada"`). Si no hay medios registrados, no se inventa nada.
  4. **Formatos Sencillos y Despejados:** Simplificar drásticamente los formatos de cotización y factura tanto en WhatsApp como en el recibo visual (descartar caracteres ASCII sobrecargados, divisores pesados y textos redundantes; presentar la información de forma directa, limpia y ejecutiva).
- **Implementación Técnica:**
  - **Edición Completa en Catálogo (`abrirModalEditarProducto(id)`):**
    - Se incorporó un botón de edición `✏️` en cada tarjeta de producto y servicio del catálogo.
    - El modal `#newProductModal` opera en modo dual (Creación / Edición) mediante la variable `editingProductId`, cargando en tiempo real datos, costos, precios, stock y la foto previa.
    - Integración de carga y captura fotográfica (`#productPhotoInp` con soporte `capture="environment"` para cámara móvil) con previsualización inmediata y botón de eliminación.
    - Al guardar con `guardarNuevoProducto()`, se actualizan los datos en el inventario global (`catalogItems`), se sincronizan en caliente en el carrito de compras (`retailCart` y `cart`) si ya habían sido agregados, y se persisten en `localStorage`.
  - **Medios de Pago y Código QR en Perfil del Negocio:**
    - Nuevos campos en el modal `#bizModal`: Nequi, Daviplata, Bancolombia, Otro Medio / Llave Bre-B, y cargador de código QR (`#bizQrPhotoInp`, `#bizQrPreview`).
    - Las nuevas cuentas creadas inician limpias en `limpiarEstadoEnMemoria()` y `registrarNuevoNegocio()`, sin autocompletar números demo con el teléfono del dueño.
    - Persistencia integral en `bizProfile` con almacenamiento en Base64 de la imagen QR y sincronización en `localStorage`.
  - **Filtrado Estricto de Cero Datos Inventados (`obtenerMediosDePagoActivos()`):**
    - Se creó la función centralizada `obtenerMediosDePagoActivos()`, que evalúa los campos registrados y retorna únicamente métodos con datos reales introducidos por el usuario.
    - Si el negocio no ha configurado ningún medio de pago ni QR, la sección de medios de pago se omite por completo tanto en el texto de WhatsApp como en el comprobante visual.
  - **Rediseño Minimalista de Cotización y Factura:**
    - **WhatsApp (`generarTextoCotizacionWhatsApp()` y `generarTextoFacturaWhatsApp()`):** Formato limpio, directo y elegante: título claro, consecutivo, fecha, cliente, desglose conciso de ítems, total en COP, medios de pago activos y teléfono de contacto.
    - **Modal Visual (`invoiceReceiptModal`):** Despeje tipográfico, tabla simplificada de ítems, distintivo claro según estado (Cotización en amarillo vs Factura en verde), y bloque dinámico `#recPaymentContainer` que renderiza las cuentas activas y el código QR (`#recQrImg`) con un diseño estético y moderno.
    - Sincronización completa en los disparadores `copiarWhatsAppCotizacion()`, `cotizarYCopiarWhatsApp()`, `enviarReciboWhatsApp()`, `copiarTextoRecibo()` y `procesarCobroRetail()`.
  - **Refinamiento de Envío de Imagen QR y Regla de Factura Pagada:**
    - **Envío de QR en Cotizaciones:** Se implementó `compartirOEnviarCotizacionWhatsApp(receiptData)` junto con `dataURLtoFile()`, `descargarImagenQR()` y `copiarQRAlPortapapeles()`. En dispositivos móviles (Android/iOS) utiliza el Web Share API (`navigator.share`) para adjuntar el archivo nativo de imagen del QR directamente al chat de WhatsApp junto con el texto formateado. En escritorio o navegadores sin share de archivos, descarga la imagen del código QR automáticamente y la copia al portapapeles (`Ctrl+V`) informando al comerciante para adjuntarla al chat de WhatsApp Web.
    - **Exclusión Absoluta del QR en Facturas:** En la factura el código QR permanece **100% oculto** tanto en el modal como en cualquier exportación (`qrWrapper.style.display = 'none'`), cumpliendo la regla de negocio de que el cliente ya canceló. Asimismo, si la factura está totalmente saldada (`saldo <= 0`), la caja completa de medios de pago se oculta automáticamente. Si existe un saldo pendiente por cobrar, únicamente se enlistan los datos bancarios de transferencia sin imagen de código QR.

#### Hito 20: Personalización Dinámica de Pantalla de Inicio (Selector de 4 Layouts en Vivo)
- **Requerimiento del Usuario:**
  - Sustituir la sección de "Personalizar / Temas de Colores" previa para no limitarse a paletas estéticas que se abordarán en una etapa posterior.
  - Ofrecer en la opción de "Personalizar" (accesible desde el Perfil del Negocio `⚙️`) las **4 propuestas de pantalla de inicio**, permitiendo al comerciante alternar entre ellas en vivo, probarlas directamente con sus datos reales y definir cuál se adapta mejor a su operación diaria.
- **Implementación Técnica:**
  1. **Eliminación de Paletas Antiguas:** Se retiraron las combinaciones cromáticas previas (`theme-light`, `theme-midnight`, etc.) para dar paso a la selección de arquitectura y experiencia de usuario.
  2. **Las 4 Pantallas de Inicio Implementadas e Interactivas:**
     - **Opción A: Cockpit Operativo Diario (`layout_a`):**
       - Saludo y fecha en tiempo real.
       - Semáforo de prioridades ejecutivas: pedidos con fecha de entrega para hoy, cotizaciones pendientes de seguimiento comercial con botón de contacto WhatsApp en 1 toque, e insumos/productos con stock crítico.
       - Balance y cuadre de caja del día (ingresos, cobros y ventas recientes).
     - **Opción B: Terminal Mostrador Rápido / POS-First (`layout_b`):**
       - Indicadores comerciales directos (ventas hoy, ticket promedio).
       - Buscador instantáneo de catálogo y filtro táctil por categorías (Todos, Servicios, Ropa, etc.).
       - Cuadrícula ágil de productos con botón directo `+` para agregar al carrito en un toque y barra flotante de cobro inmediato.
     - **Opción C: Tablero Visual Kanban de Producción (`layout_c`):**
       - Visión global de pedidos en curso y monto pendiente por cobrar.
       - Selector de fases operativas: `Cotización`, `Diseño`, `Producción`, `Empaque`, `Entregado`.
       - Tarjetas interactivas con avance de estado en 1 clic (`Avanzar a Producción ➔`) y acceso directo a la lista de chequeo / insumos del pedido.
     - **Opción D: Enfoque Híbrido Modular por Widgets (`layout_d`):**
       - Widget de Saldo Disponible en tiempo real + Botón protagonista `⚡ Tomar Pedido`.
       - Barra de 4 Accesos Rápidos: `Vender`, `Gasto`, `Catálogo`, `Clientes`.
       - Bloques de alertas prioritarias y actividad reciente interactiva.
  3. **Selector Modal de Experiencia (`#themeModal`):**
     - Tarjetas táctiles descriptivas con ícono, título y resumen funcional.
     - Badge dinámico `✓ Activo` y activación reactiva en tiempo real al tocar cualquier opción.
  4. **Persistencia en LocalStorage:**
     - Guardado automático de la preferencia en `zentra_active_layout`.
     - Integración con el perfil del negocio (`#bizModal`), mostrando el diseño activo bajo el campo "Diseño de Pantalla de Inicio".
  5. **Mantenimiento de Subsecciones Operativas:**
     - Clientes, Movimientos Generales de Caja y Catálogo se conservan como subsecciones navegables con botones de retorno `← Volver al Inicio`.

#### Hito 21: Registro Directo de Otros Ingresos y Módulo de Seguimiento de Cotizaciones / Carritos Guardados
- **Requerimiento del Usuario:**
  1. **Botón para Registrar Otros Ingresos:** Asegurar un acceso visual claro y directo para registrar ingresos independientes (no atados a un pedido o proyecto particular), reflejándolos en el cuadre de caja de hoy y en las finanzas del negocio.
  2. **Seguimiento Comercial de Cotizaciones y Carritos:** Las cotizaciones de carritos no podían recuperarse si el cliente no cancelaba el mismo día. Se requirió una solución integral para:
     - Guardar automáticamente las cotizaciones para retomar la venta en cualquier momento.
     - Permitir recuperar con 1 clic los ítems cotizados en el carrito para cobrar o editar.
     - Eliminar definitivamente las cotizaciones que ya no van.
     - Establecer una caducidad de tiempo automática para descartar cotizaciones sin respuesta.
     - Ofrecer una opción para **extender la vigencia (+15 días)** si el negocio aún sigue viable.
- **Implementación Técnica:**
  - **Accesos Rápidos para Registrar Otros Ingresos:**
    - Botones directos `➕ Registrar Ingreso` y `➖ Registrar Gasto` incorporados en:
      - La tarjeta de *Cuadre Rápido de Caja de Hoy* en el **Cockpit Operativo (Opción A)**.
      - El bloque financiero de *Saldo Disponible* en el **Híbrido Modular (Opción D)**.
      - La subsección de *Movimientos Generales (`subSecMovimientos`)*.
    - Integración en `renderLayoutCockpit()` y `recalcularTodo()` sumando `generalIncomes` al cálculo de dinero real ingresado hoy.
  - **Estructura de Datos y Aislamiento Multi-Tenant (`savedQuotes`):**
    - Colección de cotizaciones aislada por negocio en `localStorage` bajo `zentra_quotes_${bizId}`.
    - Campos por cotización: `id`, `consecutivo`, `date`, `createdAt`, `expiresAt` (15 días por defecto), `clientName`, `clientPhone`, `clientDoc`, `clientId`, `items` (copia profunda del carrito), `total`, `status` (`'activa'`, `'por_vencer'`, `'vencida'`, `'facturada'`) y `extendedCount`.
  - **Motor de Caducidad Dinámica (`calcularEstadoCotizacion(q)`):**
    - Evalúa en milisegundos los días restantes de vigencia:
      - `> 3 días`: Badge azul `Vence en X días`.
      - `≤ 3 días`: Alerta naranja `⏰ Vence en X días`.
      - `< 0 días`: Alerta roja `⚠️ Expiró hace X días`.
      - Facturada: Badge verde `✓ Facturada`.
    - Depuración automática (`depurarCotizacionesAutomaticas()`): purga automática en background de cotizaciones vencidas hace más de 30 días sin renovar.
    - Botón de acción masiva `🧹 Depurar Vencidas` para descartar cotizaciones expiradas con confirmación.
  - **Flujo de Retoma de Ventas (`retomarVentaCotizacion(id)`):**
    - Carga en 1 toque todos los productos, cantidades y cliente vinculado en el carrito de compras (`retailCart`, `selectedCartClientId`), abriendo el carrito listo para cobrar (`💳 COBRAR`) o añadir ítems.
    - Vínculo activo `activeWorkingQuoteId`: al presionar `COBRAR` en `procesarCobroRetail()`, la cotización pasa automáticamente a estado `'facturada'` vinculando el número de factura `#FAC-...`.
  - **Extensión de Vigencia y Seguimiento Comercial WhatsApp:**
    - Botón `⏰ +15 días` (`extenderVigenciaCotizacion(id)`): añade 15 días adicionales a partir de la fecha actual y restablece el estado a vigente.
    - Botón `💬 WhatsApp` (`enviarSeguimientoCotizacionWhatsApp(id)`): genera un mensaje preformateado de seguimiento comercial al cliente con el desglose de productos y total para concretar el cierre de la venta.
    - Botón `💾 Guardar Cotización` dentro del carrito de ventas para guardar borradores sin necesidad de enviar por WhatsApp.
  - **Indicadores y Accesos UI:**
    - Botón `#btnHeaderQuotes` en la cabecera superior con badge `#headerQuotesBadge`.
    - Botón interactivo en la barra de navegación inferior (`bottom-bar`) con badge `#navQuotesBadge`.
    - Indicador en POS Mostrador (`#posQuotesCountVal`) y contador en el carrito (`#cartQuotesCountBadge`).
    - Alerta en tiempo real en el semáforo del Cockpit y en las alertas del Híbrido.

#### Hito 22: Soporte Completo para Subida de Imágenes desde Galería del Teléfono y Cámara en Catálogo
- **Problema previo:**
  - En teléfonos móviles (Android Chrome, iOS Safari), el input de foto del catálogo utilizaba exclusivamente el atributo `capture="environment"`, lo cual forzaba la apertura directa de la cámara trasera y bloqueaba la posibilidad de seleccionar fotos previamente tomadas, descargadas o guardadas en la galería del teléfono.
  - Además, el trigger dependía de llamadas a `.click()` sobre inputs con `display: none;`, lo cual en algunos navegadores móviles es restringido por políticas de seguridad táctil.
- **Solución implementada:**
  1. **Selector Dual Independiente en Móvil:**
     - **`📁 Galería / Fotos`:** Conectado a un input `<input type="file" id="prodPhotoGalleryInp" accept="image/*">` **sin capture**, permitiendo al usuario abrir el carrete de fotos, Google Fotos, descargas y almacenamiento interno de su celular.
     - **`📸 Cámara`:** Conectado a un input `<input type="file" id="prodPhotoCameraInp" accept="image/*" capture="environment">` para quienes prefieran capturar la foto en vivo del producto en la mesa de trabajo.
  2. **Activación Nativa por `<label for="...">`:**
     - La asociación táctil se realiza mediante etiquetas `<label>` nativas del navegador, garantizando que el diálogo del sistema operativo se abra el 100% de las veces en dispositivos móviles sin bloqueos de eventos sintéticos.
  3. **Optimización Canvas y Feedback:**
     - Redimensionamiento proporcional automático en cliente (máx 400px, compresión JPEG 0.8) para garantizar nitidez visual sin desbordar la cuota de `localStorage` del dispositivo.
     - Indicadores de estado visual: *"⏳ Procesando imagen..."*, *"✓ Foto cargada exitosamente"* y *"✓ Foto actual cargada (puedes cambiarla o quitarla)"* al entrar a editar un producto.
     - Reseteo automático de los campos de archivo para permitir cambiar de foto o volver a subir una corregida sin necesidad de recargar la página.
  4. **Persistencia y Sincronización:**
     - Al guardar la edición (`guardarNuevoProducto()`), la nueva foto se actualiza inmediatamente en el catálogo (`catalogItems`), se sincroniza en caliente en el carrito de compras (`retailCart`) si el ítem ya estaba agregado, y se almacena en `localStorage`.

---

#### Hito 23: Flujo Directo de Personalización sin Modales Huérfanos y Módulo de Tareas Pendientes con Seguimiento Interactivo en Inicio
- **Requerimiento del Usuario:**
  1. **Flujo de Personalización sin Fricción:** Al hacer clic en "Personalizar" dentro del modal del perfil del negocio (`#bizModal`), este debe cerrarse automáticamente para que al seleccionar o cambiar el diseño de inicio el comerciante quede directamente en la pantalla de inicio, sin tener que cerrar manualmente la pestaña de perfil que quedaba abierta detrás.
  2. **Módulo de Tareas Pendientes con Seguimiento en Inicio (Especial para Taller):** Agregar una función práctica para crear tareas y llevar su seguimiento con checklist interactivo visible directamente en la pantalla de inicio principal (crucial para operaciones de taller, reparaciones y encargos del día a día).
  3. **Control Habilitar/Deshabilitar:** Integrar la opción de activar o desactivar este módulo de tareas tanto en el menú de *Personalizar* (`#themeModal`) como en el *Perfil del Negocio* (`#bizModal`), de modo que el comerciante decida si lo quiere ver y usar o si prefiere ocultarlo.
- **Implementación Técnica:**
  1. **Redirección Fluida en `openThemeModal()`:**
     - Se vinculó el cierre automático de `#bizModal` (`cerrarBusinessProfileModal()`) de modo que al pulsar "Personalizar", el perfil se oculta de inmediato y se presenta el selector de experiencia. Al elegir cualquier modo o pulsar "Aceptar y Continuar", se regresa inmediatamente a la pantalla de inicio activa limpia.
  2. **Módulo de Tareas Pendientes (`pendingTasks`):**
     - Estructura de cada tarea: `id`, `text`, `priority` (`'alta'` 🔴 Urgente / `'normal'`), `completed` (booleano), `createdAt` y `completedAt`.
     - Aislamiento multi-tenant en `localStorage` bajo `zentra_tasks_${bizId}`.
     - Operaciones CRUD completas:
       - `agregarNuevaTarea(text, priority)` y `agregarNuevaTareaDesdeWidget(suffix)` con tecla Enter y botón rápido `+ Agregar`.
       - Checkbox circular amplio (24px) que alterna entre pendiente y completada (`toggleEstadoTarea(taskId)`), con animación, tachado visual de texto y opacidad atenuada.
       - Selector de prioridad en 1 toque (`🔴 Urgente`).
       - Eliminación individual (`eliminarTarea(taskId)`) y acción masiva `🧹 Limpiar completadas` (`limpiarTareasCompletadas()`).
  3. **Widget Reactivo en Pantalla de Inicio:**
     - Inyectado en los layouts principales: **Cockpit Operativo (Opción A)**, **Tablero Kanban de Taller (Opción C)**, **Híbrido Modular (Opción D)** y **POS Mostrador (Opción B)** mediante `actualizarWidgetsTareasPendientes()`.
     - Badge reactivo en tiempo real: muestra conteo de pendientes (ej. `2 pendientes`) o badge verde `✓ Todo al día` cuando no hay pendientes.
  4. **Interruptor Dinámico Habilitar/Deshabilitar (`bizProfile.showPendingTasks`):**
     - Sincronizado en tiempo real tanto en `#themeModal` como en `#bizModal` mediante `sincronizarToggleTareasPendientesUI()`.
     - Si está deshabilitado (`false`), los contenedores de tareas se ocultan totalmente del DOM (`display: none`), manteniendo la pantalla limpia para quienes no requieran el módulo.
  5. **Unificación a 1 Solo Botón en el Hero (Eliminación de Redundancias):**
     - Se eliminó el botón de *"Mi Negocio"* de la barra de navegación inferior (`bottom-bar`), dejando la barra optimizada con 3 accesos operativos principales: `Inicio`, `Catálogo` y `Cotizaciones`.
     - En el header/hero superior se retiró el badge del dueño que abría el mismo modal y se unificó en un único botón con ícono y texto: `[ 🏪 Mi Negocio ]`, eliminando la triple duplicidad de accesos para la misma acción.

---

## 6. Procedimiento para Registrar Nuevos Cambios

Cada vez que se reciba un nuevo requerimiento o se implemente una mejora:
1. **Analizar la lógica:** Verificar si impacta el Modelo de Servicios, el Modelo Retail o ambos.
2. **Actualizar el código:** Reflejar el cambio tanto en el prototipo interactivo ([preview.html](file:///c:/Proyectos/MyBusiness/preview.html)) como en la app Flutter ([zentra/](file:///c:/Proyectos/MyBusiness/zentra/)).
3. **Actualizar esta Bitácora:** Añadir una nueva fila en la tabla de la Sección 5 y describir el cambio en la subsección de detalles.
4. **Commit & Push:** Realizar commit descriptivo y subirlo al repositorio en GitHub.

---

## 7. Hoja de Ruta / Próximos Pasos

- [x] **Persistencia Web (LocalStorage / IndexedDB):** Guardar en el navegador los proyectos, compras e inventario creados por el usuario en `preview.html` para no perderlos al recargar.
- [ ] **Generador de Recibos / Comprobantes en PDF:** Descarga de comprobante de entrega y anticipo para enviar al cliente.
- [ ] **Módulo de Clientes:** Directorio con historial de pedidos de cada cliente y total acumulado comprado.
- [ ] **Sincronización Supabase:** Conexión de la base de datos remota para persistencia multi-dispositivo cuando haya internet.
