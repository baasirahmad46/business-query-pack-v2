# Business Query Pack v2

10 real business questions answered with SQL on the Northwind database (Microsoft SQL Server).

Each query is written the way a junior data analyst would answer a manager's question: the question comes first, then the query, then a plain-English explanation of what the result shows.

## Dataset

**Northwind** is a sample database for a trading company that sells food products. It has customers, orders, products, categories and employees, with orders from July 1996 to May 1998.

**Tables used:** `Customers`, `Orders`, `[Order Details]`, `Products`, `Categories`, `Employees`

**Revenue formula used throughout:**

```
revenue = UnitPrice * Quantity * (1 - Discount)
```

The `UnitPrice` always comes from `[Order Details]`, because that is the price actually charged on each order line.

## How to run it

1. Install SQL Server and SQL Server Management Studio (SSMS).
2. Create an empty database: `CREATE DATABASE Northwind;`
3. Select the `Northwind` database in SSMS, then open and run `instnwnd.sql` (it creates the tables and loads the data but does not create the database itself).
4. Open `queries.sql` and run each query (highlight one and press F5).

## Queries

### Basics: JOIN, GROUP BY, aggregates

**Q1. Who are our top 5 customers by total revenue?**
Joins `Customers`, `Orders` and `[Order Details]`, adds up revenue per customer and keeps the top 5.
*Result:* QUICK-Stop is the top customer with about 110,277 in revenue, followed by Ernst Handel and Save-a-lot Markets.

**Q2. Which product categories earn the most revenue?**
Joins `Categories`, `Products` and `[Order Details]` and totals revenue per category.
*Result:* Beverages lead with about 267,868, followed by Dairy Products. Grains/Cereals earn the least of the 8 categories.

**Q3. What is our revenue for each month?**
Groups revenue by year and month so that the same month in different years is kept separate.
*Result:* 23 months of data from July 1996 to May 1998. The last month (May 1998) is much lower, which suggests the data stops partway through that month.

**Q4. Which 10 products sell the most units?**
Sums the quantity sold per product and keeps the top 10.
*Result:* Camembert Pierrot sells the most with 1,577 units.

**Q5. How much revenue did each employee generate from the orders they handled?**
Joins `Employees`, `Orders` and `[Order Details]` and groups by employee.
*Result:* Margaret Peacock generated the most (about 232,891) and Steven Buchanan the least (about 68,792).

### Window functions

**Q6. Within each category, how do products rank by revenue?**
Uses `DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC)` so the ranking restarts at 1 in every category.
*Result:* In Beverages, Cote de Blaye ranks first with about 141,397 in revenue, far ahead of the second product.

**Q7. What is the month-over-month revenue growth rate?**
Uses a CTE for monthly revenue, then `LAG()` to fetch the previous month and calculate the percentage change.
*Result:* Growth swings a lot from month to month, for example -8.53% in August 1996 and +35.41% in January 1997. The first month has no growth value because there is no month before it.

**Q8. What is the running total of revenue over time?**
Uses `SUM() OVER (ORDER BY year, month)` on the monthly revenue CTE to show revenue accumulated so far.
*Result:* The running total starts at about 27,862 (July 1996) and grows every month, showing how total revenue builds up over time.

### CTEs combined with window functions

**Q9. Which customer's latest order was above their own average order value?**
Uses two chained CTEs. The first calculates the total value of every order. The second uses `AVG() OVER (PARTITION BY customer)` for each customer's average and `ROW_NUMBER()` to mark their most recent order. The final query keeps only the customers whose latest order beat their own average.
*Result:* These customers spent more than usual in their latest order, which makes them good candidates for sales follow-up. For example, ALFKI's latest order was worth 933.50 against an average of about 712.17, and ERNSH (Ernst Handel) placed a 5,218 order against an average of about 3,495.83.

**Q10. Which products are priced above the average price of their category?**
Uses a CTE with `AVG(UnitPrice) OVER (PARTITION BY category)` to attach each category's average price to every product, then keeps the products priced above it. This query uses the list price from the `Products` table.
*Result:* Premium products stand out clearly. Cote de Blaye costs 263.50 against a Beverages average of about 37.98, and Sir Rodney's Marmalade costs 81.00 against a Confections average of about 25.16.

## SQL concepts demonstrated

- INNER JOINs across 2 to 3 tables
- GROUP BY with aggregate functions (SUM, ROUND)
- Date functions (YEAR, MONTH)
- Window functions: DENSE_RANK, ROW_NUMBER, LAG, AVG OVER, running SUM
- CTEs (`WITH ... AS`), including two chained CTEs in one query
- Partitioning window functions with `PARTITION BY`

## Repository contents

| File | Purpose |
|---|---|
| `instnwnd.sql` | Microsoft's script that creates and loads the Northwind tables |
| `queries.sql` | All 10 business questions with their solutions |
| `README.md` | This file |

## Tools

Microsoft SQL Server, SQL Server Management Studio (SSMS), Git and GitHub Desktop.
