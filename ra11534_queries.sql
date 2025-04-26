-- 1. How much would a business have paid before CREATE vs. after?

SELECT 
  business_id,
  name,
  industry,
  region,
  year,
  ROUND(net_income * corp_tax_before, 2) AS tax_payable_before_create,
  ROUND(net_income * corp_tax_after, 2) AS tax_payable_after_create,
  ROUND((net_income * corp_tax_before) - (net_income * corp_tax_after), 2) AS tax_savings
FROM 
  create_law_combined_dataset
WHERE 
  year >= 2021
ORDER BY 
  business_id, year;


-- 2. Which regions have the most businesses receiving incentives?

SELECT 
  region,
  COUNT(DISTINCT business_id) AS total_businesses,
  COUNT(DISTINCT CASE WHEN incentive_type IS NOT NULL THEN business_id END) AS businesses_with_incentives,
  ROUND(
    (COUNT(DISTINCT CASE WHEN incentive_type IS NOT NULL THEN business_id END) / 
     COUNT(DISTINCT business_id)) * 100, 2
  ) AS percentage_with_incentives
FROM 
  create_law_combined_dataset
GROUP BY 
  region
ORDER BY 
  businesses_with_incentives DESC;


-- 3. What is the ROI of tax incentives across sectors?

SELECT 
  industry,
  SUM(estimated_savings) AS total_tax_savings,
  SUM(net_income) AS total_net_income,
  SUM(net_income) / SUM(estimated_savings) AS roi_income_per_peso_saved
FROM 
  create_law_combined_dataset
WHERE 
  year >= 2021
  AND estimated_savings > 0
GROUP BY 
  industry
ORDER BY 
  roi_income_per_peso_saved DESC;


-- 4. How many MSMEs were able to grow into large businesses after CREATE?

SELECT 
  COUNT(DISTINCT business_id) AS msmes_grown_to_large
FROM (
  SELECT 
    business_id
  FROM 
    create_law_combined_dataset
  GROUP BY 
    business_id
  HAVING 
    MIN(size) = 'MSME' 
    AND MAX(gross_revenue) >= 100000000
) AS growing_businesses;


-- 5. Which industries gained the most savings after the CREATE Act?

SELECT 
  industry,
  SUM(estimated_savings) AS total_savings
FROM 
  create_law_combined_dataset
WHERE 
  year >= 2021
GROUP BY 
  industry
ORDER BY 
  total_savings DESC;