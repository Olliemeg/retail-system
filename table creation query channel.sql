



/*
CREATE TABLE customer (
  customer_id INTEGER PRIMARY KEY,
  age INTEGER,
  education VARCHAR(25),
  marital_status VARCHAR(25),
  income INTEGER,
  kid_home INTEGER,
  teen_home INTEGER,
  reg_date DATE,
  last_visit INTEGER,
  country VARCHAR(25),
  num_deals INTEGER,
  num_web_buy INTEGER,
  num_walkin_pur INTEGER,
  num_web_visit INTEGER,
  complaints INTEGER
);

CREATE TABLE sales(
sale_id SERIAL PRIMARY KEY,
customer_id INTEGER,
amt_liq INTEGER,
amt_veg INTEGER,
amt_meat INTEGER,
amt_fish INTEGER,
amt_choc INTEGER,
amt_comm INTEGER,
num_deals INTEGER
);

CREATE TABLE traffic( 
traffic_id SERIAL PRIMARY KEY,
customer_id INTEGER,
num_web_buy INTEGER,
num_walkin_pur INTEGER,
num_web_visit INTEGER
);

traffic( traffic_id , customer_id, num_web_buy, num_walkin_pur, num_web_visit)

--NOT RIGHT
CREATE TABLE ads(
ad_id SERIAL PRIMARY KEY,
customer_id INTEGER,
ad_response VARCHAR	(5),
country VARCHAR(25),
lead_conv INTEGER,
bulkmail_ad INTEGER,
twitter_ad INTEGER,
instagram_ad INTEGER,
facebook_ad INTEGER,
brochure_ad INTEGER
);

--CORRECT
CREATE TABLE ads (
    ad_id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    response BOOLEAN,
    country TEXT,
    count_success INTEGER,
    bulkmail_ad BOOLEAN,
    twitter_ad BOOLEAN,
    instagram_ad BOOLEAN,
    facebook_ad BOOLEAN,
    brochure_ad BOOLEAN
);

\copy ads(customer_id, ad_type, ad_response, country, lead_conv, bulkmail_ad, twitter_ad, instagram_ad, facebook_ad, brochure_ad) FROM 'C:\Users\Olive\OneDrive\Documents\DATA COURSE\Assignments\Assignment 1 - 2market\Working data\CVS' DELIMITER ',' CSV HEADER;
*/

/*
###########################################################
###########################################################
#######################QUERIES#############################
###########################################################
###########################################################
*/

--Best performing ads
SELECT
  'Bulkmail' AS ad_type,
  COUNT(*) AS successful_leads
FROM ads
WHERE response = TRUE AND bulkmail_ad = TRUE

UNION ALL
SELECT
  'Twitter' AS ad_type,
  COUNT(*) AS successful_leads
FROM ads
WHERE response = TRUE AND twitter_ad = TRUE

UNION ALL
SELECT
  'Instagram' AS ad_type,
  COUNT(*) AS successful_leads
FROM ads
WHERE response = TRUE AND instagram_ad = TRUE

UNION ALL
SELECT
  'Facebook' AS ad_type,
  COUNT(*) AS successful_leads
FROM ads
WHERE response = TRUE AND facebook_ad = TRUE

UNION ALL
SELECT
  'Brochure' AS ad_type,
  COUNT(*) AS successful_leads
FROM ads
WHERE response = TRUE AND brochure_ad = TRUE
ORDER BY successful_leads DESC
LIMIT 1;



--spend per country
SELECT c.country, SUM(s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.country

--avg age per country
SELECT c.country, ROUND(AVG(c.age), 2) as avg_age
FROM customer c
GROUP BY c.country;



--total number of purchases w+wi by country
SELECT c.country, SUM(t.num_web_buy + t.num_walkin_pur) as total_purchases
FROM customer c
JOIN traffic t ON c.customer_id = t.customer_id
GROUP BY c.country;


--total spend per product per country
SELECT c.country, 
       'Liquid' as product, SUM(s.amt_liq) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.country
UNION
SELECT c.country, 
       'Vegetable' as product, SUM(s.amt_veg) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.country
UNION
SELECT c.country, 
       'Meat' as product, SUM(s.amt_meat) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.country
UNION
SELECT c.country, 
       'Fish' as product, SUM(s.amt_fish) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.country
UNION
SELECT c.country, 
       'Chocolate' as product, SUM(s.amt_choc) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.country
UNION
SELECT c.country, 
       'Common' as product, SUM(s.amt_comm) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.country;


--most popular products in each country
WITH ProductTotals AS (
    SELECT c.country,
           'Liquid' as product, SUM(s.amt_liq) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.country
    UNION
    SELECT c.country,
           'Vegetable' as product, SUM(s.amt_veg) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.country
    UNION
    SELECT c.country,
           'Meat' as product, SUM(s.amt_meat) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.country
    UNION
    SELECT c.country,
           'Fish' as product, SUM(s.amt_fish) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.country
    UNION
    SELECT c.country,
           'Chocolate' as product, SUM(s.amt_choc) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.country
    UNION
    SELECT c.country,
           'Common' as product, SUM(s.amt_comm) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.country
)
SELECT country, product, spend
FROM (
    SELECT country, product, spend,
           ROW_NUMBER() OVER (PARTITION BY country ORDER BY spend DESC) as rn
    FROM ProductTotals
) ranked
WHERE rn = 1;



-- Average Spend per Customer by Marital Status
SELECT c.marital_status, ROUND(AVG(s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm), 2) as avg_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.marital_status;


--products by age and income
SELECT
  CASE 
    WHEN c.age < 30 THEN 'Under 30'
    WHEN c.age BETWEEN 30 AND 44 THEN '30-44'
    WHEN c.age BETWEEN 45 AND 59 THEN '45-59'
    ELSE '60+'
  END AS age_group,

  CASE 
    WHEN c.income < 40000 THEN 'Low Income'
    WHEN c.income BETWEEN 40000 AND 70000 THEN 'Mid Income'
    ELSE 'High Income'
  END AS income_group,

  SUM(s.amt_meat) AS total_meat,
  SUM(s.amt_veg) AS total_veg,
  SUM(s.amt_choc) AS total_choc,
  SUM(s.amt_liq) AS total_liq,
  SUM(s.amt_fish) AS total_fish,
  SUM(s.amt_comm) AS total_comm

FROM sales s
JOIN customer c ON s.customer_id = c.customer_id
GROUP BY age_group, income_group
ORDER BY age_group, income_group;


---------------------------------------------------------
--#########################################################
#--#########################################################
----------------------POPULAR PRODUCTS-----------------

--AGE

WITH product_sales AS (
  SELECT CASE 
      WHEN c.age < 30 THEN 'Under 30'
      WHEN c.age BETWEEN 30 AND 44 THEN '30–44'
      WHEN c.age BETWEEN 45 AND 59 THEN '45–59'
      ELSE '60+' 
    END AS age_group,
    'Meat' AS product, s.amt_meat AS amount
  FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT
    CASE 
      WHEN c.age < 30 THEN 'Under 30'
      WHEN c.age BETWEEN 30 AND 44 THEN '30–44'
      WHEN c.age BETWEEN 45 AND 59 THEN '45–59'
      ELSE '60+' 
    END, 'Veg', s.amt_veg
  FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL
  SELECT CASE WHEN c.age < 30 THEN 'Under 30' WHEN c.age BETWEEN 30 AND 44 THEN '30–44' WHEN c.age BETWEEN 45 AND 59 THEN '45–59' ELSE '60+' END, 'Choc', s.amt_choc FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL
  SELECT CASE WHEN c.age < 30 THEN 'Under 30' WHEN c.age BETWEEN 30 AND 44 THEN '30–44' WHEN c.age BETWEEN 45 AND 59 THEN '45–59' ELSE '60+' END, 'Fish', s.amt_fish FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL
  SELECT CASE WHEN c.age < 30 THEN 'Under 30' WHEN c.age BETWEEN 30 AND 44 THEN '30–44' WHEN c.age BETWEEN 45 AND 59 THEN '45–59' ELSE '60+' END, 'Liq', s.amt_liq FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL
  SELECT CASE WHEN c.age < 30 THEN 'Under 30' WHEN c.age BETWEEN 30 AND 44 THEN '30–44' WHEN c.age BETWEEN 45 AND 59 THEN '45–59' ELSE '60+' END, 'Comm', s.amt_comm FROM sales s JOIN customer c ON s.customer_id = c.customer_id
),
ranked AS (
  SELECT age_group, product, SUM(amount) AS total_sales,
         RANK() OVER (PARTITION BY age_group ORDER BY SUM(amount) DESC) AS rnk
  FROM product_sales
  GROUP BY age_group, product
)
SELECT age_group, product AS top_product, total_sales
FROM ranked
WHERE rnk = 1
ORDER BY age_group;




--most poular products based on marital statuss
WITH ProductTotals AS (
    SELECT c.marital_status,
           'Liquour' as product, SUM(s.amt_liq) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.marital_status
    UNION
    SELECT c.marital_status,
           'Vegetable' as product, SUM(s.amt_veg) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.marital_status
    UNION
    -- Repeat for other products (amt_meat, amt_fish, amt_choc, amt_comm)
    SELECT c.marital_status,
           'Meat' as product, SUM(s.amt_meat) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.marital_status
    UNION
    SELECT c.marital_status,
           'Fish' as product, SUM(s.amt_fish) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.marital_status
    UNION
    SELECT c.marital_status,
           'Chocolate' as product, SUM(s.amt_choc) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.marital_status
    UNION
    SELECT c.marital_status,
           'Common' as product, SUM(s.amt_comm) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY c.marital_status
)
SELECT marital_status, product, spend
FROM (
    SELECT marital_status, product, spend,
           ROW_NUMBER() OVER (PARTITION BY marital_status ORDER BY spend DESC) as rn
    FROM ProductTotals
) ranked
WHERE rn = 1;

--Income

WITH product_sales AS (
  SELECT
    CASE 
      WHEN c.income < 30000 THEN 'Low (<30k)'
      WHEN c.income BETWEEN 30000 AND 70000 THEN 'Mid (30k–70k)'
      ELSE 'High (>70k)'
    END AS income_band,
    'Meat' AS product, s.amt_meat AS amount
  FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL
  SELECT CASE WHEN c.income < 30000 THEN 'Low (<30k)' WHEN c.income BETWEEN 30000 AND 70000 THEN 'Mid (30k–70k)' ELSE 'High (>70k)' END, 'Veg', s.amt_veg FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL
  SELECT CASE WHEN c.income < 30000 THEN 'Low (<30k)' WHEN c.income BETWEEN 30000 AND 70000 THEN 'Mid (30k–70k)' ELSE 'High (>70k)' END, 'Choc', s.amt_choc FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL
  SELECT CASE WHEN c.income < 30000 THEN 'Low (<30k)' WHEN c.income BETWEEN 30000 AND 70000 THEN 'Mid (30k–70k)' ELSE 'High (>70k)' END, 'Fish', s.amt_fish FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL
  SELECT CASE WHEN c.income < 30000 THEN 'Low (<30k)' WHEN c.income BETWEEN 30000 AND 70000 THEN 'Mid (30k–70k)' ELSE 'High (>70k)' END, 'Liq', s.amt_liq FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL
  SELECT CASE WHEN c.income < 30000 THEN 'Low (<30k)' WHEN c.income BETWEEN 30000 AND 70000 THEN 'Mid (30k–70k)' ELSE 'High (>70k)' END, 'Comm', s.amt_comm FROM sales s JOIN customer c ON s.customer_id = c.customer_id
),
ranked AS (
  SELECT income_band, product, SUM(amount) AS total_sales,
         RANK() OVER (PARTITION BY income_band ORDER BY SUM(amount) DESC) AS rnk
  FROM product_sales
  GROUP BY income_band, product
)
SELECT income_band, product AS top_product, total_sales
FROM ranked
WHERE rnk = 1
ORDER BY income_band;

--Education

WITH product_sales AS (
  SELECT c.education, 'Meat' AS product, s.amt_meat AS amount FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.education, 'Veg', s.amt_veg FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.education, 'Choc', s.amt_choc FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.education, 'Fish', s.amt_fish FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.education, 'Liq', s.amt_liq FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.education, 'Comm', s.amt_comm FROM sales s JOIN customer c ON s.customer_id = c.customer_id
),
ranked AS (
  SELECT education, product, SUM(amount) AS total_sales,
         RANK() OVER (PARTITION BY education ORDER BY SUM(amount) DESC) AS rnk
  FROM product_sales
  GROUP BY education, product
)
SELECT education, product AS top_product, total_sales
FROM ranked
WHERE rnk = 1
ORDER BY education;


-- country 
WITH product_sales AS (
  SELECT c.country, 'Meat' AS product, s.amt_meat AS amount FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.country, 'Veg', s.amt_veg FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.country, 'Choc', s.amt_choc FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.country, 'Fish', s.amt_fish FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.country, 'Liq', s.amt_liq FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.country, 'Comm', s.amt_comm FROM sales s JOIN customer c ON s.customer_id = c.customer_id
),
ranked AS (
  SELECT country, product, SUM(amount) AS total_sales,
         RANK() OVER (PARTITION BY country ORDER BY SUM(amount) DESC) AS rnk
  FROM product_sales
  GROUP BY country, product
)
SELECT country, product AS top_product, total_sales
FROM ranked
WHERE rnk = 1
ORDER BY country;

--kids present
WITH product_sales AS (
  SELECT c.kid_home, c.teen_home, 'Meat' AS product, s.amt_meat AS amount FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.kid_home, c.teen_home, 'Veg', s.amt_veg FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.kid_home, c.teen_home, 'Choc', s.amt_choc FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.kid_home, c.teen_home, 'Fish', s.amt_fish FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.kid_home, c.teen_home, 'Liq', s.amt_liq FROM sales s JOIN customer c ON s.customer_id = c.customer_id
  UNION ALL SELECT c.kid_home, c.teen_home, 'Comm', s.amt_comm FROM sales s JOIN customer c ON s.customer_id = c.customer_id
),
ranked AS (
  SELECT kid_home, teen_home, product, SUM(amount) AS total_sales,
         RANK() OVER (PARTITION BY kid_home, teen_home ORDER BY SUM(amount) DESC) AS rnk
  FROM product_sales
  GROUP BY kid_home, teen_home, product
)
SELECT
  kid_home,
  teen_home,
  product AS top_product,
  total_sales
FROM ranked
WHERE rnk = 1
ORDER BY kid_home, teen_home;






-- Percentage of Customers with Children or Teens by Country
SELECT c.country,
      ROUND((SUM(CASE WHEN c.kid_home > 0 OR c.teen_home > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) as pct_with_children
FROM customer c
GROUP BY c.country;




--most popular product with child or teen at home

WITH ProductTotals AS (
    SELECT 
        CASE 
            WHEN c.kid_home > 0 OR c.teen_home > 0 THEN 'Yes'
            ELSE 'No'
        END as has_children_teens,
        'Liquid' as product, SUM(s.amt_liq) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY has_children_teens
    UNION
    SELECT 
        CASE 
            WHEN c.kid_home > 0 OR c.teen_home > 0 THEN 'Yes'
            ELSE 'No'
        END as has_children_teens,
        'Vegetable' as product, SUM(s.amt_veg) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY has_children_teens
    UNION
    -- Repeat for other products
    SELECT 
        CASE 
            WHEN c.kid_home > 0 OR c.teen_home > 0 THEN 'Yes'
            ELSE 'No'
        END as has_children_teens,
        'Meat' as product, SUM(s.amt_meat) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY has_children_teens
    UNION
    SELECT 
        CASE 
            WHEN c.kid_home > 0 OR c.teen_home > 0 THEN 'Yes'
            ELSE 'No'
        END as has_children_teens,
        'Fish' as product, SUM(s.amt_fish) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY has_children_teens
    UNION
    SELECT 
        CASE 
            WHEN c.kid_home > 0 OR c.teen_home > 0 THEN 'Yes'
            ELSE 'No'
        END as has_children_teens,
        'Chocolate' as product, SUM(s.amt_choc) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY has_children_teens
    UNION
    SELECT 
        CASE 
            WHEN c.kid_home > 0 OR c.teen_home > 0 THEN 'Yes'
            ELSE 'No'
        END as has_children_teens,
        'Common' as product, SUM(s.amt_comm) as spend
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    GROUP BY has_children_teens
)
SELECT has_children_teens, product, spend
FROM (
    SELECT has_children_teens, product, spend,
           ROW_NUMBER() OVER (PARTITION BY has_children_teens ORDER BY spend DESC) as rn
    FROM ProductTotals
) ranked
WHERE rn = 1;


--ad spend per country where interaction is true
SELECT 'Twitter' as channel,
       c.country,
       SUM(CASE WHEN a.twitter_ad = TRUE THEN s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm ELSE 0 END) as total_spend
FROM ads a
JOIN sales s ON a.customer_id = s.customer_id
JOIN customer c ON a.customer_id = c.customer_id
WHERE a.response = TRUE
GROUP BY c.country
UNION
SELECT 'Instagram' as channel,
       c.country,
       SUM(CASE WHEN a.instagram_ad = TRUE THEN s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm ELSE 0 END) as total_spend
FROM ads a
JOIN sales s ON a.customer_id = s.customer_id
JOIN customer c ON a.customer_id = c.customer_id
WHERE a.response = TRUE
GROUP BY c.country
UNION
SELECT 'Facebook' as channel,
       c.country,
       SUM(CASE WHEN a.facebook_ad = TRUE THEN s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm ELSE 0 END) as total_spend
FROM ads a
JOIN sales s ON a.customer_id = s.customer_id
JOIN customer c ON a.customer_id = c.customer_id
WHERE a.response = TRUE
GROUP BY c.country
UNION
SELECT 'Brochure' as channel,
       c.country,
       SUM(CASE WHEN a.brochure_ad = TRUE THEN s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm ELSE 0 END) as total_spend
FROM ads a
JOIN sales s ON a.customer_id = s.customer_id
JOIN customer c ON a.customer_id = c.customer_id
WHERE a.response = TRUE
GROUP BY c.country
UNION
SELECT 'Bulk Mail' as channel,
       c.country,
       SUM(CASE WHEN a.bulkmail_ad = TRUE THEN s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm ELSE 0 END) as total_spend
FROM ads a
JOIN sales s ON a.customer_id = s.customer_id
JOIN customer c ON a.customer_id = c.customer_id
WHERE a.response = TRUE
GROUP BY c.country;


--effectiveness of ads > product sales

SELECT 'Twitter' as channel,
       SUM(CASE WHEN a.twitter_ad = TRUE THEN s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm ELSE 0 END) as total_spend
FROM ads a
JOIN sales s ON a.customer_id = s.customer_id
WHERE a.response = TRUE
UNION
SELECT 'Instagram' as channel,
       SUM(CASE WHEN a.instagram_ad = TRUE THEN s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm ELSE 0 END) as total_spend
FROM ads a
JOIN sales s ON a.customer_id = s.customer_id
WHERE a.response = TRUE
UNION
SELECT 'Facebook' as channel,
       SUM(CASE WHEN a.facebook_ad = TRUE THEN s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm ELSE 0 END) as total_spend
FROM ads a
JOIN sales s ON a.customer_id = s.customer_id
WHERE a.response = TRUE
UNION
SELECT 'Brochure' as channel,
       SUM(CASE WHEN a.brochure_ad = TRUE THEN s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm ELSE 0 END) as total_spend
FROM ads a
JOIN sales s ON a.customer_id = s.customer_id
WHERE a.response = TRUE
UNION
SELECT 'Bulk Mail' as channel,
       SUM(CASE WHEN a.bulkmail_ad = TRUE THEN s.amt_liq + s.amt_veg + s.amt_meat + s.amt_fish + s.amt_choc + s.amt_comm ELSE 0 END) as total_spend
FROM ads a
JOIN sales s ON a.customer_id = s.customer_id
WHERE a.response = TRUE;



--number of deals per customer by ad response
SELECT a.response, ROUND(AVG(c.num_deals), 2) as avg_deals
FROM customer c
JOIN ads a ON c.customer_id = a.customer_id
GROUP BY a.response;



--Total Web Visits per Income Bracket
SELECT 
    CASE 
        WHEN c.income < 50000 THEN 'Low'
        WHEN c.income BETWEEN 50000 AND 100000 THEN 'Medium'
        ELSE 'High'
    END as income_bracket,
    SUM(t.num_web_visit) as total_web_visits
FROM customer c
JOIN traffic t ON c.customer_id = t.customer_id
GROUP BY income_bracket;


--education level by product
WITH CustomerProductEdu AS (
    SELECT c.education, 'Liquid' as product, COUNT(DISTINCT c.customer_id) as customer_count
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE s.amt_liq > 0
    GROUP BY c.education
    UNION
    SELECT c.education, 'Vegetable' as product, COUNT(DISTINCT c.customer_id) as customer_count
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE s.amt_veg > 0
    GROUP BY c.education
    UNION
    SELECT c.education, 'Meat', COUNT(DISTINCT c.customer_id) as customer_count
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE s.amt_meat > 0
    GROUP BY c.education
    UNION
    SELECT c.education, 'Fish', COUNT(DISTINCT c.customer_id) as customer_count
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE s.amt_fish > 0
    GROUP BY c.education
    UNION
    SELECT c.education, 'Chocolate', COUNT(DISTINCT c.customer_id) as customer_count
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE s.amt_choc > 0
    GROUP BY c.education
    UNION
    SELECT c.education, 'Common', COUNT(DISTINCT c.customer_id) as customer_count
    FROM customer c
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE s.amt_comm > 0
    GROUP BY c.education
)
SELECT education, product, customer_count
FROM (
    SELECT education, product, customer_count,
           ROW_NUMBER() OVER (PARTITION BY product ORDER BY customer_count DESC) as rn
    FROM CustomerProductEdu
) ranked
WHERE rn = 1;


--conversion rate(purchases/web visits) by country
SELECT c.country,
       ROUND(SUM(t.num_web_buy) * 100.0 / NULLIF(SUM(t.num_web_visit), 0), 2) as conversion_rate
FROM customer c
JOIN traffic t ON c.customer_id = t.customer_id
GROUP BY c.country;


--complaints by age group
SELECT 
    CASE 
        WHEN c.age < 30 THEN 'Under 30'
        WHEN c.age BETWEEN 30 AND 50 THEN '30-50'
        ELSE 'Over 50'
    END as age_group,
    SUM(c.complaints) as total_complaints
FROM customer c
GROUP BY age_group;


--total spend by product marital status
SELECT 
    c.marital_status,
    'Liquid' as product,
    SUM(s.amt_liq) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.marital_status
UNION
SELECT 
    c.marital_status,
    'Vegetable' as product,
    SUM(s.amt_veg) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.marital_status
UNION
SELECT 
    c.marital_status,
    'Meat' as product,
    SUM(s.amt_meat) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.marital_status
UNION
SELECT 
    c.marital_status,
    'Fish' as product,
    SUM(s.amt_fish) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.marital_status
UNION
SELECT 
    c.marital_status,
    'Chocolate' as product,
    SUM(s.amt_choc) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.marital_status
UNION
SELECT 
    c.marital_status,
    'Common' as product,
    SUM(s.amt_comm) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.marital_status;


--spend my marital status
SELECT 
    c.marital_status,
    SUM(COALESCE(s.amt_liq, 0) + COALESCE(s.amt_veg, 0) + COALESCE(s.amt_meat, 0) + 
         COALESCE(s.amt_fish, 0) + COALESCE(s.amt_choc, 0) + COALESCE(s.amt_comm, 0)) as total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.marital_status;


--spending from the ad where response is true
WITH SpendPerChannel AS (
    SELECT 
        c.country,
        'Liquid' as product,
        SUM(CASE WHEN a.twitter_ad = TRUE THEN s.amt_liq ELSE 0 END) as twitter_spend,
        SUM(CASE WHEN a.instagram_ad = TRUE THEN s.amt_liq ELSE 0 END) as instagram_spend,
        SUM(CASE WHEN a.facebook_ad = TRUE THEN s.amt_liq ELSE 0 END) as facebook_spend,
        SUM(CASE WHEN a.brochure_ad = TRUE THEN s.amt_liq ELSE 0 END) as brochure_spend,
        SUM(CASE WHEN a.bulkmail_ad = TRUE THEN s.amt_liq ELSE 0 END) as bulkmail_spend
    FROM customer c
    JOIN ads a ON c.customer_id = a.customer_id
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE a.response = TRUE
    GROUP BY c.country
    UNION
    SELECT 
        c.country,
        'Vegetable' as product,
        SUM(CASE WHEN a.twitter_ad = TRUE THEN s.amt_veg ELSE 0 END),
        SUM(CASE WHEN a.instagram_ad = TRUE THEN s.amt_veg ELSE 0 END),
        SUM(CASE WHEN a.facebook_ad = TRUE THEN s.amt_veg ELSE 0 END),
        SUM(CASE WHEN a.brochure_ad = TRUE THEN s.amt_veg ELSE 0 END),
        SUM(CASE WHEN a.bulkmail_ad = TRUE THEN s.amt_veg ELSE 0 END)
    FROM customer c
    JOIN ads a ON c.customer_id = a.customer_id
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE a.response = TRUE
    GROUP BY c.country
    UNION
    SELECT 
        c.country,
        'Meat' as product,
        SUM(CASE WHEN a.twitter_ad = TRUE THEN s.amt_meat ELSE 0 END),
        SUM(CASE WHEN a.instagram_ad = TRUE THEN s.amt_meat ELSE 0 END),
        SUM(CASE WHEN a.facebook_ad = TRUE THEN s.amt_meat ELSE 0 END),
        SUM(CASE WHEN a.brochure_ad = TRUE THEN s.amt_meat ELSE 0 END),
        SUM(CASE WHEN a.bulkmail_ad = TRUE THEN s.amt_meat ELSE 0 END)
    FROM customer c
    JOIN ads a ON c.customer_id = a.customer_id
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE a.response = TRUE
    GROUP BY c.country
    UNION
    SELECT 
        c.country,
        'Fish' as product,
        SUM(CASE WHEN a.twitter_ad = TRUE THEN s.amt_fish ELSE 0 END),
        SUM(CASE WHEN a.instagram_ad = TRUE THEN s.amt_fish ELSE 0 END),
        SUM(CASE WHEN a.facebook_ad = TRUE THEN s.amt_fish ELSE 0 END),
        SUM(CASE WHEN a.brochure_ad = TRUE THEN s.amt_fish ELSE 0 END),
        SUM(CASE WHEN a.bulkmail_ad = TRUE THEN s.amt_fish ELSE 0 END)
    FROM customer c
    JOIN ads a ON c.customer_id = a.customer_id
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE a.response = TRUE
    GROUP BY c.country
    UNION
    SELECT 
        c.country,
        'Chocolate' as product,
        SUM(CASE WHEN a.twitter_ad = TRUE THEN s.amt_choc ELSE 0 END),
        SUM(CASE WHEN a.instagram_ad = TRUE THEN s.amt_choc ELSE 0 END),
        SUM(CASE WHEN a.facebook_ad = TRUE THEN s.amt_choc ELSE 0 END),
        SUM(CASE WHEN a.brochure_ad = TRUE THEN s.amt_choc ELSE 0 END),
        SUM(CASE WHEN a.bulkmail_ad = TRUE THEN s.amt_choc ELSE 0 END)
    FROM customer c
    JOIN ads a ON c.customer_id = a.customer_id
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE a.response = TRUE
    GROUP BY c.country
    UNION
    SELECT 
        c.country,
        'Commodity' as product,
        SUM(CASE WHEN a.twitter_ad = TRUE THEN s.amt_comm ELSE 0 END),
        SUM(CASE WHEN a.instagram_ad = TRUE THEN s.amt_comm ELSE 0 END),
        SUM(CASE WHEN a.facebook_ad = TRUE THEN s.amt_comm ELSE 0 END),
        SUM(CASE WHEN a.brochure_ad = TRUE THEN s.amt_comm ELSE 0 END),
        SUM(CASE WHEN a.bulkmail_ad = TRUE THEN s.amt_comm ELSE 0 END)
    FROM customer c
    JOIN ads a ON c.customer_id = a.customer_id
    JOIN sales s ON c.customer_id = s.customer_id
    WHERE a.response = TRUE
    GROUP BY c.country
)
SELECT 
    country,
    product,
    twitter_spend,
    instagram_spend,
    facebook_spend,
    brochure_spend,
    bulkmail_spend,
    (twitter_spend + instagram_spend + facebook_spend + brochure_spend + bulkmail_spend) as total_ad_spend
FROM SpendPerChannel
ORDER BY country, product;

-- Web vs Walk-In Purchase Behavior by Income Bracket
SELECT 
  CASE 
    WHEN income < 30000 THEN 'Low Income'
    WHEN income BETWEEN 30000 AND 60000 THEN 'Middle Income'
    WHEN income > 60000 THEN 'High Income'
  END AS income_bracket,
  AVG(c.num_web_buy) AS avg_web_purchases,
  AVG(c.num_walkin_pur) AS avg_walkin_purchases
FROM customer c
GROUP BY income_bracket
ORDER BY income_bracket;

--average sepend by age
SELECT 
  CASE 
    WHEN age < 25 THEN 'Under 25'
    WHEN age BETWEEN 25 AND 34 THEN '25–34'
    WHEN age BETWEEN 35 AND 44 THEN '35–44'
    WHEN age BETWEEN 45 AND 54 THEN '45–54'
    WHEN age >= 55 THEN '55+'
  END AS age_group,
  ROUND(AVG(s.amt_meat + s.amt_veg + s.amt_fish + s.amt_choc + s.amt_liq + s.amt_comm), 2) AS avg_total_spend
FROM customer c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY age_group
ORDER BY age_group;


--demographic by the customer id
SELECT
  customer_id,
  CONCAT_WS(
      ' | ',
      CASE
        WHEN age < 25              THEN 'Under 25'
        WHEN age BETWEEN 25 AND 34 THEN '25–34'
        WHEN age BETWEEN 35 AND 44 THEN '35–44'
        WHEN age BETWEEN 45 AND 54 THEN '45–54'
        ELSE                           '55 +'
      END,
      education,
      marital_status,
      CASE
        WHEN income < 30_000              THEN 'Low Income'
        WHEN income BETWEEN 30_000 AND 59_999 THEN 'Lower-Mid Income'
        WHEN income BETWEEN 60_000 AND 99_999 THEN 'Upper-Mid Income'
        ELSE                                   'High Income'
      END
  ) AS demographic_profile
FROM customer;

-- count of customer by demographic type
SELECT
  CONCAT_WS(
      ' | ',
      CASE
        WHEN age < 25              THEN 'Under 25'
        WHEN age BETWEEN 25 AND 34 THEN '25–34'
        WHEN age BETWEEN 35 AND 44 THEN '35–44'
        WHEN age BETWEEN 45 AND 54 THEN '45–54'
        ELSE                           '55+'
      END,
      education,
      marital_status,
      CASE
        WHEN income < 30000              THEN 'Low Income'
        WHEN income BETWEEN 30000 AND 59999 THEN 'Lower-Mid Income'
        WHEN income BETWEEN 60000 AND 99999 THEN 'Upper-Mid Income'
        ELSE                                   'High Income'
      END
  ) AS demographic_profile,
  COUNT(*) AS customer_count
FROM customer
GROUP BY demographic_profile
ORDER BY customer_count DESC;

-- DEMOGRAPHICS

WITH customer_base AS (
  SELECT
    age,
    country,
    CONCAT(FLOOR(income / 10000) * 10, 'k–', FLOOR(income / 10000) * 10 + 9, 'k') AS income_bracket,
    marital_status,
    CASE 
      WHEN kid_home > 0 OR teen_home > 0 THEN 'Y'
      ELSE 'N'
    END AS kids_present,
    education
  FROM customer
),

most_common AS (
  SELECT
    (SELECT age FROM customer_base GROUP BY age ORDER BY COUNT(*) DESC LIMIT 1) AS age,
    (SELECT country FROM customer_base GROUP BY country ORDER BY COUNT(*) DESC LIMIT 1) AS country,
    (SELECT income_bracket FROM customer_base GROUP BY income_bracket ORDER BY COUNT(*) DESC LIMIT 1) AS income_bracket,
    (SELECT marital_status FROM customer_base GROUP BY marital_status ORDER BY COUNT(*) DESC LIMIT 1) AS marital,
    (SELECT kids_present FROM customer_base GROUP BY kids_present ORDER BY COUNT(*) DESC LIMIT 1) AS kids_present,
    (SELECT education FROM customer_base GROUP BY education ORDER BY COUNT(*) DESC LIMIT 1) AS education
)

SELECT * FROM most_common;





	
SELECT * FROM customer







