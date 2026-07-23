CREATE TABLE customers1(customer_id NUMBER(7)GENERATED AS IDENTITY CONSTRAINT pk_cistomer_id PRIMARY KEY,
                        first_name VARCHAR2(30) NOT NULL,
                        last_name VARCHAR2(30) NOT NULL,
                        open_date DATE DEFAULT SYSDATE NOT NULL,
                        close_date DATE,
                        CONSTRAINT ch_customer_date CHECK (open_date<=close_date));
                        COMMIT;
SELECT * FROM customers1;

--mehdudiyyeti deyismek ,silmek
ALTER TABLE customers1
DROP CONSTRAINT ch_customer_date;
--yeni mehdudiyyet elave etmek
ALTER TABLE customers1
ADD CONSTRAINT ch_customer_dates CHECK (open_date<=close_date);

--DATA DICTIONARY

SELECT * FROM user_objects;

SELECT * FROM user_tables
WHERE TABLE_NAME= 'CUSTOMERS1';

SELECT * FROM USER_TAB_COLUMNS
WHERE TABLE_NAME ='CUSTOMERS1';

SELECT * FROM USER_CONSTRAINTS
WHERE TABLE_NAME='CUSTOMERS1';

SELECT * FROM USER_CONS_COLUMNS UC
JOIN USER_CONSTRAINTS C ON
C.CONSTRAINT_NAME=UC.CONSTRAINT_NAME
WHERE UC. TABLE_NAME='CUSTOMERS1'


----
INSERT INTO CUSTOMERS1
  (first_name, last_name, open_date, close_date)
VALUES
  ('ceyhun', 'Hüseynov', to_date('13.05.2025', 'dd.mm.yyyy'), NULL);
                      
INSERT INTO CUSTOMERS1
  (first_name, last_name, open_date, close_date)
VALUES
  ('Cümsüd', 'Mürşüdov', SYSDATE, NULL);
INSERT INTO CUSTOMERS1
  (first_name, last_name)
VALUES
  ('Sevinc', 'Abbasova');
SELECT * FROM customers1;
     
 INSERT INTO CUSTOMERS1
   (first_name, open_date, close_date)
 VALUES
   ('Cümsüd', 'Mürşüdov', SYSDATE, NULL); --eror 'to many values' ora 00913
                    
 
 INSERT INTO CUSTOMERS1
   (first_name, last_name, open_date, close_date)
 VALUES
   ('Cümsüd', SYSDATE, NULL); --eror 'not enough values' ora 00947              
 
 INSERT INTO CUSTOMERS1
   (first_name, open_date, close_date)
 VALUES
   ('Cümsüd', SYSDATE, NULL); --last name not null omadigina gore eror verecek 
 
 INSERT INTO CUSTOMERS1
   (first_name, last_name, open_date, close_date)
 VALUES
   ('Cümsüd', 'Mürşüdov', SYSDATE, SYSDATE - 1); --eror cunki check var close_date > omalidir
  -----                    
                      
  COMMIT ; --tranzaksiyani tesdiq edir 
 ROLLBACK; -- tranzaksiyani geri qaytarir 
  /*dml emeliyyatlari(insert,update,delete,merge)commit ve rollback edir
   ve geri qaytarir ancaq    ddl emeliyyatlarinda olmur */
   
   
    SELECT * FROM customers1;
    
    ------  
   CREATE TABLE accounts(acount_id NUMBER(8,0) GENERATED AS IDENTITY PRIMARY KEY,
                            customer_id NUMBER(7,0)REFERENCES customers1(customer_id) ,-- column table,
                            iban VARCHAR2(30) NOT NULL UNIQUE,
                            open_date DATE DEFAULT SYSDATE NOT NULL,
                            close_date DATE,
                            CONSTRAINT ch_account_dates CHECK(open_date<=close_date));
              
   SELECT * FROM accounts  ;
    
   CREATE TABLE customer_infos(info_id NUMBER(8,0)GENERATED AS IDENTITY PRIMARY KEY,
                                customer_id NUMBER(7),
                                info_type CHAR CHECK(info_type IN('A','H','M')),
                                info_value  VARCHAR2(200),
                                info_status NUMBER(1) DEFAULT 1 NOT NULL,
                                CONSTRAINT fk_customer_info_id FOREIGN KEY (customer_id) 
                                REFERENCES customers1(customer_id ));
                              
 
   --table level  yeni constraint umumi cedvele aiddir(ayri sutunda yazilir)
   --not NULL TABLE levelde yazmaq olmur ,ancaq digerleri olur(pk,fk,unigue)
   /*char(5)qoysaq yeni   oracle ozu 5 dene probl qoyacaq,
     varchar2 ise ne yazsan onu da goturecek 
    char () yazilis eror vermeyec cunki ozu avtomatik 1 verecek
    varchar2 () yazilis eror verecek qiymet isteyir*/    


INSERT INTO customer_infos
  (customer_id, info_type, info_value, info_status)
VALUES
  (2, 'M', '+99412564', 1);
INSERT INTO accounts (customer_id, iban) VALUES (1, ' AZ11XX45876213985');

INSERT INTO accounts (customer_id, iban) VALUES (1, ' AZ11XX4587621398');

INSERT INTO accounts (customer_id, iban) VALUES (3, ' AZ11XX45876212311');

INSERT INTO accounts (customer_id, iban) VALUES (3, ' AZ11XX45876212312');

INSERT INTO accounts (customer_id, iban) VALUES (3, ' AZ11XX45876212313');

INSERT INTO accounts
  (customer_id, iban)
VALUES
  (100, ' AZ11XX45876212311'); --PARENTED KEY NOT FOUND

INSERT INTO accounts
  (customer_id, iban)
VALUES
  (2, ' AZ11XX00000000000000000000431111111'); --EROR SINVOL SAYI COXDUR
  
  SELECT * FROM accounts;
  
  --INSERT SELECT
  
  iNSERT INTO CUSTOMERS1 ( first_name,
                           last_name,
                           open_date
                           ) 
   SELECT frist_name,
   last_name,
   hire_date
   FROM employees 
   WHERE department_id=30   ;
   
   ALTER TABLE customers1
   ADD employee_code NUMBER; --yeni sutun elave edilir
    
   SELECT * FROM customers1; 
   
   ---
   DELETE FROM customers1
   WHERE customer_id=3;
   ----
   INSERT INTO customer_info (customer_id,info_type,info_value)  
   
   SELECT c.customer_id, 'M' AS info_type, emp.phone_number
     FROM employees emp
    INNER JOIN customers1 c
       ON emp.employee_id = c.EMPLOYEE_CODE;
   
   --
   UPDATE customer_infos
   SET info_status=0
   WHERE info_type='M';
    ---
   
   SELECT * FROM customer_infos;
   ROLLBACK;
   SELECT * FROM customers1;
   
   ---
   DELETE CUSTOMERS1
   WHERE customer_id=1;
   
   ----
    TRUNCATE TABLE /*cedvelin icindeki butun datalari silir ve sert qoyulmur,
    rolback oluna bilmir 
      DELETE-- setrleri silir ve sert qoyulur
   ddl komandasini rolback geri qaytarmir ve truncate da ddl comandasi olduguna 
   gore qaytarmir avto commit edir.
   ddl komandalari avto commitdirler
   DROP TABLE customers --ccedveli tamam silir yerli dibli
   DROP TABLE customers CASCADE CONSTRAINTS
   -- CASCADE CONSTRAINTS yeni hec neye baxma sil*/
   
   TRUNCATE TABLE customers;
   DROP TABLE customers;
   DROP TABLE customers CASCADE CONSTRAINTS;
   
   --constrainler
   PRIMARY KEY unicaldir ve bos qala bilmez yeni NULL ola bilmez
   UNIQUE unikal deyerler olmalidir
   not NULL bos qala bilmez
   FOREIGN diger cedvellere baglayir
   CHECK setrlere sert qoyur
   
   --dml komandalari (insert,update,delete,merge)commit ve rollback olur
   
   --ddl avto commitdir (create,alter,drop,trancute,rename,comment)