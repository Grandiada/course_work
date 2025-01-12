
-- OLAP Query 1: How much revenue a specific user has generated (OLAP database)
SELECT
  u.username,
  COALESCE(SUM(fs.SellingPrice * fs.Quantity), 0) AS TotalRevenue
FROM FactSales fs
JOIN DimUser u ON fs.UserKey = u.UserKey
WHERE u.UserID = '749db35a-d975-4369-8b94-fee0018e6e9e'  -- user 8
GROUP BY u.username;

-- OLAP Query 2: Symptoms without associated products (OLAP database)
SELECT DISTINCT
  ds.SymptomName,
  ds.SymptomDescription
FROM DimSymptom ds
LEFT JOIN FactUserSymptoms fus ON ds.SymptomID = fus.SymptomID
LEFT JOIN DimProduct dp ON fus.ProductID = dp.ProductID
WHERE fus.ProductID IS NULL;
