DROP VIEW cohort_analysis;

CREATE OR REPLACE VIEW cohort_analysis AS
WITH customer_revenue AS(
	SELECT
	    s.customerkey,
	    s.orderdate,
	    SUM(s.quantity * s.netprice * s.exchangerate) AS total_net_revenue,
	    COUNT(s.orderdate) AS num_orders,
	    MAX(c.countryfull) AS countryfull,
	    MAX(c.age) AS age,
	    MAX(c.givenname) AS givenname,
	    MAX(c.surname) AS surname
	FROM sales s
	INNER JOIN 
	customer c ON 
		c.customerkey = s.customerkey
	GROUP BY
		s.customerkey,
	   s.orderdate
)
SELECT
	cr.customerkey,
	cr.orderdate,
	cr.total_net_revenue,
	cr.num_orders,
	cr.countryfull,
	cr.age,
	CONCAT(TRIM(BOTH FROM cr.givenname), ' ', TRIM(BOTH FROM cr.surname)) AS cleaned_name,
	MIN(cr.orderdate) OVER(
		PARTITION BY cr.customerkey
	) AS first_purchase_date,
	EXTRACT(YEAR FROM MIN(cr.orderdate) OVER(
			PARTITION BY cr.customerkey
	)) AS cohort_year
FROM 
	customer_revenue cr;