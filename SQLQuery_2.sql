
/*1 Create a list of all customer contact names that includes the title, first name,
 middle name (if any), last name, and suffix (if any) of all customers. */
 select *
 from saleslt.customer
 select concat_ws(' ', firstname, middlename,lastname)
 , suffix 
 from SalesLT.customer

 /*2.Retrieve customer names and phone numbers 
o   Each customer has an assigned salesperson. You must write a query to create a call sheet that lists: 
•   The salesperson 
•   A column named CustomerName that displays how the customer contact should be greeted (for example, Mr Smith) 
•   The customer’s phone number. */

select salesperson, title + ' ' + lastname as customername, phone
, concat_ws(' ', title, lastname) as customername_1
from saleslt.customer

/*3: As you continue to work with the Adventure Works customer data, you must create queries for reports that have been requested by the sales team. 
Retrieve a list of customer companies 
o   You have been asked to provide a list of all customer companies in the format Customer ID : Company Name - for example, 78: Preferred Bikes. 
*/
select try_cast(customerid as varchar) + ': ' + companyname as customer_company
from saleslt.customer

/*4:Retrieve a list of sales order revisions 
o   The SalesLT.SalesOrderHeader table contains records of sales orders. You have been asked to retrieve data for a report that shows: 
•   The sales order number and revision number in the format () – for example SO71774 (2). 
*/

select salesordernumber + '(' + try_cast(revisionnumber as varchar) + ')'
 from saleslt.SalesOrderHeader
--------------------------------------------------------------------------------------
 /*1.1 Retrieve a list of cities 
Initially, you need to produce a list of all of you customers' locations. 
Write a Transact-SQL query that queries the SalesLT.Address table and retrieves the values for City and StateProvince, removing duplicates ,
 then sorts in ascending order of StateProvince and descending order of City.*/

select distinct city, stateprovince
from saleslt.address
order by stateprovince asc, city desc

/*
1.2 Retrieve the heaviest products information 
Transportation costs are increasing and you need to identify the heaviest products. Retrieve the names, weight of the top ten percent of products by weight.  
Then, add new column named Number of sell days (caculated from SellStartDate and SellEndDate) of these products (if sell end date isn't defined then get Today date)  
-- Your code here */

select top (10) percent name
        , weight 
        , datediff(day, sellstartdate, isnull(sellenddate, CURRENT_TIMESTAMP)) as numerosalesdays
        from saleslt.product 
        order by weight desc

/* 2.1 Filter products by color, size and product number 
Retrieve the ProductID, ProductNumber and Name of the products, that must have Product number begins with 'BK-' followed by any character other than 'T' 
and ends with a '-' followed by any two numerals.  
And satisfy one of the following conditions: 
•   color of black, red, or white  
•   size is S or M and  */

select productid, productnumber, name 
from saleslt.product 
where productnumber like 'bk-%[^t]-[0-9][0-9]'
and(color in ('black', 'red', 'white')
or size in('s','m'))

/*2.2.Retrieve the product ID, product number and 2 new columns:   
•   ProductName is generated by the string preceded by the '-' character (example: HL Road Frame)  
•    GroupSize follows conditions:   
- Size is 'S' or less than 43 --> 'small'  
- Size is 'M' or 'L' or from 43 to 57 --> 'medium'  
- Size is 'XL' or larger than 57 --> 'big'  
- NULL --> 'no size' */

select productid, productnumber 
, iif( charindex( '-',name) = 0,name,
    rtrim(left(name,charindex( '-',name) -1))) as productname  
, case when size = 'S' or try_cast(size as int) < 43 then 'small'
when size in('m','l') or try_cast(size as int) between 43 and 57 then 'medium'
when size ='xl' or try_cast(size as int) >57 then 'big'
else 'no size' end as groupsize
from saleslt.product

/*3.1. From DimEmployee table, extract user name of each employee from loginID . 
For example: LoginID = adventure-works\jun0  then get Username = jun0 */

select substring(loginid, charindex('\',loginid) + 1, len(loginid)) as user_name
from dimemployee

/*3.2. From FactInternetSales get all records that have Color of Product equal to "red" (using IN operator)*/

select *
from factinternetsales
where productkey in(
    select productkey
    from dimproduct
    where color ='red'
)

/*3.3. From DimEmployee get EmployeeKey, Full Name (combine FirstName, MiddleName and LastName) of all employees that have 8th character (from left) 
in FirstName equal to "a" (2 solutions)  
--Your code here  */
--way 1
select employeekey, CONCAT_WS(' ', firstname, middlename, lastname) as username
from dimemployee 
where firstname like '_______a%'

--way 2
select EmployeeKey
, CONCAT_WS(' ', firstname, middlename, lastname) as fullname
from dimemployee
where substring(firstname, 8,1) = 'a'
--------------------------------------------------------------------------------------

/*1.1  As an initial step towards generating the invoice report, 
write a query that returns the company name from the SalesLT.Customer table,
 and the sales order ID and total due from the SalesLT.SalesOrderHeader table. */

 select companyname
 , salesorderid 
 from saleslt.salesorderheader as a
left join saleslt.customer as b
on a.customerid=b.customerid

/*1.2. Retrieve Sales Information with Product (in slide)  
o   Write a query using SalesLT.SalesOrderHeader, SalesLT.Product and SalesLT.SalesOrderDetail display SalesOrderID, SalesOrderDetailID, ProductID, ProductName, OrderDate, LineTotal, SubTotal */

select a.SalesOrderID, SalesOrderDetailID, c.ProductID, c.Name, OrderDate, LineTotal, SubTotal
from SalesLT.SalesOrderHeader as a 
left join SalesLT.SalesOrderDetail as b
on a.salesorderid=b.salesorderid
left join SalesLT.Product as c 
on b.productid = c.productid

/* 2.1 A sales employee has noticed that Adventure Works does not have address information for all customers.
 You must write a query that returns a list of customer IDs, company names, contact names (first name and last name), 
and phone numbers for customers with no address stored in the database. */

select customerid,companyname, CONCAT_ws(' ', firstname,lastname) as contact_names , phone
from saleslt.customer

/*2.2.A sales manager needs a list of ordered product with more information.  
You must write a query that returns a list of product name (is generated by the string preceded by the '-' character (example: HL Road Frame)), 
only started selling in 2006, Product model name contains "Road" and CategoryName contains "Bikes" and  ListPrice value with integer part equal to 2243 */

select iif(charindex('-',sp.name)=0, sp.name, rtrim(left(sp.name,charindex('-',sp.name)-1))) as productname,
sellstartdate, spm.name, spc.name
from saleslt.product as sp 
left join saleslt.productmodel as spm 
on sp.productmodelid=spm.productmodelid
left join saleslt.productcategory as spc
on  sp.productcategoryid=spc.productcategoryid 
where year(sellstartdate) =2006
and spm.name like '%road%' 
and spc.name like '%bikes%'
and floor(listprice) =2443

/*3.1 From dbo.DimProduct, dbo.DimPromotion, dbo.FactInternetSales,  
Write a query display ProductKey, EnglishProductName which has discount percentage >= 20%*/ 
select fis.productkey, englishproductname, discountpct 
from factinternetsales as fis
left join dimproduct as dp
on fis.productkey=dp.productkey
left join dimpromotion as dpm 
on fis.promotionkey=dpm.promotionkey 
where discountpct >= 0.2

/*3.2. From FactInternetSales and FactResellerSale, DimProduct x   
Find all SalesOrderNumber  from 2 Fact tables which sales product that have Name contains 'Road' in name and Color is Yellow */
select* from dimproduct

--1
select salesordernumber 
from factinternetsales as fis 
left join dimproduct as dp 
on fis.productkey=dp.productkey
where englishproductname like'%road%'
and color ='yellow'
union
select salesordernumber 
from factresellersales as frs 
left join dimproduct as dp 
on frs.productkey=dp.productkey
where englishproductname like'%road%'
and color ='yellow'

--2
with a as ( select productkey,salesordernumber from factinternetsales as fis
union select productkey,salesordernumber from factresellersales as frs)

select distinct a.salesordernumber 
from a 
left join dimproduct as dp 
on a.productkey = dp.productkey 
where dp.englishproductname like'%road%'
and color  = 'yellow'
--------------------------------------------------------------------------------------
/*Adventure Works products each have a standard cost price that indicates the cost of manufacturing the product,
 and a list price that indicates the recommended selling price for the product. This data is stored in the SalesLT.Product table. 
 Whenever a product is ordered, the actual unit price at which it was sold is also recorded in the SalesLT.SalesOrderDetail table. 
 You must use subqueries to compare the cost and list prices for each product with the unit prices charged in each sale. 
 
 1.Retrieve Products with a list price of 100 or more that have been sold for less than 100. 
o   Retrieve the product ID, name, and list price for each product where the list price is 100 or more, and the product has been sold for less than 100. */ 
--giá bán >100 mà giá thực <100
select *
from saleslt.product

select productid,name,listprice 
from saleslt.product 
where listprice >=100
and productid in(
    select productid 
    from saleslt.salesorderdetail
    where unitprice < 100
)
/*2.1 Retrieve the cost, list price, and average selling price for each product 
o   Retrieve the product ID, name, cost, and list price for each product along with the average unit price for which that product has been sold. */
--way1
select sod.productid, name , listprice , avg(unitprice)
from saleslt.salesorderdetail as sod
left join saleslt.product as sp
on sp.productid = sod.productid
where sod.productid in(
    select productid 
    from saleslt.product)
group by sod.productid, name , listprice
order by productid
--way2
SELECT p.ProductID
, p.Name
, p.StandardCost
, p.ListPrice,
     (SELECT AVG(o.UnitPrice)
      FROM SalesLT.SalesOrderDetail AS o
      WHERE p.ProductID = o.ProductID) AS AvgSellingPrice
FROM SalesLT.Product AS p
WHERE ProductID IN (Select ProductID from SalesLT.SalesOrderDetail)
ORDER BY p.ProductID;

/*2.2 Retrieve products that have an average selling price that is lower than the cost. 
o Filter your previous query to include only products where the cost price is higher than the average selling price. */

SELECT p.ProductID, p.Name, p.StandardCost, p.ListPrice,
    (SELECT AVG(o.UnitPrice)
    FROM SalesLT.SalesOrderDetail AS o
    WHERE p.ProductID = o.ProductID) AS AvgSellingPrice
FROM SalesLT.Product AS p
WHERE StandardCost >
    (SELECT AVG(od.UnitPrice)
    FROM SalesLT.SalesOrderDetail AS od
    WHERE p.ProductID = od.ProductID)
ORDER BY p.ProductID;

/*3.1. From FactResellerSales, DimReseller  
Write a query display SalesOrderNumber, SalesOrderLineNumber, ResellerName, Phone, SalesAmount where:  
BusinessType là “Warehouse” or “Specialty Bike Shop”.  
And CarrierTrackingNumber starts with 2 characters, ends with 2 numbers and the 7th character equals to “C” or “F”.  */

select SalesOrderNumber, SalesOrderLineNumber, ResellerName, Phone, SalesAmount
from factresellersales as frs 
left join dimreseller as dim 
on frs.resellerkey = dim.resellerkey 
where carriertrackingnumber like '[a-z][a-z]____[c;f]%[0-9][0-9]' and
--way1 
businesstype in ('warehouse','specialty bike shop')
--way2 
(businesstype = 'warehouse' or businesstype ='specialty bike shop')

/* 3.2. 
From DimDepartmentGroup, Write a query display DepartmentGroupName and 
their parent DepartmentGroupName */  
select dp.DepartmentGroupName
, dim.DepartmentGroupName as parent_DepartmentGroupName
from DimDepartmentGroup as dp 
left join DimDepartmentGroup as dim 
on dp.parentDepartmentGroupkey=dim.departmentgroupkey

/*3.3.  
From FactFinance, DimOrganization, DimScenario 
Write a query display OrganizationKey, OrganizationName, Parent OrganizationKey, Parent OrganizationName, Amount 
where ScenarioName is 'Actual' */  

select fact.OrganizationKey, dim.OrganizationName, dim1.OrganizationName as ParentOrganizationName, dim.ParentOrganizationKey, Amount
from factfinance as fact 
left join dimorganization as dim 
on fact.organizationkey=dim.organizationkey 
left join dimscenario as ds 
on fact.scenariokey=ds.scenariokey
left join dimorganization as dim1
on dim.parentorganizationkey = dim1.organizationkey
where scenarioname = 'actual'

/* 3.4.From FactInternetSales, DimProduct  
Display ProductKey, EnglishProductName of products 
which never have been ordered and  
ProductCategory is 'Bikes' */

select ProductKey, EnglishProductName
from dimproduct as dp
left join dimproductsubcategory as dimp 
on dp.productsubcategorykey=dimp.productsubcategorykey
left join dimproductcategory as dim1
on dimp.productcategorykey = dim1.productcategorykey
where englishproductcategoryname = 'bikes'
and productkey not in (
    select productkey
    from factinternetsales
)

/*3.5.  
From dbo.FactInternetSales, dbo.FactInternetSalesReason, DimSalesReason, DimProduct, DimProductCategory 
Write a query displaying the 
SalesOrderNumber, SalesOrderLineNumber, ProductKey, Quantity, EnglishProductName, Color, EnglishProductCategoryName 
where SalesReasonReasonType is 'Marketing'  
and EnglishProductSubcategoryName contains 'Tires' */ 

select distinct fis.SalesOrderNumber, fis.SalesOrderLineNumber, fis.ProductKey, EnglishProductName, Color, EnglishProductCategoryName,orderquantity
from factinternetsales as fis 
left join factinternetsalesreason as fis1
on fis.salesordernumber=fis1.salesordernumber
left join dimproduct as dp 
on fis.productkey=dp.productkey 
left join dimsalesreason as dim 
on fis1.salesreasonkey=dim.salesreasonkey 
left join dimproductsubcategory as dimp 
on dp.productsubcategorykey=dimp.productsubcategorykey
left join dimproductcategory as dim1
on dimp.productcategorykey = dim1.productcategorykey
where dim.SalesReasonReasonType = 'Marketing'  
and EnglishProductSubcategoryName like '%Tires%'
--------------------------------------------------------------------------------------
/* Ex 1: From FactInternetSales, FactInternetSalesReason, DimSalesReason.  
Caculate total SalesAmount by each SalesReasonName. Display only ReasonName have total SalesAmount > 5000000*/  
 

 select distinct salesreasonname, sum(salesamount) as a 
 from factinternetsales as fis 
join factinternetsalesreason as fis1 
 on fis.salesordernumber=fis1.salesordernumber 
join dimsalesreason as dim 
 on fis1.salesreasonkey = dim.salesreasonkey
 group by salesreasonname
 having sum(salesamount) > 5000000

-- 
/* 2.2.Retrieve products that have an average selling price that is lower than the cost. 
Filter your previous query to include only products 
where the cost price is higher than the average selling price. */ 

select sod.productid, name , listprice ,standardcost, avg(unitprice)
from saleslt.salesorderdetail as sod
left join saleslt.product as sp
on sp.productid = sod.productid
where sod.productid in (
    select productid
    from saleslt.product
)
group by sod.productid, name , listprice,standardcost
HAVING AVG(UnitPrice) < StandardCost 

/* Ex 3: From FactInternetSale, DimProduct, 
Write a query that create new Color_group, if product color is 'Black' or 'Silver' leave 'Basic', else keep Color. 
Then Caculate total SalesAmount by new Color_group */ 

select case 
        
    when color in ('black','silver') 
                                then 'basic' ELSE color end as color_group
, sum(salesamount)
from factinternetsales  as fis 
left join dimproduct as dp 
on fis.productkey = dp.productkey
group by (case when color in ('black','silver') then 'basic' ELSE color end)

/* Ex 4: From the FactInternetsales and Resellersales tables, retrieve saleordernumber, productkey,  
orderdate, shipdate of orders in October 2011, along with sales type ('Resell' or 'Internet')*/

select salesordernumber, productkey, orderdate, shipdate, 'internet' as salestype
from factinternetsales as fis
where year(orderdate)=2011
and month(orderdate)=10
union
 select salesordernumber, productkey, orderdate, shipdate, 'reseller' as salestype
from factresellersales as frs
where year(orderdate)=2011
and month(orderdate)=10

/* Ex 5: From database  
Display ProductKey, EnglishProductName, Total OrderQuantity (caculate from OrderQuantity in Quarter 3 of 2013)  
of product sold Customers/Resellers live in London for each Sales type ('Resell' and 'Internet') */
SELECT fis.ProductKey, EnglishProductName, sum(orderquantity), 'internet' as sales_type 
from factinternetsales as fis 
left join dimproduct as dp 
on fis.productkey=dp.productkey
left join dimcustomer as dm 
on fis.customerkey=dm.customerkey
left join dimgeography as do 
on dm.geographykey=do.geographykey
where year(orderdate) =2013
and month(orderdate) in (7,8,9)
and city ='london'
group by fis.ProductKey, EnglishProductName
UNION
SELECT frs.ProductKey, EnglishProductName, sum(orderquantity), 'reseller' as sales_type 
from factresellersales as frs 
left join dimproduct as dp 
on frs.productkey=dp.productkey
left join dimreseller as dm1
on frs.resellerkey=dm1.resellerkey
left join dimgeography as do 
on dm1.geographykey=do.geographykey
where year(orderdate) =2013
and month(orderdate) in (7,8,9)
and city ='london'
group by frs.ProductKey, EnglishProductName

/* Ex 6 (hard): From FactInternetSales table, write a query that retrieves the following data:  
Total orders each month of the year (using OrderDate) 
Total orders each month of the year (using ShipDate) 
Total orders orders each month of the year (using DueDate) */ 

with a as(
select
 year(orderdate) as yearorder
, month(orderdate) as monthorder
, count(salesordernumber) as total_order
from factinternetsales
group by year(orderdate), month(orderdate))
,
 b as (select
 year(shipdate) as yearship 
, month(shipdate) as monthship
, count(salesordernumber) as total_order_ship
from factinternetsales
group by year(shipdate), month(shipdate))
,
c as (select
 year(duedate) as yeardue
, month(duedate) as monthdue
, count(salesordernumber) as total_order_due
from factinternetsales
group by year(duedate), month(duedate))

select COALESCE(YearOrder, YearShip, YearDue) as Year,
COALESCE(MonthOrder, MonthShip, MonthDue) as Month,
a.total_order, b.total_order_ship, c.total_order_due
from a 
full join b
on a.yearorder=b.yearship
and a.monthorder=b.monthship
full join c 
on a.yearorder=c.yeardue
and a.monthorder=c.monthdue 
order by year, month

/* Ex 7 (hard): From database, retrieve total SalesAmount monthly of internet_sales and reseller_sales.  
The result should contain the following columns: Year, Month, Internet_Sales, Reseller_Sales 
Gợi ý: Tính doanh thu từng tháng ở mỗi bảng độc lập FactInternetSales và FactResllerSales bằng sử dụng CTE */ 

with a as(
select YEAR(orderdate) as year_num
        , month(orderdate) as month_num 
        , sum(salesamount) as 'internet_sales'
from factinternetsales
group by  YEAR(orderdate), month(orderdate))
, b as (
select YEAR(orderdate) as year_num
        , month(orderdate) as month_num 
        , sum(salesamount) as 'reseller_sales'
from factresellersales
group by  YEAR(orderdate), month(orderdate))
select a.year_num, a.month_num, internet_sales, reseller_sales
from a full join b 
on a.year_num =b.year_num
and a.month_num = b.month_num
order by year_num, month_num
