WITH ads_in_order AS (
  SELECT
    ad_id,
    source,
    date,
    spend,
    impressions,
    clicks,
    installs,
    registrations,
    ROW_NUMBER() OVER (PARTITION BY ad_id, date ORDER BY timestamp DESC) AS rn
  FROM `marketingads-496622.marketingads.marketingads`
),

ads_latest AS (
  SELECT
    ad_id,
    source,
    date,
    spend,
    impressions,
    clicks,
    installs,
    registrations
  FROM ads_in_order
  WHERE rn = 1
),

daily_metrics AS (
  SELECT
    source,
    date,
    SUM(spend) AS spend,
    SUM(impressions) AS impressions,
    SUM(clicks) AS clicks,
    SUM(installs) AS installs,
    SUM(registrations) AS registrations
  FROM ads_latest
  GROUP BY source,date
),

ltv_ref AS (
  SELECT 'tiktok' AS source, 8.50 AS ltv UNION ALL
  SELECT 'meta' AS source, 6.20 AS ltv UNION ALL
  SELECT 'google' AS source, 12.40 AS ltv
)

SELECT
  dm.source,
  ROUND(SUM(dm.spend), 2) AS total_spend,
  ROUND(SUM(dm.spend) / SUM(dm.impressions) * 1000, 2) AS cpm,
  ROUND(SUM(dm.clicks) / SUM(dm.impressions) *100, 2) AS ctr,
  ROUND(SUM(dm.installs) / SUM(dm.clicks) * 100, 2) AS cr_click_install,
  ROUND(SUM(dm.registrations) / SUM(dm.installs) * 100, 2) AS cr_install_reg,
  ROUND(SUM(dm.spend) / SUM(dm.registrations), 2) AS cac,
  l.ltv AS ltv,
  ROUND(l.ltv / (SUM(spend) / SUM(registrations)), 2) AS ltv_to_cac
FROM daily_metrics AS dm
LEFT JOIN ltv_ref AS l
  ON l.source = dm.source
GROUP BY source, l.ltv
ORDER BY cac
