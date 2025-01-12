DO $$ 
DECLARE 
    csv_path TEXT := 'E:\db_course_work\csv\'; -- Путь к папке с CSV-файлами
BEGIN
    -- Создание временных таблиц
    CREATE TEMP TABLE IF NOT EXISTS users_temp (LIKE users INCLUDING ALL);
    CREATE TEMP TABLE IF NOT EXISTS symptoms_temp (LIKE symptoms INCLUDING ALL);
    CREATE TEMP TABLE IF NOT EXISTS users_symptoms_temp (LIKE users_symptoms INCLUDING ALL);
    CREATE TEMP TABLE IF NOT EXISTS products_temp (LIKE products INCLUDING ALL);
    CREATE TEMP TABLE IF NOT EXISTS products_symptoms_temp (LIKE products_symptoms INCLUDING ALL);
    CREATE TEMP TABLE IF NOT EXISTS suppliers_temp (LIKE suppliers INCLUDING ALL);
    CREATE TEMP TABLE IF NOT EXISTS supplier_product_temp (LIKE supplier_product INCLUDING ALL);
    CREATE TEMP TABLE IF NOT EXISTS orders_temp (LIKE orders INCLUDING ALL);
    CREATE TEMP TABLE IF NOT EXISTS sold_products_temp (LIKE sold_products INCLUDING ALL);

    -- Загрузка данных из CSV-файлов
    EXECUTE format(
        'COPY users_temp(id, username, password_hash, email, phone, created_at, age, weight, height)
        FROM %L DELIMITER '','' CSV HEADER;',
        csv_path || 'users.csv'
    );

    INSERT INTO users (id, username, password_hash, email, phone, created_at, age, weight, height)
    SELECT id, username, password_hash, email, phone, created_at, age, weight, height
    FROM users_temp
    ON CONFLICT (id) DO NOTHING;

    -- Загрузка данных в таблицу symptoms
    EXECUTE format(
        'COPY symptoms_temp(id, translationKeyName, translationKeyDescriptopn)
        FROM %L DELIMITER '','' CSV HEADER;',
        csv_path || 'symptoms.csv'
    );

    INSERT INTO symptoms (id, translationKeyName, translationKeyDescriptopn)
    SELECT id, translationKeyName, translationKeyDescriptopn
    FROM symptoms_temp
    ON CONFLICT (id) DO NOTHING;

    -- Загрузка данных в таблицу users_symptoms
    EXECUTE format(
        'COPY users_symptoms_temp(id, symptom_id, user_id)
        FROM %L DELIMITER '','' CSV HEADER;',
        csv_path || 'users_symptoms.csv'
    );

    INSERT INTO users_symptoms (id, symptom_id, user_id)
    SELECT id, symptom_id, user_id
    FROM users_symptoms_temp
    ON CONFLICT (id) DO NOTHING;

    -- Загрузка данных в таблицу products
    EXECUTE format(
        'COPY products_temp(id, name, translationKeyName)
        FROM %L DELIMITER '','' CSV HEADER;',
        csv_path || 'products.csv'
    );

    INSERT INTO products (id, name, translationKeyName)
    SELECT id, name, translationKeyName
    FROM products_temp
    ON CONFLICT (id) DO NOTHING;

    -- Загрузка данных в таблицу products_symptoms
    EXECUTE format(
        'COPY products_symptoms_temp(id, symptom_id, product_id)
        FROM %L DELIMITER '','' CSV HEADER;',
        csv_path || 'products_symptoms.csv'
    );

    INSERT INTO products_symptoms (id, symptom_id, product_id)
    SELECT id, symptom_id, product_id
    FROM products_symptoms_temp
    ON CONFLICT (id) DO NOTHING;

    -- Загрузка данных в таблицу suppliers
    EXECUTE format(
        'COPY suppliers_temp(id, companyName, address, nip, contact_phone)
        FROM %L DELIMITER '','' CSV HEADER;',
        csv_path || 'suppliers.csv'
    );

    INSERT INTO suppliers (id, companyName, address, nip, contact_phone)
    SELECT id, companyName, address, nip, contact_phone
    FROM suppliers_temp
    ON CONFLICT (id) DO NOTHING;

    -- Загрузка данных в таблицу supplier_product
    EXECUTE format(
        'COPY supplier_product_temp(id, supplier_id, product_id, supplier_price, selling_price, quantity)
        FROM %L DELIMITER '','' CSV HEADER;',
        csv_path || 'supplier_product.csv'
    );

    INSERT INTO supplier_product (id, supplier_id, product_id, supplier_price, selling_price, quantity)
    SELECT id, supplier_id, product_id, supplier_price, selling_price, quantity
    FROM supplier_product_temp
    ON CONFLICT (id) DO NOTHING;

    -- Загрузка данных в таблицу orders
    EXECUTE format(
        'COPY orders_temp(id, user_id, orderCreatedAt, orderPaidAt, supplierRequestedAt, supplierSentAt, deliveredAt, refundedAt, completedAt)
        FROM %L DELIMITER '','' CSV HEADER;',
        csv_path || 'orders.csv'
    );

    INSERT INTO orders (id, user_id, orderCreatedAt, orderPaidAt, supplierRequestedAt, supplierSentAt, deliveredAt, refundedAt, completedAt)
    SELECT id, user_id, orderCreatedAt, orderPaidAt, supplierRequestedAt, supplierSentAt, deliveredAt, refundedAt, completedAt
    FROM orders_temp
    ON CONFLICT (id) DO NOTHING;

    -- Загрузка данных в таблицу sold_products
    EXECUTE format(
        'COPY sold_products_temp(id, order_id, supplier_price, selling_price, supply_id)
        FROM %L DELIMITER '','' CSV HEADER;',
        csv_path || 'sold_products.csv'
    );

    INSERT INTO sold_products (id, order_id, supplier_price, selling_price, supply_id)
    SELECT id, order_id, supplier_price, selling_price, supply_id
    FROM sold_products_temp
    ON CONFLICT (id) DO NOTHING;
    
   -- Удаление временных таблиц после выполнения
    DROP TABLE IF EXISTS users_temp;
    DROP TABLE IF EXISTS symptoms_temp;
    DROP TABLE IF EXISTS users_symptoms_temp;
    DROP TABLE IF EXISTS products_temp;
    DROP TABLE IF EXISTS products_symptoms_temp;
    DROP TABLE IF EXISTS suppliers_temp;
    DROP TABLE IF EXISTS supplier_product_temp;
    DROP TABLE IF EXISTS orders_temp;
    DROP TABLE IF EXISTS sold_products_temp;
END $$;
