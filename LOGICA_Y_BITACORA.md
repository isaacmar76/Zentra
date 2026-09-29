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
| **2026-09-29** | `051ed97` | Deploy / PWA | Estructura para despliegue instantáneo en Vercel (`index.html`, `vercel.json`, `manifest.json`, iconos PWA) | ✅ Completado |
| **2026-09-29** | *Pendiente Push* | UI / Branding | Integración de la paleta oficial de TM Diseños Creativos (`#ff2b78`, `#ff4400`, `#ffe3f4`, `#545454`, `#ffffff`) como tema oficial | ✅ Completado |

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

#### Hito 6: Paleta Oficial de Marca TM Diseños Creativos
- **Especificación de Marca recibida:**
  - Fucsia vibrante: `#ff2b78`
  - Naranja vibrante: `#ff4400`
  - Rosa pastel suave (fondo): `#ffe3f4`
  - Gris carbón (texto y contraste): `#545454`
  - Blanco puro (tarjetas y superficies): `#ffffff`
- **Implementación:**
  1. Se agregó la paleta `tm_disenos` como tema oficial principal tanto en Flutter ([app_theme.dart](file:///c:/Proyectos/MyBusiness/zentra/lib/core/theme/app_theme.dart), [theme_provider.dart](file:///c:/Proyectos/MyBusiness/zentra/lib/core/theme/theme_provider.dart)) como en la versión web PWA ([index.html](file:///c:/Proyectos/MyBusiness/index.html) y [preview.html](file:///c:/Proyectos/MyBusiness/preview.html)).
  2. Se añadió como primera opción destacada con distintivo `OFICIAL` en el selector de temas.
  3. Se sincronizó la persistencia del tema en el almacenamiento local.

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
