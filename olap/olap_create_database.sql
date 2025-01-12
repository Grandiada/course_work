-- Создание таблиц измерений

-- Измерение времени (DimDate)
CREATE TABLE DimDate (
    DateKey DATE PRIMARY KEY,
    Year INTEGER NOT NULL,
    Quarter INTEGER NOT NULL,
    Month INTEGER NOT NULL,
    Day INTEGER NOT NULL,
    Week INTEGER NOT NULL,
    IsWeekend BOOLEAN NOT NULL
);

-- Измерение пользователей (DimUser) с поддержкой SCD Type 2
CREATE TABLE DimUser (
    UserID UUID NOT NULL,               
    UserKey UUID PRIMARY KEY,           
    Username VARCHAR NOT NULL,
    Email VARCHAR,
    Phone VARCHAR,
    Age INTEGER,
    Weight INTEGER,
    Height INTEGER,
    StartDate DATE NOT NULL,            
    EndDate DATE,                       
    IsCurrent BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_user UNIQUE (UserID, IsCurrent)
);

-- Измерение продуктов (DimProduct)
CREATE TABLE DimProduct (
    ProductID UUID PRIMARY KEY,   
    ProductName VARCHAR NOT NULL,
    TranslationKeyName VARCHAR
);

-- Измерение поставщиков (DimSupplier)
CREATE TABLE DimSupplier (
    SupplierID UUID PRIMARY KEY,
    CompanyName VARCHAR NOT NULL,
    Address VARCHAR,
    NIP VARCHAR,
    ContactPhone VARCHAR
);

-- Измерение симптомов (DimSymptom)
CREATE TABLE DimSymptom (
    SymptomID UUID PRIMARY KEY,
    SymptomName VARCHAR NOT NULL,
    SymptomDescription VARCHAR
);

-- Таблица фактов продаж продуктов (FactSales)
CREATE TABLE FactSales (
    SalesID UUID PRIMARY KEY,
    DateKey DATE NOT NULL,
    UserKey UUID NOT NULL,
    ProductID UUID NOT NULL,
    SupplierID UUID,
    Quantity INTEGER NOT NULL,
    SellingPrice NUMERIC(10, 2),
    CostPrice NUMERIC(10, 2),
    TotalRevenue NUMERIC(10, 2) GENERATED ALWAYS AS (Quantity * SellingPrice) STORED,
    TotalCost NUMERIC(10, 2) GENERATED ALWAYS AS (Quantity * CostPrice) STORED,
    Profit NUMERIC(10, 2) GENERATED ALWAYS AS ((Quantity * SellingPrice) - (Quantity * CostPrice)) STORED,
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (UserKey) REFERENCES DimUser(UserKey),
    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
    FOREIGN KEY (SupplierID) REFERENCES DimSupplier(SupplierID)
);


-- Таблица фактов симптомов пользователей (FactUserSymptoms)
CREATE TABLE FactUserSymptoms (
    SymptomFactID UUID PRIMARY KEY,
    DateKey DATE NOT NULL,
    UserKey UUID NOT NULL,
    SymptomID UUID NOT NULL,
    ProductID UUID,
    SymptomOccurrenceCount INTEGER NOT NULL,
    FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    FOREIGN KEY (UserKey) REFERENCES DimUser(UserKey),
    FOREIGN KEY (SymptomID) REFERENCES DimSymptom(SymptomID),
    FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID)
);

-- Генерация данных для таблицы DimDate (с 2020 по 2030 год)
INSERT INTO DimDate (DateKey, Year, Quarter, Month, Day, Week, IsWeekend)
SELECT
    date::DATE AS DateKey,
    EXTRACT(YEAR FROM date) AS Year,
    EXTRACT(QUARTER FROM date) AS Quarter,
    EXTRACT(MONTH FROM date) AS Month,
    EXTRACT(DAY FROM date) AS Day,
    EXTRACT(WEEK FROM date) AS Week,
    (EXTRACT(ISODOW FROM date) IN (6, 7))::BOOLEAN AS IsWeekend
FROM GENERATE_SERIES('2020-01-01'::DATE, '2030-12-31'::DATE, INTERVAL '1 day') AS date;
