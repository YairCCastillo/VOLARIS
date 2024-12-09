create database SQL_Test;
use SQL_Test;

create table Customer (
Customerid int,
Email varchar(50),
Name varchar(50),
LastName varchar(50),
Gender bool 
);

insert into Customer(Customerid, Email, Name, LastName, Gender )
values (50000279,'email1','TOMAS','RODRIGUEZ SOTO',0),
(50000632,'email2','INGRID PAOLA','RAMIREZ AVILA',1),
(50002844,'email3','ANAPAOLA','MUNOZ ARELLANO',1),
(50003623,'email4','MOISES ALEJANDRO','MENDOZA CASTANON',0),
(50004609,'email5','MARIA LUISA','MENA',1),
(50005402,'email6','FABIOLA','MEDELLIN',1),
(50006907,'email7','GUILLERMO','IGLESIASRIVERO',0),
(50006947,'email8','JOSE','CORDOVA',1),
(50007359,'email9','DANIEL','CANO PALACIOS',1),
(50007487,'email10','ALEJANDRO','BANUELOS CHAO',1);

select * from Customer;

create table Product (
ProductID int,
Name varchar(50),
Datesale date,
Channel varchar(50),
Currency_Code varchar(50),
Amount int, 
Customerid int, 
Stationid int 
);

insert into Product(ProductID,Name,Datesale,Channel,Currency_Code,Amount,Customerid,Stationid)
values (2,'Maleta','2012-01-02','WEB','MEX', 219 ,50007487,43419),
(5,'Maleta extra', '2012-02-23','APP','MEX', 141 ,50007487,34552),
(6,'Cambio de nombre','2012-03-22','APP','USA',21 ,50000279,12957),
(1,'Asiento','2012-05-17','CALLCENTER','MEX', 247 ,50000279,34552),
(5,'Maleta extra','2012-06-17','APP','MEX', 215 ,50002844,86387),
(4,'Mascota abordo','2012-06-17','APP','MEX', 299 ,50004609,86387),
(4,'Mascota abordo','2012-06-21','APP','USA', 80 ,50002844,12957),
(1,'Asiento','2012-07-06','WEB','USA', 30 ,50002844,12957),
(3,'Maleta de mano','2012-07-09','WEB','MEX', 297 ,50006907,86387),
(2,'Maleta','2012-07-19','CALLCENTER','MEX', 334 ,50000632,86387),
(3,'Maleta de mano','2012-07-25','CALLCENTER','USA', 18 ,50003623,15116),
(2,'Maleta','2012-07-30','APP','MEX', 322 ,50000632,43419),
(3,'Maleta de mano','2012-08-14','CALLCENTER','USA', 27 ,50004609,15116),
(1,'Asiento','2012-08-14','CALLCENTER','MEX', 167 ,50006907,34552),
(1,'Asiento','2012-08-14','APP','MEX', 311 ,50002844,34552),
(1,'Asiento','2012-08-14','CALLCENTER','USA', 24 ,50006907,13878),
(7,'Atención personal','2012-08-16','APP','MEX', 84 ,50004609,34552),
(4,'Mascota abordo','2012-08-20','CALLCENTER','MEX', 150 ,50004609,43193),
(5,'Maleta extra','2012-08-25','APP','MEX', 118 ,50007487,43419),
(2,'Maleta','2012-08-26','CALLCENTER','USA', 20 ,50004609,12957),
(7,'Atención personal','2012-09-17','CALLCENTER','USA', 32 ,50006947,15116),
(6,'Cambio de nombre','2012-09-18','CALLCENTER','MEX', 316 ,50007359,43193);

select * from Product;

create table Station(
Stationid int,
Region varchar(10),
City varchar(10)
);

drop table Station;
insert into Station(Stationid, Region, City)
values (43193,'MX','CUU'),
(34553,'MX','GDL'), -- Se cambió a 34553 este Stationid de este renglón debido a que es el mismo que el MX - TGZ, 
(43419,'MX','MEX'), -- Y esto da algunas fallas.
(34552,'MX','TGZ'),
(86387,'MX','MTY'),
(12957,'US','DEN'),
(15116,'US','LAX'),
(13878,'US','ATL');

select * from Station;

-- 1. Name y LastName que representan el top 1 de clientes con más compras en cada región MX y USA
-- MX

select Customer.Name, LastName, Total from Customer 
	join (select *, rank() over (order by Total desc) as orden from (                    
	select Customerid, sum(Amount) as Total from Product join Station on Product.Stationid = Station.Stationid 
					where Region = 'MX' group by Customerid) as PS) as PS1 on PS1.Customerid = Customer.customerid
				where orden = 1; 
-- US

select Customer.Name, LastName, Total from Customer 
	join (select *, rank() over (order by Total desc) as orden from (                    
	select Customerid, sum(Amount) as Total from Product join Station on Product.Stationid = Station.Stationid 
					where Region = 'US' group by Customerid) as PS) as PS1 on PS1.Customerid = Customer.customerid
				where orden = 1; 
                
-- En una sola query da para los 2 resultados
select Name, LastName, Total, Region from (            
select Name, LastName, Total, Region,  rank() over (partition by Region order by Total desc) as rn from Customer join 
	(SELECT Customerid, SUM(Amount) AS Total, Region FROM Product 
			join Station on Product.Stationid = Station.Stationid GROUP BY Customerid, Region) as PS 
            on  PS.Customerid = Customer.customerid) as PS2 where rn=1;

-- 2. ¿Cuáles son los emails de los clientes mujeres con valor de productos comprados mayor a $100?

select Customer.Customerid, email, sum(Amount) from Product join Customer on Product.Customerid = Customer.Customerid 
			where gender = 1 group by Customer.Customerid, email having sum(Amount)>100;
            
-- Otra forma de hacerlo

select P.email from 
			(select email, sum(Amount) as d from Product join Customer 
					on Product.Customerid = Customer.Customerid where gender = 1 group by email) as P where d>100;

-- 3. ¿Cuál es el número de productos, número de clientes y amount total por región? Compartir Query y resultado

select count(distinct Customer.Customerid) as No_clientes, count(distinct Product.Stationid) as No_productos, sum(Amount) as Total, Region from Customer 
			join Product on Product.Customerid = Customer.Customerid 
					join Station on Product.Stationid = Station.Stationid group by Region;