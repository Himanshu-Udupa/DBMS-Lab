-- sailors database
CREATE DATABASE SAILORS;
USE SAILORS;

CREATE TABLE SAILOR(
sid INT PRIMARY KEY,
sname VARCHAR(30),
rating FLOAT,
age INT
);

CREATE TABLE BOAT(
bid INT PRIMARY KEY,
bname VARCHAR(15),
color TEXT
);

CREATE TABLE RESERVES(
sid INT,
bid INT,
date DATE,
FOREIGN KEY (sid) REFERENCES SAILOR(sid) ON DELETE CASCADE,
FOREIGN KEY (bid) REFERENCES BOAT(bid) ON DELETE CASCADE
);

INSERT INTO SAILOR VALUES
(1,"Albert",5.0,45),
(2,"Nakul",6.0,18),
(3,"Sandeep",5.0,42),
(4,"Syed Stormer",9.0,30),
(5,"Neil Armstorm",8.4,28);

INSERT INTO BOAT VALUES
(101,"Boat 1","Green"),
(102,"Boat 2","Red"),
(103,"Boat 3","Yellow");

INSERT INTO RESERVES VALUES
(1,101,"2024-01-12"),
(2,102,"2024-01-20"),
(1,102,"2024-01-24"),
(3,103,"2024-02-01"),
(1,103,"2024-01-15"),
(2,101,"2024-01-18");

SELECT * FROM SAILOR;
SELECT * FROM BOAT;
SELECT * FROM RESERVES;

-- Find the colours of the boats reserved by Albert
SELECT color FROM SAILOR s, BOAT b, RESERVES r WHERE s.sid=r.sid AND b.bid=r.bid AND s.sname = "Albert";


-- Find all the sailor sids who have rating atleast 8 or reserved boat 103
SELECT sid FROM SAILOR WHERE rating>=8 UNION SELECT sid FROM RESERVES WHERE bid=103;


-- Find the names of the sailor who have not reserved a boat whose name contains the string "storm". Order the name in the ascending order
SELECT s.sname FROM SAILOR s where s.sid NOT IN(SELECT s1.sid FROM SAILOR s1, RESERVES r WHERE s1.sid=r.sid AND s1.sname LIKE "%storm%") AND s.sname LIKE "%storm%" ORDER BY s.sname;


-- Find the name of the sailors who have reserved all boats
SELECT sname FROM SAILOR s WHERE NOT EXISTS( SELECT * FROM BOAT b WHERE NOT EXISTS(SELECT * FROM RESERVES r WHERE s.sid=r.sid AND r.bid=b.bid));;


-- Find the name and age of the oldest sailor
SELECT sname, age FROM SAILOR WHERE age IN(SELECT MAX(age) FROM SAILOR);


-- For each boat which was reserved by atleast 2 sailors with age >= 40, find the bid and average age of such sailors
SELECT b.bid, AVG(s.age) AS average_age FROM SAILOR s, BOAT b, RESERVES r WHERE s.sid=r.sid AND r.bid=b.bid AND s.age>=40 GROUP BY bid HAVING 2<=COUNT(DISTINCT r.sid);


-- Create a view that shows the names and colours of all the boats that have been reserved by a sailor with a specific rating.
CREATE VIEW NameAndColor AS
SELECT DISTINCT bname, color
FROM SAILOR s, BOAT b, RESERVES r
WHERE s.sid=r.sid AND r.bid=b.bid
AND s.rating=5;

SELECT * FROM NameAndColor;


-- Trigger that prevents boats from being deleted if they have active reservation
DELIMITER //
CREATE TRIGGER PreventDelete
before delete on BOAT
for each row
BEGIN
       IF EXISTS (SELECT * FROM RESERVES WHERE RESERVES.bid=old.bid) THEN
           SIGNAL SQLSTATE '45000' SET message_text="Boat Has active reservation hence cannot delete";
       END IF;
END;//

DELIMITER ;

DELETE FROM BOAT WHERE bid=103; -- This gives error since boat 103 is reserved
