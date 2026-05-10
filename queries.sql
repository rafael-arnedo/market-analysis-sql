-- ==============================================
-- DATA EXPLORATION
-- ==============================================

-- Preview funnel events data
SELECT * FROM mercadolibre_funnel LIMIT 5;

-- Preview retention data
SELECT * FROM mercadolibre_retention LIMIT 5;

-- Identify available events in the funnel
SELECT DISTINCT event_name
FROM mercadolibre_funnel
ORDER BY event_name;


-- ==============================================
-- USER DISTRIBUTION BY FUNNEL STAGE
-- ==============================================

-- Define each step of the funnel based on user actions
WITH first_visit AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'first_visit'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
select_item AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name IN ('select_item', 'select_promotion')
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_to_cart AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'add_to_cart'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
begin_checkout AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'begin_checkout'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_shipping_info AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'add_shipping_info'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_payment_info AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'add_payment_info'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
purchase AS (
    SELECT DISTINCT user_id
    FROM mercadolibre_funnel
    WHERE event_name = 'purchase'
      AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
)

-- Aggregate users at each stage
SELECT
    COUNT(fv.user_id) AS users_first_visit,
    COUNT(si.user_id) AS users_select_item,
    COUNT(atc.user_id) AS users_add_to_cart,
    COUNT(bc.user_id) AS users_begin_checkout,
    COUNT(asi.user_id) AS users_add_shipping_info,
    COUNT(api.user_id) AS users_add_payment_info,
    COUNT(p.user_id) AS users_purchase
FROM first_visit fv
LEFT JOIN select_item si ON fv.user_id = si.user_id
LEFT JOIN add_to_cart atc ON fv.user_id = atc.user_id
LEFT JOIN begin_checkout bc ON fv.user_id = bc.user_id
LEFT JOIN add_shipping_info asi ON fv.user_id = asi.user_id
LEFT JOIN add_payment_info api ON fv.user_id = api.user_id
LEFT JOIN purchase p ON fv.user_id = p.user_id;


-- ==============================================
-- FUNNEL CONVERSION RATES
-- ==============================================

-- Calculate conversion percentages across funnel stages
WITH funnel_counts AS (
    SELECT
        COUNT(fv.user_id) AS usuarios_first_visit,
        COUNT(si.user_id) AS usuarios_select_item,
        COUNT(a.user_id) AS usuarios_add_to_cart,
        COUNT(bc.user_id) AS usuarios_begin_checkout,
        COUNT(asi.user_id) AS usuarios_add_shipping_info,
        COUNT(api.user_id) AS usuarios_add_payment_info,
        COUNT(p.user_id) AS usuarios_purchase
    FROM first_visit fv
    LEFT JOIN select_item si ON fv.user_id = si.user_id
    LEFT JOIN add_to_cart a ON fv.user_id = a.user_id
    LEFT JOIN begin_checkout bc ON fv.user_id = bc.user_id
    LEFT JOIN add_shipping_info asi ON fv.user_id = asi.user_id
    LEFT JOIN add_payment_info api ON fv.user_id = api.user_id
    LEFT JOIN purchase p ON fv.user_id = p.user_id
)

SELECT
    ROUND((usuarios_select_item * 100.0) / NULLIF(usuarios_first_visit, 0), 2) AS conversion_select_item,
    ROUND((usuarios_add_to_cart * 100.0) / NULLIF(usuarios_first_visit, 0), 2) AS conversion_add_to_cart,
    ROUND((usuarios_begin_checkout * 100.0) / NULLIF(usuarios_first_visit, 0), 2) AS conversion_begin_checkout,
    ROUND((usuarios_add_shipping_info * 100.0) / NULLIF(usuarios_first_visit, 0), 2) AS conversion_add_shipping_info,
    ROUND((usuarios_add_payment_info * 100.0) / NULLIF(usuarios_first_visit, 0), 2) AS conversion_add_payment_info,
    ROUND((usuarios_purchase * 100.0) / NULLIF(usuarios_first_visit, 0), 2) AS conversion_purchase
FROM funnel_counts;


-- ==============================================
-- FUNNEL ANALYSIS BY COUNTRY
-- ==============================================

-- Evaluate conversion rates across different countries
SELECT 
    country,
    usuarios_select_item * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_select_item,
    usuarios_add_to_cart * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_add_to_cart,
    usuarios_begin_checkout * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_begin_checkout,
    usuarios_add_shipping_info * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_add_shipping_info,
    usuarios_add_payment_info * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_add_payment_info,
    usuarios_purchase * 100.0 / NULLIF(usuarios_first_visit, 0) AS conversion_purchase
FROM funnel_counts
ORDER BY conversion_purchase DESC;


-- ==============================================
-- RETENTION ANALYSIS BY COUNTRY
-- ==============================================

-- Calculate retention metrics at different time intervals
SELECT
    country,
    ROUND((COUNT(DISTINCT CASE WHEN day_after_signup >= 7 AND active = 1 THEN user_id END) * 100.0) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d7_pct,
    ROUND((COUNT(DISTINCT CASE WHEN day_after_signup >= 14 AND active = 1 THEN user_id END) * 100.0) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d14_pct,
    ROUND((COUNT(DISTINCT CASE WHEN day_after_signup >= 21 AND active = 1 THEN user_id END) * 100.0) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d21_pct,
    ROUND((COUNT(DISTINCT CASE WHEN day_after_signup >= 28 AND active = 1 THEN user_id END) * 100.0) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d28_pct
FROM mercadolibre_retention
WHERE activity_date BETWEEN '2025-01-01' AND '2025-08-31'
GROUP BY country
ORDER BY country;


-- ==============================================
-- COHORT ANALYSIS
-- ==============================================

-- Assign users to cohorts based on signup month
WITH cohort AS (
    SELECT
        user_id,
        TO_CHAR(DATE_TRUNC('month', MIN(signup_date)), 'YYYY-MM') AS cohort
    FROM mercadolibre_retention
    GROUP BY user_id
),

-- Combine user activity with cohort assignment
activity AS (
    SELECT
        mlr.user_id,
        c.cohort,
        mlr.day_after_signup,
        mlr.active
    FROM mercadolibre_retention mlr
    LEFT JOIN cohort c ON c.user_id = mlr.user_id
    WHERE activity_date BETWEEN '2025-01-01' AND '2025-08-31'
)

-- Calculate retention by cohort over time
SELECT
    cohort,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN active = 1 AND day_after_signup >= 7 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d7_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN active = 1 AND day_after_signup >= 14 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d14_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN active = 1 AND day_after_signup >= 21 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d21_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN active = 1 AND day_after_signup >= 28 THEN user_id END) / NULLIF(COUNT(DISTINCT user_id), 0), 1) AS retention_d28_pct
FROM activity
GROUP BY cohort
ORDER BY cohort;
