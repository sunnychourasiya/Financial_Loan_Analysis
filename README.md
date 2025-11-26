# Financial Loan Data Analysis Project  
*A Complete End-to-End Business Intelligence, Risk Analytics & Portfolio Monitoring Solution*
---

<p>
  <img src="https://img.shields.io/badge/Python-3.9-blue" />
  <img src="https://img.shields.io/badge/MySQL-8.0-orange" />
  <img src="https://img.shields.io/badge/PowerBI-Dashboard-yellow" />
  <img src="https://img.shields.io/badge/Project-Complete-brightgreen" />
</p>

# Executive Summary  
This project delivers a production-ready **Financial Loan Analytics Platform** designed to support **credit risk assessment, portfolio monitoring, and strategic decision-making** across lending institutions such as banks, NBFCs, and fintech companies.

Using Python, MySQL, and Power BI, the solution transforms raw loan-level data into a structured analytical ecosystem that enables:

- Early identification of high-risk borrower segments
- Monitoring repayment behaviour and delinquency trends
- Portfolio performance evaluation across geographies, credit grades, and income groups
- KPI-driven insights for underwriting, capital allocation, and recovery strategies 
- The solution transforms raw loan data into a complete analytics ecosystem involving:

The platform replicates real-world workflows used in financial analytics, incorporating data engineering, KPI modeling, and enterprise-grade business intelligence dashboards.

---

# Key Highlights  
  
- Full end-to-end pipeline integrating **Python → SQL Modeling → Power BI Dashboards**
- 38,000+ records processed across 24 loan and borrower attributes
- 15+ core business KPIs including Default Rate, Recovery %, ROI, and Loss Metrics
- 5 interactive Power BI dashboards covering portfolio health, credit grades, borrower risk, and trends
- Designed with a clear focus on **business value, analytical accuracy, and decision enablement**

---

## 📑 Table of Contents

| No. | Section | Link |
|-----|---------|------|
| 1 | Project Overview | [Go to Section](#project-overview) |
| 2 | Business Problem | [Go to Section](#business-problem) |
| 3 | Objectives | [Go to Section](#business-objectives) |
| 4 | Technologies Used | [Go to Section](#technologies-used) |
| 5 | Repository Structure | [Go to Section](#repository-structure) |
| 6 | Dataset Description | [Go to Section](#dataset-description) |
| 7 | Python Data Cleaning & Preprocessing | [Go to Section](#python-data-cleaning--preprocessing) |
| 8 | SQL KPI Modeling | [Go to Section](#sql-kpi-modeling) |
| 9 | Power BI Dashboards | [Go to Section](#power-bi-dashboards) |
|10 | Insights and  Findings  | [Go to Section](#insights-and-findings) |
|11 | Business Impact | [Go to Section](#business-impact) |
|12 | Challenges & Learnings | [Go to Section](#challenges--learnings) |
|13 | Conclusion | [Go to Section](#conclusion) |

---

# Project Overview  
This project presents a complete Financial Loan Analytics workflow that helps lending institutions analyze borrower characteristics, credit risk, and overall portfolio performance.

The system integrates:
- Data engineering — cleaning, preprocessing, and preparation
- Analytical modeling — KPI-based SQL views and trend analyses
- Business intelligence — interactive dashboards and insights

It integrates **data engineering, BI development, and analytical modeling** to deliver insights for financial decision-makers.

---

# Business Problem  
Banks and lending companies manage large loan portfolios with diverse customers. They face challenges such as:

- Identifying high-risk borrowers early
- Understanding repayment patterns
- Analyzing portfolio profitability
- Evaluating loan performance across states and demographics
- Tracking disbursement and collection trends  

These complexities require a structured analytics solution driven by data accuracy, domain-specific KPIs, and clear visual intelligence.

---

## Business Objectives  

- Develop a clean, standardized dataset ready for analytical modeling
- Build key business KPIs capturing risk, profitability, and performance
- Create SQL-based analytical views for trends and segmentation
- Deliver end-to-end Power BI dashboards for executives and risk teams
- Generate actionable insights to strengthen credit underwriting and portfolio strategy 

---

## Technologies Used  

| Technology | Purpose |
|------------|---------|
| **Python (Pandas, NumPy)** | Data cleaning & preprocessing |
| **MySQL 8.0** | KPI modeling & analytical queries |
| **Power BI** | Dashboard development |
| **Excel/CSV** | Data ingestion & storage |

---

## Repository Structure  
```
Financial-Loan-Analysis/
│
├── data/
│   ├── Clean_Financial_Loan_Data.csv
│   └── financial_loan.csv
│
├── python/
│   └── Bank_loan.ipynb
│
├── sql/
│   └── Financial_loan_data_sql_script.sql
│
├── dashboard/
│   └── Financial_Loan_Dashboard.pbix
│
├── docs/
│   └── Terminologies in Data.docx
│
└── README.md
```

---

## Dataset Description  

The dataset used in this project contains detailed information on loan applications, borrower profiles, credit attributes, and repayment performance. It includes a total of **38,576 records** across **24 columns**.

**Rows:** 38,576  
**Columns:** 24  

### Data Dictionary  

| Column Name | Description | Data Type |
|------------|-------------|-----------|
| `id` | Unique loan identifier | INT |
| `address_state` | State where the borrower resides | VARCHAR |
| `application_type` | Type of loan application (Individual/Joint) | VARCHAR |
| `emp_length` | Borrower’s employment duration | VARCHAR |
| `emp_title` | Borrower’s job title | VARCHAR |
| `grade` | Loan credit grade | VARCHAR |
| `home_ownership` | Home ownership category | VARCHAR |
| `issue_date` | Loan issue date | VARCHAR |
| `last_credit_pull_date` | Most recent credit check date | VARCHAR |
| `last_payment_date` | Most recent payment date | VARCHAR |
| `loan_status` | Current status of the loan | VARCHAR |
| `next_payment_date` | Scheduled next payment date | VARCHAR |
| `member_id` | Borrower membership/identifier | INT |
| `purpose` | Purpose of taking the loan | VARCHAR |
| `sub_grade` | Detailed credit grade classification | VARCHAR |
| `term` | Loan repayment term | VARCHAR |
| `verification_status` | Verification status of borrower details | VARCHAR |
| `annual_income` | Borrower’s annual income | FLOAT |
| `dti` | Debt-to-Income ratio | FLOAT |
| `installment` | Monthly installment amount | FLOAT |
| `int_rate` | Interest rate assigned to the loan | FLOAT |
| `loan_amount` | Principal loan amount | INT |
| `total_acc` | Total number of credit accounts | INT |
| `total_payment` | Total amount paid to date | INT |


---

## Python Data Cleaning & Preprocessing  
**File:** `python/Bank_loan.ipynb`

Key Preprocessing Steps:

- Import & explore raw dataset  
- Handling missing, inconsistent, and invalid values
- Standardizing categorical fields
- Converting interest rate, income, DTI, and numeric formats
- Parsing date fields and normalizing date formats
- Creating derived attributes for analysis
- Export cleaned dataset → `Clean_Financial_Loan_Data.csv`  

---

### SQL KPI Modeling  
**Script:** `sql/Financial_loan_data_sql_script.sql`

In this stage, SQL is used to calculate core business KPIs and prepare analytical structures.

#### ✔ KPIs Developed  
- Good vs Bad Loan Ratio  
- Default Rate (%)  
- Recovery Rate (%)  
- ROI % (Return on Investment)  
- Monthly Funded vs Received Amount  
- Grade-wise Loss and Profitability  
- Purpose-wise Loan Performance  

#### ✔ Analytical Views Created  
- Monthly loan trend view  
- Geography-wise portfolio performance  
- Grade and sub-grade insights  
- Borrower risk segmentation (income, DTI, ownership)  


## Sample SQL Query  

### 🔹 Monthly Trend Analysis  
```sql
SELECT 
  DATE_FORMAT(issue_date, '%Y-%m') AS month,
  SUM(loan_amount) AS funded_amount,
  SUM(total_payment) AS received_amount
FROM financial_loan_data
GROUP BY month
ORDER BY month;
```
---


## Power BI Dashboards  
**File:** `dashboard/Financial_Loan_Dashboard.pbix`

### 📈 Dashboard Summary

| Dashboard | Purpose | Key Insights |
|----------|----------|--------------|
| **Executive Summary** | Portfolio overview & KPIs | ROI, Recovery %, Defaults, Trends |
| **Geographic Performance** | State-wise performance analysis | Heatmaps, recovery gaps, regional default patterns |
| **Credit Grade Analysis** | Credit grade & sub-grade evaluation | Grade-wise ROI, losses, risk clusters |
| **Borrower Risk** | Identifying borrower-level risks | High DTI cases, low income borrowers, anomalies |
| **Portfolio Trend** | Long-term performance monitoring | YOY default rate, ROI trends, purpose trends |

---

## Dashboard Screenshots  
(Add your images using this format)  
```
<img src="Images/Executive_Summary.png" width="450">
<img src="Images/Geographic_Dashboard.png" width="450">
<img src="Images/Grade_Analysis.png" width="450">
<img src="Images/Risk_Analysis.png" width="450">
<img src="Images/Trend_Analysis.png" width="450">
```

---

### Insights and Findings  

### 🔹 Portfolio Performance  
- Loan disbursements show steady growth over time.  
- Recovery rates vary significantly across states.  
- Certain months reveal a noticeable gap between funded and received amounts.

### 🔹 Credit Risk Findings  
- Borrowers with **DTI > 25%** display higher default probability.  
- Credit grades **E, F, and G** account for a major share of losses.  
- Income and employment stability strongly affect repayment behaviour.

### 🔹 Trend Observations  
- Seasonal fluctuations are visible in defaults and repayments.  
- Debt consolidation is the most frequent loan purpose.  
- ROI varies month-to-month and across regions.

---

##  Business Impact

This analytical system empowers financial institutions to:

- Identify and reduce high-risk borrower segments
- Enhance underwriting with KPI-driven insights
- Strengthen recovery strategies using regional analysis
- Monitor portfolio health through automated dashboards
- Optimize capital allocation using grade-level profitability trends

---

## Challenges & Learnings

- Handling inconsistent date formats
- Standardizing categorical and text-based attributes
- Designing scalable KPI logic for SQL models
- Building dynamic and optimized Power BI measures
- Ensuring data accuracy across ETL → SQL → BI

---

### Conclusion  

This project demonstrates a complete, production-style Financial Loan Analytics Platform that integrates:

- **Data Engineering**  
- **KPI Design and Development**  
- **SQL-Based Analytical Processing**  
- **Business Intelligence Dashboard Creation**  
- **Risk and Portfolio Performance Analysis**  

The solution delivers actionable insights that support financial institutions in **risk assessment**, **operational monitoring**, and **strategic decision-making**.

---

## ⭐ Support  
If you like this project, please ⭐ star the repository — your support motivates future work!
