--EXPLORACION DE DATOS

SELECT * FROM mercadolibre_funnel
LIMIT 5

SELECT * FROM mercadolibre_retention 
LIMIT 5

SELECT
DISTINCT event_name
FROM mercadolibre_funnel
ORDER BY event_name

--CONTEO DE USUARIOS POR EVENTO
WITH first_visit AS(
SELECT DISTINCT user_id
FROM mercadolibre_funnel
WHERE event_name='first_visit' AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
select_item AS (
SELECT DISTINCT user_id
FROM mercadolibre_funnel
WHERE event_name IN('select_item','select_promotion') AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_to_cart AS (
SELECT DISTINCT user_id
FROM mercadolibre_funnel
WHERE event_name ='add_to_cart' AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
begin_checkout AS (
SELECT DISTINCT user_id
FROM mercadolibre_funnel
WHERE event_name ='begin_checkout' AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_shipping_info AS(
SELECT DISTINCT user_id
FROM mercadolibre_funnel
WHERE event_name ='add_shipping_info' AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_payment_info AS(
SELECT DISTINCT user_id
FROM mercadolibre_funnel
WHERE event_name ='add_payment_info' AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
purchase AS (
SELECT DISTINCT user_id
FROM mercadolibre_funnel
WHERE event_name ='purchase' AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
)
SELECT
COUNT(fv.user_id) AS usuarios_first_visit,
COUNT(sl.user_id) AS usuarios_select_item,
COUNT(atc.user_id) AS usuarios_add_to_cart,
COUNT(bc.user_id) AS usuarios_begin_checkout,
COUNT(asi.user_id) AS usuarios_add_shipping_info,
COUNT(api.user_id) AS usuarios_add_payment_info,
COUNT(p.user_id) AS usuarios_purchase

    
FROM first_visit fv
LEFT JOIN select_item sl
ON fv.user_id=sl.user_id
LEFT JOIN add_to_cart atc
ON fv.user_id=atc.user_id
LEFT JOIN begin_checkout bc
ON fv.user_id=bc.user_id
LEFT JOIN add_shipping_info asi
ON fv.user_id=asi.user_id
LEFT JOIN add_payment_info api
ON fv.user_id=api.user_id
LEFT JOIN purchase p
ON fv.user_id=p.user_id

--CALCULO CONVERSIONES POR ETAPAS
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
), 
funnel_counts AS(
SELECT
  COUNT(fv.user_id) AS usuarios_first_visit,
  COUNT(si.user_id) AS usuarios_select_item,
  COUNT(a.user_id) AS usuarios_add_to_cart,
  COUNT(bc.user_id) AS usuarios_begin_checkout,
  COUNT(asi.user_id) AS usuarios_add_shipping_info,
  COUNT(api.user_id) AS usuarios_add_payment_info,
  COUNT(p.user_id) AS usuarios_purchase
FROM first_visit fv
LEFT JOIN select_item si        ON fv.user_id = si.user_id
LEFT JOIN add_to_cart a         ON fv.user_id = a.user_id
LEFT JOIN begin_checkout bc     ON fv.user_id = bc.user_id
LEFT JOIN add_shipping_info asi ON fv.user_id = asi.user_id
LEFT JOIN add_payment_info api  ON fv.user_id = api.user_id
LEFT JOIN purchase p            ON fv.user_id = p.user_id
)

SELECT
ROUND((usuarios_select_item*100.0)/NULLIF(usuarios_first_visit,0),2) AS conversion_select_item,
ROUND((usuarios_add_to_cart*100.0)/NULLIF(usuarios_first_visit,0),2) AS conversion_add_to_cart,
ROUND((usuarios_begin_checkout*100.0)/NULLIF(usuarios_first_visit,0),2)
AS conversion_begin_checkout,
ROUND((usuarios_add_shipping_info*100.0)/NULLIF(usuarios_first_visit,0),2) AS conversion_add_shipping_info,
ROUND((usuarios_add_payment_info*100.0)/NULLIF(usuarios_first_visit,0),2) AS conversion_add_payment_info,
ROUND((usuarios_purchase*100.0)/NULLIF(usuarios_first_visit,0),2) AS conversion_purchase
FROM funnel_counts

  
--SEGMENTAR POR PAIS
WITH first_visits AS (
  SELECT DISTINCT user_id,country
  FROM mercadolibre_funnel
  WHERE event_name = 'first_visit'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
select_item AS (
  SELECT DISTINCT user_id,country
  FROM mercadolibre_funnel
  WHERE event_name IN ('select_item', 'select_promotion')
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_to_cart AS (
  SELECT DISTINCT user_id,country
  FROM mercadolibre_funnel
  WHERE event_name = 'add_to_cart'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
begin_checkout AS (
  SELECT DISTINCT user_id,country
  FROM mercadolibre_funnel
  WHERE event_name = 'begin_checkout'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_shipping_info AS (
  SELECT DISTINCT user_id,country
  FROM mercadolibre_funnel
  WHERE event_name = 'add_shipping_info'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
add_payment_info AS (
  SELECT DISTINCT user_id,country
  FROM mercadolibre_funnel
  WHERE event_name = 'add_payment_info'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
purchase AS (
  SELECT DISTINCT user_id,country
  FROM mercadolibre_funnel
  WHERE event_name = 'purchase'
    AND event_date BETWEEN '2025-01-01' AND '2025-08-31'
),
funnel_counts AS(
SELECT
fv.country AS country,
  COUNT(fv.user_id) AS usuarios_first_visit,
  COUNT(si.user_id) AS usuarios_select_item,
  COUNT(a.user_id) AS usuarios_add_to_cart,
  COUNT(bc.user_id) AS usuarios_begin_checkout,
  COUNT(asi.user_id) AS usuarios_add_shipping_info,
  COUNT(api.user_id) AS usuarios_add_payment_info,
  COUNT(p.user_id) AS usuarios_purchase
FROM first_visits fv
LEFT JOIN select_item si        ON fv.user_id = si.user_id and fv.country=si.country
LEFT JOIN add_to_cart a         ON fv.user_id = a.user_id and fv.country=a.country
LEFT JOIN begin_checkout bc     ON fv.user_id = bc.user_id and fv.country=bc.country
LEFT JOIN add_shipping_info asi ON fv.user_id = asi.user_id and fv.country=asi.country
LEFT JOIN add_payment_info api  ON fv.user_id = api.user_id and fv.country=api.country
LEFT JOIN purchase p            ON fv.user_id = p.user_id and fv.country=p.country
GROUP BY fv.country
)

SELECT 
country,
usuarios_select_item*100.0/NULLIF(usuarios_first_visit,0) AS conversion_select_item,
usuarios_add_to_cart*100.0/NULLIF(usuarios_first_visit,0) AS conversion_add_to_cart, usuarios_begin_checkout*100.0/NULLIF(usuarios_first_visit,0) AS conversion_begin_checkout,
usuarios_add_shipping_info*100.0/NULLIF(usuarios_first_visit,0) AS conversion_add_shipping_info,
usuarios_add_payment_info*100.0/NULLIF(usuarios_first_visit,0) AS conversion_add_payment_info,
usuarios_purchase*100.0/NULLIF(usuarios_first_visit,0) AS conversion_purchase
from funnel_counts
order by conversion_purchase DESC

--CONTEO DE USUARIOS ACUMULADOS POR PAIS PARA 7,14,21 Y 28 DIAS
SELECT
  country,
count(distinct case when activity_date between '2025-01-01' and '2025-08-31' and day_after_signup>=7 and active =1 then user_id end) as users_d7,
count(distinct case when activity_date between '2025-01-01' and '2025-08-31' and day_after_signup>=14 and active =1 then user_id end) as users_d14,
count(distinct case when activity_date between '2025-01-01' and '2025-08-31' and day_after_signup>=21 and active =1 then user_id end) as users_d21,
count(distinct case when activity_date between '2025-01-01' and '2025-08-31' and day_after_signup>=28 and active =1 then user_id end) as users_d28
FROM mercadolibre_retention
GROUP BY country;
--CONVERTIR A PORCENTAJE EL CONTEO
SELECT
  country,
  ROUND((COUNT(DISTINCT CASE WHEN day_after_signup >= 7  AND active = 1 THEN user_id END)*100.0)/NULLIF(COUNT(DISTINCT user_id),0),1)  AS retention_d7_pct,
  ROUND((COUNT(DISTINCT CASE WHEN day_after_signup >= 14 AND active = 1 THEN user_id END)*100.0)/NULLIF(COUNT(DISTINCT user_id),0),1)  AS retention_d14_pct,
  ROUND((COUNT(DISTINCT CASE WHEN day_after_signup >= 21 AND active = 1 THEN user_id END)*100.0)/NULLIF(COUNT(DISTINCT user_id),0),1)  AS retention_d21_pc,
  ROUND((COUNT(DISTINCT CASE WHEN day_after_signup >= 28 AND active = 1 THEN user_id END)*100.0)/NULLIF(COUNT(DISTINCT user_id),0),1)  AS retention_d28_pct
FROM mercadolibre_retention
WHERE activity_date BETWEEN '2025-01-01' AND '2025-08-31'
GROUP BY country
ORDER BY country;

--DEFINICION DE COHORTE
SELECT 
user_id,
MIN(signup_date) AS signup_date,
TO_CHAR(DATE_TRUNC('month',MIN(signup_date)),'YYYY-MM') AS cohort
FROM mercadolibre_retention
GROUP BY user_id
LIMIT 5

--CALCULO DE RETENCION POR COHORTE Y PERIODO
WITH cohort AS (
SELECT
user_id,
TO_CHAR(DATE_TRUNC('month', MIN(signup_date)), 'YYYY-MM') AS cohort
FROM mercadolibre_retention
GROUP BY user_id
),
activity AS (

SELECT
mlr.user_id,
c.cohort,
mlr.day_after_signup,
mlr.active
FROM mercadolibre_retention AS mlr
LEFT JOIN cohort AS c
ON c.user_id=mlr.user_id
where activity_date between '2025-01-01' AND '2025-08-31'
)

SELECT
cohort,
ROUND(100.0*count(distinct case when active = 1 AND day_after_signup >=7 then user_id end )/NULLIF(COUNT(DISTINCT user_id),0),1) AS retention_d7_pct,
ROUND(100.0*count(distinct case when active = 1 AND day_after_signup >=14 then user_id end )/NULLIF(COUNT(DISTINCT user_id),0),1) AS retention_d14_pct,
ROUND(100.0*count(distinct case when active = 1 AND day_after_signup >=21 then user_id end )/NULLIF(COUNT(DISTINCT user_id),0),1) AS retention_d21_pct,
ROUND(100.0*count(distinct case when active = 1 AND day_after_signup >=28 then user_id end )/NULLIF(COUNT(DISTINCT user_id),0),1) AS retention_d28_pct
FROM activity
GROUP BY cohort
ORDER BY cohort;




