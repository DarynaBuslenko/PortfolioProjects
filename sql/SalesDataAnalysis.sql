-- I am going to analyse sales_data_sample and get some insights from customers' past purchase behavior.
-- I go from analyzing sales revenue to creating a customer segmentation analysis using the RFM technique.
-- I am using the following skills here:
   --- Importing a file into PostgreSQL;
   --- Aggregate Functions;
   --- Window Functions;
   --- Sub Query;
   --- Common Table Expressions (CTEs);
   --- STRING_AGG Function.

-- I am starting with inspecting data: 

SELECT * 
FROM sales_data_sample;

-- Checking unique values: 

SELECT distinct "STATUS" FROM sales_data_sample;
SELECT distinct "YEAR_ID" FROM sales_data_sample;
SELECT distinct "PRODUCTLINE" FROM sales_data_sample;
SELECT distinct "COUNTRY" FROM sales_data_sample;
SELECT distinct "DEALSIZE" FROM sales_data_sample;
SELECT distinct "TERRITORY" FROM sales_data_sample;

-- Analysis 
-- I am starting by grouping sales by product line:
 
SELECT "PRODUCTLINE" , SUM ("SALES") as revenue
FROM sales_data_sample
GROUP BY "PRODUCTLINE"
ORDER BY 2 DESC; -- Classic Cars bring the biggest revenue, $3919643.

-- Here I am grouping sales by year:

SELECT "YEAR_ID" , SUM ("SALES") as revenue
FROM sales_data_sample
GROUP BY  "YEAR_ID"
ORDER BY 2 DESC;

-- 2004 is the year they made the most sales.
-- Aslo we can observe that revenue in 2005 year was relatively small. We can assume why and 
-- check how many months of data we have. We can see that there are only 5 months from 2005 year:

SELECT distinct "MONTH_ID"
FROM sales_data_sample
WHERE "YEAR_ID" = 2005;

-- Here we can see sales by products and years:

SELECT "PRODUCTLINE", "YEAR_ID" , SUM ("SALES") as revenue
FROM sales_data_sample
GROUP BY "PRODUCTLINE", "YEAR_ID"
ORDER BY 1 DESC;

-- Let's check sales by grouping them by deal size:

SELECT "DEALSIZE" , SUM ("SALES") as revenue
FROM sales_data_sample
GROUP BY  "DEALSIZE"
ORDER BY 2 DESC;

-- Apparently, the medium-sized deals are the ones that generate the most revenue.
-- So probably they should start focusing on that or if they want to make sure that small-sized deals   
-- are also generating more revenue they can put in some type of marketing or advertisement or whatever in there
-- and see how it goes.

-- What was the best month for sales in a specific year? How much was earned that month?

SELECT "MONTH_ID", SUM ("SALES") as revenue, count ("ORDERNUMBER") as frequency
FROM sales_data_sample
WHERE "YEAR_ID" = 2003 -- change year to see the result
GROUP BY "MONTH_ID"
ORDER BY 2 DESC;

-- November is an exceptional month for the company.
-- Total revenue is more than twice what the second month is which is October.

-- Now we can see that the best product is classic cars and the best month is November.

-- November seems to be the best month. What product did they sell in November?

SELECT "PRODUCTLINE", SUM ("SALES") as revenue, count ("ORDERNUMBER") as frequency
FROM sales_data_sample
WHERE "YEAR_ID" = 2003 and "MONTH_ID" = 11
GROUP BY "PRODUCTLINE"
ORDER BY 2 DESC;

-- Who is the best customer (RFM analysis will help to answer).
-- I am creating a temp table (lrfm) here. It prevents from calling CTE all the time: 

DROP TABLE IF EXISTS lrfm
;
WITH rfm as
(
	SELECT "CUSTOMERNAME", SUM ("SALES") as MonetaryValue, Round(AVG ("SALES"),2) as AvgMonetaryValue,
	       count ("ORDERNUMBER") as Frequency, max ("ORDERDATE") as LastOrderDate,
	       (select max ("ORDERDATE") from sales_data_sample) as MaxOrderDate,
	       (select max ("ORDERDATE") from sales_data_sample)-max ("ORDERDATE") as Recency
	FROM  sales_data_sample
	GROUP BY "CUSTOMERNAME"
),
rfm_calc as 
(
	SELECT r.*,
	       NTILE(4) OVER (ORDER BY Recency DESC) as rfm_recency,
	       NTILE(4) OVER (ORDER BY Frequency) as rfm_frequency,
	       NTILE(4) OVER (ORDER BY MonetaryValue) as rfm_monetary
	FROM rfm r      
	ORDER BY 4 DESC
)
SELECT c.*, rfm_recency + rfm_frequency + rfm_monetary as rfm_cell,
	CONCAT (cast(rfm_recency as varchar), ',' , cast(rfm_frequency as varchar), ',', cast(rfm_monetary as varchar)) as 
	rfm_cell_string
into lrfm	-- SELECT INTO creates a new table and fills it with data computed by a query.
	FROM rfm_calc c;

-- Whenever the customer made most recent purchase give the recency value a higher number. 4 means the high value.
-- Whenever there is 1 - it's the low value.

SELECT * 
FROM lrfm;

-- Now I am going to do a segmentation: 

SELECT "CUSTOMERNAME", rfm_recency, rfm_frequency, rfm_monetary, 
	CASE 
		WHEN rfm_cell_string in ('1,1,1', '1,1,2', '1,2,1', '1,2,2', '1,2,3', '1,3,2', '2,1,1', '2,1,2', '1,1,4',
		                         '1,4,1', '2,2,1') THEN 'lost customers'
		WHEN rfm_cell_string in ('1,3,3', '1,3,4', '1,4,3', '2,4,4', '2,3,4','1,4,4') THEN 'slipping away, cannot lose'   
		WHEN rfm_cell_string in ('3,1,1', '4,1,1', '3,3,1', '4,1,2', '4,2,1') THEN 'new customers'  
		WHEN rfm_cell_string in ('2,2,2', '2,2,3', '2,3,3', '3,2,2', '2,3,2', '4,2,3') THEN 'potential churners' 
		WHEN rfm_cell_string in ('3,2,3', '3,3,3', '3,2,1', '4,2,2', '3,3,2', '3,4,4', '3,4,3', '3,3,4','4,3,2') 
		                         THEN 'active'
		WHEN rfm_cell_string in ('4,3,3', '4,3,4', '4,4,3', '4,4,4' ) THEN 'loyal'                          
		END rfm_segment                                        
FROM lrfm;

-- What products are most often sold together?

-- First I want to check that one order can contain a few different products:

SELECT * 
FROM sales_data_sample 
WHERE "ORDERNUMBER" = 10411;

-- Here we can see which product are sold together. There are different orders with the same stuff:

SELECT "ORDERNUMBER", STRING_AGG("PRODUCTCODE", ', ') as product_code
FROM sales_data_sample p
WHERE "ORDERNUMBER" IN (
    SELECT "ORDERNUMBER"
    FROM (
        SELECT "ORDERNUMBER", COUNT(*) AS rn
        FROM sales_data_sample
        WHERE "STATUS" = 'Shipped'
        GROUP BY "ORDERNUMBER"
    ) m
    WHERE rn = 2 -- here we can put 3 and see which 3 products are purchased together 
)
GROUP BY "ORDERNUMBER";

-- What city has the highest number of sales in a specific country:

SELECT "CITY", SUM ("SALES") as revenue
FROM sales_data_sample
WHERE "COUNTRY" = 'UK'
GROUP BY 1
ORDER BY 2 desc;

-- What is the best product in the United States?

SELECT "COUNTRY", "YEAR_ID", "PRODUCTLINE", SUM ("SALES") as revenue
FROM sales_data_sample
WHERE "COUNTRY" = 'USA'
GROUP BY "COUNTRY", "YEAR_ID", "PRODUCTLINE"
ORDER BY 4 desc;
