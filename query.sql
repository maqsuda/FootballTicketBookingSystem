DROP TABLE IF EXISTS Users;
CREATE TABLE Users(
  user_id SERIAL PRIMARY KEY,
  full_name TEXT,
  email VARCHAR(30) UNIQUE NOT NULL,
  role VARCHAR(20) ,
  phone_number VARCHAR(30)
)

INSERT INTO Users (user_id, full_name, email, role, phone_number) VALUES
(1, 'Tanvir Rahman', 'tanvir@mail.com', 'Football Fan', '+8801711111111'),
(2, 'Asif Haque', 'asif@mail.com', 'Football Fan', '+8801722222222'),
(3, 'Sajjad Rahman', 'sajjad@mail.com', 'Ticket Manager', '+8801733333333'),
(4, 'Jannat Ara', 'jannat@mail.com', 'Football Fan', NULL);

DROP TABLE IF EXISTS Matches;
CREATE TABLE Matches(
  match_id INT PRIMARY KEY,
  fixture TEXT,
  tournament_category TEXT,
  base_ticket_price INT CHECK (base_ticket_price>0),
  match_status VARCHAR(20) CHECK (match_status IN ('Available', 'Selling Fast', 'Sold Out', 'Postponed'))
)

INSERT INTO Matches (match_id, fixture, tournament_category, base_ticket_price, match_status) VALUES
(101, 'Real Madrid vs Barcelona', 'Champions League', 150.00, 'Available'),
(102, 'Man City vs Liverpool', 'Premier League', 120.00, 'Selling Fast'),
(103, 'Bayern Munich vs PSG', 'Champions League', 130.00, 'Available'),
(104, 'AC Milan vs Inter Milan', 'Serie A', 90.00, 'Sold Out'),
(105, 'Juventus vs Roma', 'Serie A', 80.00, 'Available');


DROP TABLE IF EXISTS Bookings;
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    match_id INT REFERENCES matches(match_id),
    seat_number VARCHAR(20) ,
    payment_status TEXT CHECK (payment_status IN('Pending', 'Confirmed', 'Cancelled', 'Refunded')),
    total_cost INT CHECK (total_cost>0)
   );

INSERT INTO Bookings (booking_id, user_id, match_id, seat_number, payment_status, total_cost) VALUES
(501, 1, 101, 'A-12', 'Confirmed', 150.00),
(502, 1, 102, 'B-04', 'Confirmed', 120.00),
(503, 2, 101, 'A-13', 'Confirmed', 150.00),
(504, 2, 101, NULL, NULL, 150.00),
(505, 3, 102, 'C-20', 'Pending', 120.00);

-- Query 1: Retrieve all upcoming football matches belonging to the 'Champions League' where the match status is 'Available'.


SELECT match_id,fixture,base_ticket_price
  FROM matches
WHERE match_status ='Available'


-- Query 2: Search for all users whose full names start with 'Tanvir' or contain the phrase 'Haque' (case-insensitive).

SELECT user_id,full_name,email
  FROM users
WHERE full_name Ilike 'tanvir%' 
OR full_name Ilike '%haque%'

-- Query 3: Retrieve all booking records where the payment status is missing (NULL), replacing the empty result with 'Action Required'.


SELECT booking_id,user_id,match_id,coalesce(payment_status,'Action Required') 
  FROM bookings
WHERE payment_status is null


-- Query 4: Retrieve match booking details along with the User's full name and the scheduled Match fixture teams.
  
SELECT booking_id,full_name,fixture,total_cost 
  FROM users 
  JOIN bookings ON users.user_id=bookings.user_id
  JOIN matches ON matches.match_id=bookings.match_id
 
-- Query 5: Display a comprehensive list of all users and their booking IDs, ensuring that fans who have never bought a ticket are still listed.

SELECT users.user_id,full_name,booking_id
FROM users LEFT JOIN bookings ON users.user_id=bookings.user_id


-- Query 6: Find all ticket bookings where the total cost is strictly higher than the average cost of all ticket bookings.

SELECT booking_id,matches.match_id,total_cost
FROM bookings JOIN matches 
ON bookings.match_id=matches.match_id
WHERE total_cost>(SELECT AVG(total_cost) FROM bookings)


-- Query 7: Retrieve the top 2 most expensive matches sorted by base ticket price, skipping the absolute highest premium match.

SELECT match_id,fixture,base_ticket_price
  FROM matches
ORDER BY base_ticket_price DESC LIMIT 2 OFFSET 1 


