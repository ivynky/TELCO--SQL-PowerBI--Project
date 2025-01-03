-- OBJECTIVE: Exploring Customer Retention, Churn, and Financial Performance Across Demographics and Locations
-- Dataset: TELCO Company data

-- STEP 1: EXPLORATORY ANALYSIS
--	Descriptive statistics

-- Customer count by age group

SELECT 
	AVG(age) AS AVG_Age,
	MAX(age) AS Max_Age,
	MIN(age) AS Min_Age,
	STDEV(age) AS STD_Age,
	COUNT(DISTINCT gender) AS Unique_gender
FROM Customer_info;

-- Customer count by gender

SELECT gender, COUNT(*) AS Total_Customers
FROM Customer_info
GROUP BY gender;

-- Top 5 cities with the highest Number of Customers

SELECT TOP 5 city, COUNT(*) AS Total_Customers
FROM Location_data
GROUP BY city
ORDER BY Total_Customers DESC
;

-- STEP 2: CHURN ANALYSIS

-- Data Transformation: Convert churn score and churn value from bit to integers.

UPDATE Status_Analysis
SET
    churn_score = CONVERT(INT, churn_score),
    churn_value = CONVERT(INT, churn_value);

-- Change churn_score to INT

ALTER TABLE Status_Analysis
ALTER COLUMN churn_score INT;

-- Change churn_value to INT

ALTER TABLE Status_Analysis
ALTER COLUMN churn_value INT;

-- How many customers left the company, how many stayed and how many joined?

SELECT customer_status, COUNT(churn_value) AS Churn_Value
FROM Status_Analysis
GROUP BY customer_status;

-- Age group with the highest churn

SELECT
	CASE
		WHEN CI.age BETWEEN 19 AND 29 THEN '19-29'
		WHEN CI.age BETWEEN 30 AND 39 THEN '30-39'
		WHEN CI.age BETWEEN 40 AND 49 THEN '40-49'
		WHEN CI.age BETWEEN 50 AND 59 THEN '50-59'
		WHEN CI.age >= 60 THEN '60+'
END AS age_group,
SUM(churn_value) AS ChurnValue
FROM Customer_Info CI
JOIN Status_Analysis SA
	ON CI.customer_id = SA.customer_id
GROUP BY 
	  CASE
        WHEN CI.age BETWEEN 19 AND 29 THEN '19-29'
        WHEN CI.age BETWEEN 30 AND 39 THEN '30-39'
        WHEN CI.age BETWEEN 40 AND 49 THEN '40-49'
        WHEN CI.age BETWEEN 50 AND 59 THEN '50-59'
        WHEN CI.age >= 60 THEN '60+'
    END
ORDER BY ChurnValue DESC;

-- Churn by Contract Type

SELECT Contract, 
       SUM(SA.Churn_Value) AS ChurnValue
FROM Payment_Info AS P
JOIN Status_Analysis AS SA
	ON P.customer_id= SA.customer_id
GROUP BY Contract;

-- Churn by Location: Which city in California has the highest churn 

SELECT city, COUNT(LD.customer_id) AS Churn_Count
FROM Location_Data AS LD
JOIN Status_Analysis AS SA
	ON LD.customer_id = SA.customer_id
WHERE Churn_Value = 1
GROUP BY city
ORDER BY Churn_Count DESC;

-- Reason for Churn: Why are customers leaving the company?

SELECT churn_reason, COUNT(*)
FROM Status_Analysis
GROUP BY churn_reason;

--  Data Cleaning & Transformation: Churn Cateogorization: Group similar churn reasons into relevant categories.

UPDATE Status_Analysis
SET churn_reason = CASE
	WHEN churn_reason IN ('Poor expertise of phone support', 'Poor expertise of online support', 'Attitude of service provider', 'Attitude of support person', 'Poor Customer Service/Experience') THEN 'Poor Customer Service'
	WHEN churn_reason IN ('Price too high', 'Extra data charges', 'Long distance charges', 'Lack of affordable download/upload speed') THEN 'High Cost'
	WHEN churn_reason IN ('Competitor had better devices', 'Competitor made better offer', 'Competitor offered more data', 'Competitor offered higher download speeds') THEN 'Superior Competitor Offerings'
	WHEN churn_reason IN ('Product dissatisfaction', 'Network reliability', 'Service dissatisfaction', 'Limited range of Services') THEN 'Service/Product Limitation'
	ELSE churn_reason
END;

-- Reason/s why customers left the company

SELECT churn_reason, COUNT(*) AS Churn_customers#
FROM Status_Analysis
GROUP BY churn_reason
ORDER BY Churn_customers# DESC;

-- Customers with the high CLTV that churned, if cltv from 4501 and above represents High Value Customers

SELECT  COUNT(*) AS churned_high_value_customers
FROM Status_Analysis
WHERE customer_status = 'Churned' AND cltv >= 4501
;

-- STEP 3: REVENUE ANALYSIS

-- Revenue per Customer
SELECT customer_id, contract, ROUND(SUM(total_revenue), 2) AS total_revenue
FROM Payment_Info
GROUP BY customer_id, contract
ORDER BY total_revenue DESC
;

-- Revenue per Location: which location/s generated the highest revenue
SELECT LD.city, ROUND(SUM(total_revenue), 2) AS total_revenue
FROM Payment_Info AS PI
JOIN Location_data AS LD 
	ON PI.customer_id = LD.customer_id
GROUP BY LD.city
ORDER BY total_revenue DESC
;

