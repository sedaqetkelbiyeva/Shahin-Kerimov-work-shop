/*Task 1
Employees və departments cədvəlindən hər bir department-də
 employee_id-si palindrom olan işçilərin sayını tapın. 
Sütunlar: Department_name, Count_od_palindrome_id 
Palindrom tərsinə yazılışı eyni ədəd olan ədədə deyilir. 
(Məsələn, 121)
Sətir sayı: 5*/

select d.DEPARTMENT_NAME,
count(e.EMPLOYEE_ID) Count_od_palindrome_id
from hr.departments d
join  hr.employees e
on e.department_id=d.department_id
where to_char( e.EMPLOYEE_ID)= reverse(to_char(e.EMPLOYEE_ID))
group by d.DEPARTMENT_NAME ;

/*Task 2
Bazar ertəsi işə girən işçilərin orta maaşını tapın. 
Sətir sayı: 1*/

select 
avg(salary)
from hr.employees
where to_char(HIRE_DATE,'d')=02 ;

/*Task 3
Locations cədvəlində street_addrees sütununda ilk simvolun rəqəm olub
 olmamasına görə qruplaşma edin
Nəticədə ilk simvolu rəqəm olan sətirlərin sayı və ilk simvolu 
rəqəm olmayan sətirlərin sayı gəlsin.Sətir sayı: 2*/


select 
case when translate(substr(STREET_ADDRESS,1,1),'*0123456789','*') is null then 'reqem'
else 'simvol'
end simvol_tipi,
count(*) sayi
from hr.locations
group by case when translate(substr(STREET_ADDRESS,1,1),'*0123456789','*') is null then 'reqem'
else 'simvol'
end ;

select 
count(*)sayi,
case when regexp_like(STREET_ADDRESS,'^[0-9]') then 'reqemdir'else 'simvoldur' end tip
from hr.locations
group by case when regexp_like(STREET_ADDRESS,'^[0-9]') then 'reqemdir'
else 'simvoldur' end ;


/*Task 4
İşə girdiyi ay 20 gündən çox işləyən işçilərin adını, soyadını, 
vəzifəsini gətirən sorğu yazın. Sətir sayı: 31*/

select 
FIRST_NAME,
LAST_NAME,
JOB_ID,
HIRE_DATE
from hr.employees
where (last_day (HIRE_DATE)-HIRE_DATE)+1>=20

select 
FIRST_NAME,
LAST_NAME,
JOB_ID
from hr.employees
where extract(day from HIRE_DATE)<=10;

SELECT first_name,
       last_name,
       job_id
FROM hr.employees
WHERE LAST_DAY(hire_date) - hire_date > 20;

/*Task 5
Menecerin adını, qarşısında onun işçilərinin adını vergüllə ayrılmış 
siyahısnı gətirən sorğu yazın.  
Sətir sayı: 18 */

select distinct m.first_name manager,
listagg(e.FIRST_NAME,',') within group  (order by e.first_name) isciler
from hr.employees e 
join hr. employees m 
on e.manager_id=m.employee_id
group by m.first_name ;

/*Task 6
4-dən çox işçisi olan departamentlərin adını  çıxaran sorğu yazın. 
Sətir sayı: 5 */

select d.department_name,
count(e.first_name) isci_sayi
from hr. employees e
join hr.departments d 
on e.department_id= d.department_id
group by d.department_name
having count(e.first_name)>4 ;

/*Task 7
Hər bir department_id üzrə işçilərin ödədiyi komissiya məbləğinin
 cəmini tapın. Sətir sayı: 12 */

select
DEPARTMENT_ID,
sum(COMMISSION_PCT)
from hr.employees
group by department_id ;

/*Task 8
Employees cədvəlindən 2-ci ən yüksək maaşı  tapın. 
Sətir sayı: 1 */

select * from(select salary,
dense_rank()over(order by salary desc) rn
from hr.employees)
where rn=2 and rownum=1;

/*
Task 9
30-cu department-dəki hamıdan yüksək maaş alan işşiləri gətirən sorğu 
yazın.Sətir sayı: 10 */

select *
from hr.employees 
where salary > (select max(salary)
from hr.employees
where department_id=30);

/*Task 10
2006-ci ildə 5-dən çox işçi götürən departmentlərin   götürdükləri
 işçilərin sayını (hər bir department üzrə ayrılıqda) tapın.  
Sətir sayı: 2 */

select DEPARTMENT_ID,
count(*) isci_sayi
from hr.employees
where extract(year from hire_date)=2016
group by department_id
having count(*)>5 ;


