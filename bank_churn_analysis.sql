-- ================================================
-- UK Bank Customer Churn Analysis
-- Tool: MySQL
-- Dataset: 10,000 Bank Customers (Kaggle)
-- ================================================


-- ------------------------------------------------
-- STEP 1: DATABASE AND TABLE SETUP
-- ------------------------------------------------

CREATE DATABASE bank_project;
USE bank_project;

CREATE TABLE bank_churn (
  RowNumber        INT,
  CustomerId       BIGINT,
  Surname          VARCHAR(100),
  CreditScore      INT,
  Geography        VARCHAR(50),
  Gender           VARCHAR(10),
  Age              INT,
  Tenure           INT,
  Balance          DECIMAL(15,2),
  NumOfProducts    INT,
  HasCrCard        INT,
  IsActiveMember   INT,
  EstimatedSalary  DECIMAL(15,2),
  Exited           INT
);


-- ------------------------------------------------
-- STEP 2: DATA CLEANING
-- ------------------------------------------------

-- Check total rows
SELECT COUNT(*) FROM bank_churn;

-- Preview first 5 rows
SELECT * FROM bank_churn LIMIT 5;

-- Check for NULL values
SELECT
  SUM(CASE WHEN CreditScore IS NULL THEN 1 ELSE 0 END) AS null_credit,
  SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END)         AS null_age,
  SUM(CASE WHEN Balance IS NULL THEN 1 ELSE 0 END)     AS null_balance,
  SUM(CASE WHEN Exited IS NULL THEN 1 ELSE 0 END)      AS null_exited
FROM bank_churn;

-- Check for duplicate customers
SELECT CustomerId, COUNT(*) AS cnt
FROM bank_churn
GROUP BY CustomerId
HAVING COUNT(*) > 1;

-- Create clean working table (remove unnecessary columns)
CREATE TABLE bank_churn_clean AS
SELECT
  CreditScore, Geography, Gender, Age, Tenure,
  Balance, NumOfProducts, HasCrCard,
  IsActiveMember, EstimatedSalary, Exited
FROM bank_churn;


-- ------------------------------------------------
-- STEP 3: ANALYSIS QUERIES
-- ------------------------------------------------

-- Query 1: Overall churn rate
-- Result: 10,000 customers | 2,037 churned | 20.37% churn rate
SELECT
  COUNT(*)                                        AS total_customers,
  SUM(Exited)                                     AS churned,
  ROUND(100.0 * SUM(Exited) / COUNT(*), 2)        AS churn_rate_pct
FROM bank_churn_clean;


-- Query 2: Churn by age group
-- Result: Customers aged 45-59 had highest churn at 49.45%
SELECT
  CASE
    WHEN Age < 30 THEN 'Under 30'
    WHEN Age BETWEEN 30 AND 44 THEN '30-44'
    WHEN Age BETWEEN 45 AND 59 THEN '45-59'
    ELSE '60+'
  END                                             AS age_group,
  COUNT(*)                                        AS total,
  SUM(Exited)                                     AS churned,
  ROUND(100.0 * SUM(Exited) / COUNT(*), 2)        AS churn_rate_pct
FROM bank_churn_clean
GROUP BY age_group
ORDER BY churn_rate_pct DESC;


-- Query 3: Churn by number of products
-- Result: Customers with 3-4 products had 83-100% churn rate
SELECT
  NumOfProducts,
  COUNT(*)                                        AS total,
  SUM(Exited)                                     AS churned,
  ROUND(100.0 * SUM(Exited) / COUNT(*), 2)        AS churn_rate_pct
FROM bank_churn_clean
GROUP BY NumOfProducts
ORDER BY NumOfProducts;


-- Query 4: Churn by geography
-- Result: Germany had highest churn at 32.44%
SELECT
  Geography,
  COUNT(*)                                        AS total,
  SUM(Exited)                                     AS churned,
  ROUND(100.0 * SUM(Exited) / COUNT(*), 2)        AS churn_rate_pct
FROM bank_churn_clean
GROUP BY Geography
ORDER BY churn_rate_pct DESC;


-- Query 5: Churn by active membership
-- Result: Inactive members churned at 26.85% vs 14.27% for active members
SELECT
  CASE WHEN IsActiveMember = 1 THEN 'Active'
       ELSE 'Inactive' END                        AS member_status,
  COUNT(*)                                        AS total,
  SUM(Exited)                                     AS churned,
  ROUND(100.0 * SUM(Exited) / COUNT(*), 2)        AS churn_rate_pct
FROM bank_churn_clean
GROUP BY IsActiveMember;
