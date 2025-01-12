-- OLTP Query 1: How much revenue a specific user has generated (OLTP database)
SELECT
  u.username,
  COALESCE(SUM(sp.selling_price), 0) AS TotalRevenue
FROM orders o
JOIN sold_products sp ON sp.order_id = o.id
JOIN users u ON o.user_id = u.id
WHERE u.id = '749db35a-d975-4369-8b94-fee0018e6e9e'  -- user 4
GROUP BY u.username;

-- OLTP Query 2: Symptoms without associated products (OLTP database)
SELECT
  s.translationKeyName AS SymptomName,
  s.translationKeyDescriptopn AS SymptomDescription
FROM symptoms s
LEFT JOIN products_symptoms ps ON s.id = ps.symptom_id
WHERE ps.product_id IS NULL;


