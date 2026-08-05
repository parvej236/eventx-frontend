-- ============================================================================
-- CUET EventX — Academic Relational Database Management System Showcase Queries
-- Department of Computer Science & Engineering, CUET
-- Target DBMS: MySQL 8.0 / PostgreSQL
-- Derived directly from Database Schema Specification (15 Relational Tables)
-- ============================================================================

-- ============================================================================
-- MODULE 1: User Management & Student Profiles
-- ============================================================================

-- Query 1.1: Multi-Table JOIN & IN Clause
-- Purpose: Displays user accounts for students and organizers along with their department names and batch information.
-- DBMS Concepts: LEFT JOIN, IN, COALESCE, ORDER BY
SELECT 
    u.user_id, 
    u.name, 
    u.email, 
    u.role, 
    COALESCE(s.student_id, 'N/A') AS student_id, 
    COALESCE(s.batch, 'N/A') AS batch, 
    COALESCE(d.name, 'N/A') AS department_name 
FROM users u 
LEFT JOIN students s ON u.user_id = s.user_id 
LEFT JOIN departments d ON s.department_id = d.department_id 
WHERE u.role IN ('STUDENT', 'ORGANIZER') 
ORDER BY u.user_id ASC;

-- Query 1.2: Subquery with EXISTS
-- Purpose: Shows all student accounts who have registered and successfully paid for at least one campus event.
-- DBMS Concepts: EXISTS, CORRELATED SUBQUERY, INNER JOIN, WHERE
SELECT 
    u.user_id, 
    u.name, 
    u.email, 
    s.student_id, 
    s.batch 
FROM users u 
INNER JOIN students s ON u.user_id = s.user_id 
WHERE EXISTS (
    SELECT 1 
    FROM registrations r 
    WHERE r.user_id = u.user_id AND r.payment_status = 'PAID'
) 
ORDER BY s.student_id ASC;

-- Query 1.3: Role Grouping & HAVING Clause
-- Purpose: Counts the total number of user accounts registered under each system role (Student, Organizer, Admin).
-- DBMS Concepts: GROUP BY, HAVING, COUNT, ORDER BY
SELECT 
    u.role, 
    COUNT(u.user_id) AS total_users, 
    COUNT(s.student_id) AS linked_students 
FROM users u 
LEFT JOIN students s ON u.user_id = s.user_id 
GROUP BY u.role 
HAVING total_users > 0 
ORDER BY total_users DESC;


-- ============================================================================
-- MODULE 2: Events & Multi-Segment Prize Aggregation
-- ============================================================================

-- Query 2.1: Multi-Table Aggregation (SUM & COUNT)
-- Purpose: Displays active campus competitions, showing the hosting club, total segments, and total prize pool money.
-- DBMS Concepts: INNER JOIN, LEFT JOIN, SUM, COUNT, GROUP BY
SELECT 
    e.event_id, 
    e.name AS event_title, 
    c.name AS host_club, 
    COUNT(DISTINCT s.segment_id) AS total_segments, 
    COALESCE(SUM(s.prize), 0) AS aggregate_prize_pool, 
    e.status 
FROM events e 
INNER JOIN users u ON e.user_id = u.user_id 
INNER JOIN organizers o ON u.user_id = o.user_id 
INNER JOIN clubs c ON o.club_id = c.club_id 
LEFT JOIN contains cnt ON e.event_id = cnt.event_id 
LEFT JOIN event_segments s ON cnt.segment_id = s.segment_id 
GROUP BY e.event_id, e.name, c.name, e.status 
ORDER BY e.event_id DESC;

-- Query 2.2: Subquery with EXISTS & ALL
-- Purpose: Lists major flagship competitions that feature segment prize pools higher than ৳ 20,000.
-- DBMS Concepts: EXISTS, ALL, SUBQUERY, HAVING
SELECT 
    e.event_id, 
    e.name AS event_title, 
    c.name AS host_club 
FROM events e 
INNER JOIN users u ON e.user_id = u.user_id 
INNER JOIN organizers o ON u.user_id = o.user_id 
INNER JOIN clubs c ON o.club_id = c.club_id 
WHERE EXISTS (
    SELECT 1 
    FROM contains cnt 
    INNER JOIN event_segments s ON cnt.segment_id = s.segment_id 
    WHERE cnt.event_id = e.event_id AND s.prize > ALL (SELECT 20000)
) 
ORDER BY e.event_id DESC;

-- Query 2.3: Building Allocation & HAVING Clause
-- Purpose: Shows campus venue buildings that are hosting multiple events to monitor location usage.
-- DBMS Concepts: LEFT JOIN, GROUP BY, HAVING, COUNT
SELECT 
    b.building_id, 
    b.name AS building_name, 
    b.location, 
    COUNT(DISTINCT arr.segment_id) AS allocated_segments 
FROM buildings b 
LEFT JOIN arranged_in arr ON b.building_id = arr.building_id 
GROUP BY b.building_id, b.name, b.location 
HAVING allocated_segments > 1 
ORDER BY allocated_segments DESC;


-- ============================================================================
-- MODULE 3: Organizer Dashboard & Payment Verification
-- ============================================================================

-- Query 3.1: 4-Way Relational JOIN & TrxID Verification
-- Purpose: Displays student event registrations with team leader names, segment titles, mobile payment transaction IDs, and fee details for organizer verification.
-- DBMS Concepts: INNER JOIN, 4-WAY JOIN, WHERE, ORDER BY
SELECT 
    r.reg_id, 
    COALESCE(t.team_name, 'Individual') AS team_name, 
    u.name AS team_leader, 
    COALESCE(st.student_id, 'N/A') AS student_id, 
    e.name AS event_name, 
    s.title AS segment_title, 
    r.transaction_number, 
    r.method, 
    r.payment_status, 
    s.reg_fee 
FROM registrations r 
INNER JOIN users u ON r.user_id = u.user_id 
LEFT JOIN students st ON u.user_id = st.user_id 
LEFT JOIN teams t ON r.team_id = t.team_id 
INNER JOIN event_segments s ON r.segment_id = s.segment_id 
INNER JOIN contains cnt ON s.segment_id = cnt.segment_id 
INNER JOIN events e ON cnt.event_id = e.event_id 
WHERE r.payment_status IN ('PAID', 'PENDING') 
ORDER BY r.registered_at DESC;

-- Query 3.2: Payment Verification EXISTS Subquery
-- Purpose: Lists all competition segments that have received confirmed paid registrations from participating teams.
-- DBMS Concepts: EXISTS, SUBQUERY, IN, INNER JOIN
SELECT 
    s.segment_id, 
    s.title AS segment_title, 
    e.name AS event_name 
FROM event_segments s 
INNER JOIN contains cnt ON s.segment_id = cnt.segment_id 
INNER JOIN events e ON cnt.event_id = e.event_id 
WHERE EXISTS (
    SELECT 1 
    FROM registrations r 
    WHERE r.segment_id = s.segment_id AND r.payment_status = 'PAID'
) 
ORDER BY s.segment_id ASC;

-- Query 3.3: Total Revenue Aggregation by Segment
-- Purpose: Calculates the total registration fee collected and total registered teams for each competition segment.
-- DBMS Concepts: GROUP BY, SUM, COUNT, HAVING
SELECT 
    s.title AS segment_title, 
    COUNT(r.reg_id) AS total_registrations, 
    SUM(s.reg_fee) AS total_collected_revenue 
FROM event_segments s 
INNER JOIN registrations r ON s.segment_id = r.segment_id 
WHERE r.payment_status = 'PAID' 
GROUP BY s.segment_id, s.title 
HAVING total_collected_revenue > 0 
ORDER BY total_collected_revenue DESC;


-- ============================================================================
-- MODULE 4: Student Club Management & Departments
-- ============================================================================

-- Query 4.1: Multi-Table JOIN & Event Count
-- Purpose: Shows all official student clubs, their department affiliations, and the total number of events hosted by each club.
-- DBMS Concepts: LEFT JOIN, COUNT, GROUP BY, COALESCE, ORDER BY
SELECT 
    c.club_id, 
    c.name AS club_name, 
    COALESCE(d.name, 'University Wide') AS department_name, 
    COUNT(DISTINCT e.event_id) AS total_events_hosted, 
    c.status 
FROM clubs c 
LEFT JOIN organizers o ON c.club_id = o.club_id 
LEFT JOIN departments d ON o.department_id = d.department_id 
LEFT JOIN events e ON o.user_id = e.user_id 
GROUP BY c.club_id, c.name, d.name, c.status 
ORDER BY total_events_hosted DESC;

-- Query 4.2: Active Clubs EXISTS Subquery
-- Purpose: Lists student societies that are actively organizing open or upcoming campus events.
-- DBMS Concepts: EXISTS, SUBQUERY, WHERE, ORDER BY
SELECT 
    c.club_id, 
    c.name AS club_name, 
    c.status 
FROM clubs c 
WHERE EXISTS (
    SELECT 1 
    FROM organizers o 
    INNER JOIN events e ON o.user_id = e.user_id 
    WHERE o.club_id = c.club_id AND e.status IN ('REGISTRATION OPEN', 'LIVE NOW', 'UPCOMING')
) 
ORDER BY c.club_id ASC;

-- Query 4.3: Department Club Aggregation & HAVING Clause
-- Purpose: Shows the number of student clubs operating under each academic department.
-- DBMS Concepts: GROUP BY, HAVING, COUNT, INNER JOIN
SELECT 
    d.name AS department_name, 
    COUNT(DISTINCT c.club_id) AS total_clubs 
FROM departments d 
INNER JOIN organizers o ON d.department_id = o.department_id 
INNER JOIN clubs c ON o.club_id = c.club_id 
GROUP BY d.department_id, d.name 
HAVING total_clubs > 0 
ORDER BY total_clubs DESC;


-- ============================================================================
-- MODULE 5: Student Dashboard & Volunteer Duty Shifts
-- ============================================================================

-- Query 5.1: Volunteer Duties & Venue JOIN
-- Purpose: Shows the assigned volunteer duty shifts, event roles, shift dates, and venue buildings for the logged-in student.
-- DBMS Concepts: INNER JOIN, LEFT JOIN, WHERE, ORDER BY
SELECT 
    v.user_id, 
    e.name AS event_name, 
    s.title AS segment_title, 
    COALESCE(b.name, 'TBA') AS building_name, 
    v.check_in_time, 
    v.status 
FROM volunteers_in v 
INNER JOIN event_segments s ON v.segment_id = s.segment_id 
INNER JOIN contains cnt ON s.segment_id = cnt.segment_id 
INNER JOIN events e ON cnt.event_id = e.event_id 
LEFT JOIN arranged_in arr ON s.segment_id = arr.segment_id 
LEFT JOIN buildings b ON arr.building_id = b.building_id 
WHERE v.user_id = 1 
ORDER BY v.check_in_time DESC;


-- ============================================================================
-- MODULE 6: Academic Departments & Enrollment Metrics
-- ============================================================================

-- Query 6.1: Department Enrolled Student Aggregation
-- Purpose: Displays all academic departments in CUET alongside the total count of enrolled students in each department.
-- DBMS Concepts: LEFT JOIN, COUNT, GROUP BY, ORDER BY
SELECT 
    d.department_id, 
    d.name AS department_name, 
    d.code, 
    COUNT(DISTINCT s.user_id) AS total_enrolled_students 
FROM departments d 
LEFT JOIN students s ON d.department_id = s.department_id 
GROUP BY d.department_id, d.name, d.code 
ORDER BY d.department_id ASC;


-- ============================================================================
-- MODULE 7: Campus Buildings & Venue Allocations
-- ============================================================================

-- Query 7.1: Building Venue Capacity & Allocation
-- Purpose: Lists campus buildings, their location zones, operational status, and the total count of allocated events.
-- DBMS Concepts: LEFT JOIN, COUNT, GROUP BY, ORDER BY
SELECT 
    b.building_id, 
    b.name AS building_name, 
    b.location, 
    COUNT(DISTINCT arr.segment_id) AS total_allocated_segments, 
    b.status 
FROM buildings b 
LEFT JOIN arranged_in arr ON b.building_id = arr.building_id 
GROUP BY b.building_id, b.name, b.location, b.status 
ORDER BY total_allocated_segments DESC;
