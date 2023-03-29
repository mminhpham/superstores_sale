/*
 Superstores Sales Exploration
 
 Skills used: JOINs, CTE's, CONCATs, Time-series Analysis, Correlation Analysis 
 
 */
 
 -- Original Dataset
 SELECT *
 FROM project.superstores_sales
 ORDER BY invoice_date ASC;
 
 -- What was the top-selling product type in each state in 2010?
SELECT state, product_type, total_sales
FROM (
    SELECT state, product_type, SUM(sales) AS total_sales,
        RANK() OVER (PARTITION BY state ORDER BY SUM(sales) DESC) AS sales_rank
    FROM project.superstores_sales
    WHERE YEAR(invoice_date) = 2010
    GROUP BY state, product_type
) ranked_products
WHERE sales_rank = 1
ORDER BY state ASC;
 
 -- Which state had the highest total profit in 2010?
 WITH sales_profit AS(
  SELECT invoice_date, state, (sales - cogs - total_expenses) AS profit
  FROM project.superstores_sales)
  
 SELECT state, SUM(profit) as total_profit
 FROM sales_profit
 WHERE YEAR(invoice_date) = 2010
 GROUP BY state
 ORDER BY total_profit DESC;
 
 -- How did the sales of different product types vary by caffeine types?
 SELECT product_type, caffeine_type, SUM(sales) AS total_sales
 FROM project.superstores_sales
 GROUP BY product_type, caffeine_type
 ORDER BY total_sales DESC;
 
 -- What was the monthly profit of regular and decaf espresso sales in 2010?
SELECT  CONCAT(caffeine_type, ' ', product_type) AS product_name,
        MONTH(invoice_date) AS month,
        SUM(sales - cogs - total_expenses) AS total_profit
FROM project. superstores_sales
WHERE product_type = 'Espresso' AND (caffeine_type = 'Regular' OR caffeine_type = 'Decaf') AND YEAR(invoice_date) = 2010
GROUP BY month, product_name
ORDER BY month ASC;

-- What was the average growth rate of each state from 2010 to 2011?
SELECT state, AVG((sales_2011 - sales_2010) / sales_2010 * 100) AS avg_growth_rate
FROM (
    SELECT state,
           SUM(CASE WHEN YEAR(invoice_date) = 2010 THEN sales ELSE 0 END) AS sales_2010,
           SUM(CASE WHEN YEAR(invoice_date) = 2011 THEN sales ELSE 0 END) AS sales_2011
    FROM project.superstores_sales
    GROUP BY state
) AS sales_by_state
GROUP BY state;

-- Which state had the highest gross margin percentage in 2010?
SELECT state, (SUM(sales) - SUM(cogs)) / SUM(sales) * 100 AS gross_margin_percentage
FROM project.superstores_sales
WHERE YEAR(invoice_date) = 2010
GROUP BY state
ORDER BY gross_margin_percentage DESC
LIMIT 1;

-- What was the total sales trend for each product type from 2010 to 2011?
SELECT product_type,
       SUM(CASE WHEN year = 2010 THEN total_sales ELSE 0 END) AS sales_2010,
       SUM(CASE WHEN year = 2011 THEN total_sales ELSE 0 END) AS sales_2011
FROM (
  SELECT product_type,
         YEAR(invoice_date) AS year,
         SUM(sales) AS total_sales
  FROM project.superstores_sales
  WHERE YEAR(invoice_date) BETWEEN 2010 AND 2011
  GROUP BY product_type, year
) AS sales_by_product_type
GROUP BY product_type
ORDER BY sales_2011 DESC;

-- What is the variance between the total budgeted COGS and the actual COGS for each product type?
SELECT product_type, SUM(budget_cogs) AS total_budget_cogs, SUM(cogs) AS total_actual_cogs,
       SUM(cogs) - SUM(budget_cogs) AS variance
FROM project.superstores_sales
GROUP BY product_type;

-- Which product description of Espresso had the highest sale in 2010?
SELECT d.product_description, SUM(s.sales) AS total_sales
FROM project.superstores_sales AS s
JOIN project.drink_sales AS d
ON s.product_type = d.product_type
WHERE YEAR(s.invoice_date) = 2010 AND s.product_type = 'Espresso'
GROUP BY d.product_description
ORDER BY total_sales DESC
LIMIT 1;

-- What is the correlation between marketing expenses and sales?
SELECT (
    POWER((COUNT(*) * SUM(x * y) - SUM(x) * SUM(y)) /
    SQRT((COUNT(*) * SUM(x*x) - SUM(x) * SUM(x)) * (COUNT(*) * SUM(y*y) - SUM(y) * SUM(y))), 2)
) AS r_squared
FROM (
    SELECT marketing AS x, sales AS y
    FROM project.superstores_sales
) AS data;
