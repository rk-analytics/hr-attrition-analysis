USE hr_analytics;

SELECT COUNT(*) AS total_employees
FROM hr_attrition;

-- Objective: Calculate total employees, attrition count, and overall attrition rate.
SELECT 
COUNT(*) AS total_employees,
SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrition_count,
ROUND(AVG(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100, 2) AS attrition_rate_pct
FROM hr_attrition;
-- Attrition rate is 16.12%, meaning ~1 in 6 employees have left the organization

-- Objective: Identify missing values across key columns to ensure data quality before analysis
SELECT 
COUNT(*) AS total_rows,
COUNT(*) - COUNT(Attrition) AS null_attrition,
COUNT(*) - COUNT(Gender) AS null_gender,
COUNT(*) - COUNT(Department) AS null_department,
COUNT(*) - COUNT(JobRole) AS null_jobrole,
COUNT(*) - COUNT(MonthlyIncome) AS null_income,
COUNT(*) - COUNT(YearsAtCompany) AS null_tenure,
COUNT(*) - COUNT(OverTime) AS null_overtime
FROM hr_attrition;
-- Interpretation: No missing values detected across key columns, indicating clean and analysis-ready data

-- Objective: Validate that Attrition column contains only expected values ('Yes', 'No')
SELECT 
Attrition, COUNT(*) AS count
FROM hr_attrition
GROUP BY Attrition;
-- Interpretation: Attrition values are clean and consistent, with 237 employees (16.12%) leaving and 1233 (83.88%) retained, confirming no unexpected categories

-- Objective: Validate min and max values including Age column with encoding issue
SELECT 
MIN(`ï»¿Age`) AS min_age,
MAX(`ï»¿Age`) AS max_age,
MIN(MonthlyIncome) AS min_income,
MAX(MonthlyIncome) AS max_income,
MIN(YearsAtCompany) AS min_tenure,
MAX(YearsAtCompany) AS max_tenure
FROM hr_attrition;
-- Note: Age column contains BOM encoding issue (ï»¿Age); handled using backticks or should be renamed for consistency
-- Interpretation: All numerical features fall within realistic ranges (Age: 18–60, Income: 1009–19999, Tenure: 0–40), indicating no data entry errors or extreme anomalies.

-- Objective: Segment employees into Low, Medium, and High income groups
WITH income_data AS (SELECT MonthlyIncome, NTILE(3) OVER (ORDER BY MonthlyIncome) AS income_group
FROM hr_attrition)
SELECT CASE 
WHEN income_group = 1 THEN 'Low Income'
WHEN income_group = 2 THEN 'Medium Income'
WHEN income_group = 3 THEN 'High Income'
END AS income_segment,

COUNT(*) AS employee_count, MIN(MonthlyIncome) AS min_income, MAX(MonthlyIncome) AS max_income
FROM income_data
GROUP BY income_group
ORDER BY income_group;
-- Interpretation: Employees are evenly distributed across income segments (~33% each), with income ranges clearly separating low (1009–3629), medium (3633–6524), and high (6538–19999) groups, enabling unbiased comparison of attrition patterns

-- Objective: Analyze attrition rate across departments to identify high-risk business units
WITH base AS (SELECT *, CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS attrition_flag
FROM hr_attrition
)
SELECT Department, COUNT(*) AS total_employees,
ROUND(AVG(attrition_flag) * 100, 2) AS attrition_rate_pct,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS workforce_share_pct
FROM base
GROUP BY Department
ORDER BY attrition_rate_pct DESC;
-- Interpretation: Sales has the highest attrition rate (20.63%) and represents ~30% of the workforce, making it the primary driver of overall attrition, while R&D, despite lower attrition (13.84%), contributes most to absolute churn due to its large workforce share (~65%).

-- Objective: Evaluate the impact of overtime on attrition to identify workload-related churn risk
WITH base AS (SELECT *, CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS attrition_flag
FROM hr_attrition)
SELECT OverTime, COUNT(*) AS total_employees,
ROUND(AVG(attrition_flag) * 100, 2) AS attrition_rate_pct,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS workforce_share_pct
FROM base
GROUP BY OverTime
ORDER BY attrition_rate_pct DESC;
-- Interpretation: Employees working overtime have a significantly higher attrition rate (30.53% vs 10.44%), ~3x increase, making overtime the strongest driver of churn despite representing only ~28% of the workforce.

-- Objective: Identify job roles with highest attrition to pinpoint role-specific churn risk
WITH base AS (SELECT *, CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS attrition_flag
FROM hr_attrition)
SELECT JobRole, COUNT(*) AS total_employees,
ROUND(AVG(attrition_flag) * 100, 2) AS attrition_rate_pct,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS workforce_share_pct
FROM base
GROUP BY JobRole
HAVING COUNT(*) >= 20
ORDER BY attrition_rate_pct DESC;
-- Interpretation: Attrition is highly concentrated in Sales Representative roles (~39.76%), nearly 2.5x the overall average, while roles like Laboratory Technician (~23.94%) also show elevated risk; however, Sales Executives (~22% workforce) contribute more to total churn due to scale despite lower attrition (~17.48%).

-- Objective: Analyze attrition across tenure groups to identify high-risk periods in employee lifecycle
WITH base AS (SELECT *, 
CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS attrition_flag,
CASE 
WHEN YearsAtCompany <= 2 THEN '0-2 Years'
WHEN YearsAtCompany <= 5 THEN '3-5 Years'
WHEN YearsAtCompany <= 10 THEN '6-10 Years'
ELSE '10+ Years'
END AS tenure_group
FROM hr_attrition)

SELECT tenure_group, COUNT(*) AS total_employees,
ROUND(AVG(attrition_flag) * 100, 2) AS attrition_rate_pct,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS workforce_share_pct
FROM base
GROUP BY tenure_group
ORDER BY attrition_rate_pct DESC;
-- Interpretation: Attrition is highest in the first 2 years (29.82%), ~2x higher than mid-tenure and ~3.5x higher than long-tenure employees, indicating early-stage churn as the most critical risk despite representing ~23% of the workforce.

-- Objective: Create multi-dimensional employee segments combining income, tenure, and overtime to identify high-risk groups
WITH base AS (SELECT *,CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS attrition_flag,

NTILE(3) OVER (ORDER BY MonthlyIncome) AS income_group,

CASE 
WHEN YearsAtCompany <= 2 THEN '0-2 Years'
WHEN YearsAtCompany <= 5 THEN '3-5 Years'
WHEN YearsAtCompany <= 10 THEN '6-10 Years'
ELSE '10+ Years'
END AS tenure_group
FROM hr_attrition),

final AS (SELECT 
CASE 
WHEN income_group = 1 THEN 'Low Income'
WHEN income_group = 2 THEN 'Medium Income'
WHEN income_group = 3 THEN 'High Income'
END AS income_segment, tenure_group, OverTime, attrition_flag
FROM base
)

SELECT income_segment, tenure_group, OverTime,
COUNT(*) AS total_employees,
ROUND(AVG(attrition_flag) * 100, 2) AS attrition_rate_pct,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS workforce_share_pct
FROM final
GROUP BY income_segment, tenure_group, OverTime
ORDER BY attrition_rate_pct DESC
LIMIT 10;
-- Interpretation: The highest-risk segments are concentrated among low-income, early-tenure employees working overtime, with attrition rates exceeding 60%, indicating compounding effects of low pay, low experience, and high workload.

-- Objective: Create segment-level dataset for prioritization using income, tenure, and overtime
WITH base AS (SELECT *, CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END AS attrition_flag,
NTILE(3) OVER (ORDER BY MonthlyIncome) AS income_group,
CASE 
WHEN YearsAtCompany <= 2 THEN '0-2 Years'
WHEN YearsAtCompany <= 5 THEN '3-5 Years'
WHEN YearsAtCompany <= 10 THEN '6-10 Years'
ELSE '10+ Years'
END AS tenure_group
FROM hr_attrition),

final AS 
(SELECT CASE 
WHEN income_group = 1 THEN 'Low Income'
WHEN income_group = 2 THEN 'Medium Income'
WHEN income_group = 3 THEN 'High Income'
END AS income_segment, tenure_group, OverTime, attrition_flag
FROM base)

SELECT 
CONCAT(income_segment, ' | ', tenure_group, ' | OT:', OverTime) AS segment,
COUNT(*) AS total_employees,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS workforce_share_pct,
ROUND(AVG(attrition_flag) * 100, 2) AS attrition_rate_pct
FROM final
GROUP BY income_segment, tenure_group, OverTime
ORDER BY attrition_rate_pct DESC
LIMIT 10;
-- Interpretation: Segments combining low income, early tenure, and overtime show the highest attrition, enabling prioritization using both risk (attrition rate) and scale (workforce share)


-- FINAL SUMMARY: HR ATTRITION ANALYSIS

-- Overall Findings:
-- The overall attrition rate stands at ~16%, indicating moderate employee turnover.
-- However, attrition is not uniformly distributed and is driven by specific employee segments.

-- Key Drivers Identified:

-- 1. Overtime (Strongest Driver)
-- Employees working overtime have ~3x higher attrition (30% vs 10%),
-- making workload and burnout the most critical factor.

-- 2. Tenure (Lifecycle Effect)
-- Attrition peaks in the first 2 years (~30%) and declines steadily,
-- indicating early-stage disengagement and onboarding gaps.

-- 3. Job Role (Role-Specific Risk)
-- Sales Representatives show extreme attrition (~40%),
-- confirming role-specific pressure and performance-driven churn.

-- 4. Department (Business Unit Impact)
-- Sales department has the highest attrition (~20%) and a significant workforce share (~30%),
-- making it the primary contributor to overall churn.

-- 5. Compensation (Income Effect)
-- Low-income employees exhibit significantly higher attrition,
-- indicating compensation sensitivity in early and mid-career stages.

-- 6. Combined Risk Segmentation (Most Critical Insight)
-- Highest-risk segments are:
-- Low Income + Early Tenure (0–2 years) + Overtime
-- These segments show attrition rates exceeding 60%,
-- demonstrating compounding effects of multiple risk factors.

-- BUSINESS INTERPRETATION

-- Attrition is not driven by a single factor but by a combination of:
-- - Workload (Overtime)
-- - Experience level (Tenure)
-- - Compensation (Income)
-- - Role-specific pressure (Sales roles)

-- High attrition occurs when these factors intersect.

-- RECOMMENDATIONS

-- 1. Improve Early Employee Experience (0–2 Years)
-- - Strengthen onboarding programs
-- - Implement mentorship/buddy systems
-- - Conduct early engagement surveys (first 90 days)

-- 2. Reduce Overtime Dependency
-- - Monitor overtime at team/role level
-- - Introduce workload balancing strategies
-- - Set limits or alerts for excessive overtime

-- 3. Target High-Risk Roles (Sales Representatives)
-- - Review performance targets and incentives
-- - Provide better support systems (training, tools)
-- - Introduce retention bonuses or role redesign

-- 4. Compensation Optimization for Low-Income Segments
-- - Benchmark salaries against market standards
-- - Introduce structured salary progression
-- - Provide non-monetary benefits (flexibility, recognition)

-- 5. Dual Strategy Approach (Critical)
-- - Targeted interventions → High-risk small segments
-- - Scalable policies → Large workforce segments (Sales Exec, R&D)

-- 6. Continuous Monitoring
-- - Build attrition dashboards for real-time tracking
-- - Track key indicators: Overtime %, Early attrition %, Segment risk

-- FINAL CONCLUSION

-- Attrition is concentrated in specific, identifiable employee segments.
-- By focusing on early-tenure employees, reducing overtime, and addressing
-- role-specific and compensation-related issues, the organization can
-- significantly reduce churn and improve retention outcomes.
