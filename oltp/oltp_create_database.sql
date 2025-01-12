-- Создание таблицы users
CREATE TABLE users (
  id UUID PRIMARY KEY,
  username VARCHAR NOT NULL UNIQUE,
  password_hash VARCHAR NOT NULL,
  email VARCHAR NOT NULL UNIQUE,
  phone VARCHAR UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  age INTEGER,
  weight INTEGER,
  height INTEGER
);

-- Создание таблицы symptoms
CREATE TABLE symptoms (
  id UUID PRIMARY KEY,
  translationKeyName VARCHAR NOT NULL UNIQUE,
  translationKeyDescriptopn VARCHAR
);

-- Создание таблицы users_symptoms
CREATE TABLE users_symptoms (
  id UUID PRIMARY KEY,
  symptom_id UUID NOT NULL,
  user_id UUID NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (symptom_id) REFERENCES symptoms(id) ON DELETE CASCADE
);

-- Создание таблицы products
CREATE TABLE products (
  id UUID PRIMARY KEY,
  name VARCHAR NOT NULL,
  translationKeyName VARCHAR
);

-- Создание таблицы products_symptoms
CREATE TABLE products_symptoms (
  id UUID PRIMARY KEY,
  symptom_id UUID NOT NULL,
  product_id UUID NOT NULL,
  FOREIGN KEY (symptom_id) REFERENCES symptoms(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Создание таблицы orders
CREATE TABLE orders (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  orderCreatedAt DATE NOT NULL DEFAULT CURRENT_DATE,
  orderPaidAt DATE,
  supplierRequestedAt DATE,
  supplierSentAt DATE,
  deliveredAt DATE,
  refundedAt DATE,
  completedAt DATE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);


-- Создание таблицы suppliers
CREATE TABLE suppliers (
  id UUID PRIMARY KEY,
  companyName VARCHAR NOT NULL,
  address VARCHAR NOT NULL,
  nip VARCHAR NOT NULL,
  contact_phone VARCHAR NOT NULL
);

-- Создание таблицы supplier_product
CREATE TABLE supplier_product (
  id UUID PRIMARY KEY,
  supplier_id UUID NOT NULL,
  product_id UUID NOT NULL,
  supplier_price NUMERIC(10, 2) NOT NULL,
  selling_price NUMERIC(10, 2) NOT NULL,
  quantity INTEGER NOT NULL,
  FOREIGN KEY (supplier_id) REFERENCES suppliers(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Создание таблицы sold_products
CREATE TABLE sold_products (
  id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  supplier_price NUMERIC(10, 2) NOT NULL,
  selling_price NUMERIC(10, 2) NOT NULL,
  supply_id UUID NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (supply_id) REFERENCES supplier_product(id) ON DELETE CASCADE
);

