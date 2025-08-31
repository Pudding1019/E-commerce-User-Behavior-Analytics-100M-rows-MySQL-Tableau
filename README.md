## Project Introduction

**Live Dashboard:** https://public.tableau.com/app/profile/aiyi.sun7073/viz/Userbehavioranalysis/Dashboard1?publish=yes

[![Dashboard Preview](figures/dashboard_overview.png)](https://public.tableau.com/app/profile/aiyi.sun7073/viz/Userbehavioranalysis/Dashboard1?publish=yes)
<!-- 将上面的图片替换为你仓库中的实际路径，如 figures/dashboard_overview.png -->

### Background
This repository analyzes large-scale e-commerce behavior data to answer core product and growth questions—how users are acquired, retained, and converted; which paths lead to purchase; and which items/categories truly drive value. The analysis is implemented on **Google Cloud SQL (MySQL)** and surfaced via a **Tableau** dashboard for non-technical stakeholders.

### Dataset
We use the public **Taobao User Behavior (UserBehavior)** dataset, originally released by Alibaba Tianchi and mirrored on Kaggle.

- **Kaggle mirror:** https://www.kaggle.com/datasets/marwa80/userbehavior  
- **Official Tianchi page:** https://tianchi.aliyun.com/dataset/649?lang=en-us
- **Scale:** ~100,150,807 interaction records from ~987,994 users and ~4,162,024 items, across **9,439 categories**  
- **Time window:** **2017-11-25 → 2017-12-03** (9 consecutive days)  
- **Schema (5 columns):**
  - `user_id` – anonymized user identifier  
  - `item_id` – anonymized item identifier  
  - `category_id` – item category identifier  
  - `behavior_type` – one of `pv` (view), `cart` (add to cart), `fav` (favorite), `buy` (purchase)  
  - `timestamp` – Unix time (seconds)

### What this MySQL project does
Built on **Google Cloud SQL (MySQL)**, the project delivers an end-to-end analytical layer for large-scale user behavior:

1. **Data cleaning & modeling**  
   Standardize fields and types, **deduplicate** (same user × item × timestamp), derive calendar fields (date/hour), define analysis windows, and add task-oriented indexes; curate **reusable SQL views/wide tables** for BI.

2. **Eight metric modules (ready-to-query)**  
   - **Acquisition:** daily **PV/UV** and **PV per UV** (traffic quality & reach)  
   - **Retention:** **D1 / D7** retention, sliceable by category/segment/channel  
   - **Time-series:** hourly/daily/weekly profiles for pv/cart/fav/buy (peaks & rhythms)  
   - **Conversion (funnel):** **pv → cart → buy** step conversion & drop-off diagnostics  
   - **Behavior paths:** session-level **top paths** and **exit nodes** (e.g., `pv→pv→bounce`, `pv→cart→pv→buy`)  
   - **RFM model:** **Recency / Frequency / Monetary** segmentation for high-value & growth cohorts  
   - **Item heat:** exposure/engagement hotness to spot traffic magnets vs. engagement drivers  
   - **Item conversion:** view-to-purchase by item/category/price band for assortment & shelf tuning

### Outputs
- **SQL artifacts:** schema, cleaning scripts, and metric views (plug-and-play for BI)  
- **Dashboard (Tableau):** live link above; see preview image for a quick glance





