USE login;

CREATE TABLE IF NOT EXISTS STUDY_PROGRESS (
  MATERIAL_ID    INT UNSIGNED NOT NULL,
  `S.ROLL`       VARCHAR(20) NOT NULL,
  PROGRESS_STATUS ENUM('not_started','in_progress','completed') NOT NULL DEFAULT 'not_started',
  COMPLETED_AT   DATETIME NULL,
  updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (MATERIAL_ID, `S.ROLL`),
  CONSTRAINT fk_studyprog_material FOREIGN KEY (MATERIAL_ID) REFERENCES STUDY_MATERIALS(MATERIAL_ID) ON DELETE CASCADE,
  CONSTRAINT fk_studyprog_student  FOREIGN KEY (`S.ROLL`)      REFERENCES STUDENT(ROLL) ON DELETE CASCADE,
  INDEX idx_studyprog_roll (`S.ROLL`, PROGRESS_STATUS)
) ENGINE=InnoDB;

-- 1. TEACHER_LOGIN   (50 teachers, T001 - T050)
INSERT INTO TEACHER_LOGIN (TID, PASSWORD) VALUES
('T001','teach123'),('T002','teach123'),('T003','teach123'),('T004','teach123'),('T005','teach123'),
('T006','teach123'),('T007','teach123'),('T008','teach123'),('T009','teach123'),('T010','teach123'),
('T011','teach123'),('T012','teach123'),('T013','teach123'),('T014','teach123'),('T015','teach123'),
('T016','teach123'),('T017','teach123'),('T018','teach123'),('T019','teach123'),('T020','teach123'),
('T021','teach123'),('T022','teach123'),('T023','teach123'),('T024','teach123'),('T025','teach123'),
('T026','teach123'),('T027','teach123'),('T028','teach123'),('T029','teach123'),('T030','teach123'),
('T031','teach123'),('T032','teach123'),('T033','teach123'),('T034','teach123'),('T035','teach123'),
('T036','teach123'),('T037','teach123'),('T038','teach123'),('T039','teach123'),('T040','teach123'),
('T041','teach123'),('T042','teach123'),('T043','teach123'),('T044','teach123'),('T045','teach123'),
('T046','teach123'),('T047','teach123'),('T048','teach123'),('T049','teach123'),('T050','teach123');

-- 2. TEACHER   (50 rows)
INSERT INTO TEACHER (TID, NAME, EMAIL, DEPT, DESIGNATION) VALUES
('T001','Aarav Sharma','teacher01@uni.edu','Computer Science','Professor'),
('T002','Priya Nair','teacher02@uni.edu','Computer Science','Professor'),
('T003','Rohan Verma','teacher03@uni.edu','Computer Science','Assistant Professor'),
('T004','Sneha Iyer','teacher04@uni.edu','Computer Science','Assistant Professor'),
('T005','Karan Malhotra','teacher05@uni.edu','Computer Science','Lecturer'),
('T006','Ananya Gupta','teacher06@uni.edu','Computer Science','Lecturer'),
('T007','Vikram Singh','teacher07@uni.edu','Computer Science','Associate Professor'),
('T008','Meera Reddy','teacher08@uni.edu','Computer Science','Professor'),
('T009','Aditya Joshi','teacher09@uni.edu','Computer Science','Lecturer'),
('T010','Pooja Menon','teacher10@uni.edu','Computer Science','Assistant Professor'),
('T011','Rahul Desai','teacher11@uni.edu','Computer Science','Lecturer'),
('T012','Kavya Pillai','teacher12@uni.edu','Computer Science','Associate Professor'),
('T013','Arjun Rao','teacher13@uni.edu','Mathematics','Professor'),
('T014','Divya Menon','teacher14@uni.edu','Mathematics','Assistant Professor'),
('T015','Sanjay Kumar','teacher15@uni.edu','Mathematics','Professor'),
('T016','Neha Agarwal','teacher16@uni.edu','Mathematics','Lecturer'),
('T017','Arjun Bhat','teacher17@uni.edu','Mathematics','Lecturer'),
('T018','Pooja Kulkarni','teacher18@uni.edu','Mathematics','Associate Professor'),
('T019','Manish Yadav','teacher19@uni.edu','Mathematics','Assistant Professor'),
('T020','Sneha Chawla','teacher20@uni.edu','Mathematics','Lecturer'),
('T021','Rahul Bose','teacher21@uni.edu','Mathematics','Professor'),
('T022','Anjali Chakraborty','teacher22@uni.edu','Mathematics','Lecturer'),
('T023','Nikhil Ranjan','teacher23@uni.edu','Mathematics','Assistant Professor'),
('T024','Megha Sinha','teacher24@uni.edu','Mathematics','Lecturer'),
('T025','Arjun Pandey','teacher25@uni.edu','Cyber Security','Professor'),
('T026','Divya Sundaram','teacher26@uni.edu','Cyber Security','Professor'),
('T027','Karthik Subramanian','teacher27@uni.edu','Cyber Security','Associate Professor'),
('T028','Neha Varma','teacher28@uni.edu','Cyber Security','Assistant Professor'),
('T029','Sanjay Thakur','teacher29@uni.edu','Cyber Security','Lecturer'),
('T030','Pooja Ranganathan','teacher30@uni.edu','Cyber Security','Professor'),
('T031','Vikram Chauhan','teacher31@uni.edu','Cyber Security','Lecturer'),
('T032','Sneha Bhatt','teacher32@uni.edu','Cyber Security','Assistant Professor'),
('T033','Rahul Trivedi','teacher33@uni.edu','Cyber Security','Lecturer'),
('T034','Ananya Dutta','teacher34@uni.edu','Cyber Security','Professor'),
('T035','Karan Kapoor','teacher35@uni.edu','Cyber Security','Associate Professor'),
('T036','Megha Iyengar','teacher36@uni.edu','Cyber Security','Assistant Professor'),
('T037','Manoj Tiwari','teacher37@uni.edu','Cyber Security','Lecturer'),
('T038','Priyanka Naidu','teacher38@uni.edu','Cyber Security','Lecturer'),
('T039','Santosh Hegde','teacher39@uni.edu','Cyber Security','Assistant Professor'),
('T040','Divya Ghosh','teacher40@uni.edu','Cyber Security','Professor'),
('T041','Arindam Sen','teacher41@uni.edu','General','Lecturer'),
('T042','Nandini Pillai','teacher42@uni.edu','General','Assistant Professor'),
('T043','Vivek Chaudhary','teacher43@uni.edu','General','Lecturer'),
('T044','Shruti Patil','teacher44@uni.edu','General','Associate Professor'),
('T045','Rahul Barman','teacher45@uni.edu','General','Lecturer'),
('T046','Deepika Solanki','teacher46@uni.edu','General','Assistant Professor'),
('T047','Ajay Mukherjee','teacher47@uni.edu','General','Professor'),
('T048','Bhavana Rao','teacher48@uni.edu','General','Lecturer'),
('T049','Gaurav Sethi','teacher49@uni.edu','General','Professor'),
('T050','Kavya Deshmukh','teacher50@uni.edu','General','Lecturer');

-- 3. STUDENT_LOGIN   (50 students, CS001 - CS050)
INSERT INTO STUDENT_LOGIN (ROLL, PASSWORD) VALUES
('CS001','stud123'),('CS002','stud123'),('CS003','stud123'),('CS004','stud123'),('CS005','stud123'),
('CS006','stud123'),('CS007','stud123'),('CS008','stud123'),('CS009','stud123'),('CS010','stud123'),
('CS011','stud123'),('CS012','stud123'),('CS013','stud123'),('CS014','stud123'),('CS015','stud123'),
('CS016','stud123'),('CS017','stud123'),('CS018','stud123'),('CS019','stud123'),('CS020','stud123'),
('CS021','stud123'),('CS022','stud123'),('CS023','stud123'),('CS024','stud123'),('CS025','stud123'),
('CS026','stud123'),('CS027','stud123'),('CS028','stud123'),('CS029','stud123'),('CS030','stud123'),
('CS031','stud123'),('CS032','stud123'),('CS033','stud123'),('CS034','stud123'),('CS035','stud123'),
('CS036','stud123'),('CS037','stud123'),('CS038','stud123'),('CS039','stud123'),('CS040','stud123'),
('CS041','stud123'),('CS042','stud123'),('CS043','stud123'),('CS044','stud123'),('CS045','stud123'),
('CS046','stud123'),('CS047','stud123'),('CS048','stud123'),('CS049','stud123'),('CS050','stud123');

-- 4. STUDENT   (50 rows, SEM cycles 3..8)
INSERT INTO STUDENT (ROLL, NAME, EMAIL, DEPT, SEM) VALUES
('CS001','Aditya Sharma','student01@uni.edu','Computer Science',3),
('CS002','Bhavana Patel','student02@uni.edu','Computer Science',3),
('CS003','Rohan Gupta','student03@uni.edu','Computer Science',3),
('CS004','Neha Reddy','student04@uni.edu','Computer Science',3),
('CS005','Karan Malhotra','student05@uni.edu','Computer Science',4),
('CS006','Priya Nair','student06@uni.edu','Computer Science',4),
('CS007','Vikram Singh','student07@uni.edu','Computer Science',4),
('CS008','Ananya Iyer','student08@uni.edu','Computer Science',4),
('CS009','Arjun Rao','student09@uni.edu','Computer Science',4),
('CS010','Meera Joshi','student10@uni.edu','Computer Science',5),
('CS011','Nikhil Verma','student11@uni.edu','Computer Science',5),
('CS012','Kavya Menon','student12@uni.edu','Computer Science',5),
('CS013','Rahul Desai','student13@uni.edu','Computer Science',5),
('CS014','Divya Pillai','student14@uni.edu','Computer Science',5),
('CS015','Sanjay Kumar','student15@uni.edu','Computer Science',6),
('CS016','Pooja Agarwal','student16@uni.edu','Computer Science',6),
('CS017','Yash Bhat','student17@uni.edu','Computer Science',6),
('CS018','Sneha Kulkarni','student18@uni.edu','Computer Science',6),
('CS019','Manish Yadav','student19@uni.edu','Computer Science',6),
('CS020','Riya Chawla','student20@uni.edu','Computer Science',6),
('CS021','Rahul Bose','student21@uni.edu','Computer Science',6),
('CS022','Anjali Chakraborty','student22@uni.edu','Computer Science',7),
('CS023','Nikhil Ranjan','student23@uni.edu','Computer Science',7),
('CS024','Megha Sinha','student24@uni.edu','Computer Science',7),
('CS025','Arjun Pandey','student25@uni.edu','Computer Science',7),
('CS026','Divya Sundaram','student26@uni.edu','Computer Science',7),
('CS027','Karthik Subramanian','student27@uni.edu','Computer Science',7),
('CS028','Neha Varma','student28@uni.edu','Computer Science',8),
('CS029','Sanjay Thakur','student29@uni.edu','Computer Science',8),
('CS030','Pooja Ranganathan','student30@uni.edu','Computer Science',8),
('CS031','Vikram Chauhan','student31@uni.edu','Computer Science',8),
('CS032','Ishita Bhatt','student32@uni.edu','Computer Science',8),
('CS033','Rahul Trivedi','student33@uni.edu','Computer Science',8),
('CS034','Ananya Dutta','student34@uni.edu','Computer Science',3),
('CS035','Karan Kapoor','student35@uni.edu','Computer Science',3),
('CS036','Megha Iyengar','student36@uni.edu','Computer Science',3),
('CS037','Manoj Tiwari','student37@uni.edu','Computer Science',4),
('CS038','Priyanka Naidu','student38@uni.edu','Computer Science',4),
('CS039','Santosh Hegde','student39@uni.edu','Computer Science',4),
('CS040','Divya Ghosh','student40@uni.edu','Computer Science',4),
('CS041','Arindam Sen','student41@uni.edu','Computer Science',5),
('CS042','Nandini Pillai','student42@uni.edu','Computer Science',5),
('CS043','Vivek Chaudhary','student43@uni.edu','Computer Science',5),
('CS044','Shruti Patil','student44@uni.edu','Computer Science',5),
('CS045','Rahul Barman','student45@uni.edu','Computer Science',6),
('CS046','Deepika Solanki','student46@uni.edu','Computer Science',6),
('CS047','Ajay Mukherjee','student47@uni.edu','Computer Science',6),
('CS048','Bhavana Rao','student48@uni.edu','Computer Science',7),
('CS049','Gaurav Sethi','student49@uni.edu','Computer Science',7),
('CS050','Kavya Deshmukh','student50@uni.edu','Computer Science',7);

-- 5. COURSES   (the 5 courses + their owner teacher)
INSERT INTO COURSES (COURSE_ID, COURSE_NAME, CREDITS, TID) VALUES
('C001','Programming',4.0,'T001'),
('C002','Discrete Math',3.0,'T013'),
('C003','Reverse Engineering',4.0,'T025'),
('C004','Pentesting',4.0,'T026'),
('C005','Soc',2.0,'T041');

-- 6. STU_COURSES   (250 rows = 50 students x 5 courses)
INSERT INTO STU_COURSES (`S.ROLL`, C_ID, status)
SELECT s.ROLL, c.COURSE_ID, 'enrolled'
FROM STUDENT s CROSS JOIN COURSES c;

UPDATE STU_COURSES SET status = 'dropped'
WHERE (`S.ROLL` = 'CS014' AND C_ID = 'C004')
   OR (`S.ROLL` = 'CS023' AND C_ID = 'C002')
   OR (`S.ROLL` = 'CS037' AND C_ID = 'C001');

UPDATE STU_COURSES SET status = 'completed'
WHERE (`S.ROLL` IN ('CS001','CS002','CS003','CS004','CS005') AND C_ID = 'C001')
   OR (`S.ROLL` IN ('CS009','CS010','CS011') AND C_ID = 'C002');

-- 7. ASSESSMENTS   (15 rows = 5 courses x CT-1, CT-2, Final Exam)
INSERT INTO ASSESSMENTS (COURSE_ID, TITLE, MAX_MARKS, WEIGHT, ASSESSMENT_DATE) VALUES
('C001','CT-1',30.00,20.00,'2026-08-10'),('C001','CT-2',30.00,20.00,'2026-09-01'),('C001','Final Exam',40.00,60.00,'2026-09-28'),
('C002','CT-1',30.00,20.00,'2026-08-11'),('C002','CT-2',30.00,20.00,'2026-09-02'),('C002','Final Exam',40.00,60.00,'2026-09-28'),
('C003','CT-1',30.00,20.00,'2026-08-12'),('C003','CT-2',30.00,20.00,'2026-09-03'),('C003','Final Exam',40.00,60.00,'2026-09-29'),
('C004','CT-1',30.00,20.00,'2026-08-13'),('C004','CT-2',30.00,20.00,'2026-09-04'),('C004','Final Exam',40.00,60.00,'2026-09-29'),
('C005','CT-1',30.00,20.00,'2026-08-14'),('C005','CT-2',30.00,20.00,'2026-09-07'),('C005','Final Exam',40.00,60.00,'2026-09-30');

-- 8. ACADEMICS   (750 rows = 15 assessments x 50 students)
INSERT INTO ACADEMICS (ASSESSMENT_ID, `S.ROLL`, SEM_MARKS, REMARKS, entered_by)
SELECT t.ASSESSMENT_ID, t.ROLL, t.MARKS,
       CASE WHEN t.MARKS / t.MAX_MARKS < 0.40 THEN 'Fail' ELSE 'Pass' END,
       t.TID
FROM (
  SELECT a.ASSESSMENT_ID, s.ROLL, c.TID, a.MAX_MARKS,
         ROUND(LEAST(a.MAX_MARKS, a.MAX_MARKS * (0.55 + MOD(CRC32(CONCAT(s.ROLL, a.ASSESSMENT_ID)), 46) / 100)), 2) AS MARKS
  FROM ASSESSMENTS a
  JOIN COURSES c ON c.COURSE_ID = a.COURSE_ID
  CROSS JOIN STUDENT s
) t;

-- 9. SEED_CLASS_DAYS  (12 weekday class days, helper table)
CREATE TABLE IF NOT EXISTS SEED_CLASS_DAYS (CLASS_DATE DATE NOT NULL PRIMARY KEY) ENGINE=InnoDB;

INSERT INTO SEED_CLASS_DAYS (CLASS_DATE) VALUES
('2026-08-03'),('2026-08-06'),('2026-08-10'),('2026-08-13'),
('2026-08-17'),('2026-08-20'),('2026-08-24'),('2026-08-27'),
('2026-08-31'),('2026-09-03'),('2026-09-07'),('2026-09-10');

-- 10. ATTENDENCE   (3000 rows = 5 courses x 12 days x 50 students)
INSERT INTO ATTENDENCE (COURSE_ID, `S.ROLL`, CLASS_DATE, ATTENDENCE_STATUS, marked_by)
SELECT c.COURSE_ID, s.ROLL, d.CLASS_DATE,
       CASE MOD(CRC32(CONCAT(s.ROLL, c.COURSE_ID, d.CLASS_DATE)), 10)
         WHEN 0 THEN 'absent'
         WHEN 1 THEN 'late'
         WHEN 2 THEN 'excused'
         ELSE 'present'
       END,
       c.TID
FROM COURSES c
CROSS JOIN STUDENT s
CROSS JOIN SEED_CLASS_DAYS d;

-- 11. STUDY_MATERIALS   (100 rows = 20 per course)
INSERT INTO STUDY_MATERIALS (COURSE_ID, TITLE, DESCRIPTION, FILE_PATH, FILE_TYPE, FILE_SIZE, uploaded_by) VALUES
('C001','Programming Unit 1 - Fundamentals Notes','Intro, variables, operators, control flow','materials/C001/unit-01-notes.pdf','pdf',184320,'T001'),
('C001','Programming Unit 1 - Slides','Lecture slide deck for unit 1','materials/C001/unit-01-slides.pdf','pdf',1245184,'T001'),
('C001','Programming Unit 1 - Lab Sheet','Lab exercises for unit 1','materials/C001/unit-01-lab.pdf','pdf',232448,'T001'),
('C001','Programming Unit 2 - Functions Notes','Functions, recursion, scope','materials/C001/unit-02-notes.pdf','pdf',196608,'T001'),
('C001','Programming Unit 2 - Slides','Lecture slide deck for unit 2','materials/C001/unit-02-slides.pdf','pdf',1310720,'T001'),
('C001','Programming Unit 2 - Lab Sheet','Lab exercises for unit 2','materials/C001/unit-02-lab.pdf','pdf',245760,'T001'),
('C001','Programming Unit 3 - Arrays Notes','Arrays, strings, sorting','materials/C001/unit-03-notes.pdf','pdf',212992,'T001'),
('C001','Programming Unit 3 - Slides','Lecture slide deck for unit 3','materials/C001/unit-03-slides.pdf','pdf',1187840,'T001'),
('C001','Programming Unit 3 - Lab Sheet','Lab exercises for unit 3','materials/C001/unit-03-lab.pdf','pdf',204800,'T001'),
('C001','Programming Unit 4 - OOP Notes','Classes, objects, inheritance, polymorphism','materials/C001/unit-04-notes.pdf','pdf',241664,'T001'),
('C001','Programming Unit 4 - Slides','Lecture slide deck for unit 4','materials/C001/unit-04-slides.pdf','pdf',1363148,'T001'),
('C001','Programming Unit 4 - Lab Sheet','Lab exercises for unit 4','materials/C001/unit-04-lab.pdf','pdf',225280,'T001'),
('C001','Programming Unit 5 - File Handling Notes','Files, exceptions, debugging','materials/C001/unit-05-notes.pdf','pdf',198656,'T001'),
('C001','Programming Unit 5 - Slides','Lecture slide deck for unit 5','materials/C001/unit-05-slides.pdf','pdf',1284096,'T001'),
('C001','Programming Unit 5 - Lab Sheet','Lab exercises for unit 5','materials/C001/unit-05-lab.pdf','pdf',215040,'T001'),
('C001','Programming Previous Year Paper 2024','Full question paper with answers','materials/C001/pyp-2024.pdf','pdf',655360,'T001'),
('C001','Programming Previous Year Paper 2023','Full question paper with answers','materials/C001/pyp-2023.pdf','pdf',634880,'T001'),
('C001','Programming Assignment 1 Solution','Step by step reference solution','materials/C001/assignment-01.pdf','pdf',286720,'T001'),
('C001','Programming Assignment 2 Solution','Step by step reference solution','materials/C001/assignment-02.pdf','pdf',296960,'T001'),
('C001','Programming Revision Cheat Sheet','One page formula sheet','materials/C001/revision-cheatsheet.pdf','pdf',184320,'T001'),

('C002','Discrete Math Unit 1 - Sets Notes','Sets, Venn diagrams, operations','materials/C002/unit-01-notes.pdf','pdf',194560,'T013'),
('C002','Discrete Math Unit 1 - Slides','Lecture slide deck for unit 1','materials/C002/unit-01-slides.pdf','pdf',1179648,'T013'),
('C002','Discrete Math Unit 2 - Relations Notes','Relations and equivalence classes','materials/C002/unit-02-notes.pdf','pdf',201728,'T013'),
('C002','Discrete Math Unit 2 - Slides','Lecture slide deck for unit 2','materials/C002/unit-02-slides.pdf','pdf',1218560,'T013'),
('C002','Discrete Math Unit 3 - Functions Notes','Mappings, injective, surjective','materials/C002/unit-03-notes.pdf','pdf',188416,'T013'),
('C002','Discrete Math Unit 3 - Slides','Lecture slide deck for unit 3','materials/C002/unit-03-slides.pdf','pdf',1146880,'T013'),
('C002','Discrete Math Unit 4 - Induction Notes','Mathematical induction, recursion','materials/C002/unit-04-notes.pdf','pdf',176128,'T013'),
('C002','Discrete Math Unit 4 - Slides','Lecture slide deck for unit 4','materials/C002/unit-04-slides.pdf','pdf',1105920,'T013'),
('C002','Discrete Math Unit 5 - Counting Notes','Permutation, combination, pigeonhole','materials/C002/unit-05-notes.pdf','pdf',199680,'T013'),
('C002','Discrete Math Unit 5 - Slides','Lecture slide deck for unit 5','materials/C002/unit-05-slides.pdf','pdf',1196032,'T013'),
('C002','Discrete Math Unit 6 - Recurrence Notes','Recurrence relations and solving','materials/C002/unit-06-notes.pdf','pdf',209920,'T013'),
('C002','Discrete Math Unit 6 - Slides','Lecture slide deck for unit 6','materials/C002/unit-06-slides.pdf','pdf',1245184,'T013'),
('C002','Discrete Math Unit 7 - Graph Theory Notes','Trees, cycles, Euler, Hamilton','materials/C002/unit-07-notes.pdf','pdf',227328,'T013'),
('C002','Discrete Math Unit 7 - Slides','Lecture slide deck for unit 7','materials/C002/unit-07-slides.pdf','pdf',1331200,'T013'),
('C002','Discrete Math Unit 8 - Boolean Algebra Notes','Logic, truth tables, simplification','materials/C002/unit-08-notes.pdf','pdf',183296,'T013'),
('C002','Discrete Math Unit 8 - Slides','Lecture slide deck for unit 8','materials/C002/unit-08-slides.pdf','pdf',1075200,'T013'),
('C002','Discrete Math Practice Set 1','Exercise set with solutions','materials/C002/practice-01.pdf','pdf',253952,'T013'),
('C002','Discrete Math Previous Year Paper 2024','Full question paper with answers','materials/C002/pyp-2024.pdf','pdf',675840,'T013'),
('C002','Discrete Math Previous Year Paper 2023','Full question paper with answers','materials/C002/pyp-2023.pdf','pdf',655360,'T013'),
('C002','Discrete Math Formula Sheet','Quick reference for exams','materials/C002/formula-sheet.pdf','pdf',172032,'T013'),

('C003','Reverse Engineering Unit 1 - Overview Notes','Static vs dynamic analysis, tooling','materials/C003/unit-01-notes.pdf','pdf',205824,'T025'),
('C003','Reverse Engineering Unit 1 - Slides','Lecture slide deck for unit 1','materials/C003/unit-01-slides.pdf','pdf',1258291,'T025'),
('C003','Reverse Engineering Unit 2 - Assembly Notes','x86 basics, registers, calling conventions','materials/C003/unit-02-notes.pdf','pdf',235520,'T025'),
('C003','Reverse Engineering Unit 2 - Slides','Lecture slide deck for unit 2','materials/C003/unit-02-slides.pdf','pdf',1310720,'T025'),
('C003','Reverse Engineering Unit 2 - Ghidra Lab','Hands on lab sheet for unit 2','materials/C003/unit-02-lab.pdf','pdf',212992,'T025'),
('C003','Reverse Engineering Unit 3 - Disassembly Notes','Disassembly, control flow recovery','materials/C003/unit-03-notes.pdf','pdf',219136,'T025'),
('C003','Reverse Engineering Unit 3 - Slides','Lecture slide deck for unit 3','materials/C003/unit-03-slides.pdf','pdf',1284096,'T025'),
('C003','Reverse Engineering Unit 3 - CrackMe Lab','Hands on lab sheet for unit 3','materials/C003/unit-03-lab.pdf','pdf',196608,'T025'),
('C003','Reverse Engineering Unit 4 - Binary Formats Notes','ELF, PE, file format internals','materials/C003/unit-04-notes.pdf','pdf',208896,'T025'),
('C003','Reverse Engineering Unit 4 - Slides','Lecture slide deck for unit 4','materials/C003/unit-04-slides.pdf','pdf',1245184,'T025'),
('C003','Reverse Engineering Unit 5 - Patching Notes','Patching, anti-debug, obfuscation','materials/C003/unit-05-notes.pdf','pdf',227328,'T025'),
('C003','Reverse Engineering Unit 5 - Slides','Lecture slide deck for unit 5','materials/C003/unit-05-slides.pdf','pdf',1363148,'T025'),
('C003','Reverse Engineering Unit 6 - Malware Notes','Malware families and behaviour','materials/C003/unit-06-notes.pdf','pdf',190464,'T025'),
('C003','Reverse Engineering Unit 6 - Slides','Lecture slide deck for unit 6','materials/C003/unit-06-slides.pdf','pdf',1187840,'T025'),
('C003','Reverse Engineering CT-1 Solution Paper','Worked solution for CT-1','materials/C003/ct1-solution.pdf','pdf',231424,'T025'),
('C003','Reverse Engineering CT-2 Solution Paper','Worked solution for CT-2','materials/C003/ct2-solution.pdf','pdf',236544,'T025'),
('C003','Reverse Engineering Previous Year Paper 2024','Full question paper with answers','materials/C003/pyp-2024.pdf','pdf',696320,'T025'),
('C003','Reverse Engineering Previous Year Paper 2023','Full question paper with answers','materials/C003/pyp-2023.pdf','pdf',675840,'T025'),
('C003','Reverse Engineering Tool Cheat Sheet','Ghidra, IDA, objdump reference','materials/C003/tool-cheatsheet.pdf','pdf',184320,'T025'),
('C003','Reverse Engineering Project Guide','Mini project instructions','materials/C003/project-guide.pdf','pdf',264192,'T025'),

('C004','Pentesting Unit 1 - Ethics Notes','Scope, rules of engagement, legality','materials/C004/unit-01-notes.pdf','pdf',199680,'T026'),
('C004','Pentesting Unit 1 - Slides','Lecture slide deck for unit 1','materials/C004/unit-01-slides.pdf','pdf',1234567,'T026'),
('C004','Pentesting Unit 2 - Recon Notes','Passive and active reconnaissance','materials/C004/unit-02-notes.pdf','pdf',213504,'T026'),
('C004','Pentesting Unit 2 - Slides','Lecture slide deck for unit 2','materials/C004/unit-02-slides.pdf','pdf',1284096,'T026'),
('C004','Pentesting Unit 3 - Scanning Notes','Nmap, service fingerprinting','materials/C004/unit-03-notes.pdf','pdf',207872,'T026'),
('C004','Pentesting Unit 3 - Slides','Lecture slide deck for unit 3','materials/C004/unit-03-slides.pdf','pdf',1310720,'T026'),
('C004','Pentesting Unit 4 - Web Attacks Notes','OWASP top 10 walkthrough','materials/C004/unit-04-notes.pdf','pdf',256000,'T026'),
('C004','Pentesting Unit 4 - Slides','Lecture slide deck for unit 4','materials/C004/unit-04-slides.pdf','pdf',1415577,'T026'),
('C004','Pentesting Unit 4 - DVWA Lab','Hands on lab sheet for unit 4','materials/C004/unit-04-lab.pdf','pdf',229376,'T026'),
('C004','Pentesting Unit 5 - Exploitation Notes','Payloads, pivoting, privilege escalation','materials/C004/unit-05-notes.pdf','pdf',262144,'T026'),
('C004','Pentesting Unit 5 - Slides','Lecture slide deck for unit 5','materials/C004/unit-05-slides.pdf','pdf',1384120,'T026'),
('C004','Pentesting Unit 6 - Reporting Notes','Report writing and remediation','materials/C004/unit-06-notes.pdf','pdf',194560,'T026'),
('C004','Pentesting Unit 6 - Slides','Lecture slide deck for unit 6','materials/C004/unit-06-slides.pdf','pdf',1218560,'T026'),
('C004','Pentesting CT-1 Solution Paper','Worked solution for CT-1','materials/C004/ct1-solution.pdf','pdf',237568,'T026'),
('C004','Pentesting CT-2 Solution Paper','Worked solution for CT-2','materials/C004/ct2-solution.pdf','pdf',242688,'T026'),
('C004','Pentesting Previous Year Paper 2024','Full question paper with answers','materials/C004/pyp-2024.pdf','pdf',686080,'T026'),
('C004','Pentesting Previous Year Paper 2023','Full question paper with answers','materials/C004/pyp-2023.pdf','pdf',665600,'T026'),
('C004','Pentesting Command Cheat Sheet','Nmap, Burp, Hydra reference','materials/C004/command-cheatsheet.pdf','pdf',192512,'T026'),
('C004','Pentesting Lab Environment Setup','Kali VM setup guide','materials/C004/lab-setup.pdf','pdf',215040,'T026'),
('C004','Pentesting Final Year Project Brief','Project brief and rubric','materials/C004/project-brief.pdf','pdf',270336,'T026'),

('C005','Soc Unit 1 - Society Notes','Society, culture, social change','materials/C005/unit-01-notes.pdf','pdf',180224,'T041'),
('C005','Soc Unit 1 - Slides','Lecture slide deck for unit 1','materials/C005/unit-01-slides.pdf','pdf',1126400,'T041'),
('C005','Soc Unit 2 - Social Institutions Notes','Family, education, religion, economy','materials/C005/unit-02-notes.pdf','pdf',186368,'T041'),
('C005','Soc Unit 2 - Slides','Lecture slide deck for unit 2','materials/C005/unit-02-slides.pdf','pdf',1155072,'T041'),
('C005','Soc Unit 3 - Social Stratification Notes','Class, caste, gender, inequality','materials/C005/unit-03-notes.pdf','pdf',194560,'T041'),
('C005','Soc Unit 3 - Slides','Lecture slide deck for unit 3','materials/C005/unit-03-slides.pdf','pdf',1196032,'T041'),
('C005','Soc Unit 4 - Social Movements Notes','Collective action and movements','materials/C005/unit-04-notes.pdf','pdf',190464,'T041'),
('C005','Soc Unit 4 - Slides','Lecture slide deck for unit 4','materials/C005/unit-04-slides.pdf','pdf',1171457,'T041'),
('C005','Soc Unit 5 - Urban Society Notes','Urbanisation, migration, slums','materials/C005/unit-05-notes.pdf','pdf',184320,'T041'),
('C005','Soc Unit 5 - Slides','Lecture slide deck for unit 5','materials/C005/unit-05-slides.pdf','pdf',1146880,'T041'),
('C005','Soc Unit 6 - Media Notes','Media, propaganda, public sphere','materials/C005/unit-06-notes.pdf','pdf',177152,'T041'),
('C005','Soc Unit 6 - Slides','Lecture slide deck for unit 6','materials/C005/unit-06-slides.pdf','pdf',1105920,'T041'),
('C005','Soc Case Study 1 - Rural to Urban Migration','Field based case study','materials/C005/case-study-01.pdf','pdf',245760,'T041'),
('C005','Soc Case Study 2 - Digital Communities','Field based case study','materials/C005/case-study-02.pdf','pdf',251904,'T041'),
('C005','Soc CT-1 Solution Paper','Worked solution for CT-1','materials/C005/ct1-solution.pdf','pdf',227328,'T041'),
('C005','Soc CT-2 Solution Paper','Worked solution for CT-2','materials/C005/ct2-solution.pdf','pdf',231424,'T041'),
('C005','Soc Previous Year Paper 2024','Full question paper with answers','materials/C005/pyp-2024.pdf','pdf',645120,'T041'),
('C005','Soc Previous Year Paper 2023','Full question paper with answers','materials/C005/pyp-2023.pdf','pdf',624640,'T041'),
('C005','Soc Terminology Glossary','Key terms with short meaning','materials/C005/glossary.pdf','pdf',169984,'T041'),
('C005','Soc Reading List','Recommended books and articles','materials/C005/reading-list.pdf','pdf',163840,'T041');

-- 12. STUDY_PROGRESS   (5000 rows = 100 materials x 50 students)
INSERT INTO STUDY_PROGRESS (MATERIAL_ID, `S.ROLL`, PROGRESS_STATUS)
SELECT m.MATERIAL_ID, s.ROLL,
       CASE WHEN MOD(CRC32(CONCAT(s.ROLL, m.MATERIAL_ID)), 100) < 55 THEN 'not_started'
            WHEN MOD(CRC32(CONCAT(s.ROLL, m.MATERIAL_ID)), 100) < 80 THEN 'in_progress'
            ELSE 'completed'
       END
FROM STUDY_MATERIALS m CROSS JOIN STUDENT s;

-- stamp completion time only for completed rows
UPDATE STUDY_PROGRESS p
JOIN STUDENT s ON s.ROLL = p.`S.ROLL`
SET p.COMPLETED_AT = TIMESTAMP(DATE_SUB('2026-10-01', INTERVAL MOD(CRC32(CONCAT(p.`S.ROLL`, p.MATERIAL_ID)), 45) DAY), '16:30:00')
WHERE p.PROGRESS_STATUS = 'completed';

-- 13. NOTICES   (20 rows)
INSERT INTO NOTICES (TITLE, CONTENT, PRIORITY, AUDIENCE, posted_by, IS_PINNED, EXPIRES_AT) VALUES
('Semester Exam Schedule Released','The CT-3 and final examination schedule for all five courses has been published on the department notice board. Reporting time is 30 minutes before each paper.','urgent','all','T001',1,'2026-10-30 23:59:00'),
('Library Extended Hours','The central library will now stay open till 22:00 on weekdays and 17:00 on Saturdays during the examination period.','normal','all','T047',0,NULL),
('Course Registration Deadline','Course registration for the next semester closes on Friday at 17:00. Contact your course teacher for any substitution requests.','high','students','T013',1,'2026-10-15 23:59:00'),
('Pentesting Lab Access','Pentesting students must submit a signed ethics form before starting the unit 5 exploitation lab. Forms are available at the Cyber Security lab counter.','high','students','T026',1,'2026-09-20 23:59:00'),
('Reverse Engineering Tool License','The department has purchased 40 additional Ghidra licenses. Collect your license key from the lab admin with your student ID.','low','students','T025',0,NULL),
('Faculty Meeting Notice','The monthly department faculty meeting is scheduled for Saturday 10:00 in the conference room. Attendance is mandatory for all course teachers.','normal','teachers','T047',0,NULL),
('Internal Test 2 Results Published','CT-2 results for all courses are now available on the student portal. Report any discrepancy within seven days.','high','students','T013',0,NULL),
('Holiday Notice','The university will remain closed on the second and fourth Saturday of every month as per the academic calendar.','normal','all','T047',0,NULL),
('Study Material Upload Deadline','All course teachers must upload unit wise study material before the respective CT-1 examination date.','normal','teachers','T001',1,NULL),
('Anti Ragging Committee','Report any ragging incident immediately to the anti ragging committee. Confidential helpline numbers are displayed at every department notice board.','urgent','all','T047',1,NULL),
('Programming Contest Announcement','A campus wide programming contest will be held next month. Practice sheets and previous year papers are available in the study material section.','normal','students','T001',0,NULL),
('Soc Field Visit Schedule','The sociology field visit schedule for unit 6 has been uploaded. Students must carry the consent form signed by a guardian.','normal','students','T041',0,NULL),
('Wi-Fi Maintenance','Campus Wi-Fi will be unavailable on Sunday between 09:00 and 13:00 for router maintenance.','low','all','T047',0,NULL),
('Mid Semester Marks Re-evaluation','Students who wish to apply for re-evaluation of CT-1 and CT-2 marks must submit the application before the end of this month.','normal','students','T013',0,'2026-10-31 23:59:00'),
('Guest Lecture Announcement','A guest lecture on cyber ethics will be conducted by an industry expert. All students of Pentesting and Reverse Engineering are expected to attend.','normal','all','T025',0,NULL),
('Sports Meet Selection','Trials for the inter university sports meet will be held on the college ground. Reporting time is 07:00 sharp.','low','all','T047',0,NULL),
('Seminar Registration Open','Registration for the student technical seminar is open. Each participant gets a ten minute slot plus five minutes for questions.','normal','students','T001',0,'2026-11-10 23:59:00'),
('Teacher Training Workshop','A workshop on outcome based education will be conducted next week for all teaching staff. Attendance certificate will be issued.','normal','teachers','T041',0,NULL),
('Course Material Quality Feedback','Students are requested to share feedback on the uploaded study material quality using the feedback form linked in the portal.','low','students','T026',0,NULL),
('Annual Convocation Notice','The annual convocation ceremony will be held in the main auditorium. Gold medal recipients must report one day early for rehearsal.','urgent','all','T047',1,'2026-12-20 23:59:00');

-- 14. cleanup helper table
DROP TABLE IF EXISTS SEED_CLASS_DAYS;

-- 15. VERIFICATION   (run these, they only SELECT)
SELECT 'STUDENT_LOGIN' AS tbl, COUNT(*) AS rows_ FROM STUDENT_LOGIN
UNION ALL SELECT 'STUDENT',       COUNT(*) FROM STUDENT
UNION ALL SELECT 'TEACHER_LOGIN', COUNT(*) FROM TEACHER_LOGIN
UNION ALL SELECT 'TEACHER',       COUNT(*) FROM TEACHER
UNION ALL SELECT 'COURSES',       COUNT(*) FROM COURSES
UNION ALL SELECT 'STU_COURSES',   COUNT(*) FROM STU_COURSES
UNION ALL SELECT 'ASSESSMENTS',   COUNT(*) FROM ASSESSMENTS
UNION ALL SELECT 'ACADEMICS',     COUNT(*) FROM ACADEMICS
UNION ALL SELECT 'ATTENDENCE',    COUNT(*) FROM ATTENDENCE
UNION ALL SELECT 'STUDY_MATERIALS', COUNT(*) FROM STUDY_MATERIALS
UNION ALL SELECT 'STUDY_PROGRESS',  COUNT(*) FROM STUDY_PROGRESS
UNION ALL SELECT 'NOTICES',       COUNT(*) FROM NOTICES;

-- per course: material count + how much one student has completed
SELECT c.COURSE_ID, c.COURSE_NAME,
       COUNT(m.MATERIAL_ID) AS total_material,
       SUM(p.PROGRESS_STATUS = 'completed') AS completed_cs001,
       ROUND(SUM(p.PROGRESS_STATUS = 'completed') * 100 / COUNT(m.MATERIAL_ID), 2) AS percent_cs001
FROM COURSES c
JOIN STUDY_MATERIALS m ON m.COURSE_ID = c.COURSE_ID
JOIN STUDY_PROGRESS p  ON p.MATERIAL_ID = m.MATERIAL_ID AND p.`S.ROLL` = 'CS001'
GROUP BY c.COURSE_ID, c.COURSE_NAME;

-- one student's full academics sheet
SELECT c.COURSE_NAME, a.TITLE, a.MAX_MARKS, ac.SEM_MARKS, ac.REMARKS
FROM ACADEMICS ac
JOIN ASSESSMENTS a ON a.ASSESSMENT_ID = ac.ASSESSMENT_ID
JOIN COURSES c     ON c.COURSE_ID = a.COURSE_ID
WHERE ac.`S.ROLL` = 'CS001'
ORDER BY c.COURSE_ID, a.ASSESSMENT_ID;

-- one student's attendance summary per course
SELECT c.COURSE_NAME,
       SUM(a.ATTENDENCE_STATUS = 'present') AS present,
       SUM(a.ATTENDENCE_STATUS = 'absent')  AS absent,
       SUM(a.ATTENDENCE_STATUS = 'late')    AS late,
       SUM(a.ATTENDENCE_STATUS = 'excused') AS excused,
       COUNT(*) AS total_classes
FROM ATTENDENCE a
JOIN COURSES c ON c.COURSE_ID = a.COURSE_ID
WHERE a.`S.ROLL` = 'CS001'
GROUP BY c.COURSE_NAME;
