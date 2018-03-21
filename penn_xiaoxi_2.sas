*import data;
proc import datafile='/folders/myfolders/data folder/paexercise.csv'
out=xx.pa
dbms=csv;
run;

* pre-view;
proc contents data=xx.pa;run;
proc sort data=xx.pa  ;by  descending Pr1;   
proc print data=xx.pa (obs=100) ;
where PR1='740'; run;
proc freq data=xx.pa;
table att_id;


* 1.number of doctors deliver babies n= 176;
data xx.pa1;
set xx.pa;
id_unique = _N_;  
RUN;

proc sort data=xx.pa1;
by  id_unique id att_id RACE SEX;
run;

proc transpose data=xx.pa1 out=xx.pa2 (rename=(COL1=PR _NAME_=PR_name));
by id_unique id att_id RACE SEX;
var PR1 PR2 PR3;
run;

proc sql;
create table xiaoxi1 as
select  count( distinct att_id) as total_count_deliver,*
from xx.pa2
where PR IN ('720', '721', '724', '726', '728', '729', '731', '733', '736', '738',
 '740', '741', '742', '744') and att_id is not null;
quit;


*2.	Average number of deliveries and c-sections per doctor avg=15.170454545;
*row=2695;
proc sql ;
create table xiaoxi2 as
select distinct att_id,id,race,count_per_doctor,pr,PR_name
from(select  count(distinct Id) as count_per_doctor,att_id,RACE,id,pr,PR_name
from xiaoxi1
where ATT_ID is not null
group by Att_id);
quit;

proc sql;
create table xiaoxi2_2 as
select avg(count_per_doctor) as avg_deli, *
from (select distinct att_id, count_per_doctor  from xiaoxi2);
quit;

*c-section   avg=6.7867647059 ;
proc sql;
create table xiaoxi2_3 as
select count(distinct id) as count_per_doctor_c,id,att_id
from xiaoxi2
where pr in ('740','741','742','744')
group by Att_id;
quit;

proc sql;
create table xiaoxi2_4 as
select *,avg(count_per_doctor_c) as avg_deli_c,att_id
from (select distinct att_id, count_per_doctor_c from xiaoxi2_3);
quit;

*3. Positive skewed distribution;
title 'Positive skewed distribution';
ods graphics on;
proc univariate data= xiaoxi2_2;
   histogram count_per_doctor / normal odstitle = title  ;
  run;
  
*4 The percentage of mothers delivering babies who are black weight=0.0378277154 #of B= 101 ;
proc sql;
create table xiaoxi4 as
select count(DISTINCT(ID)) as id_b, count(DISTINCT(ID))/id_b_all as weight,*
from(
select count(DISTINCT(ID))  as id_b_all,* from xiaoxi2)
where Race='B';
quit;

*5. high volume doctors ;
data xiaoxi5;
set xiaoxi2;
if count_per_doctor>15 then vol='high';
if count_per_doctor<=15 then vol='low';
run;

* caculate black patient percentage of per doctor;
proc sql;
create table xiaoxi5_2 as
select distinct att_id, vol,race,weight_b
from(
select count(DISTINCT(ID)) as id_b, count(DISTINCT(ID))/id_b_all as weight_b,*
from(
select count(DISTINCT(ID))  as id_b_all, *from xiaoxi5 
group by att_id)
where Race='B'
group by att_id);
quit;

proc sql;
create table xiaoxi5_3 as
select avg(weight_b) as weight_vol,vol
from xiaoxi5_2
group by vol;
quit;

* final;
data xiaoxi_final;
merge xiaoxi1(keep=total_count_deliver ) xiaoxi2_2(keep=avg_deli)
 xiaoxi2_4(keep=avg_deli_c)  xiaoxi4(keep=weight)  xiaoxi5_3 ;
run;
proc print data=xiaoxi_final (obs=2); 
run;

