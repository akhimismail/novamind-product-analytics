-- table creation

CREATE TABLE novamind_users (
    CustomerID INT,
    Churn INT,
    Tenure INT,
    PreferredLoginDevice VARCHAR(50),
    CityTier INT,
    WarehouseToHome INT,
    PreferredPaymentMode VARCHAR(50),
    Gender VARCHAR(20),
    HourSpendOnApp DECIMAL(5,2),
    NumberOfDeviceRegistered INT,
    PreferedOrderCat VARCHAR(50),
    SatisfactionScore INT,
    MaritalStatus VARCHAR(20),
    NumberOfAddress INT,
    Complain INT,
    OrderAmountHikeFromlastYear DECIMAL(5,2),
    CouponUsed INT,
    OrderCount INT,
    DaySinceLastOrder INT,
    CashbackAmount DECIMAL(10,2)
);

SELECT * FROM novamind_users LIMIT 5;


-- data cleaning

SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END) AS missing_tenure,
    SUM(CASE WHEN hourspendonapp IS NULL THEN 1 ELSE 0 END) AS missing_hours,
    SUM(CASE WHEN orderamounthikefromlastyear IS NULL THEN 1 ELSE 0 END) AS missing_order_hike,
    SUM(CASE WHEN warehousetohome IS NULL THEN 1 ELSE 0 END) AS missing_warehouse,
    SUM(CASE WHEN daysincelastorder IS NULL THEN 1 ELSE 0 END) AS missing_last_order,
    SUM(CASE WHEN couponused IS NULL THEN 1 ELSE 0 END) AS missing_coupon,
    SUM(CASE WHEN ordercount IS NULL THEN 1 ELSE 0 END) AS missing_ordercount,
    SUM(CASE WHEN cashbackamount IS NULL THEN 1 ELSE 0 END) AS missing_cashback
FROM novamind_users;


UPDATE novamind_users
SET 
    tenure = COALESCE(tenure, (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tenure) FROM novamind_users)),
    hourspendonapp = COALESCE(hourspendonapp, (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY hourspendonapp) FROM novamind_users)),
    orderamounthikefromlastyear = COALESCE(orderamounthikefromlastyear, (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY orderamounthikefromlastyear) FROM novamind_users)),
    warehousetohome = COALESCE(warehousetohome, (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY warehousetohome) FROM novamind_users)),
    daysincelastorder = COALESCE(daysincelastorder, (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY daysincelastorder) FROM novamind_users)),
    couponused = COALESCE(couponused, (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY couponused) FROM novamind_users)),
    ordercount = COALESCE(ordercount, (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ordercount) FROM novamind_users));


SELECT 
    SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END) AS missing_tenure,
    SUM(CASE WHEN hourspendonapp IS NULL THEN 1 ELSE 0 END) AS missing_hours,
    SUM(CASE WHEN orderamounthikefromlastyear IS NULL THEN 1 ELSE 0 END) AS missing_order_hike,
    SUM(CASE WHEN warehousetohome IS NULL THEN 1 ELSE 0 END) AS missing_warehouse,
    SUM(CASE WHEN daysincelastorder IS NULL THEN 1 ELSE 0 END) AS missing_last_order,
    SUM(CASE WHEN couponused IS NULL THEN 1 ELSE 0 END) AS missing_coupon,
    SUM(CASE WHEN ordercount IS NULL THEN 1 ELSE 0 END) AS missing_ordercount
FROM novamind_users;


-- churn rate

SELECT
    COUNT(*) AS total_users,
    SUM(churn) AS churned_users,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM novamind_users;


-- churn by city

SELECT
    citytier,
    COUNT(*) AS total_users,
    SUM(churn) AS churned_users,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM novamind_users
GROUP BY citytier
ORDER BY churn_rate_pct DESC;


-- churn by tenure

WITH tenure_segments AS (
    SELECT *,
        CASE
            WHEN tenure <= 3 THEN '0-3 months'
            WHEN tenure BETWEEN 4 AND 12 THEN '4-12 months'
            WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
            ELSE '24+ months'
        END AS tenure_band
    FROM novamind_users
)
SELECT
    tenure_band,
    COUNT(*) AS total_users,
    SUM(churn) AS churned_users,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM tenure_segments
GROUP BY tenure_band
ORDER BY churn_rate_pct DESC;


-- churn by satisfaction

SELECT
    satisfactionscore,
    COUNT(*) AS total_users,
    SUM(churn) AS churned_users,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM novamind_users
GROUP BY satisfactionscore
ORDER BY satisfactionscore;


-- complaints vs churn

SELECT
    complain,
    COUNT(*) AS total_users,
    SUM(churn) AS churned_users,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM novamind_users
GROUP BY complain
ORDER BY complain;


-- engagements vs churn

WITH engagement_ranked AS (
    SELECT
        customerid,
        churn,
        hourspendonapp,
        ordercount,
        RANK() OVER (ORDER BY hourspendonapp DESC) AS engagement_rank
    FROM novamind_users
)
SELECT
    CASE
        WHEN engagement_rank <= 1000 THEN 'High Engagement'
        WHEN engagement_rank <= 3000 THEN 'Mid Engagement'
        ELSE 'Low Engagement'
    END AS engagement_tier,
    COUNT(*) AS total_users,
    SUM(churn) AS churned_users,
    ROUND(SUM(churn) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM engagement_ranked
GROUP BY engagement_tier
ORDER BY churn_rate_pct DESC;


-- revenue at risk

WITH user_value AS (
    SELECT
        customerid,
        citytier,
        churn,
        cashbackamount,
        ordercount,
        ROUND(cashbackamount * ordercount, 2) AS estimated_revenue
    FROM novamind_users
),
city_summary AS (
    SELECT
        citytier,
        COUNT(*) AS total_users,
        SUM(CASE WHEN churn = 1 THEN estimated_revenue ELSE 0 END) AS revenue_at_risk,
        ROUND(AVG(estimated_revenue), 2) AS avg_user_revenue
    FROM user_value
    GROUP BY citytier
)
SELECT
    citytier,
    total_users,
    revenue_at_risk,
    avg_user_revenue
FROM city_summary
ORDER BY revenue_at_risk DESC;


-- top churned users

SELECT
    customerid,
    tenure,
    ordercount,
    cashbackamount,
    satisfactionscore,
    complain,
    ROUND(cashbackamount * ordercount, 2) AS estimated_revenue
FROM novamind_users
WHERE churn = 1
ORDER BY estimated_revenue DESC
LIMIT 10;