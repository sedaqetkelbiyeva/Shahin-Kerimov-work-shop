/*BLOK 1.1
Neçə müştəri, hesab, kart və tranzaksiya var? Hamısını tək SELECT sorğusunda göstər.*/
select 
(select count(*) from customers) musteri_sayi,
(select count(*) from transactions) tranzaksiya_sayi,
(select count(*) from accounts )  hesab_sayi,
(select count(*) from cards) kard_sayi
from dual;

/*1.2
Şəhərlər üzrə müştəri sayını göstər. Ən çox müştərisi olan şəhər yuxarıda olsun.*/

select city,
count(*) musteri_sayi
from customers
group by city
order by musteri_sayi desc;

/*1.3
Hesab növləri (account_type) və statuslara (status) görə neçə hesab olduğunu və orta balansı göstər.*/

 select account_type,
 status,
 count(*) hesab_sayi,
round(avg(balance),2) orta_balance 
 from accounts
group by account_type, status ;
 
/*BLOK 2.1
Kanal (MOBILE, ATM, POS, ONLINE, BRANCH) üzrə tranzaksiya sayını, ümumi məbləği
və orta məbləği göstər. Yalnız DEBIT əməliyyatları. Ən çox məbləğ olan kanal yuxarıda olsun.*/

select
channel,
count(*) tranzaksiya_sayi,
sum(amount) umumi_mebleg,
round(avg(amount),2) orta_mebleg
from transactions 
where TXN_TYPE = 'DEBIT'
GROUP BY channel 
order by sum(amount) DESC;

/*2.2
Aylıq xərc dinamikasını göstər (2022-2026). Hər ay üçün əməliyyat sayı və ümumi xərc.*/

SELECT TO_CHAR(TXN_DATE,'YYYY-MM') AY,
COUNT(*) EMELIYYAT_SAYI
FROM TRANSACTIONS
WHERE TO_CHAR(TXN_DATE,'YYYY')BETWEEN 2022 AND 2026 
 GROUP BY TO_CHAR(TXN_DATE,'YYYY-MM')
 ORDER BY TO_CHAR(TXN_DATE,'YYYY-MM') ASC;
 
 
/*2.3
Ən çox xərc olunan TOP 5 kateqoriyanı tap. Hər kateqoriya üçün əməliyyat sayı,
ümumi xərc və ən böyük tək əməliyyat məbləği. Yalnız 5-dən çox əməliyyatı olan kateqoriyalar.*/
SELECT * FROM(SELECT CATEGORY,
COUNT(*) EMELIYYAT_SAYI,
SUM(AMOUNT) UMUMI_XERC ,
MAX(AMOUNT) MAX_XERC
from transactions
GROUP BY CATEGORY
HAVING COUNT(*) >5
ORDER BY SUM(AMOUNT) DESC)
where rownum<=5;

/*2.4
Müştəri segmentinə (P=Premium, S=Standard, C=Corporate) görə müştəri sayı, hesab sayı, 
orta balans, minimum və maksimum balansı göstər.Yalnız aktiv hesablar.*/

SELECT 
C.SEGMENT,
COUNT(DISTINCT C.CUSTOMER_ID) MUSTERI_SAYI,
COUNT(A.ACCOUNT_ID) HESAB_SAYI,
ROUND(AVG(A.BALANCE),2) ORTA_BALANCE,
MIN(A.BALANCE) MIN_BALANS,
MAX(A.BALANCE) MAX_BALANS
FROM CUSTOMERS C 
JOIN ACCOUNTS A 
ON C.CUSTOMER_ID=A.CUSTOMER_ID
WHERE A.STATUS = 'A'
GROUP BY C.SEGMENT
ORDER BY MUSTERI_SAYI DESC;


/*2.5
Kart növü (DEBIT, CREDIT, VIRTUAL) və statusuna (A=Aktiv, B=Bloklu, E=Müddəti bitmiş) 
görə neçə kart olduğunu göstər.*/

SELECT CARD_TYPE,
STATUS,
COUNT(*) KART_SAYI
FROM CARDS 
GROUP BY CARD_TYPE,STATUS
ORDER BY STATUS ;



/* BLOK 3.1
Hər hesabın ən son tranzaksiyasını tap. Müştəri adı, tarix, məbləğ və kanal göstərilsin.*/
SELECT * FROM(
SELECT CUS.FULL_NAME  MUSTERI_ADI,
T.TXN_DATE TARIX,
T.AMOUNT MEBLEG,
T.CHANNEL KANAL,
ROW_NUMBER()OVER(PARTITION BY A.ACCOUNT_ID ORDER BY T.TXN_DATE DESC) TRANZAKSIYA_RN
FROM CUSTOMERS CUS
JOIN  ACCOUNTS A
ON CUS.CUSTOMER_ID=A.CUSTOMER_ID
JOIN TRANSACTIONS T
ON A.ACCOUNT_ID=T.ACCOUNT_ID )
WHERE TRANZAKSIYA_RN=1;

 /*3.2  
  Aylıq ümumi xərci hesabla (yalnız DEBIT). Hər ay üçün bu ayın xərci, əvvəlki ayın xərci,
  fərq və artım faizi göstərilsin.*/
 
 WITH AYLIQ_XERC AS( 
  SELECT TO_CHAR(TXN_DATE,'MM') AY,
 SUM( AMOUNT) UMUMI_XERC
  FROM TRANSACTIONS 
  WHERE TXN_TYPE='DEBIT'
GROUP BY TO_CHAR(TXN_DATE,'MM'))
 SELECT UMUMI_XERC,
 LAG(UMUMI_XERC)OVER(ORDER BY AY) EVVELKI_AY,
 UMUMI_XERC- LAG(UMUMI_XERC)OVER(ORDER BY AY) FERQI,
 ROUND((UMUMI_XERC-LAG(UMUMI_XERC)OVER(ORDER BY AY))*100/LAG(UMUMI_XERC)OVER(ORDER BY AY),2) ARTIM_FAIZI 
 FROM AYLIQ_XERC
 ORDER BY AY;
 
 
 /*3.3
Hər müştərinin ən böyük 3 xərcini tap. Müştəri adı, tarix, 
kateqoriya və məbləğ göstərilsin.*/
 WITH XERC AS (
SELECT C.FULL_NAME MUSTERI_ADI,
T.TXN_DATE TARIX,
T.CATEGORY KATEQORIYA,
T.AMOUNT MEBLEG,
ROW_NUMBER()OVER(PARTITION BY C.FULL_NAME ORDER BY T.AMOUNT DESC) RN_XERCI
FROM CUSTOMERS  C
JOIN  ACCOUNTS A
ON C.CUSTOMER_ID=A.CUSTOMER_ID
JOIN TRANSACTIONS T
ON A.ACCOUNT_ID=T.ACCOUNT_ID)
SELECT XERC.*
FROM XERC
WHERE RN_XERCI <4 ;

/*3.4
2023-cü il üçün aylıq xərc və yığılan (kumulyativ) xərci göstər.*/

WITH AYLIQ_XERC AS(
SELECT 
DISTINCT TO_CHAR(TXN_DATE,'YYYY-MM') TARIX,
SUM(AMOUNT)OVER(PARTITION BY TO_CHAR(TXN_DATE,'YYYY-MM') )UMUMI_XERC
FROM TRANSACTIONS
WHERE TO_CHAR(TXN_DATE,'YYYY') =2023
 ORDER BY TO_CHAR(TXN_DATE,'YYYY-MM'))

SELECT TARIX,
UMUMI_XERC,
SUM(UMUMI_XERC)OVER(ORDER BY TARIX ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
FROM AYLIQ_XERC ;

/*3.5
Hər hesab üçün hər tranzaksiyanı əvvəlki tranzaksiya ilə müqayisə et. Əvvəlki əməliyyatın
məbləği, fərq və trend (↑ Artdı / ↓ Azaldı / = Eyni) göstərilsin. Yalnız DEBIT əməliyyatları.*/

WITH TR AS (
SELECT 
A.ACCOUNT_ID HESAB,
T.TXN_DATE CARI_TARIX,
T.AMOUNT MEBLEG ,
LAG(AMOUNT)OVER(ORDER BY TXN_DATE) EVVELKI_TRANZAK
FROM ACCOUNTS  A
JOIN TRANSACTIONS T 
ON A.ACCOUNT_ID=T.ACCOUNT_ID 
AND TXN_TYPE='DEBIT')
SELECT TR.*,
EVVELKI_TRANZAK - MEBLEG  FERQ,
CASE WHEN EVVELKI_TRANZAK - MEBLEG <0 THEN '↑ Artdı '
WHEN  EVVELKI_TRANZAK - MEBLEG >0 THEN '↓ Azaldı'
ELSE '=EYNI'
END TREND
FROM TR;


/*4.1

Aktiv kartı olan, lakin son 90 gündür heç bir əməliyyat etməyən müştəriləri tap. Seqmentə görə qruplaşdır və göstər:

•	Neçə müştəri var?
•	Orta neçə gün keçib?
•	Heç vaxt əməliyyat etməyənlər neçədir?
*/


with  activ_stifadeci as(
select 
c.customer_id  musteri,
c.segment seqment ,
max(t.txn_date) max_tarix
from transactions t
join accounts  a on t.account_id = a.account_id
join customers c on c.customer_id=a.customer_id
where a.status='A'
group by c.segment, c.customer_id)

select 
seqment ,
count(musteri) musteri_sayi,
avg(sysdate-max_tarix) orta_gun
from activ_stifadeci 
where max_tarix <  sysdate-90  or  max_tarix is null
group by seqment ;
    



/*4.2
Hər müştərinin ən çox xərc etdiyi kateqoriyanı tap. Müştəri adı,
kateqoriya və ümumi məbləğ göstərilsin.*/

with amount_category as (
select c.full_name musteri_adi,
t.category kateqoriya,
sum(t.amount) cem
from customers c  
join accounts a on c.customer_id=a.customer_id
join transactions t on a.account_id=t.account_id
 group by c.full_name,t.category),
 
  cateqory_rownum as (select amount_category .*,
row_number()over(partition by kateqoriya order by cem desc) rn
  from amount_category )
  
   select * from cateqory_rownum
   where rn=1 ;
   
   
   /*4.3
   Fraud (is_flagged = 'Y') əməliyyatlarını analiz et. Kanal üzrə neçəsi var, ümumi məbləği nə qədərdir,
   hansı müştərilər daha çox flaglanıb?*/
    ---kanal uzre fraud sayi
SELECT
    channel,
    COUNT(*)  fraud_count,
    SUM(amount)  total_amount,
    round(avg(amount),2) orta_mebleg
FROM transactions 
WHERE is_flagged = 'Y'
GROUP BY channel
ORDER BY fraud_count DESC;


--musteri uzre en cox fraud edilen

SELECT
    c.full_name,
    COUNT(*) AS fraud_count,
    SUM(t.amount) AS total_amount
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
WHERE t.is_flagged = 'Y'
GROUP BY c.customer_id, c.full_name
ORDER BY fraud_count DESC;


SELECT * FROM TRANSACTIONS ;
SELECT * FROM CUSTOMERS ;
SELECT * FROM ACCOUNTS ;