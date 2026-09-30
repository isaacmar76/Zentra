ACTÚA COMO: Un arquitecto de software senior + diseñador UX para microempresas en Colombia.

MISIÓN: Construir "ZENTRA V1.2" una app móvil Flutter y Web para gestión financiera y operativa de negocios.

CONTEXTO CRÍTICO:
Zentra es una plataforma para emprendedores y micronegocios en Colombia (retail y servicios creativos). Los diseños deben ser limpios, visuales y armónicos, con fondos blancos/perla suaves y sin saturación estridente. La personalización de "TM Diseños Creativos" se mantiene disponible como tema opcional activable para Tatiana, mientras que Zentra mantiene su enfoque público general, neutral y profesional.

ROLES Y PERFILES DE USUARIO (SISTEMA DE ACCESO):
1. **Dueño / Administrador (`OWNER`):** Control total del negocio. Acceso ilimitado a métricas de ganancia neta, costos de materiales, compras directas, configuración del negocio y gestión CRUD de colaboradores (crear, editar, eliminar y asignar PINs).
2. **Colaborador / Vendedor (`COLLABORATOR`):** Perfil operativo para ventas diarias, creación de pedidos, checklist de tareas de proyectos y consulta de catálogo. Por confidencialidad, las métricas de ganancia neta y el desglose de márgenes permanecen protegidos/enmascarados (`••••••`).

CATÁLOGO MULTIMEDIA:
- Soporte para subir imágenes o capturar fotos directas desde la cámara del celular (`accept="image/*"` con compresión a 320x320 px).
- Visualización de miniaturas en catálogo, punto de venta (POS) y selectores de pedidos.

PROYECTOS MULTI-PRODUCTO / MULTI-ÍTEM:
- Dentro de un mismo proyecto (ej. "Cumpleaños", "Boda"), se pueden agregar múltiples productos del catálogo (toppers, portaplatos, dulces, invitaciones) con cantidades ajustables y subtotales calculados automáticamente.
- Soporte para ítems a medida personalizados.
- Generación automática de cotizaciones detalladas e itemizadas listas para enviar por WhatsApp con datos bancarios (Nequi, Bancolombia).

REGLAS DE ORO:
1. Usa SIEMPRE los archivos de documentación del repositorio como fuente de verdad.
2. Todo el código comentado en español.
3. Prioriza simpleza, velocidad y facilidad visual sobre interfaces sobrecargadas.
4. Funcionamiento offline-first con persistencia local antes de sincronizar en la nube.
5. Preservar fondos limpios y estéticos en todas las pantallas.

ENTREGA POR FASES:
FASE 1: Proyecto Flutter y Web base con Login multi-usuario (PIN) y selección de modo (Retail vs Servicios).
FASE 2: Dashboard con tarjetas de métricas adaptadas según el rol del usuario activo.
FASE 3: Proyectos multi-ítem con catálogo de productos, fotos y cotización para WhatsApp.
FASE 4: CRUD de usuarios y roles (Dueño vs Colaborador) con privacidad de utilidades.
FASE 5: Sincronización con base de datos / Supabase según especificaciones del archivo 04.