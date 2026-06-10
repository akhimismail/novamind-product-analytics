# NovaMind AI — Product Analytics & User Retention

**Tools:** PostgreSQL · Excel · Power BI  
**Domain:** SaaS · Product Analytics · User Retention

---

## What This Project Is About

NovaMind AI is a fictional B2B SaaS company selling AI productivity tools to small businesses. I built this project around a problem that's very common in early-stage SaaS — the numbers look fine on the surface (users are signing up) but something is quietly wrong underneath (they're not staying).

The brief I gave myself: figure out where users are dropping off, why, and what the business should do about it before a Series A pitch.

---

## The Data

- Sourced from Kaggle's E-Commerce Customer Churn dataset
- 5,630 users, 20 columns
- Rebranded to fit a SaaS context
- 7 columns had missing values — handled with median imputation before analysis

I kept both the raw and cleaned versions in the data folder so the cleaning process is visible.

---

## Data Cleaning

Before running any analysis I checked for missing values. Seven columns came back with gaps ranging from 251 to 307 rows — under 10% each, so I filled them with column medians rather than dropping rows.

| Column | Missing |
|---|---|
| Tenure | 264 |
| Hours on App | 255 |
| Order Amount Hike | 265 |
| Warehouse to Home | 251 |
| Days Since Last Order | 307 |
| Coupon Used | 256 |
| Order Count | 258 |

Median was the right call here because several of these columns are skewed — using the mean would have pulled imputed values toward outliers.

---

## SQL Analysis

I wrote 8 queries in PostgreSQL to answer specific business questions. The full file is in `/sql/novamind_analysis.sql`.

| # | Question | Finding |
|---|---|---|
| 1 | What is the overall churn rate? | **16.84%** — more than 3x the healthy SaaS benchmark |
| 2 | Which city markets are losing the most users? | City Tier 1 accounts for **56%** of all churned users |
| 3 | When in the lifecycle does churn peak? | **41.86%** of churned users left within their first 3 months |
| 4 | Does satisfaction score predict churn? | Score 5 users still churning — points to a value gap, not a service gap |
| 5 | How much does a complaint change churn probability? | Complained users churn at significantly higher rates |
| 6 | Is low engagement driving churn? | Mid-engagement users (2-3 hrs/day) make up the bulk of churn |
| 7 | Where is revenue most at risk? | City Tier 1 carries the highest revenue exposure |
| 8 | Who are the highest-value users we already lost? | Top 10 identified for retrospective CS analysis |

---

## Dashboard

Built in Power BI with two pages — an executive overview and a deeper engagement and revenue breakdown.

### Page 1 — Executive Overview
![Dashboard Page 1](dashboard/dashboard_page1.png)

### Page 2 — Engagement & Revenue
![Dashboard Page 2](dashboard/dashboard_page2.png)

---

## What I Found

The churn problem at NovaMind isn't random — it has a clear shape.

Almost 42% of churned users left within the first 3 months. That's not a retention problem, that's an activation problem. Users are signing up, not finding value fast enough, and leaving before they ever become loyal.

The satisfaction score finding surprised me. Users giving the product a 5 out of 5 were still churning. That usually means the product is well-liked but not essential — users enjoy it when they use it, they just don't build a habit around it.

City Tier 1 is where the most damage is happening — both in volume and revenue terms. Any retention campaign should start there.

---

## Recommendations

**In the next 30 days:**
- Build a structured onboarding flow targeting the first 90 days — that's the window where nearly half of churn happens
- Create an escalation path for complaint tickets — these users are the highest churn risk and the most recoverable with the right response

**In the next 90 days:**
- Track activation milestones at day 30, 60, and 90 — users who hit these milestones churn at near-zero rates
- Focus retention spend on City Tier 1 first — highest volume, highest revenue at risk

**Longer term:**
- Investigate the satisfaction-churn paradox — if happy users are still leaving, the issue is likely pricing, habit formation, or competitive alternatives
- Build a mid-engagement nurture track for 2-3 hrs/day users before they go quiet

---

## Repository Structure

```
novamind-product-analytics/
├── data/
│   ├── novamind_users.csv
│   └── novamind_users_clean.csv
├── sql/
│   └── novamind_analysis.sql
├── dashboard/
│   ├── dashboard_page1.png
│   ├── dashboard_page2.png
│   └── novamind_powerbi.pbix
└── README.md
```

---

## Tools Used

| Tool | Purpose |
|---|---|
| PostgreSQL + pgAdmin | All SQL analysis |
| Excel | EDA and pivot tables |
| Power BI | Two-page executive dashboard |

---

**Connect:** [LinkedIn](https://www.linkedin.com/in/akhimismail) · [GitHub](https://github.com/akhimismail)
