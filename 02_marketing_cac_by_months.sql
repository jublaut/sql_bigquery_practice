WITH ads_in_order AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY ad_id, date ORDER BY timestamp DESC) AS rn
  FROM `marketingads-496622.marketingads.marketingads`
),
ads_latest AS (
  SELECT * FROM ads_in_order WHERE rn = 1
)
SELECT
  source,
  DATE_TRUNC(date, MONTH) AS month,
  ROUND(SUM(spend), 2) AS spend,
  SUM(registrations) AS registrations,
  ROUND(SUM(spend) / SUM(registrations), 2) AS cac
FROM ads_latest
GROUP BY source, month
ORDER BY source, month
