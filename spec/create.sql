-- Test against mysql
-- use run the specs you must first run this against mysql
-- mysql -u root < create.sql

drop database if exists ar_exporter_test;

create database ar_exporter_test;
	
use ar_exporter_test;	
	
create table people_data
(
	first varchar(50),
	last varchar(50),
	age		  int
);

insert into people_data (first, last, age)
values ('doug', 'tolton', '33'),
       ('torrey', 'tolton', '31'),
       ('lisa', 'tolton', null);