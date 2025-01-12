-- Установка postgres_fdw расширения
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Подключение к OLTP базе данных
DROP SERVER IF EXISTS oltp_server CASCADE;
CREATE SERVER oltp_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'localhost', dbname 'course_work1', port '5432');

-- Аутентификация пользователя
CREATE USER MAPPING FOR CURRENT_USER
SERVER oltp_server
OPTIONS (user 'postgres', password 'root');

-- Создание внешних таблиц для чтения из OLTP базы
IMPORT FOREIGN SCHEMA public
  LIMIT TO (users, symptoms, users_symptoms, products, products_symptoms, orders, suppliers, supplier_product, sold_products)
  FROM SERVER oltp_server
  INTO public;

-- Обновление таблицы DimUser с поддержкой SCD Type 2
INSERT INTO DimUser (UserID, UserKey, Username, Email, Phone, Age, Weight, Height, StartDate, EndDate, IsCurrent)
SELECT
  u.id AS UserID,
  gen_random_uuid() AS UserKey,
  u.username,
  u.email,
  u.phone,
  u.age,
  u.weight,
  u.height,
  CURRENT_DATE AS StartDate,
  NULL AS EndDate,
  TRUE AS IsCurrent
FROM users u
LEFT JOIN DimUser du
  ON u.id = du.UserID AND du.IsCurrent = TRUE
WHERE
  (du.UserID IS NULL)
  OR (du.Username IS DISTINCT FROM u.username OR du.Email IS DISTINCT FROM u.email OR du.Phone IS DISTINCT FROM u.phone OR du.Age IS DISTINCT FROM u.age OR du.Weight IS DISTINCT FROM u.weight OR du.Height IS DISTINCT FROM u.height);

UPDATE DimUser
SET EndDate = CURRENT_DATE, IsCurrent = FALSE
FROM users u
WHERE DimUser.UserID = u.id AND DimUser.IsCurrent = TRUE
AND (DimUser.Username IS DISTINCT FROM u.username OR DimUser.Email IS DISTINCT FROM u.email OR DimUser.Phone IS DISTINCT FROM u.phone OR DimUser.Age IS DISTINCT FROM u.age OR DimUser.Weight IS DISTINCT FROM u.weight OR DimUser.Height IS DISTINCT FROM u.height);

-- Обновление таблицы DimProduct
INSERT INTO DimProduct (ProductID, ProductName, TranslationKeyName)
SELECT
  p.id AS ProductID,
  p.name AS ProductName,
  p.translationKeyName
FROM products p
LEFT JOIN DimProduct dp ON p.id = dp.ProductID
WHERE dp.ProductID IS NULL;

-- Обновление таблицы DimSymptom
INSERT INTO DimSymptom (SymptomID, SymptomName, SymptomDescription)
SELECT
  s.id AS SymptomID,
  s.translationKeyName AS SymptomName,
  s.translationKeyDescriptopn AS SymptomDescription
FROM symptoms s
LEFT JOIN DimSymptom ds ON s.id = ds.SymptomID
WHERE ds.SymptomID IS NULL;

-- Обновление таблицы DimDate (если даты приходят из OLTP событий)
INSERT INTO DimDate (DateKey, Year, Quarter, Month, Day, Week, IsWeekend)
SELECT
  date::DATE AS DateKey,
  EXTRACT(YEAR FROM date) AS Year,
  EXTRACT(QUARTER FROM date) AS Quarter,
  EXTRACT(MONTH FROM date) AS Month,
  EXTRACT(DAY FROM date) AS Day,
  EXTRACT(WEEK FROM date) AS Week,
  CASE WHEN EXTRACT(DOW FROM date) IN (0, 6) THEN TRUE ELSE FALSE END AS IsWeekend
FROM generate_series('2023-01-01'::DATE, '2030-12-31'::DATE, '1 day'::INTERVAL) date
LEFT JOIN DimDate dd ON dd.DateKey = date::DATE
WHERE dd.DateKey IS NULL;

-- Обновление таблицы DimSupplier
INSERT INTO DimSupplier (SupplierID, CompanyName, Address, Nip, ContactPhone)
SELECT
  s.id AS SupplierID,
  s.companyName AS CompanyName,
  s.address AS Address,
  s.nip AS Nip,
  s.contact_phone AS ContactPhone
FROM suppliers s
LEFT JOIN DimSupplier ds ON s.id = ds.SupplierID
WHERE ds.SupplierID IS NULL;

-- Обновление таблицы FactSales
INSERT INTO FactSales (SalesID, DateKey, UserKey, ProductID, SupplierID, Quantity, SellingPrice, CostPrice)
SELECT
  gen_random_uuid() AS SalesID,
  o.orderCreatedAt::DATE AS DateKey,
  du.UserKey AS UserKey,
  sup_prod.product_id AS ProductID,
  sup_prod.supplier_id AS SupplierID,
  1 AS Quantity,  -- может быть изменено на количество из OLTP, если предусмотрено
  sp.selling_price AS SellingPrice,
  sp.supplier_price AS CostPrice
FROM orders o
JOIN sold_products sp ON sp.order_id = o.id
JOIN supplier_product sup_prod on sup_prod.id = sp.supply_id
JOIN DimUser du ON du.UserID = o.user_id AND du.IsCurrent = TRUE
LEFT JOIN FactSales fs ON fs.DateKey = o.orderCreatedAt::DATE AND fs.UserKey = du.UserKey AND fs.ProductID = sp.supply_id
WHERE fs.SalesID IS NULL;

-- Обновление таблицы FactUserSymptoms
INSERT INTO FactUserSymptoms (SymptomFactID, DateKey, UserKey, SymptomID, ProductID, SymptomOccurrenceCount)
SELECT
  gen_random_uuid() AS SymptomFactID,
  CURRENT_DATE AS DateKey,
  du.UserKey AS UserKey,
  us.symptom_id AS SymptomID,
  ps.product_id AS ProductID,
  1 AS SymptomOccurrenceCount
FROM users_symptoms us
JOIN DimUser du ON du.UserID = us.user_id AND du.IsCurrent = TRUE
LEFT JOIN products_symptoms ps ON ps.symptom_id = us.symptom_id
LEFT JOIN FactUserSymptoms fus ON fus.DateKey = CURRENT_DATE AND fus.UserKey = du.UserKey AND fus.SymptomID = us.symptom_id
WHERE fus.SymptomFactID IS NULL;

-- Завершение всех транзакций ETL
COMMIT;
