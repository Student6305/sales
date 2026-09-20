# Sales and Profit Analysis Across Regions and Categories

## 1. Dataset

Dataset: Superstore retail dataset

File used: `train.csv`

The dataset contains 9,994 rows and 21 columns.

The data was loaded into a local SQLite database named `superstore.db`.

The main table is `orders`.

---

## 2. Methodology

The analysis was performed using SQL as the primary analytical engine.

SQL was used for:

* Aggregation
* GROUP BY analysis
* HAVING filters
* CASE WHEN categorisation
* Ranking
* Window functions
* Date calculations
* Year-over-year calculations
* CTE-based analysis

Python was used only to:

* Connect to SQLite
* Execute SQL queries
* Load summarized results using `pd.read_sql()`
* Display query results
* Create visualizations

The complete SQL queries are stored in `queries.sql`.

---

## 3. Database Schema

```sql
CREATE TABLE orders (
    row_id INTEGER,
    order_id TEXT,
    order_date DATE,
    ship_date DATE,
    ship_mode TEXT,
    customer_id TEXT,
    customer_name TEXT,
    segment TEXT,
    country TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    region TEXT,
    product_id TEXT,
    category TEXT,
    sub_category TEXT,
    product_name TEXT,
    sales NUMERIC,
    quantity INTEGER,
    discount NUMERIC,
    profit NUMERIC
);
```

---

## 4. SQL Analysis

### Q1 — Table Profile

The orders table contains 9,994 records. The query also calculates the number of distinct customers and products, as well as the earliest and latest order dates.

### Q2 — NULL Analysis

A NULL-value check was performed across all 21 columns to identify missing data in the orders table.

### Q3 — Duplicate Order Lines

Duplicate order lines were checked using the combination of `order_id` and `product_id` as the natural key.

### Q4 — Shipping Delay

Average shipping time was calculated for each shipping mode using SQLite's `julianday()` date function.

### Q5 — Regional and Category Profitability

Sales, profit, and profit margin were calculated for each combination of region, category, and sub-category. Results were ordered by total profit.

### Q6 — Top and Bottom Sub-Categories

Sub-categories were ranked by total profit using the `RANK()` window function.

The five highest-profit sub-categories were:

| Rank | Sub-Category | Total Profit |
| ---: | ------------ | -----------: |
|    1 | Copiers      |   $55,617.82 |
|    2 | Phones       |   $44,515.73 |
|    3 | Accessories  |   $41,936.64 |
|    4 | Paper        |   $34,053.57 |
|    5 | Binders      |   $30,221.76 |

The five lowest-profit sub-categories were:

| Rank | Sub-Category | Total Profit |
| ---: | ------------ | -----------: |
|    1 | Tables       |  -$17,725.48 |
|    2 | Bookcases    |   -$3,472.56 |
|    3 | Supplies     |   -$1,189.10 |
|    4 | Fasteners    |      $949.52 |
|    5 | Machines     |    $3,384.76 |

### Q7 — Discount Band Analysis

Orders were divided into four discount bands using `CASE WHEN`:

* 0%
* 1–20%
* 21–40%
* 41%+

The results were:

| Discount Band | Order Count | Average Profit | Total Profit |
| ------------- | ----------: | -------------: | -----------: |
| 0%            |       2,644 |         $66.90 |  $320,987.60 |
| 1–20%         |       2,507 |         $26.50 |  $100,785.47 |
| 21–40%        |         400 |        -$77.86 |  -$35,817.47 |
| 41%+          |         737 |       -$106.71 |  -$99,558.59 |

### Q8 — Year-over-Year Sales

Annual sales and year-over-year changes were calculated using the `LAG()` window function.

| Year | Total Sales |  YoY Change | YoY Change % |
| ---: | ----------: | ----------: | -----------: |
| 2014 | $484,247.50 |           — |            — |
| 2015 | $470,532.51 | -$13,714.99 |       -2.83% |
| 2016 | $609,205.60 | $138,673.09 |       29.47% |
| 2017 | $733,215.26 | $124,009.66 |       20.36% |

### Q9 — Loss-Making Sub-Categories

Three sub-categories recorded negative total profit:

| Sub-Category | Total Sales | Total Profit | Revenue Share |
| ------------ | ----------: | -----------: | ------------: |
| Tables       | $206,965.53 |  -$17,725.48 |         9.01% |
| Bookcases    | $114,880.00 |   -$3,472.56 |         5.00% |
| Supplies     |  $46,673.54 |   -$1,189.10 |         2.03% |

### Q10 — Top 10 Customers

The top 10 customers were identified based on lifetime profit. The query also calculated order count, lifetime sales, and average order value for each customer.

---

## 5. Business Insights

### Insight 1 — Discount and Profit

According to Q7, the 0% discount band generated the highest average profit at $66.90 and total profit of $320,987.60. Profitability decreased as discounts increased: the 21–40% band had an average profit of -$77.86, while the 41%+ band had an average profit of -$106.71 and a total loss of $99,558.59.

### Insight 2 — Loss-Making Sub-Categories

According to Q9, three sub-categories were loss-making: Tables, Bookcases, and Supplies. Tables recorded the largest loss at -$17,725.48 and accounted for 9.01% of total revenue. Bookcases had a loss of -$3,472.56 and represented 5.00% of total revenue, while Supplies had a loss of -$1,189.10 and represented 2.03% of total revenue.

### Insight 3 — Sub-Category Profitability

According to Q6, Tables had the lowest total profit at -$17,725.48, followed by Bookcases with -$3,472.56. Copiers generated the highest total profit at $55,617.82, followed by Phones at $44,515.73.

### Insight 4 — Sales Growth

According to Q8, annual sales decreased by 2.83% in 2015, from $484,247.50 in 2014 to $470,532.51. Sales then increased by 29.47% in 2016 to $609,205.60 and by a further 20.36% in 2017 to $733,215.26.

---

## 6. Visualizations

The notebook contains three visualizations:

1. **Profit by Sub-Category**

   * Compares total profit across sub-categories.
   * Loss-making sub-categories are highlighted separately.

2. **Average Profit by Discount Band**

   * Compares average profit across the four discount bands.
   * Shows the relationship between discount levels and average profit in the dataset.

3. **Yearly Sales Trend with YoY Change**

   * Shows annual sales from 2014 to 2017.
   * YoY percentage changes are displayed alongside the yearly sales trend.

---

## 7. Project Files

The project contains:

* `train.csv` — original Superstore dataset
* `superstore.db` — SQLite database
* `superstore_analysis.ipynb` — Python notebook containing SQL execution, results, and visualizations
* `queries.sql` — complete set of SQL analysis queries
* `note.md` — project methodology, results, and business insights
