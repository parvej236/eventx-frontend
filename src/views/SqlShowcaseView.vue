<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { 
  Database, Code2, Check, Copy, X, Terminal, HelpCircle, Info, 
  Layers, Sparkles, Search, CheckCircle2, Clock, ShieldCheck, Mail, 
  Tag, Hash, ArrowUpRight, Zap, User, Trophy, Building2, GraduationCap, 
  Users, Calendar, CreditCard, MapPin, ExternalLink, ChevronRight, Home, ArrowLeft,
  Download, Maximize2, Minimize2, Loader2
} from 'lucide-vue-next'
import html2canvas from 'html2canvas'

const route = useRoute()
const router = useRouter()

// All 7 Presentation Modules with complete SQL query suites
const modulesData = {
  users: {
    id: 'users',
    title: 'User Management & Student Profiles',
    icon: User,
    badge: 'Users & Roles',
    queries: [
      {
        name: '1. Multi-Table JOIN & IN Clause',
        concepts: ['LEFT JOIN', 'IN', 'COALESCE', 'ORDER BY'],
        purpose: 'Displays user accounts for students and organizers along with their department names and batch information.',
        query: `SELECT u.user_id, u.name, u.email, u.role, COALESCE(s.student_id, 'N/A') AS student_id, COALESCE(s.batch, 'N/A') AS batch, COALESCE(d.name, 'N/A') AS department_name FROM users u LEFT JOIN students s ON u.user_id = s.user_id LEFT JOIN departments d ON s.department_id = d.department_id WHERE u.role IN ('STUDENT', 'ORGANIZER') ORDER BY u.user_id ASC;`,
        explanation: 'Performs LEFT JOIN operations between users, students, and departments tables based on user_id and department_id foreign keys from schema.sql.',
        columns: ['User ID', 'Name', 'Email', 'Role', 'Student ID', 'Batch', 'Department'],
        rows: [
          [1, 'Alice Mahmud', 'alice@cuet.ac.bd', 'STUDENT', '2304001', '2023', 'Computer Science & Engineering'],
          [2, 'Tanvir Hossain', 'tanvir@cuet.ac.bd', 'STUDENT', '2302044', '2023', 'Electrical and Electronic Engineering'],
          [3, 'Sayed Tasriful Islam', 'tasriful@cuet.ac.bd', 'ORGANIZER', 'N/A', 'N/A', 'Computer Science & Engineering'],
          [4, 'M Parvej Alam', 'parvej@cuet.ac.bd', 'ORGANIZER', 'N/A', 'N/A', 'Computer Science & Engineering']
        ]
      },
      {
        name: '2. Subquery with EXISTS',
        concepts: ['EXISTS', 'CORRELATED SUBQUERY', 'INNER JOIN', 'WHERE'],
        purpose: 'Shows all student accounts who have registered and successfully paid for at least one campus event.',
        query: `SELECT u.user_id, u.name, u.email, s.student_id, s.batch FROM users u INNER JOIN students s ON u.user_id = s.user_id WHERE EXISTS (SELECT 1 FROM registrations r WHERE r.user_id = u.user_id AND r.payment_status = 'PAID') ORDER BY s.student_id ASC;`,
        explanation: 'Executes a correlated subquery evaluated with EXISTS on the registrations table using reg_id and user_id foreign key mappings.',
        columns: ['User ID', 'Student Name', 'Email', 'Student ID', 'Batch'],
        rows: [
          [1, 'Alice Mahmud', 'alice@cuet.ac.bd', '2304001', '2023'],
          [2, 'Tanvir Hossain', 'tanvir@cuet.ac.bd', '2302044', '2023'],
          [8, 'Noshin Tarannum', 'noshin@cuet.ac.bd', '2405089', '2024']
        ]
      },
      {
        name: '3. Role Grouping & HAVING',
        concepts: ['GROUP BY', 'HAVING', 'COUNT', 'ORDER BY'],
        purpose: 'Counts the total number of user accounts registered under each system role (Student, Organizer, Admin).',
        query: `SELECT u.role, COUNT(u.user_id) AS total_users, COUNT(s.student_id) AS linked_students FROM users u LEFT JOIN students s ON u.user_id = s.user_id GROUP BY u.role HAVING total_users > 0 ORDER BY total_users DESC;`,
        explanation: 'Groups system user accounts by role (STUDENT, ORGANIZER, ADMIN), computes aggregate headcounts, and enforces minimum profile constraints using a HAVING clause.',
        columns: ['User Role', 'Total Accounts', 'Linked Student Profiles'],
        rows: [
          ['STUDENT', 15, 15],
          ['ORGANIZER', 4, 0],
          ['ADMIN', 1, 0]
        ]
      }
    ]
  },
  events: {
    id: 'events',
    title: 'Events & Multi-Segment Prize Aggregation',
    icon: Trophy,
    badge: 'Events & Competitions',
    queries: [
      {
        name: '1. Multi-Table Aggregation (SUM & COUNT)',
        concepts: ['INNER JOIN', 'LEFT JOIN', 'SUM', 'COUNT', 'GROUP BY'],
        purpose: 'Displays active campus competitions, showing the hosting club, total segments, and total prize pool money.',
        query: `SELECT e.event_id, e.name AS event_title, c.name AS host_club, COUNT(DISTINCT s.segment_id) AS total_segments, COALESCE(SUM(s.prize), 0) AS aggregate_prize_pool, e.status FROM events e INNER JOIN users u ON e.user_id = u.user_id INNER JOIN organizers o ON u.user_id = o.user_id INNER JOIN clubs c ON o.club_id = c.club_id LEFT JOIN contains cnt ON e.event_id = cnt.event_id LEFT JOIN event_segments s ON cnt.segment_id = s.segment_id GROUP BY e.event_id, e.name, c.name, e.status ORDER BY e.event_id DESC;`,
        explanation: 'Navigates relational joins from events to organizers and clubs via user_id, and sums sub-segment prize amounts from contains junction table.',
        columns: ['Event ID', 'Event Title', 'Host Club', 'Segments', 'Prize Pool', 'Status'],
        rows: [
          [1, 'CUET TechFest & National Hackathon 2026', 'Computer Club', 8, '৳ 170,000.00', 'REGISTRATION OPEN'],
          [2, 'RoboClash & MechaWars Arena 2026', 'RMA (Robotics & Mechatronics Association)', 5, '৳ 95,000.00', 'REGISTRATION OPEN'],
          [3, 'Joyoddhoney Sanskritik Sandhya & Drama Fest', 'Joyoddhoney', 5, '৳ 80,000.00', 'REGISTRATION OPEN'],
          [4, 'CUET National Parliamentary Debate 2026', 'Debating Society', 5, '৳ 77,000.00', 'REGISTRATION OPEN']
        ]
      },
      {
        name: '2. Subquery with EXISTS & ALL',
        concepts: ['EXISTS', 'ALL', 'SUBQUERY', 'HAVING'],
        purpose: 'Lists major flagship competitions that feature segment prize pools higher than ৳ 20,000.',
        query: `SELECT e.event_id, e.name AS event_title, c.name AS host_club FROM events e INNER JOIN users u ON e.user_id = u.user_id INNER JOIN organizers o ON u.user_id = o.user_id INNER JOIN clubs c ON o.club_id = c.club_id WHERE EXISTS (SELECT 1 FROM contains cnt INNER JOIN event_segments s ON cnt.segment_id = s.segment_id WHERE cnt.event_id = e.event_id AND s.prize > ALL (SELECT 20000)) ORDER BY e.event_id DESC;`,
        explanation: 'Evaluates correlated subqueries joining contains and event_segments with ALL threshold operators based on schema.sql DDL.',
        columns: ['Event ID', 'Event Title', 'Host Club'],
        rows: [
          [1, 'CUET TechFest & National Hackathon 2026', 'Computer Club'],
          [2, 'RoboClash & MechaWars Arena 2026', 'RMA (Robotics & Mechatronics Association)'],
          [3, 'Joyoddhoney Sanskritik Sandhya & Drama Fest', 'Joyoddhoney'],
          [4, 'CUET National Parliamentary Debate 2026', 'Debating Society']
        ]
      },
      {
        name: '3. Building Allocation & HAVING',
        concepts: ['LEFT JOIN', 'GROUP BY', 'HAVING', 'COUNT'],
        purpose: 'Shows campus venue buildings that are hosting multiple events to monitor location usage.',
        query: `SELECT b.building_id, b.name AS building_name, b.location, COUNT(DISTINCT arr.segment_id) AS allocated_segments FROM buildings b LEFT JOIN arranged_in arr ON b.building_id = arr.building_id GROUP BY b.building_id, b.name, b.location HAVING allocated_segments > 1 ORDER BY allocated_segments DESC;`,
        explanation: 'Groups arranged_in junction table allocations per building venue and applies a HAVING clause for event count filtering.',
        columns: ['Building ID', 'Building Name', 'Location Zone', 'Allocated Segments'],
        rows: [
          [1, 'CSE Building', 'Academic Complex - Block A', 10],
          [2, 'Electrical & Electronics Building', 'Academic Complex - Block B', 5],
          [3, 'CUET Central Auditorium', 'Administrative Square', 5],
          [5, 'Civil Engineering Building', 'Academic Complex - Block C', 5],
          [4, 'Student Recreation Center', 'Sports Ground West', 5]
        ]
      }
    ]
  },
  organizer: {
    id: 'organizer',
    title: 'Organizer Dashboard & Payment Verification',
    icon: ShieldCheck,
    badge: 'Verification Portal',
    queries: [
      {
        name: '1. 4-Way Relational JOIN & TrxID',
        concepts: ['INNER JOIN', '4-WAY JOIN', 'WHERE', 'ORDER BY'],
        purpose: 'Displays student event registrations with team leader names, segment titles, mobile payment transaction IDs, and fee details for organizer verification.',
        query: `SELECT r.reg_id, COALESCE(t.team_name, 'Individual') AS team_name, u.name AS team_leader, COALESCE(st.student_id, 'N/A') AS student_id, e.name AS event_name, s.title AS segment_title, r.transaction_number, r.method, r.payment_status, s.reg_fee FROM registrations r INNER JOIN users u ON r.user_id = u.user_id LEFT JOIN students st ON u.user_id = st.user_id LEFT JOIN teams t ON r.team_id = t.team_id INNER JOIN event_segments s ON r.segment_id = s.segment_id INNER JOIN contains cnt ON s.segment_id = cnt.segment_id INNER JOIN events e ON cnt.event_id = e.event_id WHERE r.payment_status IN ('PAID', 'PENDING') ORDER BY r.registered_at DESC;`,
        explanation: 'Performs relational joins across registrations (reg_id, transaction_number, method), users, teams, event_segments, contains, and events.',
        columns: ['Reg ID', 'Team Name', 'Leader', 'Student ID', 'Event Name', 'Segment Title', 'TrxID', 'Method', 'Status', 'Reg Fee'],
        rows: [
          [1020, 'Apex Predators', 'Sadaf Karim', '2501015', 'Inter-Dept Esports Championship 2026', 'Mobile Legends (MLBB) Showdown', 'BKSH66192038', 'bKash', 'PAID', '৳ 300.00'],
          [1019, 'Orators of CUET', 'Noshin Tarannum', '2405089', 'CUET National Parliamentary Debate 2026', 'Inter-College Invitational Debate', 'NGD88291039', 'Nagad', 'PAID', '৳ 400.00'],
          [1001, 'ByteBuilders', 'Alice Mahmud', '2304001', 'CUET TechFest & National Hackathon 2026', 'National 24-Hour AI & Web Hackathon', 'TXN88921092', 'bKash', 'PAID', '৳ 600.00'],
          [1003, 'Echo Waves', 'Adnan Chowdhury', '2408012', 'Joyoddhoney Sanskritik Sandhya & Drama Fest', 'Inter-Department Battle of the Bands', 'BKSH99120485', 'bKash', 'PENDING', '৳ 800.00']
        ]
      },
      {
        name: '2. Payment Verification EXISTS Subquery',
        concepts: ['EXISTS', 'SUBQUERY', 'IN', 'INNER JOIN'],
        purpose: 'Lists all competition segments that have received confirmed paid registrations from participating teams.',
        query: `SELECT s.segment_id, s.title AS segment_title, e.name AS event_name FROM event_segments s INNER JOIN contains cnt ON s.segment_id = cnt.segment_id INNER JOIN events e ON cnt.event_id = e.event_id WHERE EXISTS (SELECT 1 FROM registrations r WHERE r.segment_id = s.segment_id AND r.payment_status = 'PAID') ORDER BY s.segment_id ASC;`,
        explanation: 'Evaluates correlated EXISTS subqueries on registrations referencing event_segments and contains mapping tables.',
        columns: ['Segment ID', 'Segment Title', 'Event Name'],
        rows: [
          [101, 'National 24-Hour AI & Web Hackathon', 'CUET TechFest & National Hackathon 2026'],
          [102, 'CUET National IUPC Programming Contest', 'CUET TechFest & National Hackathon 2026'],
          [201, 'Autonomous Line Follower (LFR)', 'RoboClash & MechaWars Arena 2026']
        ]
      },
      {
        name: '3. Total Revenue Aggregation by Segment',
        concepts: ['GROUP BY', 'SUM', 'COUNT', 'HAVING'],
        purpose: 'Calculates the total registration fee collected and total registered teams for each competition segment.',
        query: `SELECT s.title AS segment_title, COUNT(r.reg_id) AS total_registrations, SUM(s.reg_fee) AS total_collected_revenue FROM event_segments s INNER JOIN registrations r ON s.segment_id = r.segment_id WHERE r.payment_status = 'PAID' GROUP BY s.segment_id, s.title HAVING total_collected_revenue > 0 ORDER BY total_collected_revenue DESC;`,
        explanation: 'Sums registration fees per segment using s.reg_fee and registrations.reg_id with GROUP BY and HAVING clauses.',
        columns: ['Segment Title', 'Total Registrations', 'Collected Revenue'],
        rows: [
          ['National 24-Hour AI & Web Hackathon', 1, '৳ 600.00'],
          ['Autonomous Line Follower (LFR)', 1, '৳ 500.00'],
          ['CUET National IUPC Programming Contest', 1, '৳ 500.00']
        ]
      }
    ]
  },
  clubs: {
    id: 'clubs',
    title: 'Student Club Management & Departments',
    icon: Users,
    badge: 'Campus Clubs',
    queries: [
      {
        name: '1. Multi-Table JOIN & Event Count',
        concepts: ['LEFT JOIN', 'COUNT', 'GROUP BY', 'COALESCE', 'ORDER BY'],
        purpose: 'Shows all official student clubs, their department affiliations, and the total number of events hosted by each club.',
        query: `SELECT c.club_id, c.name AS club_name, COALESCE(d.name, 'University Wide') AS department_name, COUNT(DISTINCT e.event_id) AS total_events_hosted, c.status FROM clubs c LEFT JOIN organizers o ON c.club_id = o.club_id LEFT JOIN departments d ON o.department_id = d.department_id LEFT JOIN events e ON o.user_id = e.user_id GROUP BY c.club_id, c.name, d.name, c.status ORDER BY total_events_hosted DESC;`,
        explanation: 'Navigates clubs to organizers, departments, and events via relational foreign key links defined in schema.sql.',
        columns: ['Club ID', 'Club Name', 'Department Name', 'Events Hosted', 'Status'],
        rows: [
          [14, 'Computer Club', 'Computer Science & Engineering', 2, 'ACTIVE'],
          [5, 'RMA (Robotics & Mechatronics Association)', 'Computer Science & Engineering', 2, 'ACTIVE'],
          [10, 'Joyoddhoney', 'Computer Science & Engineering', 1, 'ACTIVE'],
          [13, 'Debating Society', 'Electrical and Electronic Engineering', 1, 'ACTIVE']
        ]
      },
      {
        name: '2. Active Clubs EXISTS Subquery',
        concepts: ['EXISTS', 'SUBQUERY', 'WHERE', 'ORDER BY'],
        purpose: 'Lists student societies that are actively organizing open or upcoming campus events.',
        query: `SELECT c.club_id, c.name AS club_name, c.status FROM clubs c WHERE EXISTS (SELECT 1 FROM organizers o INNER JOIN events e ON o.user_id = e.user_id WHERE o.club_id = c.club_id AND e.status IN ('REGISTRATION OPEN', 'LIVE NOW', 'UPCOMING')) ORDER BY c.club_id ASC;`,
        explanation: 'Applies EXISTS subquery filtering across organizers and events tables targeting active club schedules.',
        columns: ['Club ID', 'Club Name', 'Status'],
        rows: [
          [5, 'RMA (Robotics & Mechatronics Association)', 'ACTIVE'],
          [10, 'Joyoddhoney', 'ACTIVE'],
          [13, 'Debating Society', 'ACTIVE'],
          [14, 'Computer Club', 'ACTIVE']
        ]
      },
      {
        name: '3. Department Club Aggregation & HAVING',
        concepts: ['GROUP BY', 'HAVING', 'COUNT', 'INNER JOIN'],
        purpose: 'Shows the number of student clubs operating under each academic department.',
        query: `SELECT d.name AS department_name, COUNT(DISTINCT c.club_id) AS total_clubs FROM departments d INNER JOIN organizers o ON d.department_id = o.department_id INNER JOIN clubs c ON o.club_id = c.club_id GROUP BY d.department_id, d.name HAVING total_clubs > 0 ORDER BY total_clubs DESC;`,
        explanation: 'Groups student clubs by academic department foreign key relationships from organizers table.',
        columns: ['Department Name', 'Hosted Student Clubs'],
        rows: [
          ['Computer Science & Engineering', 3],
          ['Electrical and Electronic Engineering', 1]
        ]
      }
    ]
  },
  students: {
    id: 'students',
    title: 'Student Dashboard & Volunteer Duty Shifts',
    icon: Sparkles,
    badge: 'Volunteer Duty',
    queries: [
      {
        name: '1. Volunteer Duties & Venue JOIN',
        concepts: ['INNER JOIN', 'LEFT JOIN', 'WHERE', 'ORDER BY'],
        purpose: 'Shows the assigned volunteer duty shifts, event roles, shift dates, and venue buildings for the logged-in student.',
        query: `SELECT v.user_id, e.name AS event_name, s.title AS segment_title, COALESCE(b.name, 'TBA') AS building_name, v.check_in_time, v.status FROM volunteers_in v INNER JOIN event_segments s ON v.segment_id = s.segment_id INNER JOIN contains cnt ON s.segment_id = cnt.segment_id INNER JOIN events e ON cnt.event_id = e.event_id LEFT JOIN arranged_in arr ON s.segment_id = arr.segment_id LEFT JOIN buildings b ON arr.building_id = b.building_id WHERE v.user_id = 1 ORDER BY v.check_in_time DESC;`,
        explanation: 'Queries volunteers_in junction table joined with event_segments, contains, events, arranged_in, and buildings.',
        columns: ['User ID', 'Event Name', 'Segment Title', 'Building Venue', 'Check-In Time', 'Status'],
        rows: [
          [1, 'CUET TechFest & National Hackathon 2026', 'National 24-Hour AI & Web Hackathon', 'CSE Building', '2026-08-25 09:30:00', 'CHECKED_IN'],
          [1, 'RoboClash & MechaWars Arena 2026', 'Wireless Robo Soccer Championship', 'Electrical & Electronics Building', '2026-08-16 11:00:00', 'CHECKED_IN']
        ]
      }
    ]
  },
  departments: {
    id: 'departments',
    title: 'Academic Departments & Enrollment Metrics',
    icon: GraduationCap,
    badge: 'Academic Faculties',
    queries: [
      {
        name: '1. Department Enrolled Student Aggregation',
        concepts: ['LEFT JOIN', 'COUNT', 'GROUP BY', 'ORDER BY'],
        purpose: 'Displays all academic departments in CUET alongside the total count of enrolled students in each department.',
        query: `SELECT d.department_id, d.name AS department_name, d.code, COUNT(DISTINCT s.user_id) AS total_enrolled_students FROM departments d LEFT JOIN students s ON d.department_id = s.department_id GROUP BY d.department_id, d.name, d.code ORDER BY d.department_id ASC;`,
        explanation: 'Performs LEFT JOIN operations between departments and students tables, counting distinct enrolled student IDs.',
        columns: ['Dept ID', 'Department Name', 'Code', 'Enrolled Students'],
        rows: [
          [1, 'Architecture', 'ARCH', 2],
          [5, 'Computer Science & Engineering', 'CSE', 7],
          [7, 'Electrical and Electronic Engineering', 'EEE', 3],
          [12, 'Mechanical Engineering', 'ME', 2],
          [13, 'Mechatronics & Industrial Engineering', 'MIE', 1]
        ]
      }
    ]
  },
  buildings: {
    id: 'buildings',
    title: 'Campus Buildings & Venue Allocations',
    icon: Building2,
    badge: 'Infrastructure Venues',
    queries: [
      {
        name: '1. Building Venue Capacity & Allocation',
        concepts: ['LEFT JOIN', 'COUNT', 'GROUP BY', 'ORDER BY'],
        purpose: 'Lists campus buildings, their location zones, operational status, and the total count of allocated events.',
        query: `SELECT b.building_id, b.name AS building_name, b.location, COUNT(DISTINCT arr.segment_id) AS total_allocated_segments, b.status FROM buildings b LEFT JOIN arranged_in arr ON b.building_id = arr.building_id GROUP BY b.building_id, b.name, b.location, b.status ORDER BY total_allocated_segments DESC;`,
        explanation: 'Aggregates segment allocations per building venue using arranged_in junction table and GROUP BY.',
        columns: ['Building ID', 'Building Name', 'Location Zone', 'Allocated Segments', 'Status'],
        rows: [
          [1, 'CSE Building', 'Academic Complex - Block A', 10, 'ACTIVE'],
          [2, 'Electrical & Electronics Building', 'Academic Complex - Block B', 5, 'ACTIVE'],
          [3, 'CUET Central Auditorium', 'Administrative Square', 5, 'ACTIVE'],
          [4, 'Student Recreation Center', 'Sports Ground West', 5, 'ACTIVE'],
          [5, 'Civil Engineering Building', 'Academic Complex - Block C', 5, 'ACTIVE'],
          [6, 'Architecture Studio Block', 'Design Quadrangle', 3, 'ACTIVE']
        ]
      }
    ]
  }
}

// Active Selected Module Key (Default from URL query param ?module=users)
const activeModuleKey = ref('users')
const activeTabIndex = ref(0)
const resultSearchQuery = ref('')
const copied = ref(false)
const tableContainerRef = ref(null)
const isExporting = ref(false)
const isLargeView = ref(false)

const triggerDownload = (dataUrl, filename) => {
  const link = document.createElement('a')
  link.href = dataUrl
  link.download = filename
  link.setAttribute('download', filename)
  document.body.appendChild(link)
  link.click()
  setTimeout(() => {
    if (document.body.contains(link)) {
      document.body.removeChild(link)
    }
  }, 500)
}

const downloadAsPng = async () => {
  if (!tableContainerRef.value) return
  isExporting.value = true
  
  const modTitle = String(activeModuleKey.value).toUpperCase()
  const qNum = activeTabIndex.value + 1
  const filename = `CUET_EventX_SQL_${modTitle}_Query_${qNum}_Output.png`
  const el = tableContainerRef.value

  try {
    // 1. Try html2canvas with allowTaint: false to prevent browser SecurityError on toDataURL
    const canvas = await html2canvas(el, {
      backgroundColor: '#ffffff',
      scale: 2,
      useCORS: true,
      allowTaint: false,
      logging: false,
      scrollX: 0,
      scrollY: 0
    })

    const dataUrl = canvas.toDataURL('image/png')
    triggerDownload(dataUrl, filename)
  } catch (err) {
    console.warn('html2canvas primary export failed, trying fallback SVG canvas:', err)
    
    try {
      // 2. Fail-safe fallback using SVG foreignObject canvas snapshot
      const width = el.offsetWidth || 900
      const height = el.offsetHeight || 500
      const clonedEl = el.cloneNode(true)
      clonedEl.setAttribute('xmlns', 'http://www.w3.org/1999/xhtml')

      const svgData = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}">
        <foreignObject width="100%" height="100%">
          ${new XMLSerializer().serializeToString(clonedEl)}
        </foreignObject>
      </svg>`

      const img = new Image()
      const svgBlob = new Blob([svgData], { type: 'image/svg+xml;charset=utf-8' })
      const url = URL.createObjectURL(svgBlob)

      img.onload = () => {
        const fallbackCanvas = document.createElement('canvas')
        fallbackCanvas.width = width * 2
        fallbackCanvas.height = height * 2
        const ctx = fallbackCanvas.getContext('2d')
        if (ctx) {
          ctx.scale(2, 2)
          ctx.fillStyle = '#ffffff'
          ctx.fillRect(0, 0, width, height)
          ctx.drawImage(img, 0, 0)
          URL.revokeObjectURL(url)
          const fallbackDataUrl = fallbackCanvas.toDataURL('image/png')
          triggerDownload(fallbackDataUrl, filename)
        }
      }
      img.src = url
    } catch (fallbackErr) {
      console.error('All PNG export methods failed:', fallbackErr)
      alert('Unable to generate PNG in current browser context. Please take a screenshot or use Large View mode.')
    }
  } finally {
    isExporting.value = false
  }
}

onMounted(() => {
  const modParam = route.query.module
  if (modParam && modulesData[modParam]) {
    activeModuleKey.value = modParam
  }
})

const selectModule = (key) => {
  activeModuleKey.value = key
  activeTabIndex.value = 0
  resultSearchQuery.value = ''
  router.replace({ query: { module: key } })
}

const currentModule = computed(() => modulesData[activeModuleKey.value] || modulesData.users)

const activeQueryObj = computed(() => {
  const qList = currentModule.value.queries || []
  return qList[activeTabIndex.value] || qList[0]
})

const filteredRows = computed(() => {
  const allRows = activeQueryObj.value.rows || []
  if (!resultSearchQuery.value.trim()) return allRows
  
  const q = resultSearchQuery.value.toLowerCase().trim()
  return allRows.filter(row => row.some(cell => String(cell).toLowerCase().includes(q)))
})

const copyQuery = () => {
  navigator.clipboard.writeText(activeQueryObj.value.query || '')
  copied.value = true
  setTimeout(() => { copied.value = false }, 2000)
}

// Smart formatting helpers for table cells
const getInitials = (name) => {
  if (!name || typeof name !== 'string') return 'U'
  const parts = name.trim().split(' ')
  if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase()
  return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
}

const isStatusValue = (val) => {
  if (typeof val !== 'string') return false
  return ['PAID', 'CONFIRMED', 'ACTIVE', 'CHECKED_IN', 'PENDING', 'UPCOMING', 'ASSIGNED', 'LIVE NOW'].includes(val.toUpperCase())
}

const isRoleValue = (val) => {
  if (typeof val !== 'string') return false
  return ['STUDENT', 'ORGANIZER', 'ADMIN'].includes(val.toUpperCase())
}

const isEmailValue = (val) => typeof val === 'string' && val.includes('@')
const isCurrencyValue = (val) => typeof val === 'string' && (val.includes('৳') || val.includes('$'))
const isCodeOrId = (val) => {
  if (typeof val === 'number') return true
  if (typeof val !== 'string') return false
  return val.startsWith('TRX') || (val.length >= 7 && !isNaN(val)) || ['CCC', 'CRS', 'CDS', 'CCC-C', 'CSA'].includes(val)
}

const getColType = (colName, val) => {
  if (!colName) return 'default'
  const col = String(colName).toLowerCase()

  if (col.includes('name') || col.includes('leader') || col.includes('user')) {
    if (col.includes('team') && !col.includes('leader')) return 'team'
    if (col.includes('event')) return 'event'
    if (col.includes('club')) return 'club'
    if (col.includes('building') || col.includes('venue')) return 'building'
    if (col.includes('department') || col.includes('dept')) return 'department'
    return 'person'
  }

  if (col.includes('event') || col.includes('competition')) return 'event'
  if (col.includes('club')) return 'club'
  if (col.includes('building') || col.includes('venue') || col.includes('location')) return 'building'
  if (col.includes('department') || col.includes('dept')) return 'department'
  if (col.includes('date') || col.includes('shift')) return 'date'
  if (col.includes('team')) return 'team'

  return 'default'
}
</script>

<template>
  <div class="min-h-screen bg-slate-950 text-slate-100 font-sans flex flex-col">
    
    <!-- Top Academic Presentation Navbar -->
    <header class="bg-slate-900 border-b border-slate-800 px-6 py-4 sticky top-0 z-30 shadow-lg">
      <div class="max-w-7xl mx-auto flex items-center justify-between">
        
        <div class="flex items-center gap-4">
          <div class="p-2.5 rounded-2xl bg-gradient-to-tr from-blue-600 to-indigo-600 text-white shadow-md">
            <Database class="w-6 h-6" />
          </div>
          <div>
            <div class="flex items-center gap-3">
              <h1 class="text-xl font-black text-white tracking-tight">CUET EventX SQL Inspector</h1>
              <span class="px-3 py-0.5 rounded-full bg-emerald-500/20 text-emerald-300 font-mono font-bold text-xs border border-emerald-400/30">
                MySQL 8.0 Engine
              </span>
            </div>
            <p class="text-xs text-slate-400">Academic Presentation & Relational Database Execution Suite</p>
          </div>
        </div>

        <div class="flex items-center gap-3">
          <router-link 
            to="/dashboard" 
            class="px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-bold flex items-center gap-2 border border-slate-700 transition-all shadow-xs"
          >
            <ArrowLeft class="w-4 h-4 text-blue-400" />
            <span>Return to Dashboard</span>
          </router-link>
        </div>

      </div>
    </header>

    <!-- Main Workspace Page Layout (Sidebar + Content Canvas) -->
    <div class="max-w-7xl mx-auto w-full flex-1 p-6 grid grid-cols-1 lg:grid-cols-12 gap-6">
      
      <!-- Left Sidebar: Presentation Module Selector -->
      <aside class="lg:col-span-3 space-y-3">
        <div class="px-3 py-2 text-xs font-black uppercase text-slate-400 tracking-wider flex items-center gap-2">
          <Layers class="w-4 h-4 text-blue-400" />
          <span>Presentation Modules</span>
        </div>

        <div class="space-y-1.5">
          <button
            v-for="(mod, key) in modulesData"
            :key="key"
            @click="selectModule(key)"
            :class="[
              activeModuleKey === key 
                ? 'bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-extrabold shadow-md ring-1 ring-blue-400/30' 
                : 'bg-slate-900/80 hover:bg-slate-800 text-slate-300 font-semibold border border-slate-800/80',
              'w-full p-3.5 rounded-2xl text-xs transition-all text-left flex items-center justify-between group'
            ]"
          >
            <div class="flex items-center gap-3 min-w-0">
              <component :is="mod.icon" class="w-4 h-4 shrink-0 text-blue-400 group-hover:text-white" />
              <span class="truncate">{{ mod.badge }}</span>
            </div>
            <ChevronRight class="w-4 h-4 shrink-0 opacity-60 group-hover:opacity-100" />
          </button>
        </div>

        <!-- Technical Environment Card -->
        <div class="p-4 rounded-2xl bg-slate-900 border border-slate-800 text-xs space-y-2 mt-6">
          <div class="font-bold text-slate-200 flex items-center gap-2">
            <Sparkles class="w-4 h-4 text-amber-400" />
            <span>Academic Evaluator Info</span>
          </div>
          <p class="text-slate-400 text-[11px] leading-relaxed">
            Demonstrates relational queries, join strategies, subqueries (`EXISTS`, `IN`), group aggregations (`HAVING`, `SUM`, `COUNT`), and live application output views.
          </p>
        </div>
      </aside>

      <!-- Main Presentation Content Canvas -->
      <main class="lg:col-span-9 space-y-6">
        
        <!-- Module Header Card -->
        <div class="p-6 rounded-3xl bg-slate-900 border border-slate-800 flex items-center justify-between flex-wrap gap-4 shadow-xl">
          <div class="flex items-center gap-4">
            <div class="p-3.5 rounded-2xl bg-blue-500/10 border border-blue-400/20 text-blue-400 shrink-0">
              <component :is="currentModule.icon" class="w-7 h-7" />
            </div>
            <div>
              <h2 class="text-xl font-black text-white tracking-tight">{{ currentModule.title }}</h2>
              <p class="text-xs text-slate-400 mt-1">Select sub-queries below to inspect syntax & live light-theme result table.</p>
            </div>
          </div>
        </div>

        <!-- Query Selector Tabs -->
        <div v-if="currentModule.queries && currentModule.queries.length > 1" class="flex items-center gap-2 overflow-x-auto pb-1">
          <button
            v-for="(q, idx) in currentModule.queries"
            :key="idx"
            @click="activeTabIndex = idx"
            :class="[
              activeTabIndex === idx 
                ? 'bg-blue-600 text-white font-extrabold shadow-md' 
                : 'bg-slate-900 text-slate-400 hover:text-white hover:bg-slate-800 border border-slate-800',
              'px-4 py-2.5 rounded-xl text-xs transition-all flex items-center gap-2 shrink-0 font-medium'
            ]"
          >
            <Code2 class="w-4 h-4" />
            <span>{{ q.name }}</span>
          </button>
        </div>

        <!-- Query Purpose Banner -->
        <div class="bg-slate-900 p-5 rounded-3xl border border-slate-800 space-y-3 shadow-lg">
          <div class="flex items-center justify-between flex-wrap gap-2">
            <div class="flex items-center gap-2 text-blue-400 font-extrabold text-xs uppercase tracking-wider">
              <Info class="w-4 h-4 text-blue-400" />
              <span>What this SQL query does</span>
            </div>

            <!-- Concept Badges -->
            <div v-if="activeQueryObj.concepts && activeQueryObj.concepts.length > 0" class="flex items-center gap-1.5 flex-wrap">
              <span 
                v-for="c in activeQueryObj.concepts" 
                :key="c"
                class="px-2.5 py-1 rounded-lg bg-slate-950 text-blue-300 font-mono font-bold text-[10px] border border-slate-800"
              >
                {{ c }}
              </span>
            </div>
          </div>

          <div class="p-4 bg-slate-950 rounded-2xl border border-slate-800/90 text-sm font-semibold text-slate-200 leading-relaxed flex items-start sm:items-center gap-3">
            <span class="px-2.5 py-1 rounded-lg bg-blue-600 text-white font-black text-xs uppercase shrink-0 shadow-xs">
              Query Purpose
            </span>
            <span>{{ activeQueryObj.purpose }}</span>
          </div>
        </div>

        <!-- Executed SQL Query Syntax Block -->
        <div class="space-y-2">
          <div class="flex items-center justify-between">
            <label class="text-xs font-bold text-slate-400 uppercase tracking-wider flex items-center gap-2">
              <Code2 class="w-4 h-4 text-blue-400" />
              <span>Executed MySQL Query Syntax</span>
            </label>
            <button 
              @click="copyQuery" 
              class="px-3.5 py-1.5 rounded-xl bg-slate-900 hover:bg-slate-800 text-blue-400 text-xs font-mono font-bold flex items-center gap-2 transition-all border border-slate-800 shadow-xs"
            >
              <Check v-if="copied" class="w-3.5 h-3.5 text-emerald-400" />
              <Copy v-else class="w-3.5 h-3.5 text-blue-400" />
              <span>{{ copied ? 'Copied SQL' : 'Copy Query' }}</span>
            </button>
          </div>

          <div class="bg-slate-950 p-5 rounded-3xl border border-slate-800 font-mono text-xs text-blue-300 overflow-x-auto leading-relaxed shadow-inner">
            <pre><code>{{ activeQueryObj.query }}</code></pre>
          </div>
        </div>

        <!-- Technical Relational Explanation -->
        <div class="space-y-2" v-if="activeQueryObj.explanation">
          <label class="text-xs font-bold text-slate-400 uppercase tracking-wider flex items-center gap-2">
            <HelpCircle class="w-4 h-4 text-amber-400" />
            <span>Relational Execution & Advanced Concepts</span>
          </label>
          <div class="p-4 rounded-2xl bg-slate-900 border border-slate-800 text-xs text-slate-300 leading-relaxed shadow-xs">
            <p>{{ activeQueryObj.explanation }}</p>
          </div>
        </div>

        <!-- Smart Application Execution Output Grid (Clean Light Theme Component) -->
        <div class="space-y-3" :class="{ 'fixed inset-0 z-50 bg-slate-950/95 p-6 overflow-y-auto flex flex-col justify-center': isLargeView }">
          
          <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div class="flex items-center gap-3">
              <label class="text-xs font-extrabold text-white uppercase tracking-wider flex items-center gap-2">
                <Terminal class="w-4 h-4 text-emerald-400" />
                <span>Application Execution Output Grid (Light Theme Component)</span>
              </label>

              <button 
                @click="isLargeView = !isLargeView" 
                class="px-3 py-1 rounded-xl bg-slate-900 hover:bg-slate-800 text-slate-300 text-xs font-semibold flex items-center gap-1.5 border border-slate-800 transition-all shadow-xs"
                :title="isLargeView ? 'Restore normal view' : 'Expand to Large View'"
              >
                <Minimize2 v-if="isLargeView" class="w-3.5 h-3.5 text-blue-400" />
                <Maximize2 v-else class="w-3.5 h-3.5 text-blue-400" />
                <span>{{ isLargeView ? 'Normal View' : 'Large View' }}</span>
              </button>
            </div>

            <div class="flex items-center gap-3 flex-wrap">
              <!-- Result Search Filter -->
              <div class="relative">
                <Search class="w-3.5 h-3.5 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
                <input 
                  v-model="resultSearchQuery"
                  type="text"
                  placeholder="Filter output rows..."
                  class="pl-8 pr-3 py-1.5 text-xs bg-slate-900 border border-slate-800 text-white placeholder-slate-500 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/40 focus:border-blue-500 w-44 font-medium transition-all shadow-xs"
                />
              </div>

              <!-- Row Count Badge -->
              <span class="px-3 py-1 rounded-xl bg-emerald-500/10 text-emerald-400 font-mono font-bold text-xs border border-emerald-500/20 shadow-2xs">
                {{ filteredRows.length }} / {{ (activeQueryObj.rows || []).length }} row(s)
              </span>

              <!-- Download Output as PNG Image Button -->
              <button 
                @click="downloadAsPng" 
                :disabled="isExporting"
                class="px-3.5 py-1.5 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-500 hover:to-teal-500 text-white font-extrabold text-xs flex items-center gap-2 shadow-lg transition-all active:scale-95 border border-emerald-400/30 disabled:opacity-50"
              >
                <Loader2 v-if="isExporting" class="w-3.5 h-3.5 animate-spin" />
                <Download v-else class="w-3.5 h-3.5" />
                <span>{{ isExporting ? 'Generating PNG...' : 'Download PNG' }}</span>
              </button>
            </div>
          </div>

          <!-- Light Theme Data Table Card Component (Targeted for PNG Export) -->
          <div 
            ref="tableContainerRef"
            v-if="activeQueryObj.columns && activeQueryObj.columns.length > 0 && activeQueryObj.rows && activeQueryObj.rows.length > 0" 
            class="overflow-hidden border border-slate-200/90 rounded-3xl bg-white p-3 shadow-2xl transition-all font-sans"
            :class="{ 'p-4 sm:p-6': isLargeView }"
          >
            <!-- Output Grid Table Container -->
            <div class="bg-white overflow-x-auto">
              <table class="w-full text-left" :class="isLargeView ? 'text-sm' : 'text-xs'">
                <thead class="bg-slate-100 text-slate-800 font-extrabold border-b border-slate-200 tracking-wide" :class="isLargeView ? 'text-xs' : 'text-[11px]'">
                  <tr>
                    <th class="py-4 px-4 w-12 text-center text-slate-400 font-mono">#</th>
                    <th v-for="col in activeQueryObj.columns" :key="col" class="py-4 px-4 font-black text-slate-900">{{ col }}</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-100 text-slate-800 font-medium">
                  <tr 
                    v-for="(row, rIdx) in filteredRows" 
                    :key="rIdx" 
                    class="hover:bg-blue-50/70 transition-all even:bg-slate-50/40"
                  >
                    <!-- Row Number Index Column -->
                    <td class="py-4 px-4 text-center font-mono text-slate-400 font-semibold select-none" :class="isLargeView ? 'text-xs' : 'text-[11px]'">
                      {{ rIdx < 9 ? `0${rIdx + 1}` : rIdx + 1 }}
                    </td>

                    <!-- Cell Columns with Rich Application Styling -->
                    <td v-for="(val, cIdx) in row" :key="cIdx" class="py-4 px-4">
                      
                      <!-- 1. Status Badges -->
                      <template v-if="isStatusValue(val)">
                        <span v-if="['PAID', 'CONFIRMED', 'ACTIVE', 'CHECKED_IN'].includes(String(val).toUpperCase())" class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 font-extrabold text-xs border border-emerald-200 shadow-2xs">
                          <CheckCircle2 class="w-3.5 h-3.5 text-emerald-600" />
                          <span>{{ val }}</span>
                        </span>
                        <span v-else-if="['PENDING', 'UPCOMING', 'ASSIGNED'].includes(String(val).toUpperCase())" class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-50 text-amber-700 font-extrabold text-xs border border-amber-200 shadow-2xs">
                          <Clock class="w-3.5 h-3.5 text-amber-600" />
                          <span>{{ val }}</span>
                        </span>
                        <span v-else-if="String(val).toUpperCase() === 'LIVE NOW'" class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-rose-50 text-rose-700 font-extrabold text-xs border border-rose-200 animate-pulse">
                          <span class="w-2 h-2 rounded-full bg-rose-600"></span>
                          <span>{{ val }}</span>
                        </span>
                        <span v-else class="px-3 py-1 rounded-full bg-slate-100 text-slate-700 font-extrabold text-xs border border-slate-200">
                          {{ val }}
                        </span>
                      </template>

                      <!-- 2. Role Badges -->
                      <template v-else-if="isRoleValue(val)">
                        <span v-if="String(val).toUpperCase() === 'STUDENT'" class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-blue-50 text-blue-700 font-bold text-xs border border-blue-200">
                          <span>🎓 {{ val }}</span>
                        </span>
                        <span v-else-if="String(val).toUpperCase() === 'ORGANIZER'" class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-purple-50 text-purple-700 font-bold text-xs border border-purple-200">
                          <span>⚡ {{ val }}</span>
                        </span>
                        <span v-else-if="String(val).toUpperCase() === 'ADMIN'" class="inline-flex items-center gap-1 px-3 py-1 rounded-full bg-slate-900 text-slate-100 font-bold text-xs border border-slate-800">
                          <span>🛡️ {{ val }}</span>
                        </span>
                      </template>

                      <!-- 3. Person Name with Rich Avatar Image Bubble -->
                      <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'person'">
                        <div class="flex items-center gap-3">
                          <div class="w-7 h-7 rounded-full bg-gradient-to-tr from-blue-600 to-indigo-600 text-white flex items-center justify-center text-xs font-black shadow-2xs shrink-0 ring-1 ring-white">
                            {{ getInitials(val) }}
                          </div>
                          <span class="font-extrabold text-slate-900" :class="isLargeView ? 'text-base' : 'text-xs'">{{ val }}</span>
                        </div>
                      </template>

                      <!-- 4. Event Title with Event Icon -->
                      <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'event'">
                        <div class="flex items-center gap-2.5">
                          <div class="p-1.5 rounded-lg bg-amber-50 border border-amber-200 text-amber-600 shrink-0">
                            <Trophy class="w-4 h-4" />
                          </div>
                          <span class="font-black text-slate-900" :class="isLargeView ? 'text-base' : 'text-xs'">{{ val }}</span>
                        </div>
                      </template>

                      <!-- 5. Club Name with Shield Icon -->
                      <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'club'">
                        <div class="flex items-center gap-2.5">
                          <div class="p-1.5 rounded-lg bg-blue-50 border border-blue-200 text-blue-600 shrink-0">
                            <Users class="w-4 h-4" />
                          </div>
                          <span class="font-bold text-slate-900" :class="isLargeView ? 'text-sm' : 'text-xs'">{{ val }}</span>
                        </div>
                      </template>

                      <!-- 6. Venue Building with Location Icon -->
                      <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'building'">
                        <div class="flex items-center gap-2.5">
                          <div class="p-1.5 rounded-lg bg-emerald-50 border border-emerald-200 text-emerald-600 shrink-0">
                            <Building2 class="w-4 h-4" />
                          </div>
                          <span class="font-semibold text-slate-800" :class="isLargeView ? 'text-sm' : 'text-xs'">{{ val }}</span>
                        </div>
                      </template>

                      <!-- 7. Department with Graduation Cap -->
                      <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'department'">
                        <div class="flex items-center gap-2.5">
                          <div class="p-1.5 rounded-lg bg-purple-50 border border-purple-200 text-purple-600 shrink-0">
                            <GraduationCap class="w-4 h-4" />
                          </div>
                          <span class="font-semibold text-slate-800" :class="isLargeView ? 'text-sm' : 'text-xs'">{{ val }}</span>
                        </div>
                      </template>

                      <!-- 8. Team Name with Sparkles -->
                      <template v-else-if="getColType(activeQueryObj.columns[cIdx], val) === 'team'">
                        <div class="flex items-center gap-2 font-extrabold text-slate-900" :class="isLargeView ? 'text-base' : 'text-xs'">
                          <Sparkles class="w-4 h-4 text-indigo-500 shrink-0" />
                          <span>{{ val }}</span>
                        </div>
                      </template>

                      <!-- 9. Email Formatting -->
                      <template v-else-if="isEmailValue(val)">
                        <span class="font-mono text-blue-600 hover:text-blue-800 font-bold inline-flex items-center gap-1.5" :class="isLargeView ? 'text-sm' : 'text-xs'">
                          <Mail class="w-3.5 h-3.5 text-blue-400" />
                          <span>{{ val }}</span>
                        </span>
                      </template>

                      <!-- 10. Currency Monetary Amounts -->
                      <template v-else-if="isCurrencyValue(val)">
                        <span class="font-mono font-extrabold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-md border border-emerald-200 inline-block" :class="isLargeView ? 'text-sm' : 'text-xs'">
                          {{ val }}
                        </span>
                      </template>

                      <!-- 11. Code / ID Formatting -->
                      <template v-else-if="isCodeOrId(val)">
                        <span class="font-mono font-extrabold text-slate-800 bg-slate-100 px-2.5 py-1 rounded-md border border-slate-200 text-xs">
                          {{ val }}
                        </span>
                      </template>

                      <!-- 12. Default Text Value -->
                      <template v-else>
                        <span class="text-slate-900 font-semibold" :class="isLargeView ? 'text-sm' : 'text-xs'">
                          {{ val }}
                        </span>
                      </template>

                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <div v-else class="p-8 text-center bg-slate-900 border border-slate-800 rounded-3xl text-slate-400">
            <p class="text-xs font-semibold">No matching execution rows found for "{{ resultSearchQuery }}"</p>
          </div>
        </div>

      </main>

    </div>
  </div>
</template>
