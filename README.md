# Hospital Admissions & Discharge Analytics | SQL Server

![SQL Server](https://img.shields.io/badge/SQL-SQL%20Server-blue)
![SSMS](https://img.shields.io/badge/Tool-SSMS-lightgrey)
![Domain](https://img.shields.io/badge/Domain-Healthcare%20Operations-green)
![Focus](https://img.shields.io/badge/Focus-Data%20Cleaning%20and%20KPIs-orange)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

> Turning 15,757 raw hospital admission records into a clean, reusable dataset and the KPIs managers use to plan beds, staffing, and discharge capacity.

**Links:** [Dataset (Kaggle)](https://www.kaggle.com/datasets/ashishsahani/hospital-admissions-data/data?select=HDHI+Admission+data.csv) · [SQL Script](sql/hdhi_admissions_analysis.sql)

## 1. Executive Summary

Hospital managers can't plan capacity from duplicated, unvalidated records. I took 15,757 raw admission records (January 2017 to December 2019) in SQL Server, removed 1,217 duplicates (7.7%) with a window function, and published a reusable view (`VW_AdmissionData`) that every KPI query runs on. After cleaning, the hospital recorded **12,608 discharges** with an average stay of **6.55 days** and about **11.9 discharges per day**.

**Key outcome:** Discharge demand is driven by older patients (59% are 60+) and peaks midweek (Wednesday, 1,947 discharges vs 1,486 on Sunday), which gives operations teams concrete inputs for bed and staffing plans.

## 2. Business Problem

**Stakeholder:** Hospital Operations Manager / Bed Management Team

**Question:** "How many patients are we discharging, how long do they stay, who are they, and when do discharges happen?"

## 3. Data & Tools

- **Dataset:** [HDHI Admission data (Kaggle)](https://www.kaggle.com/datasets/ashishsahani/hospital-admissions-data/data?select=HDHI+Admission+data.csv), 15,757 rows, January 2017 to December 2019
- **Database:** Microsoft SQL Server, managed in SSMS
- **Techniques:** CTEs, `ROW_NUMBER() OVER (PARTITION BY)`, reusable VIEW, `CASE` with `CROSS APPLY`, `SUM() OVER` for percentage share, `DATEDIFF` / `DATENAME`, type casting

## 4. Methodology

**Phase 1: Data cleaning**

- Flagged duplicate admissions on `MRD_No + D_O_A + D_O_D` using `ROW_NUMBER()` and kept one record per group, ordered by a unique ID so results are repeatable
- Removed records with a missing patient ID
- Published `VW_AdmissionData` as the single source of truth
- Validated the result: **15,757 raw rows, 14,540 clean rows, 1,217 duplicates removed (7.7%)**

**Phase 2: KPI analysis**

- Total discharges, average daily discharge rate (discharges per calendar day), average length of stay
- Segmentation by age group (pediatric under 18, adult 18-59, senior 60+) and gender, with percentage share
- Discharge distribution by day of week

## 5. Key Findings

1. **Total discharges:** 12,608 out of 14,540 clean admissions. The rest ended in other outcomes.
2. **Average daily discharges:** 11.87 per day (12,607 dated discharges over 1,062 days).
3. **Average length of stay:** 6.55 days.
4. **Age mix:** seniors (60+) are 59.0% of discharges (7,439), adults 40.6% (5,122), and pediatric 0.4% (47).
5. **Gender split:** 63.3% male (7,977) and 36.7% female (4,631).
6. **Discharges by weekday:**

| Day | Discharges | Share |
|---|---|---|
| Sunday | 1,486 | 11.8% |
| Monday | 1,785 | 14.2% |
| Tuesday | 1,773 | 14.1% |
| Wednesday | 1,947 | 15.4% |
| Thursday | 1,880 | 14.9% |
| Friday | 1,891 | 15.0% |
| Saturday | 1,845 | 14.6% |

Wednesday is the busiest day and Sunday the quietest, about 24% lower. Saturday stays close to weekday levels, so the dip is mostly a Sunday effect.

## 6. Recommendations

1. **Plan bed capacity and discharge support around senior patients,** who make up nearly 6 in 10 discharges.
2. **Staff discharge support (pharmacy, billing, transport) for the midweek peak,** and keep Saturday covered, since it is nearly as busy as a weekday.
3. **Track average length of stay monthly** (baseline 6.55 days) as a bed-turnover KPI.
4. **Keep de-duplication in the pipeline.** Duplicates were 7.7% of raw rows and would have inflated every KPI.

## 7. Limitations

- 1 discharge record has no discharge date, so it is excluded from date-based KPIs (daily rate and weekday distribution), which use 12,607.
- Only 47 pediatric discharges, too few for reliable conclusions about that group.
- Single hospital, so results may not generalize.
- KPIs cover discharged patients only. Other outcomes are excluded by design.
- Descriptive analysis only, with no causal claims.

## 8. How to Run

1. Import the CSV into SQL Server as `[HDHI Admission data]`
2. Open `sql/hdhi_admissions_analysis.sql` in SSMS
3. Run the view first, then each KPI query one block at a time

## 9. SQL Skills Demonstrated

`CTEs` · `ROW_NUMBER()` · `Deduplication` · `VIEW Creation` · `CASE + CROSS APPLY` · `SUM() OVER` · `DATEDIFF / DATENAME` · `Type Casting` · `Data Quality Checks`

**Author:** Fatima Binta Mohammed | Healthcare Data Analyst | [LinkedIn](https://www.linkedin.com/in/fatima-binta-mohammed-094bb2414)