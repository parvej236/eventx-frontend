# EventX Frontend — CUET Centralized Event Management & Verification System

> **Department of Computer Science & Engineering**  
> **Chittagong University of Engineering & Technology (CUET)**  
> *Course Project: Full-Stack Web Application & Academic Presentation Suite*

---

## 📌 Project Overview

**EventX Frontend** is a modern, high-performance Single Page Application (SPA) built with **Vue.js 3 (Composition API)**, **Vite 8**, and **TailwindCSS v4**. It delivers a responsive, glassmorphic user interface tailored for students, club organizers, volunteers, and university administrators at Chittagong University of Engineering & Technology (CUET).

The application also features an embedded **Academic SQL Presentation Showcase Suite** capable of rendering complex relational queries and exporting high-resolution PNG images of output tables for academic course evaluations.

---

## 🎨 Tech Stack & UI Libraries

- **Framework**: Vue.js 3 (Composition API with `<script setup>`)
- **Build Tool**: Vite 8 (Instantaneous HMR & bundled production output)
- **Styling**: TailwindCSS v4 + Vanilla CSS Design Tokens (Glassmorphism, Dark/Light Themes)
- **Iconography**: Lucide Vue Next
- **Image Export**: `html2canvas` (High-DPI PNG table screenshot generator)
- **Routing**: Vue Router 4 (Role-based view navigation)

---

## 🚀 Key Features & Role Dashboards

### 👨‍🎓 1. Student Participant Portal
- **Event Discovery**: Search and filter university hackathons, RoboClash battles, debate championships, and cultural festivals.
- **Multi-Segment Registration**: Register for individual or team events with leader configuration.
- **Mobile Banking Payment**: Submit transaction IDs for bKash, Nagad, and Rocket payments with status tracking (`PAID`, `PENDING`).

### 🙋‍♂️ 2. Student Volunteer Duty Tracker
- **Shift Assignment View**: View assigned duty segments, time slots, and campus building venue locations.
- **Digital Check-In**: One-click digital check-in modal updating real-time attendance logs.

### 🏛 3. Club Organizer Portal
- **Document Verification Upload**: Submit official club approval documents (`.pdf`/`.png`) for administrative authorization.
- **Team Registration Audit**: Review student transaction numbers and verify payment receipts.
- **Event Hosting**: Configure multi-segment competition rules, prize pools, and schedules.

### 🛡 4. System Administrator Dashboard
- **Organizer Document Portal**: Approve (`APPROVED`) or Reject (`REJECTED`) pending club organizer authorization applications.
- **Campus Building Allocation**: Map physical academic buildings (CSE Block, EEE Building, Central Auditorium) to event segments.
- **Directory Audit**: Manage 18 CUET academic departments and 15 student societies.

### 📊 5. Interactive SQL Presentation Showcase
- **Academic Query Runner**: Renders 14 complex database showcase queries (4-way JOINs, correlated subqueries, `EXISTS`, `HAVING`, `COALESCE`).
- **PNG Table Output Export**: One-click PNG image generation of query output tables for inclusion in academic slide presentations.

---

## 📂 Project Structure

```
eventx-frontend/
├── public/                      # Public static assets & SQL showcase query files
│   ├── showcase_queries.sql     # 14 Academic showcase queries
│   └── select_all_tables.sql    # Table inspection SQL script
├── src/
│   ├── assets/                  # Logos, banners, and static graphics
│   ├── components/              # Modular UI components
│   │   ├── dashboard/           # Role-specific dashboard views
│   │   │   ├── BuildingManagement.vue
│   │   │   ├── DepartmentManagement.vue
│   │   │   ├── EventCreation.vue
│   │   │   ├── EventManagement.vue
│   │   │   ├── OrganizerVerification.vue
│   │   │   └── PaymentVerification.vue
│   │   ├── Navbar.vue           # Reactive navigation bar
│   │   ├── Footer.vue           # Page footer component
│   │   └── VolunteerModal.vue   # Volunteer shift check-in modal
│   ├── router/                  # Vue Router configuration
│   ├── views/                   # Main page view components
│   │   ├── HomeView.vue         # Landing page & hero showcase
│   │   ├── EventsView.vue       # Event directory & segment details
│   │   ├── DashboardView.vue    # Role-based unified dashboard
│   │   ├── SqlShowcaseView.vue  # DBMS presentation showcase suite
│   │   ├── LoginView.vue        # Auth login page
│   │   └── RegisterView.vue     # User registration page
│   ├── App.vue                  # Root application component
│   ├── main.js                  # App initialization & plugin mounting
│   └── style.css                # TailwindCSS & glassmorphic custom tokens
├── package.json                 # Node dependencies & script commands
└── vite.config.js               # Vite build configuration
```

---

## 💻 Installation & Setup

### Prerequisites
- **Node.js**: Version 18.0 or higher
- **npm**: Version 9.0 or higher

### Step-by-Step Execution

1. **Install Dependencies**:
   ```bash
   npm install
   ```

2. **Run Development Server**:
   ```bash
   npm run dev
   ```
   Access application at: **`http://localhost:5173`**

3. **Build for Production**:
   ```bash
   npm run build
   ```
   Production bundle will be compiled into the `dist/` directory.

4. **Preview Production Build**:
   ```bash
   npm run preview
   ```

---

## 👥 Academic Authors & Metadata

- **Sharika Hossain** — ID: `2304084`
- **Sayed Tasriful Islam** — ID: `2304085`
- **M Parvej Alam** — ID: `2304086`

**Supervisor**: **Md. Atiqul Islam Rizvi** (Assistant Professor, Dept of CSE, CUET)  
**Session**: 2023 - 2024  
**Institution**: Chittagong University of Engineering & Technology (CUET)
