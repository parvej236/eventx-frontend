-- ============================================================================
-- SQL Script: Display Contents of All Database Tables One by One (Capped at 5 Rows)
-- CUET Event Management System (EventX Database Verification)
-- Department of Computer Science & Engineering, CUET
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Departments Table
-- Tracks 18 official academic departments across CUET (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM departments LIMIT 5;

-- ----------------------------------------------------------------------------
-- 2. Clubs Table
-- Tracks 15 official CUET student societies and clubs (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM clubs LIMIT 5;

-- ----------------------------------------------------------------------------
-- 3. Users Table
-- Central authentication table (Students, Organizers, System Admins) (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM users LIMIT 5;

-- ----------------------------------------------------------------------------
-- 4. Students Table
-- Student profile extension detailing Student ID, Batch, and Department (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM students LIMIT 5;

-- ----------------------------------------------------------------------------
-- 5. Organizers Table
-- Club organizer profile mapping user to club leadership position
-- ----------------------------------------------------------------------------
SELECT * FROM organizers LIMIT 5;

-- ----------------------------------------------------------------------------
-- 6. Organizer Documents Table
-- Official verification documents uploaded by club organizers
-- ----------------------------------------------------------------------------
SELECT * FROM organizer_documents LIMIT 5;

-- ----------------------------------------------------------------------------
-- 7. Events Table
-- Master entity storing campus competitions, hackathons, and cultural events (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM events LIMIT 5;

-- ----------------------------------------------------------------------------
-- 8. Event Segments Table
-- Sub-segments and competition categories under master events (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM event_segments LIMIT 5;

-- ----------------------------------------------------------------------------
-- 9. Contains Relationship Table
-- Junction table mapping events to their constituent event segments (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM contains LIMIT 5;

-- ----------------------------------------------------------------------------
-- 10. Buildings Table
-- Campus academic complex buildings and venue facilities (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM buildings LIMIT 5;

-- ----------------------------------------------------------------------------
-- 11. Arranged In Relationship Table
-- Physical venue allocation mapping event segments to building locations (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM arranged_in LIMIT 5;

-- ----------------------------------------------------------------------------
-- 12. Volunteers In Relationship Table
-- Volunteer shift duty allocations connecting students with event segments (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM volunteers_in LIMIT 5;

-- ----------------------------------------------------------------------------
-- 13. Teams Table
-- Student participant team formations for group segments (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM teams LIMIT 5;

-- ----------------------------------------------------------------------------
-- 14. Forms Relationship Table
-- Junction table representing team member compositions (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM forms LIMIT 5;

-- ----------------------------------------------------------------------------
-- 15. Registrations Table
-- Core transaction table tracking segment registrations and payment statuses (Limited to 5 rows)
-- ----------------------------------------------------------------------------
SELECT * FROM registrations LIMIT 5;
