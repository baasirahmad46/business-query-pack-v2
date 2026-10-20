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