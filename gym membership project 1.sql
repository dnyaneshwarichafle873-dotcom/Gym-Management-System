Create database GYM ;

use GYM;
CREATE TABLE members (
    member_id INT PRIMARY KEY,
    name VARCHAR(100),
    join_date DATE,
    membership_plan VARCHAR(50)
);

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY,
    member_id INT,
    check_in_time DATETIME,
    check_out_time DATETIME,
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

CREATE TABLE trainers (
    trainer_id INT PRIMARY KEY,
    name VARCHAR(100),
    specialization VARCHAR(100)
);

CREATE TABLE sessions (
    session_id INT PRIMARY KEY,
    member_id INT,
    trainer_id INT,
    session_date DATE,
    duration INT,
    type VARCHAR(50),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id)
);


-- Insert data into members table
INSERT INTO members (member_id, name, join_date, membership_plan) VALUES
(1, 'Aarav Sharma', '2024-01-10', 'Gold'),
(2, 'Priya Mehta', '2024-02-15', 'Silver'),
(3, 'Rohan Verma', '2024-03-05', 'Platinum'),
(4, 'Sneha Iyer', '2024-01-20', 'Gold'),
(5, 'Karan Patel', '2024-04-12', 'Silver'),
(6, 'Neha Kapoor', '2024-02-28', 'Platinum'),
(7, 'Vikram Singh', '2024-03-18', 'Gold'),
(8, 'Ananya Rao', '2024-05-01', 'Silver'),
(9, 'Rahul Nair', '2024-01-30', 'Platinum'),
(10, 'Meera Joshi', '2024-04-22', 'Gold');

-- Insert data into attendance table
INSERT INTO attendance (attendance_id, member_id, check_in_time, check_out_time) VALUES
(101, 1, '2024-06-01 07:00:00', '2024-06-01 08:30:00'),
(102, 2, '2024-06-01 08:00:00', '2024-06-01 09:00:00'),
(103, 3, '2024-06-01 06:30:00', '2024-06-01 08:00:00'),
(104, 4, '2024-06-02 07:15:00', '2024-06-02 08:45:00'),
(105, 5, '2024-06-02 09:00:00', '2024-06-02 10:00:00'),
(106, 6, '2024-06-03 06:45:00', '2024-06-03 08:15:00'),
(107, 7, '2024-06-03 07:30:00', '2024-06-03 09:00:00'),
(108, 8, '2024-06-04 08:15:00', '2024-06-04 09:15:00'),
(109, 9, '2024-06-04 06:00:00', '2024-06-04 07:30:00'),
(110, 10, '2024-06-05 07:45:00', '2024-06-05 09:00:00');

-- Insert data into trainers table
INSERT INTO trainers (trainer_id, name, specialization) VALUES
(201, 'Raj Malhotra', 'Strength Training'),
(202, 'Simran Kaur', 'Yoga'),
(203, 'Amit Desai', 'Cardio Fitness'),
(204, 'Pooja Menon', 'Pilates'),
(205, 'Arjun Reddy', 'CrossFit'),
(206, 'Nisha Gupta', 'Weight Loss'),
(207, 'Sandeep Roy', 'Bodybuilding'),
(208, 'Kavya Pillai', 'Zumba'),
(209, 'Manoj Kulkarni', 'Functional Training'),
(210, 'Isha Bansal', 'Nutrition Coaching');

-- Insert data into sessions table
INSERT INTO sessions (session_id, member_id, trainer_id, session_date, duration, type) VALUES
(301, 1, 201, '2024-06-01', 60, 'Strength'),
(302, 2, 202, '2024-06-01', 45, 'Yoga'),
(303, 3, 203, '2024-06-02', 50, 'Cardio'),
(304, 4, 204, '2024-06-02', 40, 'Pilates'),
(305, 5, 205, '2024-06-03', 70, 'CrossFit'),
(306, 6, 206, '2024-06-03', 55, 'Weight Loss'),
(307, 7, 207, '2024-06-04', 65, 'Bodybuilding'),
(308, 8, 208, '2024-06-04', 50, 'Zumba'),
(309, 9, 209, '2024-06-05', 60, 'Functional'),
(310, 10, 210, '2024-06-05', 45, 'Nutrition');



-- 1. Calculate the average number of visits per member per month
SELECT 
    member_id,
    COUNT(attendance_id) / COUNT(DISTINCT MONTH(check_in_time)) AS avg_visits_per_month
FROM attendance
GROUP BY member_id;


-- 2. Find the most popular time of day for gym visits
SELECT 
    CASE
        WHEN HOUR(check_in_time) BETWEEN 5 AND 11 THEN 'Morning'
        WHEN HOUR(check_in_time) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN HOUR(check_in_time) BETWEEN 17 AND 21 THEN 'Evening'
        ELSE 'Night'
    END AS time_of_day,
    COUNT(*) AS total_visits
FROM attendance
GROUP BY time_of_day
ORDER BY total_visits DESC;


-- 3. List all members with an active "Premium" membership plan
SELECT *
FROM members
WHERE membership_plan = 'Premium';


-- 4. Count the number of sessions led by each trainer
SELECT 
    t.trainer_id,
    t.name AS trainer_name,
    COUNT(s.session_id) AS total_sessions
FROM trainers t
LEFT JOIN sessions s
ON t.trainer_id = s.trainer_id
GROUP BY t.trainer_id, t.name;


-- 5. Identify members who have not visited the gym in the last 30 days
SELECT 
    m.member_id,
    m.name
FROM members m
LEFT JOIN attendance a
ON m.member_id = a.member_id
GROUP BY m.member_id, m.name
HAVING MAX(a.check_in_time) < NOW() - INTERVAL 30 DAY
   OR MAX(a.check_in_time) IS NULL;


-- 6. Calculate the total hours each member has spent in the gym
SELECT 
    m.member_id,
    m.name,
    ROUND(SUM(TIMESTAMPDIFF(MINUTE, a.check_in_time, a.check_out_time)) / 60, 2) AS total_hours
FROM members m
JOIN attendance a
ON m.member_id = a.member_id
GROUP BY m.member_id, m.name;


-- 7. Find the most requested type of training session
SELECT 
    type,
    COUNT(*) AS total_requests
FROM sessions
GROUP BY type
ORDER BY total_requests DESC
LIMIT 1;


-- 8. List trainers who have no scheduled sessions
SELECT 
    t.trainer_id,
    t.name
FROM trainers t
LEFT JOIN sessions s
ON t.trainer_id = s.trainer_id
WHERE s.session_id IS NULL;


-- 9. Find the member with the most attended sessions
SELECT 
    m.member_id,
    m.name,
    COUNT(s.session_id) AS attended_sessions
FROM members m
JOIN sessions s
ON m.member_id = s.member_id
GROUP BY m.member_id, m.name
ORDER BY attended_sessions DESC
LIMIT 1;


-- 10. Calculate the monthly retention rate of members
SELECT 
    MONTH(join_date) AS join_month,
    COUNT(member_id) AS total_members,
    ROUND(
        (COUNT(member_id) /
        (SELECT COUNT(*) FROM members)) * 100,
        2
    ) AS retention_rate_percentage
FROM members
GROUP BY MONTH(join_date)
ORDER BY join_month;


