/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name
FROM `Facilities`
WHERE membercost >0
LIMIT 0 , 1000


A:Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court


/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT( DISTINCT name ) AS facility_count
FROM `Facilities`
WHERE membercost =0
Answer:4

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

(0, 'Tennis Court 1', 5.0, 200),
(1, 'Tennis Court 2', 5.0, 200),
(4, 'Massage Room 1', 9.9, 3000),
(5, 'Massage Room 2', 9.9, 3000),
(6, 'Squash Court', 3.5, 80);

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
FROM `Facilities`
WHERE facid
IN ( 1, 5 )

facid name membercost guestcost initialoutlay monthlymaintenance
1 Tennis Court 2 5.0 25.0 8000 200
5 Massage Room 2 9.9 80.0 4000 3000

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance,
CASE
WHEN monthlymaintenance >100
THEN 'expensive'
ELSE 'cheap'
END AS label
FROM `Facilities`

name	monthlymaintenance	label	
Tennis Court 1	200	expensive
Tennis Court 2	200	expensive
Badminton Court	50	cheap
Table Tennis	10	cheap
Massage Room 1	3000	expensive
Massage Room 2	3000	expensive
Squash Court	80	cheap
Snooker Table	15	cheap
Pool Table	15	cheap

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT surname, firstname
FROM Members
WHERE joindate = (
SELECT MAX( joindate )
FROM Members )

surname  firstname
Smith       Darren


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT
   m.firstname ||' '|| m.surname AS fullname
FROM
   Members as m
INNER JOIN Bookings as b 
ON m.memid=b.memid
INNER JOIN Facilities as f 
ON f.facid=b.facid
WHERE
   f.name IN ('Tennis Court 1','Tennis Court 2');


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT surname AS Member, name AS Facility,
CASE
WHEN Members.memid =0
THEN Bookings.slots * Facilities.guestcost
ELSE Bookings.slots * Facilities.membercost
END AS cost
FROM Members
JOIN Bookings ON Members.memid = Bookings.memid
JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE Bookings.starttime >= '2012-09-14'
AND Bookings.starttime < '2012-09-15'
AND ((Members.memid =0
AND Bookings.slots * Facilities.guestcost >30)
OR (Members.memid !=0
AND Bookings.slots * Facilities.membercost >30))
ORDER BY cost DESC

A:
Member   Facility                      cost 
GUEST    Massage Room 2   320.0
GUEST    Massage Room 1   160.0
GUEST    Massage Room 1   160.0
GUEST    Massage Room 1   160.0
GUEST    Tennis Court 2          150.0
GUEST    Tennis Court 1           75.0
GUEST    Tennis Court 2           75.0
GUEST    Tennis Court 1           75.0
GUEST    Squash Court            70.0
Farrell       Massage Room 1    39.6
GUEST    Squash Court            35.0
GUEST    Squash Court            35.0



/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT member, facility, cost
FROM (

SELECT Members.surname AS member, Facilities.name AS facility,
CASE
WHEN Members.memid =0
THEN Bookings.slots * Facilities.guestcost
ELSE Bookings.slots * Facilities.membercost
END AS cost
FROM Members
JOIN Bookings ON Members.memid = Bookings.memid
JOIN Facilities ON Bookings.facid = Facilities.facid
WHERE Bookings.starttime >= '2012-09-14'
AND Bookings.starttime < '2012-09-15'
) AS bookings
WHERE cost >30
ORDER BY cost DESC


/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
Select f.name,
	SUM(CASE 
		WHEN b.memid <>0 
			THEN f.membercost*b.slots
			ELSE f.guestcost*b.slots
		END) AS revenue
FROM Bookings as b
INNER JOIN Facilities as f
ON b.facid = f.facid
GROUP BY f.name
HAVING revenue > 1000
ORDER BY revenue DESC


A:

name                           revenue 
Massage Room 1      50351.6
Massage Room 2      14454.6
Tennis Court 2            14310.0
Tennis Court 1            13860.0
Squash Court             13468.0
Badminton Court        1906.5

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT 
    m.surname, m.firstname, m.recommendedby AS recomender_id, r.surname AS recomender_surname, 
    r.firstname AS recomender_firstname
FROM Members AS m
LEFT JOIN Members AS r ON m.recommendedby = r.memid
WHERE m.recommendedby != 0
ORDER BY r.surname, r.firstname;

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT b.facid, COUNT( b.memid ) AS member_usage, f.name as facility_name
FROM (
SELECT facid, memid
FROM Bookings
WHERE memid !=0
) AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
GROUP BY b.facid;

/* Q13: Find the facilities usage by month, but not guests */
SELECT b.months, COUNT( b.memid ) AS member_usage
FROM (
SELECT MONTH( starttime ) AS months, memid
FROM Bookings
WHERE memid !=0
) AS b
GROUP BY b.months;
