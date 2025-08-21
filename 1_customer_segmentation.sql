WITH customer_ltv AS(
	SELECT
		customerkey,
		cleaned_name,
		SUM(total_net_revenue) AS total_ltv
	FROM
		cohort_analysis
	GROUP BY 
		customerkey,
		cleaned_name
), customer_segments AS(
	SELECT
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th_percentile,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th_percentile
	FROM 
		customer_ltv
),
segment_values AS (
	SELECT
		cl.*,
		CASE
			WHEN cl.total_ltv < cs.ltv_25th_percentile THEN '1 - Low-Value'
			WHEN cl.total_ltv <= cs.ltv_75th_percentile THEN '2 - Mid-Value'
			ELSE '3 - High-Value'
		END AS customer_segment
	FROM
		customer_ltv cl,
		customer_segments cs
)
SELECT
	sv.customer_segment,
	SUM(sv.total_ltv) AS total_ltv,
	COUNT(sv.customerkey) AS customer_count,
	SUM(sv.total_ltv)/COUNT(sv.customerkey) AS avg_ltv
FROM 
	segment_values sv
GROUP BY 
	sv.customer_segment
ORDER BY
	sv.customer_segment DESC;