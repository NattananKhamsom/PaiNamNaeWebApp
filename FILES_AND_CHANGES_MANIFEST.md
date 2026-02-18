# Incident Reporting System - Files & Changes Reference Ai make it and Nattanan Read to confirm

## 📁 Complete File Manifest

### Backend Files (6 Created)

#### 1. Backend Validation
**File:** `backend/src/validations/incident.validation.js`
- **Purpose:** Input validation schemas using Zod
- **Contains:** 3 validation schemas for create, update, and list operations
- **Lines:** ~50
- **Status:** ✅ Created

#### 2. Backend Service Layer
**File:** `backend/src/services/incident.service.js`
- **Purpose:** Business logic for incident operations
- **Contains:** 7 async functions for CRUD operations
- **Lines:** ~280
- **Status:** ✅ Created
- **Functions:**
  - `createIncident(reporterId, data)`
  - `getIncidentById(id)`
  - `getMyIncidents(userId, page, limit)`
  - `getAllIncidents(filters, page, limit)`
  - `updateIncidentStatus(id, status, adminNotes)`
  - `deleteIncident(id)`
  - `getIncidentsAgainstUser(userId, page, limit)`

#### 3. Backend Controller
**File:** `backend/src/controllers/incident.controller.js`
- **Purpose:** HTTP request handlers
- **Contains:** 7 controller functions
- **Lines:** ~220
- **Status:** ✅ Created
- **Endpoints Handled:**
  - POST /incidents
  - GET /incidents/me
  - GET /incidents/{id}
  - GET /incidents/admin/all
  - PATCH /incidents/admin/{id}/status
  - DELETE /incidents/admin/{id}
  - GET /incidents/admin/user/{userId}

#### 4. Backend Routes
**File:** `backend/src/routes/incident.routes.js`
- **Purpose:** Express route definitions
- **Contains:** All incident routes with middleware
- **Lines:** ~50
- **Status:** ✅ Created
- **Features:** Auth middleware, admin role checks

#### 5. Backend Documentation
**File:** `backend/src/docs/incident.doc.js`
- **Purpose:** Swagger/OpenAPI documentation
- **Contains:** Complete API documentation
- **Lines:** ~280
- **Status:** ✅ Created
- **Coverage:** All 7 endpoints with schemas

#### 6. Routes Registration (Modified)
**File:** `backend/src/routes/index.js`
- **Purpose:** Main routes file
- **Changes:** Added incident route import and registration
- **Lines Modified:** +2
- **Status:** ✅ Updated
- **Added:** 
  ```javascript
  const incidentRoutes = require('./incident.routes')
  router.use('/incidents', incidentRoutes);
  ```

---

### Database Schema (Modified)

**File:** `backend/prisma/schema.prisma`
- **Purpose:** Database schema definition
- **Status:** ✅ Updated
- **Changes Made:**
  1. Added `IncidentType` enum with 6 values
  2. Added `IncidentStatus` enum with 4 values
  3. Updated `NotificationType` enum (added INCIDENT)
  4. Added `Incident` model with 10 fields
  5. Updated `User` model with incident relationships

**Enums Added:**
```prisma
enum IncidentType {
  DRIVER_BEHAVIOR
  PASSENGER_BEHAVIOR
  SAFETY_ISSUE
  VEHICLE_ISSUE
  HARASSMENT
  OTHER
}

enum IncidentStatus {
  PENDING
  REVIEWED
  RESOLVED
  CLOSED
}
```

**Model Added:**
```prisma
model Incident {
  id                String          @id @default(cuid())
  reporterId        String
  reporter          User            @relation("ReportedIncidents", ...)
  reportedUserId    String?
  reportedUser      User?           @relation("IncidentsReportedAgainst", ...)
  type              IncidentType
  title             String
  description       String
  attachmentUrl     String?
  status            IncidentStatus
  adminNotes        String?
  resolvedAt        DateTime?
  closedAt          DateTime?
  createdAt         DateTime
  updatedAt         DateTime
}
```

---

### Frontend Files (3 Created)

#### 1. Report Incident Page
**File:** `frontend/pages/report-incident.vue`
- **Purpose:** Form for users to report incidents
- **Template Lines:** ~120
- **Script Lines:** ~120
- **Status:** ✅ Created
- **Features:**
  - 6 incident type selector
  - Title input (5-100 chars) with counter
  - Description textarea (10-2000 chars) with counter
  - Optional reported user ID field
  - Optional attachment URL field
  - Real-time validation
  - Toast notifications
  - Success/error messages
  - Auto-redirect after submission

#### 2. My Incidents Page
**File:** `frontend/pages/my-incidents.vue`
- **Purpose:** Display user's reported incidents
- **Template Lines:** ~140
- **Script Lines:** ~150
- **Status:** ✅ Created
- **Features:**
  - List of user's incidents
  - Status badges with color coding
  - Incident details display
  - Admin notes visibility
  - Timeline with dates
  - Pagination support
  - Report new incident link
  - Empty/loading/error states

#### 3. Admin Incidents Dashboard
**File:** `frontend/pages/admin/incidents/index.vue`
- **Purpose:** Admin incident management
- **Template Lines:** ~200
- **Script Lines:** ~180
- **Status:** ✅ Created
- **Features:**
  - Incidents table view
  - Filter by status and type
  - Modal for incident details
  - Status update form
  - Admin notes input
  - Pagination controls
  - Authorization checks

---

### Documentation Files (5 Created)

---

## 🔄 Relationships Between Files

### Backend Flow
```
incident.routes.js
    ↓ (routes to)
incident.controller.js
    ↓ (calls)
incident.service.js
    ↓ (uses)
Prisma + Database
    
Routes also use:
- incident.validation.js (Zod schemas)
- auth.js middleware (JWT verification)
- errorHandler.js middleware (error handling)
```

### Frontend Flow
```
report-incident.vue
    → $api.post('/incidents')
    
my-incidents.vue
    → $api.get('/incidents/me')
    
admin/incidents/index.vue
    → $api.get('/incidents/admin/all')
    → $api.patch('/incidents/admin/{id}/status')
    
All use:
- useAuth() composable
- useToast() composable
- Tailwind CSS for styling
```

---

## 📝 Change Summary by Component

### Backend Changes
- ✅ Added incident validation layer
- ✅ Added incident service layer with 7 functions
- ✅ Added incident controller with 7 handlers
- ✅ Added incident routes with 7 endpoints
- ✅ Added incident Swagger documentation
- ✅ Updated routes/index.js to register incident routes
- ✅ Updated Prisma schema (added Incident model + enums)

### Frontend Changes
- ✅ Created report-incident.vue page
- ✅ Created my-incidents.vue page
- ✅ Created admin/incidents/index.vue page

### Documentation Changes
- ✅ Created 6 comprehensive documentation files
- ✅ Covers setup, usage, architecture, testing, and deployment


## 🚀 Deployment Checklist


### Main Entry Points
- Backend: `backend/src/routes/incident.routes.js`
- Frontend: `frontend/pages/report-incident.vue`
- Database: `backend/prisma/schema.prisma`


### Key Endpoints
- Report: `POST /api/incidents`
- Track: `GET /api/incidents/me`
- Admin: `GET /api/incidents/admin/all`

### Pages
- Report: `/report-incident`
- Track: `/my-incidents`
- Admin: `/admin/incidents`




---

**All implementation files are ready for deployment! 🎉**

For detailed information about any file, refer to the documentation files.
