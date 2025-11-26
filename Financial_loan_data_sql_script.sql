/****************************************************************************************
📘 PROJECT: Financial Loan Portfolio Analytics    
PURPOSE: A complete SQL-driven data story that prepares, transforms, and analyzes
         a NBFC's loan portfolio to uncover performance and risk insights.
****************************************************************************************/


/*--------------------------------------------------------------
 # CREATE DATABASE
--------------------------------------------------------------*/
CREATE DATABASE IF NOT EXISTS Financial_Loan;
USE Financial_Loan;

/*--------------------------------------------------------------
 # CREATE CORE TABLE STRUCTURE
--------------------------------------------------------------*/
CREATE TABLE IF NOT EXISTS financial_loan_data (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    address_state VARCHAR(10),
    application_type VARCHAR(30),
    emp_length VARCHAR(20),
    emp_title VARCHAR(100),
    grade VARCHAR(5),
    home_ownership VARCHAR(20),
    issue_date DATE,
    last_credit_pull_date DATE,
    last_payment_date DATE,
    loan_status VARCHAR(50),
    next_payment_date DATE,
    member_id INT,
    purpose VARCHAR(50),
    sub_grade VARCHAR(5),
    term VARCHAR(20),
    verification_status VARCHAR(30),
    annual_income DOUBLE,
    dti DOUBLE,
    installment DOUBLE,
    int_rate DOUBLE,
    loan_amount DOUBLE,
    total_acc INT,
    total_payment DOUBLE
);

/*--------------------------------------------------------------
 # LOAD DATA INTO THE TABLE FROM CSV
--------------------------------------------------------------*/
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Clean_Financial_Loan_Data.csv.csv'
INTO TABLE financial_loan_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

/*--------------------------------------------------------------
 # VALIDATE DATA IMPORT
--------------------------------------------------------------*/
SELECT COUNT(*) AS total_records FROM financial_loan_data;
SELECT * FROM financial_loan_data LIMIT 10;

/*--------------------------------------------------------------
 # ADD DERIVED FIELDS -- Create additional columns for analytics and segmentation.
--------------------------------------------------------------*/
ALTER TABLE financial_loan_data
ADD COLUMN issue_month INT,
ADD COLUMN issue_year INT,
ADD COLUMN loan_category VARCHAR(10),
ADD COLUMN recovery_rate_pct DOUBLE,
ADD COLUMN income_to_loan_ratio DOUBLE,
ADD COLUMN dti_bucket VARCHAR(20);
               
UPDATE financial_loan_data
SET
  issue_month = MONTH(issue_date),
  issue_year  = YEAR(issue_date),
  
  loan_category = CASE
                    WHEN loan_status IN ('Fully Paid', 'Current') THEN 'Good'
                    WHEN loan_status = 'Charged Off' THEN 'Bad'
                    ELSE 'Other'
                  END,

  recovery_rate_pct = CASE
                        WHEN loan_amount IS NULL OR loan_amount = 0 THEN NULL
                        ELSE ROUND((total_payment / loan_amount) * 100, 2)
                      END,

  income_to_loan_ratio = CASE
                           WHEN loan_amount IS NULL OR loan_amount = 0 THEN NULL
                           ELSE ROUND(annual_income / loan_amount, 2)
                         END,

  dti_bucket = CASE
                 WHEN dti IS NULL THEN 'Unknown'
                 WHEN dti < 0.10 THEN 'Low (<10%)'
                 WHEN dti BETWEEN 0.10 AND 0.20 THEN 'Medium (10-20%)'
                 ELSE 'High (>20%)'
               END;
               
/*--------------------------------------------------------------
 # PORTFOLIO OVERVIEW KPI
--------------------------------------------------------------*/
SELECT
  COUNT(id) AS total_applications,
  SUM(loan_amount) AS total_funded,
  SUM(total_payment) AS total_received,
  ROUND(AVG(int_rate) * 100, 2) AS avg_interest_pct,
  ROUND(AVG(dti) * 100, 2) AS avg_dti_pct,
  ROUND(SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(id),0),2) AS default_rate_pct,
  ROUND(SUM(total_payment) / (SUM(loan_amount)) * 100, 2) AS recovery_rate_pct
FROM financial_loan_data;

/*--------------------------------------------------------------
# GOOD VS BAD LOAN PERFORMANCE KPI
--------------------------------------------------------------*/
SELECT
   loan_category,
   COUNT(id) AS total_loans,
   ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS recovery_pct,
   ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN loan_amount ELSE 0 END)
      / NULLIF(SUM(loan_amount), 0) * 100, 2) AS default_pct
FROM financial_loan_data
GROUP BY loan_category
ORDER BY default_pct DESC;    

/*--------------------------------------------------------------
 # MONTH-TO-DATE (MTD) KPI METRICS
--------------------------------------------------------------*/
-- 4.2 Month-to-Date (MTD) KPIs
WITH latest AS (
  SELECT 
    YEAR(MAX(issue_date)) AS yr,
    MONTH(MAX(issue_date)) AS mn
  FROM financial_loan_data
)
SELECT
  COUNT(id) AS mtd_applications,
  SUM(loan_amount) AS mtd_funded,
  SUM(total_payment) AS mtd_received
FROM financial_loan_data
JOIN latest
  ON YEAR(issue_date) = latest.yr
 AND MONTH(issue_date) = latest.mn;           

/*--------------------------------------------------------------
 # MONTHLY PERFORMANCE VIEW
--------------------------------------------------------------*/
CREATE OR REPLACE VIEW vw_monthly_summary AS
SELECT
  DATE_FORMAT(issue_date, '%m-%Y') AS month_year,
  COUNT(id) AS total_applications,
  SUM(loan_amount) AS total_funded,
  SUM(total_payment) AS total_received,
  ROUND(AVG(int_rate) * 100, 2) AS avg_interest_pct,
  ROUND(AVG(dti) * 100, 2) AS avg_dti_pct,
  SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END) AS total_defaults,
  ROUND(SUM(CASE WHEN loan_category = 'Bad' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(id), 0),2) AS default_rate_pct,
  ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount), 0) * 100,2) AS recovery_rate_pct
FROM financial_loan_data
GROUP BY DATE_FORMAT(issue_date, '%m-%Y')
ORDER BY month_year;

SELECT * FROM vw_monthly_summary LIMIT 10;

/*--------------------------------------------------------------
 # TIME-SERIES TRENDS -- Monthly MoM Growth
--------------------------------------------------------------*/
WITH months AS (
  SELECT month_year, total_funded FROM vw_monthly_summary
)
SELECT
  month_year,
  total_funded,
  LAG(total_funded) OVER (ORDER BY month_year) AS prev_month_funded,
  ROUND((total_funded - LAG(total_funded) OVER (ORDER BY month_year)) * 100.0 / 
        NULLIF(LAG(total_funded) OVER (ORDER BY month_year),0),2) AS mom_growth_pct
FROM months
ORDER BY month_year;

/*--------------------------------------------------------------
 # TIME-SERIES TRENDS -- Rolling 3-Month Average Funding
--------------------------------------------------------------*/
SELECT
  month_year,
  total_funded,
  ROUND(AVG(total_funded) OVER (ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS rolling_3m_avg_funded,
  ROUND((total_funded - AVG(total_funded) OVER (ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)) 
  / NULLIF(AVG(total_funded) OVER (ORDER BY month_year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),0) * 100, 2) AS deviation_from_avg_pct
FROM vw_monthly_summary;

/*--------------------------------------------------------------
 # MONTHLY LOAN ISSUANCE & COLLECTION TRENDS
--------------------------------------------------------------*/
SELECT
    DATE_FORMAT(issue_date, '%Y-%m') AS issue_month,
    COUNT(id) AS total_loans,
    SUM(loan_amount) AS total_funded,
    SUM(total_payment) AS total_received,
    SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END) AS total_defaults,
    ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS recovery_pct
FROM financial_loan_data
GROUP BY DATE_FORMAT(issue_date, '%Y-%m')
ORDER BY issue_month;

/*--------------------------------------------------------------
 # STATE-WISE PERFORMANCE VIEW
--------------------------------------------------------------*/
CREATE OR REPLACE VIEW vw_state_summary AS
SELECT
  address_state,
  COUNT(id) AS total_loans,
  SUM(loan_amount) AS total_funded,
  SUM(total_payment) AS total_received,
  ROUND(SUM(total_payment - loan_amount),2) AS net_profit,
  SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END) AS total_defaults,
  ROUND(SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(id),0), 2) AS default_rate_pct,
  ROUND(AVG(total_payment / NULLIF(loan_amount,0)) * 100, 2) AS avg_recovery_pct
FROM financial_loan_data
GROUP BY address_state
ORDER BY total_funded DESC;

SELECT * FROM vw_state_summary;

/*--------------------------------------------------------------
# STATE-LEVEL LOSS & RECOVERY DISTRIBUTION
--------------------------------------------------------------*/
SELECT
    address_state,
    COUNT(id) AS total_loans,
    SUM(loan_amount) AS total_funded,
    ROUND(SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(id),0),2) AS default_rate_pct,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN GREATEST(loan_amount - total_payment, 0)ELSE 0 END) AS total_loss,
    ROUND( SUM(CASE WHEN loan_status = 'Charged Off' THEN (loan_amount - total_payment) ELSE 0
		END ) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS loss_pct,
    ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS recovery_pct,
    ROUND( (SUM(total_payment) - SUM(loan_amount)) / NULLIF(SUM(loan_amount),0) * 100, 2) AS roi_pct
FROM financial_loan_data
GROUP BY address_state
ORDER BY roi_pct DESC;

/*--------------------------------------------------------------
 # GRADE AND SUB-GRADE PERFORMANCE VIEW
--------------------------------------------------------------*/
CREATE OR REPLACE VIEW vw_grade_performance AS
SELECT
  grade,
  sub_grade,
  COUNT(id) AS total_loans,
  SUM(loan_amount) AS total_funded,
  SUM(total_payment) AS total_received,
  ROUND(AVG(int_rate) * 100, 2) AS avg_interest_pct,
  SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END) AS total_defaults,
  ROUND(SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(id),0),2) AS default_rate_pct,
  ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount),0) * 100, 2) AS recovery_rate_pct
FROM financial_loan_data
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;

SELECT * FROM vw_grade_performance;

/*--------------------------------------------------------------
 # LOAN TERM AND INTEREST RATE IMPACT
--------------------------------------------------------------*/
SELECT
    term,
    COUNT(id) AS total_loans,
    ROUND(AVG(int_rate) * 100, 2) AS avg_interest_pct,
    SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END) AS total_defaults,
    ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN loan_amount ELSE 0 END)
          / NULLIF(SUM(loan_amount), 0) * 100, 2) AS loss_pct,
    ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS recovery_pct
FROM financial_loan_data
GROUP BY term
ORDER BY loss_pct DESC;

/*--------------------------------------------------------------
 # LOSS AMOUNT & LOSS PERCENTAGE BY GRADE
--------------------------------------------------------------*/
SELECT
    grade,
    COUNT(id) AS total_loans,
    SUM(loan_amount) AS total_funded,
    ROUND(SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(id),0),2) AS default_rate_pct,
    SUM(CASE WHEN loan_status = 'Charged Off' THEN GREATEST(loan_amount - total_payment, 0)ELSE 0 END) AS total_loss,
    ROUND( SUM(CASE WHEN loan_status = 'Charged Off' THEN (loan_amount - total_payment) ELSE 0
		END ) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS loss_pct,
	ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS recovery_pct
FROM financial_loan_data
GROUP BY grade
ORDER BY loss_pct DESC;

/*--------------------------------------------------------------
 # BORROWER RISK PROFILE VIEW
--------------------------------------------------------------*/
CREATE OR REPLACE VIEW vw_borrower_risk AS
SELECT
  member_id,
  verification_status,
  annual_income,
  grade,
  sub_grade,
  loan_amount,
  int_rate,
  dti,
  total_payment,
  recovery_rate_pct,
  loan_status,
  loan_category,
  income_to_loan_ratio,
  dti_bucket,
  CASE 
	WHEN annual_income < 40000 OR dti > 0.2 THEN 'High Risk'
    WHEN (annual_income >= 40000 AND annual_income < 80000) OR (dti >= 0.1 AND dti <= 0.2) THEN 'Medium Risk'
	ELSE 'Low Risk'
  END AS risk_category
FROM financial_loan_data;

SELECT * FROM vw_borrower_risk LIMIT 10;

/*--------------------------------------------------------------
 # ANOMALY DETECTION — TOP 10 BORROWERS BY EXTREME ROI OR LOSS
--------------------------------------------------------------*/
SELECT
  member_id,
  loan_status,
  loan_amount,
  total_payment,
  ROUND((total_payment - loan_amount) / NULLIF(loan_amount, 0) * 100, 2) AS roi_pct,
  ROUND((loan_amount - total_payment) / NULLIF(loan_amount, 0) * 100, 2) AS loss_pct
FROM financial_loan_data
WHERE loan_status IN ('Fully Paid', 'Charged Off')
ORDER BY ABS((total_payment - loan_amount) / NULLIF(loan_amount, 0)) DESC
LIMIT 10;

/*--------------------------------------------------------------
 # BORROWER INCOME BAND PERFORMANCE
--------------------------------------------------------------*/
SELECT
    CASE
        WHEN annual_income < 40000 THEN 'Low Income (<40K)'
        WHEN annual_income BETWEEN 40000 AND 80000 THEN 'Mid Income (40K-80K)'
        ELSE 'High Income (>80K)'
    END AS income_segment,
    COUNT(id) AS total_loans,
    ROUND(AVG(loan_amount), 2) AS avg_loan,
    ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS recovery_pct
FROM financial_loan_data
GROUP BY income_segment
ORDER BY recovery_pct DESC;

/*--------------------------------------------------------------
 # INCOME-TO-LOAN RATIO BUCKETS
--------------------------------------------------------------*/
SELECT
  CASE
    WHEN income_to_loan_ratio IS NULL THEN 'Unknown'
    WHEN income_to_loan_ratio < 1 THEN '<1'
    WHEN income_to_loan_ratio BETWEEN 1 AND 3 THEN '1-3'
    WHEN income_to_loan_ratio BETWEEN 3 AND 10 THEN '3-10'
    ELSE '>10'
  END AS income_loan_bucket,
COUNT(id) AS loans,
ROUND(AVG(income_to_loan_ratio),2) AS avg_ratio,
ROUND(SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS default_rate_pct
FROM financial_loan_data
GROUP BY income_loan_bucket
ORDER BY default_rate_pct DESC;

/*--------------------------------------------------------------
 # DEBT-TO-INCOME (DTI) BUCKET ANALYSIS
--------------------------------------------------------------*/
SELECT
  dti_bucket,
  ROUND(AVG(dti)*100,2) AS avg_dti_pct,
  COUNT(id) AS total_loans,
  ROUND(AVG(annual_income),0) AS avg_income,
  ROUND(AVG(loan_amount), 2) AS avg_loan_amount,
  ROUND(SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS default_rate_pct
FROM financial_loan_data
GROUP BY dti_bucket
ORDER BY default_rate_pct DESC;

/*--------------------------------------------------------------
 # RISK CLUSTERING BY PURPOSE
--------------------------------------------------------------*/
SELECT
    purpose,
    COUNT(id) AS total_loans,
    SUM(loan_amount) AS total_funded,
    ROUND(AVG(int_rate) * 100, 2) AS avg_interest_pct,
    ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)
          / COUNT(id) * 100, 2) AS default_rate,
    ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS recovery_pct
FROM financial_loan_data
GROUP BY purpose
ORDER BY default_rate DESC;

/*--------------------------------------------------------------
 # HOME OWNERSHIP IMPACT
--------------------------------------------------------------*/
SELECT
    home_ownership,
    COUNT(id) AS total_loans,
    ROUND(AVG(annual_income), 2) AS avg_income,
    ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS recovery_pct,
    ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN 1 ELSE 0 END)
          / COUNT(id) * 100, 2) AS default_rate
FROM financial_loan_data
GROUP BY home_ownership
ORDER BY recovery_pct DESC;

/*--------------------------------------------------------------
 # DEFAULT RATE BY INSTALLMENT SIZE
--------------------------------------------------------------*/
SELECT
  CASE 
    WHEN installment < 200 THEN 'Low Installment(<200)'
    WHEN installment BETWEEN 200 AND 500 THEN 'Medium Installment(200-500)'
    ELSE 'High Installment(>500)'
  END AS installment_bucket,
  COUNT(*) AS total_loans,
  ROUND(SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS default_rate_pct
FROM financial_loan_data
GROUP BY installment_bucket;

/*--------------------------------------------------------------
 # PORTFOLIO HEALTH SUMMARY BY LOAN_STATUS
--------------------------------------------------------------*/
SELECT
  loan_status,
  loan_category,
  COUNT(id) AS total_loans,
  ROUND(AVG(total_payment - loan_amount), 2) AS avg_profit,
  ROUND(AVG(dti), 2) AS avg_dti,
  ROUND(SUM(CASE WHEN loan_category = 'Bad' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS default_rate_pct,
  ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS recovery_rate_pct
FROM financial_loan_data
GROUP BY loan_category, loan_status
ORDER BY loan_category, total_loans DESC;

/*--------------------------------------------------------------
 # EXECUTIVE DASHBOARD VIEW — vw_executive_dashboard
--------------------------------------------------------------*/
CREATE OR REPLACE VIEW vw_executive_dashboard AS
SELECT
  COUNT(id) AS total_loans,
  SUM(loan_amount) AS total_funded,
  SUM(total_payment) AS total_received,
  SUM(CASE WHEN loan_status = 'Charged Off' THEN GREATEST(loan_amount - total_payment, 0) ELSE 0 END) AS total_loss,
  ROUND(SUM(CASE WHEN loan_status = 'Charged Off' THEN (loan_amount - total_payment) ELSE 0 END) 
        / NULLIF(SUM(loan_amount), 0) * 100, 2) AS loss_pct,
  ROUND(SUM(total_payment) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS recovery_pct,
  ROUND((SUM(total_payment) - SUM(loan_amount)) / NULLIF(SUM(loan_amount), 0) * 100, 2) AS roi_pct,
  ROUND(AVG(annual_income), 2) AS avg_income,
  ROUND(AVG(int_rate) * 100, 2) AS avg_interest_pct,
  ROUND(AVG(dti) * 100, 2) AS avg_dti_pct,
  ROUND(SUM(CASE WHEN loan_category='Bad' THEN 1 ELSE 0 END)*100.0/COUNT(*),2) AS default_rate_pct,
  COUNT(DISTINCT address_state) AS total_states_covered,
  COUNT(DISTINCT grade) AS total_grades
FROM financial_loan_data;

SELECT * FROM vw_executive_dashboard;

/*-------------------------------- END OF FINANCIAL LOAN ANALYTICS STORY --------------------------------*/