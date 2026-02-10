# Incident Reporting System
# ให้ AI ทำคู่มือการใช้งานออกมาโดยแสดง Database และตัวอย่างเบื้องต้น
## Overview

The Incident Reporting System allows drivers and passengers to report safety concerns, behavioral issues, and other incidents. Admins can review, update, and close reported incidents. This helps maintain a safe and trustworthy community for all users.

## Features

### For Users (Drivers & Passengers)
- **Report Incidents**: Report behavioral issues, safety concerns, vehicle problems, or harassment
- **Track Status**: Monitor the status of reported incidents in real-time
- **View Admin Notes**: See feedback and actions taken by the admin team

### For Admins
- **Review Incidents**: View all reported incidents with comprehensive details
- **Filter & Search**: Filter incidents by status and type
- **Update Status**: Mark incidents as Pending, Under Review, Resolved, or Closed
- **Add Notes**: Document actions taken on each incident
- **User Incident History**: Check incidents reported against specific users

## Database Schema

### Incident Model

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
  status            IncidentStatus  @default(PENDING)
  adminNotes        String?
  resolvedAt        DateTime?
  closedAt          DateTime?
  createdAt         DateTime        @default(now())
  updatedAt         DateTime        @updatedAt
}
```

### Enums

**IncidentType:**
- `DRIVER_BEHAVIOR` - Issues with driver conduct
- `PASSENGER_BEHAVIOR` - Issues with passenger conduct  
- `SAFETY_ISSUE` - Safety concerns (e.g., unsafe driving, accidents)
- `VEHICLE_ISSUE` - Problems with the vehicle condition
- `HARASSMENT` - Harassment or inappropriate behavior
- `OTHER` - Other incident types

**IncidentStatus:**
- `PENDING` - Initial status when reported
- `REVIEWED` - Admin has reviewed the incident
- `RESOLVED` - Issue has been addressed
- `CLOSED` - Case is closed

## API Endpoints

### User Endpoints

#### Report an Incident
```
POST /api/incidents
Authentication: Required
```

**Request Body:**
```json
{
  "type": "DRIVER_BEHAVIOR",
  "title": "Unsafe driving behavior",
  "description": "Driver was speeding and made sudden turns without signaling",
  "reportedUserId": "user123",
  "attachmentUrl": "https://example.com/photo.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Incident reported successfully",
  "data": {
    "id": "incident_id",
    "type": "DRIVER_BEHAVIOR",
    "title": "Unsafe driving behavior",
    "status": "PENDING",
    "createdAt": "2024-02-10T10:00:00Z"
  }
}
```

#### Get My Reported Incidents
```
GET /api/incidents/me?page=1&limit=10
Authentication: Required
```

**Response:**
```json
{
  "success": true,
  "message": "My incidents retrieved successfully",
  "data": [...],
  "pagination": {
    "total": 5,
    "page": 1,
    "limit": 10,
    "totalPages": 1
  }
}
```

#### Get Incident Details
```
GET /api/incidents/{id}
Authentication: Required
```

### Admin Endpoints

#### Get All Incidents
```
GET /api/incidents/admin/all?status=PENDING&type=DRIVER_BEHAVIOR&page=1&limit=10
Authentication: Required (Admin only)
```

**Query Parameters:**
- `status` - Filter by status (optional)
- `type` - Filter by incident type (optional)
- `page` - Page number (default: 1)
- `limit` - Items per page (default: 10)

#### Update Incident Status
```
PATCH /api/incidents/admin/{id}/status
Authentication: Required (Admin only)
```

**Request Body:**
```json
{
  "status": "RESOLVED",
  "adminNotes": "Driver has been warned about unsafe driving"
}
```

#### Delete Incident
```
DELETE /api/incidents/admin/{id}
Authentication: Required (Admin only)
```

#### Get Incidents Against a User
```
GET /api/incidents/admin/user/{userId}?page=1&limit=10
Authentication: Required (Admin only)
```

## Frontend Pages

### User Pages

#### Report Incident (`/report-incident`)
- Form to report a new incident
- Select incident type, title, description
- Optional: Report against specific user, attach evidence
- Confirmation message on submission
- Redirect to profile after successful submission

**File:** `frontend/pages/report-incident.vue`

#### My Incidents (`/my-incidents`)
- View all incidents reported by the current user
- See status, description, and admin notes
- Timeline showing report date and resolution dates
- Pagination support
- Link to report new incidents

**File:** `frontend/pages/my-incidents.vue`

### Admin Pages

#### Incident Management (`/admin/incidents`)
- Table view of all incidents
- Filter by status and type
- View incident details in a modal
- Update status with admin notes
- Pagination support

**File:** `frontend/pages/admin/incidents/index.vue`

## Validation Rules

### Create Incident Validation
```javascript
{
  type: enum ['DRIVER_BEHAVIOR', 'SAFETY_ISSUE', 'VEHICLE_ISSUE', 'PASSENGER_BEHAVIOR', 'HARASSMENT', 'OTHER'],
  title: string (5-100 characters),
  description: string (10-2000 characters),
  reportedUserId: optional string,
  attachmentUrl: optional URL
}
```

### Update Status Validation
```javascript
{
  status: enum ['PENDING', 'REVIEWED', 'RESOLVED', 'CLOSED'],
  adminNotes: optional string (max 1000 characters)
}
```

## Backend Files

- **Model:** `backend/prisma/schema.prisma`
- **Service:** `backend/src/services/incident.service.js`
- **Controller:** `backend/src/controllers/incident.controller.js`
- **Routes:** `backend/src/routes/incident.routes.js`
- **Validation:** `backend/src/validations/incident.validation.js`
- **Docs:** `backend/src/docs/incident.doc.js`

## Frontend Files

- **Report Incident:** `frontend/pages/report-incident.vue`
- **My Incidents:** `frontend/pages/my-incidents.vue`
- **Admin Management:** `frontend/pages/admin/incidents/index.vue`

## Usage Examples

### For Drivers/Passengers

1. Navigate to **Report Incident** page
2. Fill in incident details:
   - Select incident type
   - Enter title (brief, max 100 chars)
   - Describe what happened (10-2000 chars)
   - (Optional) Specify user ID if reporting against someone
   - (Optional) Add evidence link
3. Submit the report
4. Check status anytime on **My Incidents** page

### For Admins

1. Go to **Admin Dashboard** → **Incidents**
2. View all reported incidents
3. Filter by status or type
4. Click "View Details" on any incident
5. Update the status and add notes
6. Click "Update Status" to save changes
7. Users will see the updated status and notes

## Integration Notes

- Incidents are linked to users through `reporterId` and `reportedUserId`
- Incidents appear in admin dashboard automatically when created
- Status changes can trigger notifications to the reporter (optional enhancement)
- Admin notes are visible to the reporting user
- Pagination supports efficient handling of large incident volumes

## Future Enhancements

1. **Notifications**: Notify users when their incident status changes
2. **Severity Levels**: Add incident severity classification
3. **Auto-Actions**: Automatically suspend users based on incident count/type
4. **Analytics**: Dashboard showing incident trends and statistics
5. **Appeal System**: Allow users to appeal incident decisions
6. **Media Upload**: Direct image/video upload instead of URL only
7. **Incident Categories**: Sub-categories for more specific classification
8. **Resolution Actions**: Track specific actions taken (warning, suspension, etc.)

## Migration Steps

When deploying this feature:

1. Update Prisma schema (already done)
2. Run migration:
   ```bash
   cd backend
   npx prisma migrate dev --name add_incident_model
   ```
3. Restart backend server
4. Frontend pages are automatically available
5. Users can start reporting incidents immediately

## Support

For issues or questions:
- Check backend logs at `backend/` 
- Check frontend logs in browser console
- Review API documentation at `/documentation` (Swagger UI)
