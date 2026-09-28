# 04-DISEÑO-BASE-DATOS.md
## TABLAS PARA SUPABASE - ZENTRA V1.2

### REGLA GENERAL
Todas las tablas tienen: id, created_at, user_id, business_id

### 1. TABLAS CORE
**businesses**: id, name, mode, logo_url, address, phone
**users**: id, email, name
**business_users**: business_id, user_id, role

### 2. TABLAS CATALOGO
**clients**: id, name, phone, email, address, notes
**catalog_items**: id, name, description, price, cost, stock, image_url, type

### 3. TABLAS MODO RETAIL
**sales**: id, client_id, total, payment_method, date
**sale_items**: id, sale_id, catalog_item_id, quantity, price
**cash_movements**: id, type, amount, description, date

### 4. TABLAS MODO SERVICIOS - LAS DE TATIANA
**projects**: id, name, client_id, delivery_date, status, notes
**project_services**: id, project_id, catalog_item_id, quantity, price
**project_expenses**: id, project_id, description, amount, receipt_photo_url, date
**project_payments**: id, project_id, amount, payment_method, date, notes

### 5. TABLAS TAREAS Y ALERTAS
**tasks**: id, title, description, due_date, status, project_id

### 6. TABLAS CONFIGURACION
**app_settings**: id, key, value

### NOTAS PARA LA IA
1.  Activar RLS en Supabase. Cada usuario solo ve su business_id
2.  type en catalog_items puede ser: "product" o "service"
3.  status en projects: "En Diseño", "En Producción", "Listo", "Entregado"