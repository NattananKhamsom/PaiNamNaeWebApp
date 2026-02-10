# Incident Reporting System - Architecture & Workflow
# AI สรุปArchitecture ขึ้นมาเพื่อสะดวกต่อการดู
## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONTEND (Vue 3 + Nuxt)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐  ┌──────────────────────┐            │
│  │ Report Incident Page │  │ Admin Incidents      │            │
│  │ /report-incident     │  │ /admin/incidents     │            │
│  └────────────┬─────────┘  └─────────┬────────────┘            │
│               │                      │                         │
│  ┌──────────────────────┐            │                         │
│  │ My Incidents Page    │            │                         │
│  │ /my-incidents        │            │                         │
│  └────────────┬─────────┘            │                         │
│               └──────────┬───────────┘                         │
│                          │ API Calls                          │
├──────────────────────────┼───────────────────────────────────┤
│                          ▼                                    │
│              Nuxt API Client Plugin                           │
└──────────────────────────┬───────────────────────────────────┘
                          │ HTTP/REST
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    BACKEND (Express.js + Node)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Routes (/incidents)                                   │   │
│  │ - POST /incidents                                     │   │
│  │ - GET /incidents/me                                   │   │
│  │ - GET /incidents/{id}                                 │   │
│  │ - GET /incidents/admin/all                            │   │
│  │ - PATCH /incidents/admin/{id}/status                  │   │
│  │ - DELETE /incidents/admin/{id}                        │   │
│  │ - GET /incidents/admin/user/{userId}                  │   │
│  └────────┬─────────────────────────────────────────────┘   │
│           │                                                   │
│  ┌────────▼─────────────────────────────────────────────┐   │
│  │ Middleware (Auth, Validation)                        │   │
│  └────────┬─────────────────────────────────────────────┘   │
│           │                                                   │
│  ┌────────▼─────────────────────────────────────────────┐   │
│  │ Controllers (incident.controller.js)                │   │
│  │ - Handles HTTP requests                             │   │
│  │ - Validates input                                   │   │
│  │ - Coordinates service calls                         │   │
│  └────────┬─────────────────────────────────────────────┘   │
│           │                                                   │
│  ┌────────▼─────────────────────────────────────────────┐   │
│  │ Services (incident.service.js)                      │   │
│  │ - Business logic                                    │   │
│  │ - Database operations                               │   │
│  │ - Data processing                                   │   │
│  └────────┬─────────────────────────────────────────────┘   │
│           │                                                   │
├───────────┼───────────────────────────────────────────────────┤
│           │ Prisma ORM                                        │
│           ▼                                                    │
│  ┌──────────────────────────────────────────────────┐        │
│  │ Database (PostgreSQL)                            │        │
│  │                                                  │        │
│  │ Tables:                                          │        │
│  │ - users                                          │        │
│  │ - incidents (NEW)                                │        │
│  │ - Other tables...                                │        │
│  └──────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

### Reporting an Incident
```
User (Driver/Passenger)
       │
       ├─ Fill Report Form
       │  ├─ Incident Type
       │  ├─ Title & Description
       │  ├─ Report Against User (optional)
       │  └─ Evidence URL (optional)
       │
       ├─ Submit
       │  │
       │  └─► POST /api/incidents
       │       │
       │       ├─► Validation
       │       │   └─ Zod Schema Check
       │       │
       │       ├─► Controller
       │       │   └─ Authenticate User
       │       │
       │       ├─► Service
       │       │   ├─ Create Incident Record
       │       │   ├─ Set Status = PENDING
       │       │   └─ Return Created Incident
       │       │
       │       └─► Database
       │           └─ INSERT into incidents
       │
       └─► Success Message
           └─ Redirect to /my-incidents
```

### Admin Reviewing Incident
```
Admin
  │
  ├─ Navigate to /admin/incidents
  │  │
  │  └─► GET /api/incidents/admin/all
  │       │
  │       ├─► Auth Check (ADMIN only)
  │       ├─► Apply Filters
  │       ├─► Query Database
  │       └─► Return Incidents List
  │
  ├─ Click "View Details"
  │  └─► Display Modal with Full Details
  │
  ├─ Update Status & Add Notes
  │  │
  │  └─► PATCH /api/incidents/admin/{id}/status
  │       │
  │       ├─► Validate New Status
  │       ├─► Update Record in Database
  │       ├─ Set adminNotes
  │       ├─ If RESOLVED: Set resolvedAt = now()
  │       ├─ If CLOSED: Set closedAt = now()
  │       └─► Return Updated Incident
  │
  └─► Update Complete
      └─ Incident now visible to user with new status
```

### User Viewing Incident Status
```
User (who reported incident)
  │
  ├─ Navigate to /my-incidents
  │  │
  │  └─► GET /api/incidents/me
  │       │
  │       ├─► Auth Check
  │       ├─► Query incidents where reporterId = current user
  │       ├─ Fetch reporter and reported user details
  │       └─► Return Paginated List
  │
  ├─ See All Incidents
  │  ├─ Status Badge (PENDING → REVIEWED → RESOLVED → CLOSED)
  │  ├─ Description & Details
  │  ├─ Admin Notes (if any)
  │  └─ Timeline Dates
  │
  └─ Track Progress
      └─ Real-time updates visible
```

## Entity Relationship Diagram (ERD)

```
┌──────────────────────┐              ┌──────────────────────────┐
│       User           │              │     Incident (NEW)       │
├──────────────────────┤              ├──────────────────────────┤
│ id (PK)              │◄─────────────│ id (PK)                  │
│ username             │   FK         │ reporterId (FK)          │
│ email                │ (Reporter)   │ reportedUserId (FK)      │
│ password             │              │ type                     │
│ firstName            │              │ title                    │
│ lastName             │              │ description              │
│ role                 │              │ attachmentUrl            │
│ isVerified           │              │ status                   │
│ isActive             │              │ adminNotes               │
│ ... other fields ... │              │ resolvedAt               │
└──────────────────────┘              │ closedAt                 │
         △                            │ createdAt                │
         │ FK                         │ updatedAt                │
         │(Reported Against)          └──────────────────────────┘
         │
         └────────┐
                  │
              (optional)
```

## Status State Machine

```
                    ┌─────────────────────────────────────┐
                    │           PENDING                   │
                    │  (Initial state when reported)      │
                    └──────────────┬──────────────────────┘
                                   │
                                   │ Admin reviews
                                   ▼
                    ┌──────────────────────────────────────┐
                    │          REVIEWED                    │
                    │  (Admin has reviewed the incident)   │
                    └──────────────┬──────────────────────┘
                                   │
                  ┌────────────────┴────────────────┐
                  │                                 │
            Needs action              Ready to close
                  │                        │
                  ▼                        ▼
        ┌──────────────────┐    ┌──────────────────┐
        │     RESOLVED     │    │      CLOSED      │
        │ (Issue addressed)│    │ (Case archived)  │
        └──────────────────┘    └──────────────────┘
                  │                        ▲
                  └────────────────────────┘
                  │ Can reopen if needed
```

## User Permission Matrix

```
┌─────────────────────────────┬──────────────┬──────────────┬─────────┐
│ Action                      │ Passenger    │ Driver       │ Admin   │
├─────────────────────────────┼──────────────┼──────────────┼─────────┤
│ Report Incident             │      ✓       │      ✓       │    ✓    │
│ View Own Incidents          │      ✓       │      ✓       │    ✓    │
│ View All Incidents          │      ✗       │      ✗       │    ✓    │
│ Update Incident Status      │      ✗       │      ✗       │    ✓    │
│ Add Admin Notes             │      ✗       │      ✗       │    ✓    │
│ Delete Incident             │      ✗       │      ✗       │    ✓    │
│ View Incidents vs User      │      ✗       │      ✗       │    ✓    │
└─────────────────────────────┴──────────────┴──────────────┴─────────┘
```

## API Endpoint Structure

```
/api/incidents
├── POST /               (Create incident) - User
├── GET /me              (Get my incidents) - User
├── GET /{id}            (Get incident details) - User
└── /admin
    ├── GET /all              (List all incidents) - Admin
    ├── PATCH /{id}/status    (Update status) - Admin
    ├── DELETE /{id}          (Delete incident) - Admin
    └── GET /user/{userId}    (Get incidents vs user) - Admin
```

## Data Model

### Incident Schema

```javascript
{
  id: String,                    // Unique identifier
  reporterId: String,            // Who reported it
  reporter: User,                // Populated user object
  reportedUserId: String?,       // Who it's about (optional)
  reportedUser: User?,           // Populated user object (optional)
  type: IncidentType,            // DRIVER_BEHAVIOR | SAFETY_ISSUE | etc
  title: String,                 // Brief title (5-100 chars)
  description: String,           // Detailed description (10-2000 chars)
  attachmentUrl: String?,        // Evidence URL (optional)
  status: IncidentStatus,        // PENDING | REVIEWED | RESOLVED | CLOSED
  adminNotes: String?,           // Notes from admin (optional)
  resolvedAt: DateTime?,         // When resolved (nullable)
  closedAt: DateTime?,           // When closed (nullable)
  createdAt: DateTime,           // Reported timestamp
  updatedAt: DateTime            // Last updated timestamp
}
```

## Component Communication Flow

```
report-incident.vue
    │
    ├─ useAuth() → Get current user
    ├─ useToast() → Show notifications
    └─ $api.post('/incidents') → Create incident
            │
            └─► Backend (Controller → Service → DB)
                    │
                    └─► Return success message
                        │
                        └─► my-incidents.vue (auto-loaded on next visit)

my-incidents.vue
    │
    ├─ useAuth() → Get current user
    ├─ useToast() → Show notifications
    ├─ onMounted() → Fetch incidents
    └─ $api.get('/incidents/me') → Load user's incidents
            │
            └─► Backend (Controller → Service → DB)
                    │
                    └─► Return paginated incidents list

admin/incidents/index.vue
    │
    ├─ Auth Check → Redirect if not admin
    ├─ useAuth() → Get current user
    ├─ useToast() → Show notifications
    ├─ $api.get('/incidents/admin/all') → Fetch all incidents
    │   │
    │   └─► Backend (Controller → Service → DB)
    │
    ├─ Apply Filters → Update incidents list
    ├─ Select Incident → Show modal with details
    └─ Update Status → $api.patch('/incidents/admin/{id}/status')
            │
            └─► Backend (Controller → Service → DB)
                    │
                    └─► Update and return incident
```

---

**This architecture ensures:**
- ✅ Clean separation of concerns
- ✅ Scalable database operations
- ✅ Secure role-based access
- ✅ Proper state management
- ✅ Real-time user feedback
- ✅ Comprehensive audit trail
