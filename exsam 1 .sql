
             variant A

/*1.Ad və soyadı eyni hərflə bitməyən işçilərin təkrarlanmayan 
department_id siyahısını tapın.  --12 sətir*/

select distinct DEPARTMENT_ID
 from hr.employees
where substr(lower(first_name),-1)<>substr(lower(last_name),-1);

/*2.Locations cədvəlindən 4-cü hərfdən sonra r hərfi rast gəlinən 
şəhər adlarını tapın. --6 sətir*/
SELECT city 
FROM hr.locations 
WHERE city LIKE '____%r%';

/*3.Job_history cədvəlindən start_Date və ya  end_date tarixi 
 2-ci yarımildə olan sətirləri tapın.  --10 sətir*/

 select start_date,
 end_date 
 from hr.JOB_HISTORY
 where extract(month from start_date)>=7 or
 extract(month from end_date)>=7;

 /*4.Maaşı 12000-dən az olan işçilərin adını,soyadını, job_id,
  manager_id və işə girdiyi ayın nömrəsini tapın. 
Nəticə  manager_id-yə çoxdan aza sıralansın. --99 sətir*/

select 
FIRST_NAME,
LAST_NAME,
job_id,
MANAGER_ID,
to_char(HIRE_DATE,'mm') ay
from hr.employees
where salary <12000
order by manager_id desc;

/*5.Jobs cədvəlindən max_Salary və min_salary fərqi 15000-dən çox 
olan sətirləri çıxaran sorğu yazın. -- 2 sətir */
select *
from  hr.Jobs
where max_salary-min_salary >15000 ;

/*6.Hər bir işçinin email addressini aşağıdakı şablona uyğun çıxarın.
 --107 sətir
Steven's email address is SKING@gmail.com */

select FIRST_NAME||q'[s'email adres is']'||' '||EMAIL||'@gmail.com' email
from hr.employees;

/*7.7.Departments cədvəlində manager_id-si  boş olmayan və
 department_id-si 4-ə tam bölünən 
departmentlerin  department_id və department name-lərini hamısını
 kiçik hərflə gətirən sorğu yazın.  --5 sətir*/

select DEPARTMENT_ID,
lower(DEPARTMENT_NAME)
from hr.departments
where manager_id is not null 
and mod(department_id,4)=0;

/*8.Locations cədvəlindən postal_code sütunundan boşluğa görə bir 
hissəli postal_code-ları tapan sorğu yazın. 
Nümunə: 00989.     --19 sətir*/

select POSTAL_CODE
from hr.locations
where instr(POSTAL_CODE,' ')=0;

/*9.L.Locations cədvəlində ya postal_code,ya city, ya da state_province sutunlarindan biri boş olan sətirləri gətirin.
Ekrana location_id,street_address ve nn_address sutunlarını çıxarın
nn_address sütunu belə formalaşır: state_province,city,postal_code
 sütunlarından qeyd olunan ardıcıllıqda 
ilk hansında məlumat varsa o gəlsin ,əgər hər
 3 - ü də boşdursa 'məlumat tapılmadı' qeyd olunsun.  --6 sətir
*/

select LOCATION_ID,
STREET_ADDRESS,
coalesce(STATE_PROVINCE,city,POSTAL_CODE,'melumat tapilmadi') nn_address
from hr.locations 
where postal_code is null or city is null or state_province is null;

/*10.Şirkətdə maaş artım edilməsi ilə bağlı qərar imzalanıb. 
Belə ki, maaşı 7000-ə qədər  və ya  FI_ACCOUNT vəzifəsində işləyən
 əməkdaşlara 13 faiz artım, maaşı 7000-dən böyük əməkdaşlara isə 10
  faiz artım olunmalıdır. 
Buna uyğun select yazın.
Nəticə yekun artim məbləğinə əsasında azdan çoxa düzülsün. --107 sətir
*/

select 
salary,
JOB_ID,
case when salary<7000 or job_id='FI_ACCOUNT' then salary*13/100
when salary>7000 then salary*10/100 end artim
from hr.employees
order by artim asc;



                             Variant B 

   /*1.Ad və soyadı eyni hərflə bitən işçilərin təkrarlanmayan
    department_id siyahısını tapın.  —4 sətir*/      

    select distinct DEPARTMENT_ID
      from hr.employees                    
    where substr(FIRST_NAME,-1)=substr(LAST_NAME,-1);

    /*2.Locations cədvəlindən 6-cı hərfdən sonra o hərfi rast gəlinən
     şəhər adlarını tapın. —7 sətir*/
     select 
     city
     from hr.locations
     where city like '______%o%';

     /*3.Job_history cədvəlindən start_date və ya  end_date tarixi 
      1-ci yarımildə olan sətirləri tapın.  —8 sətir*/
      select 
      START_DATE,
      END_DATE      
      from hr.Job_history
      where extract(month from start_date)<=6 or
      extract(month from end_date)<=6 ;

      /*4.Maaşı 12000-dən az olan işçilərin adını,soyadını, 
      job_id, manager_id və işə girdiyi ayın nömrəsini tapın. 
Nəticə  manager_id-yə çoxdan aza sıralansın. --99 sətir
*/

select first_name,
last_name ,
job_id,
MANAGER_ID,
to_char(HIRE_DATE,'mm')
from hr.employees
where salary<=12000
order by manager_id desc;

/*5.Jobs cədvəlindən max_Salary və min_salary fərqi 15000-dən çox 
olan sətirləri çıxaran sorğu yazın. -- 2 sətir */
select *
from hr.Jobs
where max_Salary-min_salary >=15000;

/*6.Hər bir işçinin email addressini aşağıdakı şablona uyğun çıxarın.
 --107 sətir
Steven's email address is SKING@gmail.com */

select 
FIRST_NAME||q'['s email address is ]'|| email||'@gmail.com'
from hr.employees;

/*7.7.Departments cədvəlində manager_id-si  boş olmayan və 
department_id-si 4-ə tam bölünən 
departmentlerin  department_id və department name-lərini hamısını 
kiçik hərflə gətirən sorğu yazın.  --5 sətir */

select DEPARTMENT_ID,
lower(DEPARTMENT_NAME)
from hr.departments 
where manager_id is not null and mod(department_id,4)=0;

/*8.Locations cədvəlindən postal_code sütunundan boşluğa görə bir
 hissəli postal_code-ları tapan sorğu yazın. Nümunə: 00989.     --19 sətir
*/
select 
POSTAL_CODE,
instr(postal_code,' ',1)
from hr.locations
where instr(postal_code,' ',1)=0;

/*9.Locations cədvəlində ya postal_code,ya city, ya da state_province
 sutunlarindan biri boş olan sətirləri gətirin.Ekrana location_id,
 street_address ve nn_address sutunlarını çıxarın nn_address
  sütunu belə formalaşır: state_province,city,postal_code
   sütunlarından qeyd olunan ardıcıllıqda 
ilk hansında məlumat varsa o gəlsin ,əgər hər 3 - ü də boşdursa
 'məlumat tapılmadı' qeyd olunsun.  --6 sətir
*/

select LOCATION_ID,
STREET_ADDRESS ,
coalesce(STATE_PROVINCE,city,POSTAL_CODE,'melumat tapilmadi') nn_address
from hr.locations
where  postal_code is null or 
city is null
 or state_province  is null ;

 /*10.Şirkətdə maaş artım edilməsi ilə bağlı qərar imzalanıb. 
Belə ki, maaşı 7000-ə qədər  və ya  FI_ACCOUNT vəzifəsində işləyən
 əməkdaşlara 13 faiz artım, maaşı 7000-dən böyük əməkdaşlara isə 10 faiz artım olunmalıdır. 
Buna uyğun select yazın.
Nəticə yekun artim məbləğinə əsasında azdan çoxa düzülsün. --107 sətir
*/

select salary,
job_id,
case when salary < 7000 or job_id = 'FI_ACCOUNT' then salary *13/100 
when  salary >= 7000 then salary * 10/100 
 end  as artim
from hr.employees  ;