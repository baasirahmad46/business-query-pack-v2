use Northwind
go

-- Q1:Who are our top 5 customers by total revenue?

select top 5 c.CompanyName,round(sum(UnitPrice*Quantity*(1-Discount)),2) [Total Revenue] from customers c inner join orders o on c.customerid = o.customerid 
inner join [Order Details] od on o.orderid = od.orderid
group by c.CompanyName
order by [Total Revenue] desc

--Q2:Which product Categories earn the most revenue?

select c.CategoryName,round(sum(od.UnitPrice*Quantity*(1-Discount)),2) [Total Revenue] from Categories c inner join Products p on c.CategoryID = p.CategoryID 
inner join [Order Details] od on p.ProductID = od.ProductID
group by c.CategoryName
order by [Total Revenue] desc

--Q3:What is our Revenue for each Month?

select year(OrderDate) [Year],month(OrderDate) [Month],round(sum(UnitPrice*Quantity*(1-Discount)),2) [Total Revenue]  from orders o inner join [Order Details] od on o.OrderID = od.OrderID
group by  year(OrderDate),month(OrderDate)
order by  year(OrderDate),month(OrderDate) asc

--Q4:Which 10 products sell the most units?

select top 10 ProductName,sum(Quantity) [Total Units Sold] from products p inner join [Order Details] od on p.ProductID = od.ProductID
group by ProductName
order by [Total Units Sold] desc

--Q5:How much Revenue has each employee (sales rep) generated?

select e.EmployeeID,e.FirstName,e.LastName,round(sum(UnitPrice*Quantity*(1-Discount)),2) [Total Revenue]  from Employees e inner join orders o on e.EmployeeID = o.EmployeeID inner join [Order Details] od on o.OrderID = od.OrderID
group by e.EmployeeID,e.FirstName,e.LastName
order by [Total Revenue] desc

--Q6:Within each category,how do products rank by revenue?

select c.CategoryID,CategoryName,ProductName,round(sum(od.UnitPrice*Quantity*(1-Discount)),2) [Total Revenue],
DENSE_RANK() over (partition by categoryname order by round(sum(od.UnitPrice*Quantity*(1-Discount)),2) desc) [Rank]
from Categories c inner join Products p on c.CategoryID = p.CategoryID inner join [Order Details] od on p.ProductID = od.ProductID
group by c.CategoryID,CategoryName,ProductName
order by CategoryName,Rank

--Q7:What is month over month revenue growth rate?

with MonthlyRevenue as(
select year(OrderDate)[Year],month(orderdate)[Month],round(sum(od.UnitPrice*Quantity*(1-Discount)),2) [Total Revenue] from orders o inner join [order details] od on o.orderid = od.OrderID
group by year(OrderDate),month(orderdate)
)
select *,
lag([Total Revenue]) over ( order by [Year],[Month]) [Previous Month Revenue],
round(([Total Revenue] - lag([Total Revenue]) over ( order by [Year],[Month]))/lag([Total Revenue]) over ( order by [Year],[Month]) * 100.0,2) [Growth %]
from MonthlyRevenue 
order by [Year],[Month]

--Q8:What is the running total of revenue over time?

with MonthlyRevenue as(
select year(OrderDate)[Year],month(orderdate)[Month],round(sum(od.UnitPrice*Quantity*(1-Discount)),2) [Total Revenue] from orders o inner join [order details] od on o.orderid = od.OrderID
group by year(OrderDate),month(orderdate)
)
select *,
sum([Total Revenue]) over ( order by [Year],[Month]) [Running Total]
from MonthlyRevenue
order by [Year],[Month]

--Q9:Which customer's latest order was above their own average order value?

with OrderValues as(
	select o.OrderID,o.CustomerID,o.OrderDate,round(sum(od.UnitPrice*Quantity*(1-Discount)),2) [Ordervalue]
	from orders o inner join [Order Details] od on o.OrderID = od.OrderID
	group by  o.OrderID,o.CustomerID,o.OrderDate
),
	CustomerOrderStatus as(
	select *,avg(ordervalue) over (partition by customerid) [AvgOrderValue],
	row_number() over (partition by customerid order by orderdate desc) [orderRank]
	from OrderValues
)
select orderid,customerid,Ordervalue,AvgOrderValue from CustomerOrderStatus
where orderRank = 1 and Ordervalue > AvgOrderValue

--Q10:Which products are priced above the average price of their category?

with AvgCategoryPrices as(
	select productid,productname,categoryid,unitprice,
	avg(unitprice) over (partition by categoryid) [AvgCategoryPice]
	from Products
)
select * from AvgCategoryPrices where unitprice > [AvgCategoryPice]