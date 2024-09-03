SELECT TOP (1000) [transaction_id]
      ,[transactional_date]
      ,[product_id]
      ,[customer_id]
      ,[payment]
      ,[credit_card]
      ,[loyalty_card]
      ,[cost]
      ,[quantity]
      ,[price]
  FROM [DWcourse].ods.[dest ods]

  --- cleaning and transformaing the ODS dest table 
  select * from staging.dest



select payment
from ods.[dest ods]
where payment is null

update ods.[dest ods] 
set payment = 'Cash On Delivery'
where payment is null


-- create staging table
CREATE TABLE staging.DestStage(
	[transaction_id] [varchar](50) NULL,
	[transactional_date] [varchar](50) NULL,
	FullDate date Null ,
	[product_id] [varchar](50) NULL,
	[customer_id] [varchar](50) NULL,
	[payment] [varchar](50) NULL,
	[credit_card] [varchar](50) NULL,
	[loyalty_card] [varchar](50) NULL,
	[quantity] [varchar](50) NULL,
	[total_cost] float NULL,
	[total_price] float NULL,
	profit float NULL 
)

truncate table staging.DestStage

drop table staging.DestStage

select * from staging.deststage

--- the profit is minus !!!!!!! why ?
select * from ods.[dest ods] 
where transaction_id in (2,26 ,100)

-- the function was made wrong  🤡🤡🤡


------------------------------------- start to make the core layer (dw) after finishing the stadge layer 
create schema dw


--testing date dimension

select * from staging.deststage

SELECT distinct fullDate
FROM staging.DestStage


select fulldate , datepart(dw , fulldate)
from staging.DestStage


truncate table staging.datedim

drop table staging.datedim

select fulldate , datepart(yyyy , fulldate) as Year , 
datepart(mm , fulldate) as Month ,
datepart(dd , fulldate) as Day  ,
datepart(dw , fulldate) as DayOfWeek  , 
datename(dw , fulldate) as DayName , 
datename(mm , fulldate) as MonthName ,
concat('Q' , datepart(QUARTER ,fulldate)) as quarter   ,
datepart(dayofYear ,fulldate) as dayofYear , 
case when 
	datepart(dd , fulldate) = 6 then 'No' 
	else 'Yes' end 
	as IsWeekend
from staging.DestStage
group by fulldate
order by dayofYear 

CREATE TABLE dw.DateDim (
    [DateKey] int , 
    [FullDate] nvarchar(10),
    [Year] int,
    [Month] int,
    [Day] int,
    [dayofYear] int,
    [MonthName] nvarchar(30),
    [quarter] varchar(13),
    [DayName] nvarchar(30),
    [DayOfWeek] int,
    [IsWeekend] varchar(3)
)

select * from dw.DateDim
-- payment dimension 


select payment , loyalty_card
from staging.deststage
group by payment , loyalty_card

--there is an issue here 
--that the payment date is null so I will fix 
--this making the null values with cash on dilvery

select * from dw.paymentdim


-- product table stadge 
select  ROW_NUMBER() over(order by product_id ) as Product_PK , product_id
from [ods].[dest ods]
group by product_id
order by Product_PK 


select * from dw.productDim 


--- customer tabel

create table dw.CustomerDim (
	customer_PK BIGINT primary key,
	customer_id varchar(100) ,
	credit_card varchar(200) , 
	StartDate datetime , 
	EndDate datetime
)

select row_number() over(order by customer_id) as customer_PK , customer_id , credit_card 
from staging.deststage
group by customer_id, credit_card


select * from staging.customerDim



--- fact transaction :  


SELECT *
FROM [DWcourse].[dw].[TranactionFact]

select *
from [dw].[TranactionFact]