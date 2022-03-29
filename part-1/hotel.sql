create database mid_hotel;

use mid_hotel;

create table HOTEL
(
	H_CODE int primary key,
	H_NAME varchar(255) not null unique,
	ADDRSS varchar(255) not null,
	City varchar(255),
	PHONE_NUM varchar(25) unique,
	STAR_RATE int check(STAR_RATE between 0 and 5)
);

create table DEPARTMENT
(
	DP_ID int primary key,
	DP_NAME varchar(255) not null,
	H_CODE int foreign key references HOTEL(H_CODE)
);

create table GUEST
(
	GUEST_ID int primary key,
	FULL_NAME varchar(255) not null,
	PHONE_NUM varchar(25) unique,
	CITY varchar(255),
	CREDIT_NUM varchar(50) not null unique
);

create table RESERVATION
(
	RSRV_ID int primary key,
	H_CODE int foreign key references HOTEL(H_CODE),
	GUEST_ID int foreign key references GUEST(GUEST_ID),
	RSRV_DATE date not null,
	CHECK_IN datetime not null,
	CHECK_OUT datetime not null,
	PAYMNT_TYPE char(7) not null
);

create table ROOM_CLASS_DSCRPT
(
	CLASS_NAME varchar(255) primary key,
	CLASS_DSCRPT varchar(4000) not null
);

create table ROOM_CLASS
(
	CLASS_ID int primary key,
	CLASS_NAME varchar(255) foreign key references ROOM_CLASS_DSCRPT(CLASS_NAME),
	CLASS_TYPE varchar(255) not null,
	PRICE decimal(10, 2),
);

create table ROOM_INFO
(
	ROOM_NO int primary key,
	ROOM_CL_ID int foreign key references ROOM_CLASS(CLASS_ID),
	H_CODE int foreign key references HOTEL(H_CODE),
	ROOM_STATUS varchar(10) not null
);

create table ROOM_BOOKED
(
	RSRV_ID int foreign key references RESERVATION(RSRV_ID),
	ROOM_NO int foreign key references ROOM_INFO(ROOM_NO),
	constraint BOOKED_ROOM unique(RSRV_ID, ROOM_NO)
);

create table POS_NAME_DSCRPT
(
	POS_NAME varchar(255) primary key,
	POS_DSCRPT varchar(4000) not null
);

create table POSITION
(
	POS_ID int primary key,
	POS_NAME varchar(255) foreign key references POS_NAME_DSCRPT(POS_NAME)
);

create table EMPLOYEE
(
	EMP_ID int primary key,
	DP_ID int foreign key references DEPARTMENT(DP_ID),
	POS_ID int foreign key references POSITION(POS_ID),
	FULL_NAME varchar(255) not null,
	PHONE_NUM varchar(25) unique,
	EMAIL varchar(255) unique,
	ADDRSS varchar(255) not null,
	SALARY decimal(10, 2),
	HIRE_DATE date not null
);

create table DP_MANAGER
(
	MNGR_ID int foreign key references EMPLOYEE(EMP_ID),
	DP_ID int foreign key references DEPARTMENT(DP_ID)
);

create table SERVICE_COST
(
	SERV_NAME varchar(255) primary key,
	COST decimal(10, 2) not null
);

create table HOTEL_SERVICE
(
	SRVC_ID int primary key,
	SERV_NAME varchar(255) foreign key references SERVICE_COST(SERV_NAME),
	MNGR_ID int foreign key references EMPLOYEE(EMP_ID)
);

create table BILL
(
	BILL_ID int primary key,
	RSRV_ID int unique foreign key references RESERVATION(RSRV_ID),
	DATE_TIME datetime not null,
	TOTAL_PRICE decimal(10, 2) not null
);

create table BILL_SERVICE
(
	BILL_ID int foreign key references BILL(BILL_ID),
	SERV_ID int foreign key references HOTEL_SERVICE(SRVC_ID),
	constraint BIIL_OSERV unique(BILL_ID, SERV_ID)
);

insert into HOTEL
values
	(1, 'Kazakhstan', 'Dostyk Ave 52/2', 'Almaty', '8 (727) 291 91 01', 4);

insert into DEPARTMENT
values
	(1, 'Front Office', 1),
	(2, 'Reservation', 1),
	(3, 'Banquet', 1),
	(4, 'Finance', 1),
	(5, 'HR', 1),
	(6, 'Inventory', 1),
	(7, 'Security', 1),
	(8, 'Housekeeping', 1),
	(9, 'CRM', 1),
	(10, 'Quality Management', 1),
	(11, 'Energy Management', 1);

insert into GUEST
values
	(1, 'Anvar Sadyk', '8 (707) 456 90 00', 'Nur-Sultan', 'VISA, 4532099626602164'),
	(2, 'Serik Baymeken', '8 (707) 444 67 45', 'Atyrau', 'VISA, 4024007124705954'),
	(3, 'Assyl Aidar', '8 (711) 500 61 26', 'Taldykorgan', 'VISA, 4024007118383495'),
	(4, 'Arsen Sardyk', '8 (711) 627 55 36', 'Sochi', 'VISA, 4539478018205211'),
	(5, 'Kozha Zhanqulov', '8 (712) 106 63 69', 'Oral', 'VISA, 4916738312766363'),
	(6, 'Sara Bayit', '8 (349) 530 63 73', 'Moscow', 'VISA, 4716851877537392'),
	(7, 'Kenzhebek Myrzam', '8 (710) 657 27 55', 'Saryagash', 'VISA, 4024007182109552'),
	(8, 'Assyl Sadvakasova', '+996 312 465789', 'Bishkek', 'VISA, 4024007150236130'),
	(9, 'Arman Nadirkhan', '8 (702) 169 78 42', 'Oral', 'MASTERCARD, 5131419184497058'),
	(10, 'Erbolat Bedelkhan', '8 (700) 587 69 23', 'ALmaty', 'MASTERCARD, 5215578085850100'),
	(11, 'Aida Serikova', '+996 312 505709', 'Osh', 'MASTERCARD, 5541518874590801'),
	(12, 'Dana Zhetpisova', '8 (349) 880 86 33', 'Oskemen', 'MASTERCARD, 5206143089959802'),
	(13, 'Dmitriy Stepanov', '8 (835) 058 72 42', 'Saint Petersburg', 'MASTERCARD, 5212548318092724'),
	(14, 'Alex Zaytsev', '8 (346) 440 36 62', 'Kazan', 'MASTERCARD, 5544187231482941'),
	(15, 'Pelageya Petrova', '8 (437) 994 94 94', 'Novosibirsk', 'MASTERCARD, 5532823872547071');

insert into RESERVATION
values
	(1, 1, 3, '2022-03-13', '2022-03-14 14:00', '2022-03-17 12:00', 'online'),
	(2, 1, 13, '2022-01-23', '2022-01-23 17:20', '2022-02-06 09:00', 'by cash'),
	(3, 1, 10, '2022-03-08', '2022-03-08 21:00', '2022-03-13 12:00', 'by cash'),
	(4, 1, 1, '2021-12-28', '2021-12-28 19:00', '2022-01-02 12:00', 'online'),
	(5, 1, 2, '2021-12-28', '2021-12-28 21:00', '2022-01-03 9:00', 'by cash'),
	(6, 1, 4, '2022-03-06', '2022-03-08 15:00', '2022-03-10 10:00', 'online'),
	(7, 1, 5, '2022-02-23', '2022-02-23 22:00', '2022-02-24 12:00', 'online'),
	(8, 1, 6, '2021-09-20', '2021-10-14 15:00', '2021-10-28 12:00', 'online'),
	(9, 1, 7, '2021-11-23', '2021-11-23 19:00', '2021-11-27 12:00', 'by cash'),
	(10, 1, 8, '2022-03-05', '2022-03-08 20:00', '2022-03-13 09:00', 'online'),
	(11, 1, 9, '2021-08-01', '2021-08-01 16:00', '2021-08-08 12:00', 'by cash'),
	(12, 1, 11, '2021-08-01', '2021-08-01 21:21', '2021-08-03 12:00', 'by cash'),
	(13, 1, 12, '2021-08-01', '2021-08-01 21:05', '2022-03-03 12:00', 'online'),
	(14, 1, 14, '2022-01-23', '2022-01-23 17:40', '2022-02-06 09:00', 'online'),
	(15, 1, 15, '2022-01-23', '2022-01-23 17:33', '2022-02-06 09:00', 'online');

insert into ROOM_CLASS_DSCRPT
values
	('Standard Room', 'Comfortable one-room suite with two separate or one double bed. Low-cost and comfortable solutions for your stay.'),
	('Superior Room', 'Comfortable one-room suite with an interior in the Art Nouveau style with two separate beds or one double.'),
	('Junior Suite', 'Comfortable two-room suite with a large double bed in the bedroom and a comfortable sofa in the living room.'),
	('Queen Suite', 'Comfortable luxury two-room suite in the Art Nouveau style. Bedroom with a wide bed, living room with sofa and TV.'),
	('King Suite', 'Excellent three-room luxury room for business people. Bedroom with a wide bed, living room with sofa and TV, as well as conference room.');

insert into ROOM_CLASS
values
	(1, 'Standard Room', 'Single', 26000),
	(2, 'Standard Room', 'Double', 32000),
	(3, 'Junior Suite', 'Single', 35000),
	(4, 'Junior Suite', 'Double', 41000),
	(5, 'Junior Suite', 'Triple', 47000),
	(6, 'Superior Room', 'Single', 33000),
	(7, 'Superior Room', 'Double', 39000),
	(8, 'Queen Suite', 'Single', 45000),
	(9, 'Queen Suite', 'Double', 45000),
	(10, 'Queen Suite', 'Triple', 51000),
	(11, 'King Suite', 'Single', 70000),
	(12, 'King Suite', 'Double', 70000),
	(13, 'King Suite', 'Triple', 76000);

insert into ROOM_INFO
values
	(100, 1, 1, 'active'),
	(101, 1, 1, 'active'),
	(102, 2, 1, 'active'),
	(103, 2, 1, 'active'),
	(104, 2, 1, 'active'),
	(105, 1, 1, 'active'),
	(106, 3, 1, 'active'),
	(107, 3, 1, 'active'),
	(108, 4, 1, 'active'),
	(109, 4, 1, 'active'),
	(110, 4, 1, 'active'),
	(111, 5, 1, 'active'),
	(112, 5, 1, 'active'),
	(113, 5, 1, 'active'),
	(114, 6, 1, 'active'),
	(115, 6, 1, 'active'),
	(116, 7, 1, 'active'),
	(117, 7, 1, 'active'),
	(118, 7, 1, 'active'),
	(119, 6, 1, 'active'),
	(120, 6, 1, 'active'),
	(121, 8, 1, 'active'),
	(122, 8, 1, 'active'),
	(123, 8, 1, 'active'),
	(124, 9, 1, 'active'),
	(125, 9, 1, 'active'),
	(126, 10, 1, 'active'),
	(127, 10, 1, 'active'),
	(128, 11, 1, 'active'),
	(129, 12, 1, 'active'),
	(130, 13, 1, 'active');

insert into ROOM_BOOKED
values
	(1, 105),
	(2, 107),
	(3, 115),
	(4, 114),
	(5, 116),
	(6, 117),
	(7, 130),
	(8, 126),
	(9, 120),
	(10, 119),
	(11, 100),
	(12, 101),
	(13, 102),
	(14, 100),
	(15, 101);

-- set 'non-active' reserved rooms:
update ROOM_INFO
set ROOM_STATUS='non-active'
where ROOM_NO in (
select rm.ROOM_NO
from ROOM_BOOKED rm JOIN RESERVATION res ON res.RSRV_ID = rm.RSRV_ID
WHERE res.CHECK_OUT > GETDATE());

insert into POS_NAME_DSCRPT
values
	('Desk Clerk', 'Their duties include greeting visitors, updating records, making appointments, offering advice and information, and solving various problems.'),
	('Manager', 'Manager is a person responsible for controlling or administering an organization or group of staff in his(her) own departmnet'),
	('Telephone operator', 'The Telephone Operator helps people direct telephone calls. He/She may use computerized telephone directories to find telephone numbers that callers request and make connections for calls.'),
	('Cashier', 'Dispenses guest records after the guest checkout. Handles cash, traveller''s cheque, credit cards and direct billing requests properly.'),
	('Reservationist', 'A reservationist is someone who works in customer service and takes reservations for customers. They assist customers over the phone and in person, answering their questions and organizing their reservation plans.'),
	('Banquet Server', 'Responsibilities are serve food and beverages, clear tables, set up for event, assist with food preparation'),
	('Bartender', 'Mixing, garnishing and serving alcoholic and non-alcoholic drinks according to company specifications for guests at the bar and in the restaurant. Helping guests be aware of and choose menu items, taking orders and making guests feel taken care of during their visit.'),
	('Cook', 'A Cook plans, prepares, and cooks food items to ensure the highest quality service and experience for customers. They help keep the kitchen organized and running efficiently. They ensure proper food handling, sanitation and following food storage procedures.'),
	('Chef', ' Their main responsibilities include planning menus, overseeing the kitchen staff, and ensuring that the food meets high-quality standards.'),
	('Director of Finance', 'They oversee the whole department and make sure that the critical tasks are being performed on time and correctly.'),
	('Financial Controller', 'Financial Controller is managing the day to day operations of the department. This includes preparation and management of the hotels financial budgets, ensuring that the hotel is in compliance with the local tax laws and any other operating procedures.'),
	('Purchasing Manager', 'They ensures: that the contracts between the hotel and the external suppliers are in place, that the goods are of good quality, negotiate partnership deals with brands for long standing offers or short term promotions and negotiate the prices with supplier.'),
	('HR Manager', 'Responsibilies: Designing hiring plans for all hotel departments based on seasonal needs, managing compensation and benefits plans, overseeing employee attendance and working schedules, including paid time off, overtime and breaks'),
	('HR Assistant', 'They handles the daily administrative and HR duties of an organization. They assist HR managers with recruitment, record maintenance and payroll processing, and provide clerical support to all employees.'),
	('Inventory Manager/ Hotel Controller', 'The Hotel Controllers primary responsibility is the management and oversight of onboard storeroom inventory and accurate reporting of inventory data. The Hotel Controller audits all invoices and requisitions of incoming and outgoing products to and from main storeroom.'),
	('Security Officer', 'Security officers stationed at the hotels entrances and exits monitor the steady stream of people coming into and out of the hotel at all hours. Officers can identify suspicious individuals or activities and prevent situations from escalating.'),
	('Security Guard', 'They help protect guests and their valuables, as well as fellow hotel employees. Typically, hotel security guards do not carry firearms.'),
	('Room Attendant', 'Duties and responsibilities of housekeeping attendant include: cleaning guestrooms mid-stay and after departure, making beds, replacing dirty linens and towels, Restocking guestroom amenities like toiletries, drinking glasses, and notepads and etc..'),
	('Public Area Attendant', 'Responsibiliies: Cleaning public spaces like lobbies, restaurants, and meeting rooms, Cleaning back-of-house areas like office and employee changing rooms, Cleaning stairways, hallways, and elevators and etc..'),
	('Laundry/Linen Room Attendant', 'Responsibilies: Sorting, washing, drying, folding, ironing, and organizing all hotel laundry, which can include towels, sheets, bathrobes, napkins, tablecloths, uniforms, and more.'),
	('Hotel Manager', 'They plan, organize, coordinate, supervise and evaluate the activities and administrative processes of the hotel establishment. These professionals are responsible for all the hotel services, including the reception, the services of Keys, reservations, banquets, maintenance and restoration.'),
	('CRM Manager', 'They work with CRM software.'),
	('CRM Specialist', 'CRM consultants work with businesses to identify areas where customer service could be improved, which might mean introducing new customer relation management software or training employees on customer support best practices.'),
	('Quality Manager', 'They are responsible for consistent delivery of service that meets the high standards set by the corporation or owners of a hotel.'),
	('Energy Manager' , 'The role of an Energy Manager (EM) involves facilitating energy conservation by identifying and implementing various options for saving energy, leading awareness programs, and monitoring energy consumption.');

insert into POSITION
values
	(1, 'Manager'),
	(2, 'Desk Clerk'),
	(3, 'Telephone operator'),
	(4, 'Cashier'),
	(5, 'Reservationist'),
	(6, 'Banquet Server'),
	(7, 'Bartender'),
	(8, 'Cook'),
	(9, 'Chef'),
	(10, 'Director of Finance'),
	(11, 'Financial Controller'),
	(12, 'Purchasing Manager'),
	(13, 'HR Manager'),
	(14, 'HR Assistant'),
	(15, 'Inventory Manager/ Hotel Controller'),
	(16, 'Security Officer'),
	(17, 'Security Guard'),
	(18, 'Room Attendant'),
	(19, 'Public Area Attendant'),
	(20, 'Laundry/Linen Room Attendant'),
	(21, 'Hotel Manager'),
	(22, 'CRM Manager'),
	(23, 'CRM Specialist'),
	(24, 'Quality Manager'),
	(25, 'Energy Manager');

insert into EMPLOYEE
values
	(1, 1, 1, 'Taras Timourev', '8 (707) 067 06 56', 'tar_timu@mail.ru', 'Ul. Begalieva, bld. 14, appt. 5', 200000, '2014.02.15'),
	(2, 1, 2, 'Talgat Zhandos', '8 (717) 390 53 02', 'tal_zh@mail.ru', 'Kirova, bld. 32', 95000, '2018.03.17'),
	(3, 1, 3, 'Marat Daniyarbekev', '8 (705) 434 32 71', 'mara_d@mail.ru', ' M/r 15, bld. 3, appt. 30', 90000, '2018.03.25'),
	(4, 1, 4, 'Amina Aman', '8 (714) 909 09 81', 'amina_mn@mail.ru', 'Akademika Satpaeva, bld. 40, appt. 1', 95000, '2019.04.15'),
	(5, 2, 5, 'Samal Aidarova', '8 (707) 898 82 21', 'samal_AI@mail.ru', 'Suleymenova, bld. 8, appt. 72', 95000, '2016.02.04'),
	(6, 2, 5, 'Uljan Kairatova', '8 (700) 881 92 14', 'ulj_kai@gmail.com', 'Ul. Valikhanova, bld. 53', 95000, '2015.09.05'),
	(7, 2, 1, 'Rustem Yerbolatev', '8 (777) 300 95 33', 'rus_bol@gmail.com', 'Mkr.tastak-2, bld. 8, appt. 155', 200000, '2018.12.01'),
	(8, 3, 1, 'Aziza Kuanyshova', '8 (711) 636 08 04', 'azi_kuan@mail.ru', 'Pr.abylay KHana, bld. 34/Office 103', 300000, '2017.09.29'),
	(9, 3, 6, 'Eric Yerbolev', '8 (707) 367 68 09', 'yeric_b&gmail.com', 'Ul.michurino Michurino, bld. 23', 90000, '2020.12.12'),
	(10, 3, 6, 'Daryn Amandyq', '8 (711) 648 98 64', 'daryn_amandyq@gmail.com', 'Mkr.kazakhfilm, bld. 8, appt. 84', 90000, '2020.12.12'),
	(11, 3, 7, 'Nurjigit Nurjigitev', '8 (780) 826 47 61', 'nur_nur@inbox.ru', 'Pr. Bigeldinova (Aviatorov), bld. 15, appt. 1', 100000, '2018.05.18'),
	(12, 3, 8, 'Yedil Sultanov', '8 (777) 780 02 35', null, 'Ul.dulatova, bld. 18, appt. 1', 120000, '2019.08.12'),
	(13, 3, 8, 'Arman Sultanov', '8 (707) 880 99 34', 'arman_sula@gmail.com', 'Ul.dulatova, bld. 18, appt. 1', 120000, '2019.05.01'),
	(14, 3, 9, 'Kapan Almasev', null, 'kapan_ofc@gmail.com', 'Donetskaya, bld. 8, appt. 159', 400000, '2020.04.17'),
	(15, 4, 10, 'Askar Ershatev', '8 (747) 988 31 05', 'askar_ersh@gmail.com', 'Mkr.6, bld. 56', 450000, '2016.10.09'),
	(16, 4, 11, 'Temirzhan Hojaniasov', '8 (717) 507 58 26', 'temirzh-zh@gmail.com', ' Mkr. 12, bld. 5, appt. 29', 150000, '2017.05.05'),
	(17, 4, 11, 'Dariga Azamatova', '8 (777) 265 20 51', 'dari_aza@mail.ru', 'Tallinskaya, bld. 107, appt. 1', 150000, '2017.06.01'),
	(18, 4, 12, 'Kuanysh Fauskeev', '8 (707) 865 03 67', 'fausk-ysh@gmail.com', 'Mkr.almagul, bld. 17, appt. 52', 250000, '2016.12.20'),
	(19, 5, 13, 'Zere Maratova', '8 (747) 583 13 46', 'zere-m@mail.ru', 'Mkr.6, bld. 7, appt. 19', 325000, '2016.12.25'),
	(20, 5, 14, 'Raziya Amireva', '8 (704) 984 43 34', 'raxi_amir@gmail.com', 'Taysoygan / Ul. Samarkhanov, bld. 43', 150000, '2021.04.30'),
	(21, 6, 15, 'Rasul Bakhytzhanev', '8 (711) 343 23 55', 'rasul-b@mail.ru', 'SHakerima, bld. 12, appt. 45', 200000, '2019.05.12'),
	(22, 6, 15, 'Ershat Yerzhanev', '8 (782) 342 53 54', 'ersh_yer@gmial.com', 'Ul.tairova, bld. 54, appt. 3', 200000, '2018.05.27'),
	(23, 6, 1, 'Medet Diasov', '8 (717) 483 26 33' , 'medet_di@inbox.ru', 'Auezova M., bld. 21/1, appt. 75', 200000, '2018. 05. 01'),
	(24, 7, 16, 'Sayat Akturov', '8 (701) 456 40 54', 'say-ak@gmail.com', 'Ul.13 Voennyy Gorodok, bld. 24, appt. 22', 150000, '2019.05.02'),
	(25, 7, 17, 'Baymeken Kaldybai', '8 (712) 165 54 94', 'bay_kal@mail.ru', 'Promyshlennyy / 30 Let TSeliny Ul., bld. 2, appt. 30', 95000, '2019.11.11'),
	(26, 7, 17, 'Iskander Orazev', '8 (747) 403 51 75', 'iskande_o@gmail.com', 'Ul.tole Bi, bld. 111', 95000, '2019.06.04'),
	(27, 8, 1, 'Samal Beisenbekova', '8 (708) 450 64 87', 'samal-beis@mail.ru', 'Kataeva, bld. 31, appt. 23', 150000, '2016.04.18'),
	(28, 8, 18, 'Jarkin Bolateva', '8 (702) 545 21 87', 'jark_bol@gmail.com', 'Auezova M., bld. 26, appt. 51', 80000, '2018.04.26'),
	(29, 8, 18, 'Meyramgul Kapanova', '8 (708) 498 65 41', 'meyram@mail.ru', 'Ul. Toktybaeva, bld. 18', 80000, '2018.04.26'),
	(30, 8, 19, 'Ayia-Napa Tairova', '8 (704) 644 46 98', 'aynap-t@gmail.com', '11 Mikrorayon, bld. 19, appt. 98', 80000, '2018.01.28'),
	(31, 8, 19, 'Dariya Kairatova', '8 (712) 867 65 12', 'dar_kair@gmail.com', '6 Liniya, bld. 50', 80000, '2018.02.04'),
	(32, 8, 20, 'Aiman Amanetova', '8 (777) 458 99 20', 'aiman_amanti@mail.ru', 'Ul.muratbaeva, bld. 183, appt. 57', 80000, '2019.01.25'),
	(33, 9, 22, 'Almas Amanetev', '8 (701) 343 09 98', 'almas_amant@gmail.com', 'Ul.telman B Maylina, bld. 33', 300000, '2019.02.17'),
	(34, 9, 23, 'Nuriya Iliyaseva', '8 (706) 754 65 86', 'nur_il@mail.ru', 'Mkr. 3 / Musheltoy, bld. 25, appt. 32', 175000, '2020.06.18'),
	(35, 10, 21, 'Rasul Adilev', '8 (702) 469 88 87', 'rasul_adilev@mail.ru', 'Ul.isataya,mkr.kalkaman, bld. 22/a', 350000, '2017.08.16'),
	(36, 10, 24, 'Raya Adilova', '8 (707) 907 73 22', 'raya_ad@mail.ru', 'Kyzyl-Balyk / Ul. K.kurmasheva, bld. 105', 200000, '2018.12.11'),
	(37, 11, 25, 'Arman Dastanev', '8 (711) 498 21 68', 'arm_dast@inbox.ru', 'Ul.respubliki, bld. 15/a, appt. 30', 400000, '2018.01.09');

insert into DP_MANAGER
values
	(1, 1),
	(7, 2),
	(8, 3),
	(14, 4),
	(18, 5),
	(22, 6),
	(23, 7),
	(26, 8),
	(32, 9),
	(34, 10),
	(36, 11);

insert into SERVICE_COST
values
	('In-room breakfast', 5000),
	('Coffee/Tea in lobby', 5000),
	('Karaoke', 8000),
	('Night club', 8000),
	('Live entertainment', 15000),
	('Tea and coffee facilities', 5000),
	('Babysitting/Child services', 15000),
	('Doctor on call', 10000),
	('Room service (24-hour)', 8000),
	('Ticket service', 3000);

insert into HOTEL_SERVICE
values
	(1, 'In-room breakfast', 8),
	(2, 'Coffee/Tea in lobby', 8),
	(3, 'Karaoke', 36),
	(4, 'Night club', 36),
	(5, 'Live entertainment', 35),
	(6, 'Tea and coffee facilities', 8),
	(7, 'Doctor on call', 1),
	(8, 'Room service (24-hour)', 27),
	(9, 'Ticket service', 7);

-- fill BILL table with default values
declare @cnt int;
set @cnt = 1;
while @cnt <=15
begin
	insert into BILL
	VALUES(@cnt, @cnt, GETDATE(), 0)
	set @cnt = @cnt + 1
end;

-- insert actual values of TOTAL_PRICE and DATE_TIME
update BILL
set DATE_TIME = res.CHECK_OUT,
TOTAL_PRICE = rc.PRICE * DATEDIFF(day, res.CHECK_IN, res.CHECK_OUT)
from BILL b
	JOIN RESERVATION res ON res.RSRV_ID = b.RSRV_ID
	JOIN ROOM_BOOKED rb ON rb.RSRV_ID = res.RSRV_ID
	JOIN ROOM_INFO ri ON ri.ROOM_NO = rb.ROOM_NO
	JOIN ROOM_CLASS rc ON rc.CLASS_ID = ri.ROOM_CL_ID

insert into BILL_SERVICE
values
	(1, 1),
	(1, 8),
	(1, 2),
	(2, 2),
	(2, 8),
	(2, 9),
	(3, 1),
	(3, 8),
	(3, 5),
	(3, 3),
	(4, 4),
	(4, 5),
	(4, 8),
	(5, 7),
	(6, 2),
	(6, 8),
	(8, 8),
	(8, 1),
	(8, 9),
	(9, 8),
	(9, 4),
	(10, 2),
	(10, 6),
	(10, 8),
	(10, 9),
	(11, 8),
	(11, 6),
	(12, 8),
	(12, 5),
	(13, 7),
	(14, 1),
	(14, 6),
	(14, 8),
	(14, 9),
	(15, 1),
	(15, 2),
	(15, 8);

-- add Costs of used services to the TOTAL_PRICE in BILL
update BILL
set TOTAL_PRICE = TOTAL_PRICE + bill_serv_cost.service_cost
from BILL b
	JOIN
	(select bs.BILL_ID, sum(sc.COST) as service_cost
	from BILL b
		join BILL_SERVICE bs on b.BILL_ID = bs.BILL_ID
		join HOTEL_SERVICE s on s.SRVC_ID = bs.SERV_ID
		join SERVICE_COST sc on sc.SERV_NAME = s.SERV_NAME
	group by bs.BILL_ID
) bill_serv_cost
	ON bill_serv_cost.BILL_ID = b.BILL_ID


-- Queries

-- 1. Output active(free) room numbers and their class name
select ri.ROOM_NO, rc.CLASS_NAME
from ROOM_INFO ri
	join ROOM_CLASS rc on rc.CLASS_ID = ri.ROOM_CL_ID
where ri.ROOM_STATUS = 'active';

-- 2. Show services of each guests
select g.GUEST_ID, g.FULL_NAME, hc.SERV_NAME
from ((GUEST g
	join RESERVATION rsrv on g.GUEST_ID = rsrv.GUEST_ID)
	join BILL bll on bll.RSRV_ID = rsrv.RSRV_ID)
	join (BILL_SERVICE bc join HOTEL_SERVICE hc on hc.SRVC_ID = bc.SERV_ID)
	on bc.BILL_ID = bll.BILL_ID;

-- 3. Show how many day left for inactive rooms
select ri.ROOM_NO, datediff(day, getdate(), rsrv.CHECK_OUT) as LEFT_DAY
from ROOM_INFO ri
	join (RESERVATION rsrv join ROOM_BOOKED rb on rsrv.RSRV_ID = rb.RSRV_ID)
	on rb.ROOM_NO = ri.ROOM_NO
where ri.ROOM_STATUS = 'non-active';

-- 4. Show employees that both service manager and department manager
select distinct emp.EMP_ID, emp.FULL_NAME, pos.POS_NAME, pos_d.POS_DSCRPT
from (HOTEL_SERVICE hs
	join EMPLOYEE emp on emp.EMP_ID = hs.MNGR_ID)
	join DP_MANAGER dm on dm.MNGR_ID = emp.EMP_ID
	join POSITION pos on pos.POS_ID = emp.POS_ID
	join POS_NAME_DSCRPT pos_d on pos_d.POS_NAME = pos.POS_NAME;

-- 5. display employees who are responsible for hotel security with their positions description
select e.FULL_NAME, d.DP_NAME, p.POS_NAME, pd.POS_DSCRPT
from EMPLOYEE e
	join POSITION p on p.POS_ID = e.POS_ID
	join DEPARTMENT d on d.DP_ID = e.DP_ID
	join POS_NAME_DSCRPT pd on pd.POS_NAME = p.POS_NAME
where d.DP_NAME = 'Security';

-- 6. display number of employees for each department
select d.DP_NAME, t.EMP_NUM
from DEPARTMENT d, (
    select e.DP_ID, count(e.DP_ID) as EMP_NUM
	from EMPLOYEE e
	group by e.DP_ID
) t
where d.DP_ID = t.DP_ID

-- 7. client wants to know reservation details using bill id
select r.RSRV_DATE, r.CHECK_IN, r.CHECK_OUT, rb.ROOM_NO, rc.CLASS_NAME, rc.CLASS_TYPE, rc.PRICE as ROOM_PRICE, b.TOTAL_PRICE
from BILL b
	join RESERVATION r on r.RSRV_ID = b.RSRV_ID
	join ROOM_BOOKED rb on rb.RSRV_ID = r.RSRV_ID
	join ROOM_INFO ri on ri.ROOM_NO = rb.ROOM_NO
	join ROOM_CLASS rc on rc.CLASS_ID = ri.ROOM_CL_ID
where b.BILL_ID = 8
