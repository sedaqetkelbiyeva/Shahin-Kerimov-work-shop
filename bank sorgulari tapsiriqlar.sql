/*1. Ən çox əməliyyat edən 10 müştəri*/  
   
  with   count_cust as(
   select c.customer_id , 
   count(t.amount) say
from customers  c
left join accounts  a on c.customer_id=a.customer_id
join transactions t on a.account_id=t.account_id
group by c.customer_id
order by say desc
)
select * from count_cust 
where  rownum <11 ;

/*2. Hər müştərinin ümumi dövriyyəsi*/
select c.full_name ,
sum(t.amount) umumi_mebleg
from customers  c
left join accounts  a on c.customer_id=a.customer_id
join transactions t on a.account_id=t.account_id
group by c.full_name;

/*3. Son əməliyyatı tap*/
select  
max(txn_date)
 from transactions;
                     
  /*sonuncu emeliyyat eden musteriler*/                   
                     select * from transactions
where txn_date=(select 
                  max(txn_date)
                     from transactions)

/*4. Hər müştərinin son əməliyyatı*/

select * from (
select c.customer_id,
txn_date ,
row_number()over(partition by c.customer_id order by t.txn_date desc) rn
from customers  c
left join accounts  a on c.customer_id=a.customer_id
join transactions t on a.account_id=t.account_id)
where rn=1;

/*5. Hər ay üzrə əməliyyat məbləği*/

select to_char(txn_date,'yyyy-mm') ay,
sum(amount)
from transactions
 group by  to_char(txn_date,'yyyy-mm')
 order by ay ;
 
 select trunc(txn_date,'mon') ay,
sum(amount)
from transactions
 group by   trunc(txn_date,'mon')
 order by ay;

/*6. Balansı orta balansdan yüksək olan hesablar*/
select * from accounts
where balance>(select round(avg(balance),2) 
from accounts);

/*7. Hər müştərinin hesab sayı*/

select c.full_name,
count(*) hesab_sayi
from customers c
join accounts a on c.customer_id=a.customer_id
 group by c.full_name  ;
 
 /*lk 3 ən aktiv müştəri*/ 
  select * from (
 select c.full_name,
 count(t.amount) say
 --dense_rank()over(order by  count(t.amount)desc) dr
from customers  c
left join accounts  a on c.customer_id=a.customer_id
join transactions t on a.account_id=t.account_id
 group by c.full_name
 order by  count(t.amount) desc)
 where rownum <=3 ;
 
   select * from (
 select c.full_name,
 count(t.amount) say,
 dense_rank()over(order by  count(t.amount)desc) dr
from customers  c
left join accounts  a on c.customer_id=a.customer_id
join transactions t on a.account_id=t.account_id
 group by c.full_name
)
 where dr <=1
 
/*. Günlük əməliyyat sayı və məbləği*/ 

select trunc(txn_date) gun,
sum(amount ),
count(txn_id)
from transactions
group by trunc(txn_date);

/*10. Ardıcıl günlərdə əməliyyat edən müştərilər*/

----eyni hesab uzre ardicil gunleri tapmaq
select * from(
select account_id,
txn_date,
lag(txn_date)over(partition by account_id order by txn_date ) evvelki_tarix,
txn_date - lag(txn_date)over(partition by account_id order by txn_date ) ferq
from transactions)
where ferq=1
order by txn_date asc,evvelki_tarix asc;


--ardicil gunleri filtr etmek ucun
SELECT account_id,
       txn_date, 
       ROW_NUMBER() OVER (PARTITION BY account_id  ORDER BY txn_date )  rn,  
       txn_date - ROW_NUMBER() OVER ( PARTITION BY account_id ORDER BY txn_date) AS grp          
FROM transactions;

/*4. Bank – Son 30 günün əməliyyatları*/
--1 usul
with md as(
select 
max(txn_date) max_tarix,
max(txn_date) -30 min_tarix
from transactions)
select *
from transactions
join md on 1 = 1
where txn_date between md.min_tarix and  md.max_tarix;

--2 usul
with s_em as(
select account_id,
txn_date,
max(txn_date)over(partition by account_id) son_emel
from transactions )
select * from s_em
where txn_date >= son_emel-30;

/*Bank – Hesab üzrə ümumi mədaxil və məxaric cemini tap*/

select 
sum(case when txn_type='CREDIT' THEN 1 ELSE 0 END) mexaric_say,
sum(case when txn_type='DEBIT' THEN 1 ELSE 0 END) MEDAXIL_say,
sum(case when txn_type='CREDIT' THEN amount ELSE 0 END) mexaric,
sum(case when txn_type='DEBIT' THEN amount ELSE 0 END) MEDAXIL
from transactions
group by account_id;

/*6. Bank – Ən çox dövriyyəsi olan 10 hesab*/
with txn_sayi as(
select account_id,
sum(case when amount is not null then amount else 0 end) dovrye
from transactions 
group by account_id
order by dovrye desc)
select * from txn_sayi
where rownum <=10;

with dovr as (
select account_id,
sum (amount) dovriyye,
row_number()over( order by sum (amount) desc nulls last) rn
from transactions
group by account_id)
select * from dovr
where rn<=10 ;

/*7. Bank – Şübhəli böyük əməliyyatlar (məsələn 10 000 AZN-dən yuxarı)*/

select *
from transactions t
where amount >2000;

/*en yuksek emeliyyat aparan hesab*/

 --accountlar daxilinde en yuksek meblegi verir yeni cox sayda
with e as (
select account_id,
amount ma,
row_number()over(partition by account_id order by amount desc) rn
from transactions)
select * from e
where rn=1
order by ma desc ;

---en yusek meblegi amma 2 ci eyni mebleg itir
SELECT * FROM (
    SELECT account_id, 
           amount AS ma
    FROM transactions
    ORDER BY amount DESC)
WHERE ROWNUM = 1;

--en optimal dense eyni meblegleri eyni siralayir yeni 2 eyni mebleg ikisi de cixir

with e as (
select account_id,
amount ma,
dense_rank()over( order by amount desc) dr
from transactions)
select * from e
where dr=1 ;

/*8. Bank – Müştərinin cari balansı*/
SELECT 
account_id,
balance
FROM ACCOUNTS  ;

/*10. Bank – Günlük əməliyyat sayı və məbləği*/

select 
trunc(txn_date),
count(*) say,
sum(amount)
from transactions
group by trunc(txn_date)
order  by trunc(txn_date) ;

/*JOIN
Sual 1
customers cədvəlində olan, amma heç bir hesabı olmayan müştəriləri tap.
*/
select c.full_name,
a.account_id
from customers c
left join accounts a on c.customer_id=a.customer_id
where a.account_id is null;

/*Sual 2
Heç bir əməliyyatı olmayan hesabları tap.
*/
select a.account_id,
t.txn_id
from accounts  a
left join transactions  t on  a.account_id=t.account_id
 where t.txn_id is null;
 /*
Sual 4
3-dən çox hesabı olan müştəriləri tap.*/

select c.full_name,
count(a.account_id)
from customers c
left join accounts a on c.customer_id=a.customer_id
group by c.full_name
having count(a.account_id)>3;

/*
Sual 8
Əməliyyatı gəlir və xərc kimi ayır.*/

select t.*,
case when txn_type='DEBIT' THEN 'gelir' else 'xerc' end category
from transactions t;

/*Subquery
Sual 9
Orta balansdan yüksək hesabları tap.*/

select * from accounts
where balance > (select round(avg(balance),2)from accounts );

/*Sual 10
Ən yüksək məbləğli əməliyyatı tap.*/

select * from transactions 
where amount=  (select max(amount)
from transactions);

/*Sual 11
Ən aktiv müştərini tap*/

---1 usul
with em_s as (
select a.account_id,
count(t.txn_id) em_say
from accounts a 
join transactions t on a.account_id=t.account_id
group by  a.account_id
order by em_say desc )
select * from em_s
where rownum =1 ;


 --- 2 usul max ile
with em_s as (
select a.account_id,
count(t.txn_id) em_say
from accounts a 
join transactions t on a.account_id=t.account_id
group by  a.account_id
order by em_say desc)

select * from em_s
where em_say = (select max(em_say) from em_s);

---dense rank ile profesional seviyye



WITH em_s AS (
    SELECT a.account_id,
           COUNT(t.txn_id) em_say,
            DENSE_RANK() OVER (ORDER BY  COUNT(t.txn_id) DESC) dr
    FROM accounts a
    JOIN transactions t
      ON a.account_id = t.account_id
    GROUP BY a.account_id)
select * from em_s  
WHERE dr = 1;

/*
Sual 13
Hər müştərinin son əməliyyatını tap.*/
select c.full_name,
max(txn_date) son_emeliyyat
from  customers c 
join accounts a on c.customer_id=a.customer_id
join transactions t on a.account_id=t.account_id
group by  c.full_name ;

with max_tr as (
select c.full_name,
t.txn_date ,
row_number()over(partition by c.full_name order by t.txn_date desc) rn
from  customers c 
join accounts a on c.customer_id=a.customer_id
join transactions t on a.account_id=t.account_id)
select * from max_tr
 where rn=1 ;


/*Sual 14
Hər müştərinin ən böyük əməliyyatı.*/

with tr_am as (
select account_id,
amount,
row_number()over(partition by account_id order by amount desc) max_amount
from transactions
)
select * from tr_am
where max_amount=1 ;

/*Sual 15
Ən çox dövriyyəsi olan ilk 5 müştəri.*/

with dr as (
    SELECT account_id,
           SUM(amount) ,
           DENSE_RANK() OVER(ORDER BY SUM(amount) DESC) rnk
    from transactions 
    GROUP BY account_id
) 
select * from dr
WHERE rnk <= 5;

/*Sual 16
Müştərinin əvvəlki əməliyyat məbləğini göstər.*/

select account_id  mus_hesabi,
amount mebleg,
lag(amount)over(partition by account_id order by amount asc) evvelki_emeliyyat
from transactions;
/*Sual 17
Cari əməliyyatla əvvəlki əməliyyat arasındakı fərq.
*/

select account_id,
amount cari_emeliyyat,
lag(amount)over(partition by account_id order by amount) evvelki_emeliyyat ,
amount-lag(amount)over(partition by account_id order by amount) ferq
from transactions
order by account_id asc ;

/*Sual 18
Son 30 gündə əməliyyat edən müştərilər.*/

SELECT DISTINCT c.customer_id
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
WHERE t.txn_date >= SYSDATE - 30;

with son_tarix as (
select  account_id,
max(txn_date) s_t
from transactions
group by account_id)
select * from son_tarix
where s_t>= sysdate-30;

/*Aylıq dövriyyə hesabatı.*/

select  trunc(txn_date,'mon'),
sum(amount)
from transactions
group by trunc(txn_date,'mon')
order by trunc(txn_date,'mon');

/*Real Bank Case-ləri
Sual 20
90 gündür əməliyyat etməyən müştərilər.
*/

select c.full_name,
max(t.txn_date) max_date
from  customers c
left join accounts a on c.customer_id= a.account_id
join transactions t on t.account_id=a.account_id
group by c.full_name
having max(t.txn_date)<= sysdate-90;

/*Sual 21
Bir gündə 10-dan çox əməliyyat edən hesablar.
*/

select 
account_id  hesab,
trunc(txn_date) gun,
count(*) emeliyyat_sayi
from transactions 
group by trunc(txn_date),account_id
having count(*)>10
order by trunc(txn_date);

/* "bir gündə ən çox əməliyyat edən hesab" tap.*/

with gun_em_say as(
select  
      account_id,
        trunc(txn_date) gun,
      count(*) en_say
from transactions
group by account_id,trunc(txn_date)),

emeliy_siralamasi as (
select
     account_id,
     gun,
     row_number()over(partition by gun order by en_say desc)rn
from gun_em_say)
select  * from emeliy_siralamasi
where rn=1

----dense_rank ile 
with gun_em_say as(
select  
      account_id,
        trunc(txn_date) gun,
      count(*) en_say
from transactions
group by account_id,trunc(txn_date)),

emeliy_siralamasi as (
select
     account_id,
     gun,
     dense_rank()over(partition by gun order by en_say desc) dr
from gun_em_say)
select  * from emeliy_siralamasi
where dr=1 ;

/*Sual 22
Fraud analizi: 1 saat içində 5-dən çox əməliyyat.
(Bu sual çox məşhurdur, adətən window function və timestamp analizi ilə həll edilir.)
*/
----Oracle üçün saatlıq qruplaşdırma
SELECT account_id,
       TRUNC(txn_date, 'HH24') AS txn_hour,
       COUNT(*) AS emeliyyat_sayi
FROM transactions
GROUP BY account_id, TRUNC(txn_date, 'HH24')
HAVING COUNT(*) > 5;

 select trunc(sysdate,'hh24')from dual;
/*Həqiqi fraud hesabatlarında hər bir əməliyyatın özündən əvvəlki 1 saatlıq intervala baxılır.
Bunun üçün Oracle-da analitik COUNT(*) OVER funksiyasından və
RANGE BETWEEN intervalından istifadə edilməlidir:*/
WITH fraud_analiz AS (
    SELECT account_id,
           txn_date,
           amount,
           COUNT(*) OVER (
               PARTITION BY account_id 
               ORDER BY txn_date 
               RANGE BETWEEN INTERVAL '1' HOUR PRECEDING AND CURRENT ROW
           ) AS son_1_saatdaki_say
    FROM transactions
)
SELECT DISTINCT account_id
FROM fraud_analiz
WHERE son_1_saatdaki_say > 5;

/*Sual 23
Mənfi balansa düşən hesabları tap.*/

select *
from accounts
where balance <0;

/*Sual 24
Ən çox istifadə olunan ilk 10 hesab.*/

SELECT account_id, say 
FROM (SELECT account_id, COUNT(*) AS say,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rn
    FROM accounts
    GROUP BY account_id)
 WHERE rn <= 10;

/*Sual 25
Hər ay yeni qoşulan müştəri sayı.*/

with ilk_date as (
select
customer_id musteri,
min(open_date) ilk_open_date
from accounts
group by customer_id)
select 
trunc(ilk_open_date,'mm') ay,
count(*) yeni_musteri,
listagg (musteri,',')within  group ( order by musteri asc)
from ilk_date
 group by trunc(ilk_open_date,'mm')
order by ay ;

/*2. Dünənin əməliyyatları*/

select 
*
from transactions
where txn_date = sysdate-1;

/*3. Bu ayın əməliyyatları*/
select *
from transactions
where trunc(txn_date,'mm')=trunc(sysdate,'mm'); --zeif isleyir

--Əgər növbəti günləri gözləmədən, sadəcə ayın 1-indən bu günün tam sonuna qədər olan 
--əməliyyatları görmək istəyirsinizsə:

SELECT *
FROM transactions
WHERE txn_date >= TRUNC(SYSDATE, 'mm') 
  AND txn_date <= TRUNC(SYSDATE) + 1 - 1/24*60*60;

  
  /*TRUNC(SYSDATE) + 1 - 1/86400 yazılışının məqsədi "bu günün ən son saniyəsini"
  (yəni saat 23:59:59-u) tapmaqdır.Gəlin bu riyazi hesablamanı addım-addım parçalayaq:Gündəlik 
  saniyə sayı: 1 gündə 24 saat, hər saatda 60 dəqiqə, hər dəqiqədə 60 saniyə var. 24 * 60 * 60 = 
  86400 saniyə.1 saniyənin gün hissəsi: Oracle-da tarixlərin üzərinə rəqəm gəldikdə, o rəqəm "gün" 
  olaraq qəbul edilir.
  Deməli, 1 rəqəmi 1 günü ifadə edirsə, 1 / 86400 tam 1 saniyə deməkdir.*/

/*4. Keçən ayın əməliyyatları*/

SELECT *
FROM transactions
WHERE txn_date >= TRUNC(ADD_MONTHS(SYSDATE, -1), 'mm')
  AND txn_date < TRUNC(SYSDATE, 'mm');
  
/*5. Hər ay üzrə dövriyyə*/

SELECT 
    TO_CHAR(txn_date, 'YYYY-MM') AS ay,
    SUM(amount) AS umumi_dovriyye,
    COUNT(*) AS emeliyyat_sayi
FROM transactions
GROUP BY TO_CHAR(txn_date, 'YYYY-MM')
ORDER BY ay ASC;

/*6. Hər gün üzrə əməliyyat sayı*/

SELECT 
    TRUNC(txn_date) AS gun,
    COUNT(*) AS emeliyyat_sayi,
    SUM(amount) AS gunluk_dovriyye
FROM transactions
GROUP BY TRUNC(txn_date)
ORDER BY gun DESC;
/*7. Müştərinin neçə gündür aktiv olmadığını hesabla.*/

SELECT 
    account_id AS musteri,
    MAX(txn_date) AS son_emeliyyat_tarixi,
   TRUNC(SYSDATE) - TRUNC(MAX(txn_date)) AS qeyri_aktiv_gun_sayi
FROM transactions
GROUP BY account_id
ORDER BY qeyri_aktiv_gun_sayi DESC;
------
SELECT 
    FLOOR(1593 / 365.25) AS il,
    FLOOR(MOD(1593, 365.25) / 30.4375) AS ay
FROM dual;

----
SELECT NUMTOYMINTERVAL(1593 / 30.4375, 'month') AS netice FROM dual;


 /*Astronomik təqvimdə 4 ildən bir fevral ayı 29 gün olduğu üçün 1 il ortalama 365.25 gün qəbul 
 edilir. Bu rəqəmi bir ildəki 12 aya böldükdə standard ortalama alınır:
 365.25 gün / 12 ay = 30.4375 gün.*/
 
/*8. 90 gündür əməliyyat etməyən müştərilər.*/


select account_id,
max(txn_date) son_emeliyyat
from transactions
group by account_id
having max(txn_date) <= sysdate-90;

/*Gün fərqini hesabla.*/

select account_id,
trunc(txn_date) gun,
lag(trunc(txn_date),1)over(partition by account_id order by trunc(txn_date)) evvelki_gun,
trunc(txn_date)-lag(trunc(txn_date),1)over(order by trunc(txn_date)) gun_ferqi
from transactions

/*Bu ay qeydiyyatdan keçən müştərilər.*/
/*Son 7 gündə qeydiyyatdan keçən müştərilər*/
--

/*musterinin yasi*/
select 
floor (months_between(sysdate,birth_date)/12)
from customers; 
--usul1





SELECT * FROM TRANSACTIONS ;
SELECT * FROM CUSTOMERS ;
SELECT * FROM ACCOUNTS ;