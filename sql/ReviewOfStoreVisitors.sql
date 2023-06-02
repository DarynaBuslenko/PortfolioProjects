--Showing the number of visitors by continents

SELECT DISTINCT geoNetwork.continent, count (DISTINCT visitId) AS visitsNumber
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
GROUP BY 1
ORDER BY 2 DESC;

--Showing the number of visitors by countries

SELECT geoNetwork.country, count (DISTINCT visitId) AS visitsNumber
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--What browsers use our visitors

SELECT device.browser, count (visitId) as visitId
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
group by device.browser
order by visitId desc
Limit 10;

--Number of visitors by month

SELECT
FORMAT_DATE('%Y-%m', date) AS yyyymm, 
SUM (visitId) AS visitId
FROM ( 
SELECT  PARSE_DATE('%Y%m%d', DATE) as date, count (visitId) as visitId
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170731'
GROUP BY 1
ORDER BY 1
)
GROUP BY 1
ORDER BY 1;

--Exploring traffic sources list

SELECT distinct trafficSource.source, count (DISTINCT visitId)
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170801'
GROUP BY 1
ORDER BY 2 DESC;

--Organic traffic by continent

SELECT
geoNetwork.continent, COUNT (visitId) AS visitId 
FROM (  
  SELECT  *
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  WHERE _TABLE_SUFFIX BETWEEN '20160801' AND '20170731')
WHERE trafficSource.source IN ('(direct)','google', 'yahoo')
GROUP BY 1
ORDER BY 2 DESC;