use hotel;

-- удаление таблицы POS_NAME_DSCRPT
ALTER TABLE POSITION ADD POS_DSCRT VARCHAR(4000);

UPDATE p SET p.POS_DSCRT = pd.POS_DSCRPT
FROM [POSITION] p
    JOIN POS_NAME_DSCRPT pd ON p.POS_NAME=pd.POS_NAME;

-- EXEC sp_fkeys POS_NAME_DSCRPT;
ALTER TABLE POSITION DROP CONSTRAINT FK__POSITION__POS_NA__4316F928;
DROP TABLE POS_NAME_DSCRPT;
------------------------------

-- добавление новой колонки STATUS(wait-list, active, cancelled, non-active)
ALTER TABLE RESERVATION ADD STATUS VARCHAR(30);
-- SELECT *
-- FROM RESERVATION
UPDATE RESERVATION SET STATUS='non-active' WHERE CHECK_OUT<GETDATE()
------------------------------

ALTER TABLE RESERVATION ADD CONSTRAINT df_status DEFAULT 'wait-list' FOR STATUS;

------------------------------
-- 1)
-- displays active rooms
CREATE PROCEDURE display_active_rooms
AS
BEGIN
    SELECT ri.ROOM_NO, rc.CLASS_NAME, rc.PRICE, STRING_AGG(CONVERT(varchar, r.CHECK_IN, 104)+ ' - '+CONVERT(varchar, r.CHECK_OUT, 104), '; ') RSRV_DATES
    FROM ROOM_INFO ri
        JOIN ROOM_CLASS rc ON rc.CLASS_ID = ri.ROOM_CL_ID
        FULL JOIN ROOM_BOOKED rb ON rb.ROOM_NO = ri.ROOM_NO
        FULL JOIN RESERVATION r ON rb.RSRV_ID = r.RSRV_ID
    WHERE ri.ROOM_STATUS = 'active'
    GROUP BY ri.ROOM_NO, rc.CLASS_NAME, rc.PRICE
END;

-- обновление списка не свободных номеров
CREATE TRIGGER update_booked_rooms ON RESERVATION
AFTER INSERT, UPDATE
AS 
BEGIN
    DELETE rb FROM ROOM_BOOKED rb JOIN RESERVATION rs ON rs.RSRV_ID = rb.RSRV_ID
    WHERE rs.STATUS = 'non-active' or rs.STATUS = 'cancelled';

    UPDATE ri SET ri.ROOM_STATUS = (CASE 
        WHEN rb.ROOM_NO IS NULL THEN 'active'
        WHEN rb.ROOM_NO IS NOT NULL and GETDATE()+1 < r.CHECK_IN THEN 'active'
        ELSE 'non-active'
        END)
    FROM ROOM_INFO ri
        FULL JOIN ROOM_BOOKED rb ON ri.ROOM_NO = rb.ROOM_NO
        LEFT JOIN RESERVATION r ON r.RSRV_ID = rb.RSRV_ID
END;

-- updates room status and bill
CREATE TRIGGER update_room_st_and_bill ON ROOM_BOOKED
AFTER INSERT
AS 
DECLARE @RSRV_ID INT, @DATE_TIME DATETIME, @PRICE INT
BEGIN
    UPDATE ri SET ri.ROOM_STATUS = (CASE 
        WHEN rb.ROOM_NO IS NULL THEN 'active'
        WHEN rb.ROOM_NO IS NOT NULL and GETDATE()+1 < r.CHECK_IN THEN 'active'
        ELSE 'non-active'
        END)
    FROM ROOM_INFO ri
        FULL JOIN ROOM_BOOKED rb ON ri.ROOM_NO = rb.ROOM_NO
        JOIN RESERVATION r ON r.RSRV_ID = rb.RSRV_ID

    SELECT @RSRV_ID = INSERTED.RSRV_ID, @DATE_TIME= CHECK_OUT, @PRICE=rc.PRICE * DATEDIFF(day, rs.CHECK_IN, rs.CHECK_OUT)
    FROM INSERTED JOIN RESERVATION rs ON rs.RSRV_ID = INSERTED.RSRV_ID
        JOIN ROOM_BOOKED rb ON rb.RSRV_ID = rs.RSRV_ID
        JOIN ROOM_INFO ri ON ri.ROOM_NO = rb.ROOM_NO
        JOIN ROOM_CLASS rc ON rc.CLASS_ID = ri.ROOM_CL_ID

    IF NOT EXISTS (SELECT *
    FROM BILL
    WHERE RSRV_ID=@RSRV_ID)
    BEGIN
        INSERT INTO BILL
            (RSRV_ID, DATE_TIME, TOTAL_PRICE)
        VALUES
            (@RSRV_ID, @DATE_TIME, @PRICE)
    END
    ELSE
    BEGIN
        UPDATE BILL SET DATE_TIME=@DATE_TIME, TOTAL_PRICE=@PRICE WHERE RSRV_ID=@RSRV_ID
    END
END;

-- DROP TRIGGER display_act_rooms_call
-- call procedure to display active rooms after user registration
CREATE TRIGGER display_act_rooms_call ON RESERVATION
AFTER INSERT, UPDATE
AS
DECLARE @status VARCHAR(30)
BEGIN
    SELECT @status=INSERTED.STATUS
    FROM INSERTED

    IF(@status != 'cancelled')
    BEGIN
        EXEC display_active_rooms
    END
END

-- call Trigger 'update_booked_rooms' first, then 'display_act_rooms_call'
sp_settriggerorder @triggername= 'update_booked_rooms', @order='First', @stmttype = 'INSERT';  

-- user registration
CREATE PROCEDURE register_user
    @FULL_NAME VARCHAR(255),
    @PHONE_NUM varchar(25),
    @CITY varchar(255),
    @CREDIT_NUM varchar(50),
    @CHECK_IN DATETIME,
    @CHECK_OUT DATETIME,
    @PAYMNT_TYPE char(7)
AS
DECLARE @GUEST_ID INT
BEGIN
    IF NOT EXISTS (SELECT GUEST_ID
    FROM GUEST
    WHERE PHONE_NUM = @PHONE_NUM and CREDIT_NUM=@CREDIT_NUM)
    BEGIN
        INSERT INTO GUEST
            (FULL_NAME, PHONE_NUM, CITY, CREDIT_NUM)
        VALUES
            (@FULL_NAME, @PHONE_NUM, @CITY, @CREDIT_NUM)

        SELECT @GUEST_ID=GUEST_ID
        FROM GUEST
        WHERE PHONE_NUM = @PHONE_NUM and CREDIT_NUM=@CREDIT_NUM
    END
    ELSE
    BEGIN
        SELECT @GUEST_ID=GUEST_ID
        FROM GUEST
        WHERE PHONE_NUM = @PHONE_NUM and CREDIT_NUM=@CREDIT_NUM
    END

    INSERT INTO RESERVATION
        (GUEST_ID, RSRV_DATE, CHECK_IN, CHECK_OUT, PAYMNT_TYPE)
    VALUES
        (@GUEST_ID, CAST(GETDATE() as date), @CHECK_IN, @CHECK_OUT, @PAYMNT_TYPE)

    PRINT 'Registration was successful'
END

-- booking process
CREATE PROCEDURE booking
    @ROOM_NUM INT,
    @GUEST_PHONE_NUM VARCHAR(25)
AS
DECLARE @RSRV_ID INT
BEGIN
    SELECT @RSRV_ID=RSRV_ID
    FROM RESERVATION
    WHERE GUEST_ID=(SELECT GUEST_ID
    FROM GUEST
    WHERE PHONE_NUM=@GUEST_PHONE_NUM)
    INSERT INTO ROOM_BOOKED
    VALUES
        (@RSRV_ID, @ROOM_NUM)

    PRINT 'Registration was successful'
END


EXEC register_user  
    @FULL_NAME='Arman Nadirkhan', 
    @PHONE_NUM='8 (702) 169 78 42', 
    @CITY='Oral', 
    @CREDIT_NUM='MASTERCARD, 5131419184497058', 
    @CHECK_IN='2022-05-10 19:00', 
    @CHECK_OUT='2022-05-15 19:00', 
    @PAYMNT_TYPE='by cash'

EXEC booking 
    @ROOM_NUM=127, 
    @GUEST_PHONE_NUM='8 (702) 169 78 42'

select *
from ROOM_BOOKED
select *
from RESERVATION
-----------------------------------

-- *Functions for 2nd task*.
-- Returns left hours to check-in of customer with some reservation ID
create function hourleft(@reservation_id int)
returns int
as begin
    declare @hl int;
    SELECT @hl=DATEDIFF(HOUR, GETDATE(), CHECK_IN)
    FROM RESERVATION
    WHERE RSRV_ID=@reservation_id

    return @hl
end;

-- Returns amount of payment of customer with some reservation ID
create function amount_p(@reservation_id int)
returns decimal(10, 2)
as begin
    declare @pr decimal(10, 2);
    SELECT @pr = TOTAL_PRICE
    FROM BILL
    WHERE RSRV_ID=@reservation_id

    return @pr
end
;

2)
-- cancel reservation
CREATE PROCEDURE cancel_rsrv
    @RSRV_ID INTEGER
AS
DECLARE 
@hour_left INTEGER,
@price INTEGER
BEGIN
    set @hour_left = dbo.hourleft(@RSRV_ID);
    set @price = dbo.amount_p(@RSRV_ID);
    IF(@hour_left) <= 24
    BEGIN
        RAISERROR('Request was denied. At least 24 hours left until the moment of check-in.', 16, 1)
    END
    ELSE
    BEGIN
        UPDATE RESERVATION SET STATUS='cancelled' WHERE RSRV_ID=@RSRV_ID
        PRINT 'SUCCESS'
        IF EXISTS (SELECT TOTAL_PRICE
        FROM BILL
        WHERE RSRV_ID=@RSRV_ID)
        BEGIN
            DELETE FROM BILL WHERE RSRV_ID = @RSRV_ID
            PRINT 'RETURNED TOTAL PRICE: '+CONVERT(VARCHAR, @price)
        END
    END
END

EXEC cancel_rsrv @RSRV_ID=17

-- SELECT * FROM RESERVATION

-----------------------------------

-- Delete the table SERVICE_COST
alter table HOTEL_SERVICE add COST decimal(10, 2);

update HOTEL_SERVICE set COST = sc.COST
from HOTEL_SERVICE hs
    join SERVICE_COST sc on sc.SERV_NAME = hs.SERV_NAME;

exec sp_fkeys SERVICE_COST;
alter table HOTEL_SERVICE drop constraint FK__HOTEL_SER__SERV___5070F446;
drop table SERVICE_COST;


-- Delete service "Tea and coffee facilities" from HOTEL_SERVICE and make new bill for customers
update BILL
set TOTAL_PRICE = TOTAL_PRICE - bill_serv_cost.service_cost
from BILL b
    JOIN
    (select bs.BILL_ID, sum(s.COST) as service_cost
    from BILL b
        join BILL_SERVICE bs on b.BILL_ID = bs.BILL_ID
        join HOTEL_SERVICE s on s.SRVC_ID = bs.SERV_ID and s.SRVC_ID = 6
    group by bs.BILL_ID
) bill_serv_cost
    ON bill_serv_cost.BILL_ID = b.BILL_ID;

exec sp_fkeys HOTEL_SERVICE;
delete from BILL_SERVICE where SERV_ID = 6;
delete from HOTEL_SERVICE where SRVC_ID = 6;

-- 3)
create procedure ChangePrice
    @room_class varchar(50),
    @type varchar(50),
    @price_accmd bigint
as
begin
    update ROOM_CLASS set PRICE = @price_accmd
	where CLASS_NAME = @room_class and CLASS_TYPE = @type
end;

create trigger BillCust on ROOM_CLASS
after update
as
begin
    if update(PRICE)
	begin
        update b
		set b.TOTAL_PRICE = b.TOTAL_PRICE + (rc.PRICE - (select PRICE
        from deleted)) * DATEDIFF(day, res.CHECK_IN, res.CHECK_OUT)
		from BILL b
            JOIN RESERVATION res ON res.RSRV_ID = b.RSRV_ID
            JOIN ROOM_BOOKED rb ON rb.RSRV_ID = res.RSRV_ID
            JOIN ROOM_INFO ri ON ri.ROOM_NO = rb.ROOM_NO
            JOIN ROOM_CLASS rc ON rc.CLASS_ID = ri.ROOM_CL_ID
		where CLASS_ID = (select CLASS_ID
            from inserted) and GETDATE() < CHECK_IN
    end
end;
-- drop trigger BillCust;
exec  ChangePrice @room_class = 'Queen Suite', @type = 'Single', @price_accmd = 42000
exec  ChangePrice @room_class = 'King Suite', @type = 'Single', @price_accmd = 65000

------------------------------------------------------------

-- Create table for check for discount
alter table RESERVATION add DISCOUNT_APPLD char(3);
alter table RESERVATION add constraint disc default 'No' for DISCOUNT_APPLD;
update RESERVATION set DISCOUNT_APPLD = 'No';

-- *Function for 4th task*. Returns a table storing number of stays of all clients for the current year
create function numstc()
returns table
as return
(
	select count(*) as stay_number, GUEST_ID, max(CHECK_IN) as most_recent
from RESERVATION
group by GUEST_ID, datename(year, CHECK_IN)
having datename(year, CHECK_IN) = datename(year, getdate())
);

-- 4)
create procedure DiscCust
as
begin
    update b set b.TOTAL_PRICE = b.TOTAL_PRICE * 0.9
	from BILL b
        join RESERVATION rsrv on rsrv.RSRV_ID = b.RSRV_ID
        join (select *
        from dbo.numstc()) stay_tab on rsrv.CHECK_IN = stay_tab.most_recent and rsrv.GUEST_ID = stay_tab.GUEST_ID
	where stay_tab.stay_number > 3 and
        rsrv.DISCOUNT_APPLD = 'No' and GETDATE() < rsrv.CHECK_OUT;

    update r set r.DISCOUNT_APPLD = 'Yes'
	from RESERVATION r
        join (select *
        from dbo.numstc()) stay_tab on r.CHECK_IN = stay_tab.most_recent and r.GUEST_ID = stay_tab.GUEST_ID
	where stay_tab.stay_number > 3;
end;

exec DiscCust;

INSERT INTO RESERVATION
    (GUEST_ID, RSRV_DATE, CHECK_IN, CHECK_OUT, PAYMNT_TYPE)
VALUES
    (13, '2022-02-13', '2022-02-16 12:00', '2022-02-20 12:00', 'online'),
    (13, '2022-03-15', '2022-03-22 12:00', '2022-03-31 12:00', 'online'),
    (13, '2022-04-28', '2022-05-04 14:00', '2022-05-12 11:00', 'online'),
    (14, '2022-04-25', '2022-05-04 01:00', '2022-05-11 12:00', 'online');

INSERT INTO ROOM_BOOKED
VALUES
    (17, 114),
    (18, 115),
    (19, 128),
    (20, 121);

-- These 2 expired reservatoin with ID 17, 18 of Guest with id 13 were created to check for 4th task.
-- And here we will make their status non-activated
update RESERVATION set STATUS = 'non-active' where CHECK_OUT < GETDATE();

-----------------------------------------------------------

-- Make a new table for daily work-time duration of employees
create table EMP_JOURNAL
(
    C_Date date,
    EMP_ID int foreign key references EMPLOYEE(EMP_ID),
    ARRV_TIME time,
    LEAV_TIME time
);
alter table EMP_JOURNAL add constraint prevday default cast(getdate() - 1 as date) for C_Date;

-- 5)
create procedure BonusEmp
as
begin
    delete from  EMP_JOURNAL;

    insert into EMP_JOURNAL
        (EMP_ID, ARRV_TIME, LEAV_TIME)
    values
        (1, '08:00', '19:00'),
        (2, '00:00', '13:00'),
        -- (>9h)
        (3, '08:00', '18:00'),
        (4, '08:00', '18:50'),
        (5, '13:00', '23:59'),
        (7, '08:00', '18:00'),
        (8, '08:00', '21:00'),
        -- (>9h)
        (9, '08:00', '21:15'),
        -- (>9h)
        (10, '08:00', '21:15'),
        -- (>9h)
        (11, '08:00', '21:01'),
        -- (>9h)
        (12, '07:00', '22:00'),
        -- (>9h)
        (13, '07:00', '22:00'),
        -- (>9h)
        (14, '07:00', '20:50'),
        -- (>9h)
        (15, '08:00', '18:00'),
        (16, '08:00', '18:10'),
        (17, '08:00', '18:11'),
        (18, '08:00', '18:00'),
        (19, '08:00', '19:00'),
        (20, '08:00', '20:05'),
        (21, '08:00', '19:00'),
        (22, '08:00', '22:00'),
        -- (>9h)
        (23, '08:00', '19:00'),
        (24, '08:00', '19:00'),
        (25, '00:00', '11:00'),
        (26, '13:00', '23:59'),
        (27, '08:00', '18:00'),
        (28, '08:00', '18:00'),
        (29, '08:00', '18:00'),
        (30, '08:00', '19:00'),
        (31, '08:00', '19:00'),
        (32, '08:00', '20:00'),
        -- (>9h)
        (33, '08:00', '18:00'),
        (34, '08:00', '18:00'),
        (35, '08:00', '19:00'),
        (36, '08:00', '19:00'),
        (37, '09:00', '19:00');
end;

create trigger AddBEmp on EMP_JOURNAL
after insert 
as 
begin
    update emp set emp.SALARY = emp.SALARY + (empj.work_time_dur - 11) * (emp.SALARY*0.005)
	from EMPLOYEE emp
        join (select EMP_ID, datediff(hour, ARRV_TIME, LEAV_TIME) as work_time_dur
        from EMP_JOURNAL) empj
        on empj.EMP_ID = emp.EMP_ID
	where empj.work_time_dur > 11;
-- We won't include 2 hours for free time/lunch and etd.
end;

exec BonusEmp;
-- select * from EMPLOYEE

-----------------------------------
-- 6)
-- finish reservation
CREATE PROCEDURE finish_rsrv
    @RSRV_ID INTEGER
AS
BEGIN
    UPDATE RESERVATION SET STATUS='non-active' WHERE RSRV_ID=@RSRV_ID
    PRINT 'SUCCESS'
    EXEC display_bill @RSRV_ID=@RSRV_ID
END

CREATE PROCEDURE display_bill
    @RSRV_ID INT
AS
BEGIN
    SELECT b.RSRV_ID, b.DATE_TIME, STRING_AGG(h.SERV_NAME, ',') SERVICES, b.TOTAL_PRICE
    FROM BILL b FULL JOIN BILL_SERVICE bs ON b.BILL_ID=bs.BILL_ID
        FULL JOIN HOTEL_SERVICE h ON h.SRVC_ID = bs.SERV_ID
    WHERE b.RSRV_ID = @RSRV_ID
    GROUP BY b.RSRV_ID,b.DATE_TIME,b.TOTAL_PRICE
END

-- removes old data from Bill, updates price
CREATE TRIGGER calc_bill ON RESERVATION
AFTER UPDATE
AS
IF UPDATE(STATUS)
BEGIN
    -- remove old data
    DELETE FROM BILL_SERVICE WHERE BILL_ID IN (SELECT BILL_ID
    FROM BILL
    WHERE DATEDIFF(WEEK, DATE_TIME, GETDATE()) > 1)
    DELETE FROM BILL WHERE DATEDIFF(WEEK, DATE_TIME, GETDATE()) > 1

    -- update price
    update BILL
    set DATE_TIME = res.CHECK_OUT,
    TOTAL_PRICE = rc.PRICE * DATEDIFF(day, res.CHECK_IN, res.CHECK_OUT) + bill_serv_cost.service_cost
    from BILL b
        JOIN RESERVATION res ON res.RSRV_ID = b.RSRV_ID
        JOIN ROOM_BOOKED rb ON rb.RSRV_ID = res.RSRV_ID
        JOIN ROOM_INFO ri ON ri.ROOM_NO = rb.ROOM_NO
        JOIN ROOM_CLASS rc ON rc.CLASS_ID = ri.ROOM_CL_ID
        JOIN
        (select bs.BILL_ID, sum(s.COST) as service_cost
        from BILL b
            join BILL_SERVICE bs on b.BILL_ID = bs.BILL_ID
            join HOTEL_SERVICE s on s.SRVC_ID = bs.SERV_ID
        group by bs.BILL_ID
    ) bill_serv_cost
        ON bill_serv_cost.BILL_ID = b.BILL_ID
END

EXEC finish_rsrv @RSRV_ID=17

-- SELECT * FROM RESERVATION
