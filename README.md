# 🚗 VMS Frontend — Vehicle Management System

> **Version:** 1.0.0 (Foundation)  
> **Platform:** Flutter Web (Material 3, Desktop-first)  
> **State:** In-memory mock data — ready for Spring Boot / REST API backend integration  

A clean, production-grade **Fleet Management Admin Portal** built with Flutter Web.  
Currently operates with in-memory mock data. This document is the **single source of truth** for backend developers to implement the REST API layer.

---

## Table of Contents

- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Architecture Overview](#architecture-overview)
- [Data Models & JSON Schemas](#data-models--json-schemas)
  - [Vehicle Model](#1-vehicle-model)
  - [User Model](#2-user-model)
- [Enumerations](#enumerations)
  - [VehicleStatus](#vehiclestatus)
  - [VehicleType](#vehicletype)
- [API Endpoints Contract](#api-endpoints-contract)
  - [Authentication](#1-authentication)
  - [Vehicles CRUD](#2-vehicles-crud)
  - [Dashboard KPIs](#3-dashboard-kpis)
- [Mock Data (Full Seed Dataset)](#mock-data-full-seed-dataset)
- [Frontend Routes](#frontend-routes)
- [Local Storage (Hive)](#local-storage-hive)
- [UI / Design System](#ui--design-system)
- [Planned Modules (Future)](#planned-modules-future)
- [Backend Integration Checklist](#backend-integration-checklist)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Web target, Material 3) |
| Language | Dart ^3.13.7 |
| State Management | `ChangeNotifier` + `InheritedNotifier` (will migrate to Riverpod with API) |
| HTTP Client | `dio` ^5.11.1 (installed, not wired yet) |
| API Code Gen | `retrofit` ^4.10.0 + `retrofit_generator` ^10.3.3 |
| JSON Serialization | `json_annotation` ^4.12.0 + `json_serializable` ^6.15.2 |
| Build Runner | `build_runner` ^2.17.1 |
| UI Components | `shadcn_ui` ^0.59.0, `material_ui` |
| Local Storage | `hive` ^2.2.3 + `hive_flutter` ^1.1.0 |
| Pagination | `infinite_scroll_pagination` ^5.1.1 |
| Skeleton Loading | `skeletonizer` ^3.0.0 |

---

## Project Structure

```
lib/
├── main.dart                                  # App entry point & VehicleRepositoryScope
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                    # Semantic color palette (brand, status, sidebar)
│   │   └── app_constants.dart                 # Breakpoints, layout dims, spacing, radii
│   ├── routes/
│   │   └── app_routes.dart                    # Named route definitions & route generator
│   ├── storage/
│   │   └── hive_service.dart                  # Hive local storage for auth tokens
│   ├── theme/
│   │   └── app_theme.dart                     # Material 3 ThemeData (cards, inputs, buttons, tables)
│   └── utils/
│       └── responsive.dart                    # Responsive breakpoint helper widget
├── data/
│   ├── mock_data.dart                         # 🗄️ Static seed data (8 vehicles)
│   └── vehicle_repository.dart                # In-memory CRUD repository (ChangeNotifier)
├── models/
│   ├── user_model.dart                        # User/Admin data class
│   └── vehicle_model.dart                     # Vehicle data class + enums
├── screens/
│   ├── auth/
│   │   └── login_screen.dart                  # Admin login form
│   ├── shell/
│   │   ├── app_shell_screen.dart              # App layout shell (sidebar + top bar + content)
│   │   └── widgets/
│   │       ├── side_navigation.dart           # Sidebar drawer with nav items
│   │       └── top_app_bar.dart               # Top header with breadcrumbs & user menu
│   └── vehicles/
│       ├── vehicle_form_screen.dart           # Create / Edit vehicle form
│       └── vehicle_list_screen.dart           # Fleet inventory list + KPIs + filters
└── widgets/
    ├── confirmation_dialog.dart               # Reusable confirm/delete dialog
    ├── max_width_container.dart               # Max-width content wrapper
    ├── vehicle_stat_card.dart                 # KPI metric card widget
    └── vehicle_status_badge.dart              # Status pill badge (Active/Maintenance/OOS)
```

---

## Getting Started

```bash
# 1. Clone the repository
git clone <repo-url>
cd vms_frontend

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome (web target)
flutter run -d chrome

# 4. Build for production
flutter build web
```

**Demo Credentials (mock login — no backend validation):**
| Field | Value |
|---|---|
| Email | `admin@vms.com` |
| Password | `admin123` |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                   Flutter Web UI                 │
│  ┌────────────┐  ┌──────────┐  ┌──────────────┐ │
│  │ Login      │  │ Vehicle  │  │ Vehicle      │ │
│  │ Screen     │  │ List     │  │ Form (CRUD)  │ │
│  └─────┬──────┘  └────┬─────┘  └──────┬───────┘ │
│        │              │               │          │
│  ┌─────▼──────────────▼───────────────▼───────┐  │
│  │         VehicleRepository (ChangeNotifier)  │  │
│  │  ┌──────────────────────────────────────┐   │  │
│  │  │  Currently: In-Memory (MockData)     │   │  │
│  │  │  Future:    Dio + Retrofit → REST API│   │  │
│  │  └──────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────┘  │
│                                                   │
│  ┌─────────────────────────────────────────────┐  │
│  │  HiveService (Local Storage)                │  │
│  │  • auth_token     • auth_user               │  │
│  └─────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
                        │
                        ▼ (Future REST calls)
         ┌──────────────────────────────┐
         │   Spring Boot Backend API    │
         │   Base URL: /api/v1          │
         └──────────────────────────────┘
```

---

## Data Models & JSON Schemas

### 1. Vehicle Model

**Dart Class:** [`lib/models/vehicle_model.dart`](file:///d:/vms/vms_frontend/lib/models/vehicle_model.dart)

| Field | Type | Required | Nullable | Description |
|---|---|---|---|---|
| `id` | `String` | ✅ | ❌ | Unique identifier (e.g. `"vh-001"`) |
| `plateNumber` | `String` | ✅ | ❌ | Government license plate (e.g. `"ABC-1029"`) |
| `vin` | `String` | ✅ | ❌ | 17-char Vehicle Identification Number |
| `make` | `String` | ✅ | ❌ | Manufacturer (e.g. `"Toyota"`) |
| `model` | `String` | ✅ | ❌ | Model name (e.g. `"Camry"`) |
| `year` | `int` | ✅ | ❌ | Manufacturing year (1980–current+2) |
| `type` | `String` (enum) | ✅ | ❌ | Body type: `sedan`, `suv`, `truck`, `van`, `bus`, `electric` |
| `status` | `String` (enum) | ✅ | ❌ | Operational status: `active`, `in_maintenance`, `out_of_service` |
| `mileage` | `int` | ✅ | ❌ | Odometer reading in kilometers |
| `fuelType` | `String` | ✅ | ❌ | Powertrain: `Gasoline`, `Diesel`, `Electric`, `Hybrid`, `Plug-in Hybrid` |
| `assignedDriver` | `String` | ❌ | ✅ | Current custodian driver name |
| `lastServiceDate` | `String` (ISO 8601) | ❌ | ✅ | Last maintenance date `"YYYY-MM-DD"` |
| `notes` | `String` | ❌ | ✅ | Free-text service/equipment notes |

#### Expected JSON Structure

```json
{
  "id": "vh-001",
  "plateNumber": "ABC-1029",
  "vin": "4T1B11HK5PU102941",
  "make": "Toyota",
  "model": "Camry",
  "year": 2023,
  "type": "sedan",
  "status": "active",
  "mileage": 18200,
  "fuelType": "Gasoline",
  "assignedDriver": "Marcus Vance",
  "lastServiceDate": "2026-08-15",
  "notes": "Standard executive fleet vehicle. Pristine condition."
}
```

---

### 2. User Model

**Dart Class:** [`lib/models/user_model.dart`](file:///d:/vms/vms_frontend/lib/models/user_model.dart)

| Field | Type | Required | Nullable | Description |
|---|---|---|---|---|
| `id` | `String` | ✅ | ❌ | Unique user identifier |
| `name` | `String` | ✅ | ❌ | Full display name |
| `email` | `String` | ✅ | ❌ | Login email address |
| `role` | `String` | ✅ | ❌ | System role (e.g. `"Fleet Manager"`, `"Admin"`) |
| `avatarUrl` | `String` | ❌ | ✅ | Profile picture URL |

#### Expected JSON Structure

```json
{
  "id": "usr_admin_001",
  "name": "Sarah Connor",
  "email": "admin@vms.com",
  "role": "Fleet Manager",
  "avatarUrl": null
}
```

---

## Enumerations

### VehicleStatus

| Frontend Enum Value | Backend String Key | Display Label | Description |
|---|---|---|---|
| `VehicleStatus.active` | `active` | Active | Vehicle is operational and deployable |
| `VehicleStatus.inMaintenance` | `in_maintenance` | In Maintenance | Currently being serviced or inspected |
| `VehicleStatus.outOfService` | `out_of_service` | Out of Service | Decommissioned, awaiting parts, or retired |

### VehicleType

| Frontend Enum Value | Backend String Key | Display Label |
|---|---|---|
| `VehicleType.sedan` | `sedan` | Sedan |
| `VehicleType.suv` | `suv` | SUV |
| `VehicleType.truck` | `truck` | Truck |
| `VehicleType.van` | `van` | Van |
| `VehicleType.bus` | `bus` | Bus |
| `VehicleType.electric` | `electric` | Electric (EV) |

### Fuel Types (String Enum)

| Value |
|---|
| `Gasoline` |
| `Diesel` |
| `Electric` |
| `Hybrid` |
| `Plug-in Hybrid` |

---

## API Endpoints Contract

> **Base URL:** `http://localhost:8080/api/v1`  
> **Content-Type:** `application/json`  
> **Auth:** Bearer Token (JWT) in `Authorization` header

---

### 1. Authentication

#### `POST /api/v1/auth/login`

Authenticate a user and receive a JWT token.

**Request Body:**
```json
{
  "email": "admin@vms.com",
  "password": "admin123"
}
```

**Success Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "usr_admin_001",
      "name": "Sarah Connor",
      "email": "admin@vms.com",
      "role": "Fleet Manager",
      "avatarUrl": null
    }
  }
}
```

**Error Response:** `401 Unauthorized`
```json
{
  "success": false,
  "error": "Invalid email or password"
}
```

**Frontend Usage:** [`login_screen.dart`](file:///d:/vms/vms_frontend/lib/screens/auth/login_screen.dart) → `_handleLogin()` — currently simulates with 600ms delay, then navigates to `/vehicles`.

**Local Storage:** On success, store `token` → `HiveService.setAuthToken(token)`.

---

#### `POST /api/v1/auth/logout`

Invalidate the current session token.

**Headers:** `Authorization: Bearer <token>`

**Success Response:** `200 OK`
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

**Frontend Usage:** Sidebar logout button + Top bar profile menu → clears Hive storage and navigates to `/login`.

---

### 2. Vehicles CRUD

#### `GET /api/v1/vehicles`

Retrieve all vehicles with optional filtering, search, and pagination.

**Query Parameters:**

| Parameter | Type | Required | Description |
|---|---|---|---|
| `search` | `String` | ❌ | Text search across `plateNumber`, `make`, `model`, `vin`, `assignedDriver` |
| `status` | `String` | ❌ | Filter by status: `active`, `in_maintenance`, `out_of_service` |
| `type` | `String` | ❌ | Filter by vehicle type: `sedan`, `suv`, `truck`, `van`, `bus`, `electric` |
| `page` | `int` | ❌ | Page number (default: `0`) |
| `size` | `int` | ❌ | Page size (default: `20`) |
| `sort` | `String` | ❌ | Sort field (default: `createdAt,desc`) |

**Example Request:**
```
GET /api/v1/vehicles?search=toyota&status=active&type=sedan&page=0&size=20
```

**Success Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": "vh-001",
        "plateNumber": "ABC-1029",
        "vin": "4T1B11HK5PU102941",
        "make": "Toyota",
        "model": "Camry",
        "year": 2023,
        "type": "sedan",
        "status": "active",
        "mileage": 18200,
        "fuelType": "Gasoline",
        "assignedDriver": "Marcus Vance",
        "lastServiceDate": "2026-08-15",
        "notes": "Standard executive fleet vehicle. Pristine condition."
      }
    ],
    "totalElements": 1,
    "totalPages": 1,
    "currentPage": 0,
    "pageSize": 20
  }
}
```

**Frontend Usage:** [`vehicle_list_screen.dart`](file:///d:/vms/vms_frontend/lib/screens/vehicles/vehicle_list_screen.dart) → `repository.filter(query, status, type)` and [`vehicle_repository.dart`](file:///d:/vms/vms_frontend/lib/data/vehicle_repository.dart) → `filter()`.

---

#### `GET /api/v1/vehicles/{id}`

Retrieve a single vehicle by its unique ID.

**Success Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "vh-001",
    "plateNumber": "ABC-1029",
    "vin": "4T1B11HK5PU102941",
    "make": "Toyota",
    "model": "Camry",
    "year": 2023,
    "type": "sedan",
    "status": "active",
    "mileage": 18200,
    "fuelType": "Gasoline",
    "assignedDriver": "Marcus Vance",
    "lastServiceDate": "2026-08-15",
    "notes": "Standard executive fleet vehicle. Pristine condition."
  }
}
```

**Error Response:** `404 Not Found`
```json
{
  "success": false,
  "error": "Vehicle not found with id: vh-999"
}
```

**Frontend Usage:** [`vehicle_repository.dart`](file:///d:/vms/vms_frontend/lib/data/vehicle_repository.dart) → `getById(id)`.

---

#### `POST /api/v1/vehicles`

Register (create) a new vehicle.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "plateNumber": "NEW-5544",
  "vin": "1HGCG5655WA088453",
  "make": "Honda",
  "model": "Accord",
  "year": 2024,
  "type": "sedan",
  "status": "active",
  "mileage": 0,
  "fuelType": "Hybrid",
  "assignedDriver": "John Doe",
  "notes": "New fleet addition for Q4 2026."
}
```

> **Note:** `id` and `lastServiceDate` are **auto-generated** by the backend.

**Success Response:** `201 Created`
```json
{
  "success": true,
  "data": {
    "id": "vh-009",
    "plateNumber": "NEW-5544",
    "vin": "1HGCG5655WA088453",
    "make": "Honda",
    "model": "Accord",
    "year": 2024,
    "type": "sedan",
    "status": "active",
    "mileage": 0,
    "fuelType": "Hybrid",
    "assignedDriver": "John Doe",
    "lastServiceDate": "2026-11-22",
    "notes": "New fleet addition for Q4 2026."
  }
}
```

**Validation Errors:** `400 Bad Request`
```json
{
  "success": false,
  "errors": {
    "plateNumber": "License plate is required",
    "vin": "VIN must be at least 8 characters",
    "make": "Make is required",
    "model": "Model is required",
    "year": "Enter valid year (1980-2028)",
    "mileage": "Enter a valid positive number"
  }
}
```

**Frontend Usage:** [`vehicle_form_screen.dart`](file:///d:/vms/vms_frontend/lib/screens/vehicles/vehicle_form_screen.dart) → `_saveVehicle()` (create mode) → `repo.addVehicle(vehicle)`.

**Form Validation Rules (Client-side):**

| Field | Rule |
|---|---|
| `make` | Required, non-empty |
| `model` | Required, non-empty |
| `year` | Required, integer, range 1980 to `currentYear + 2` |
| `plateNumber` | Required, non-empty, auto-uppercased |
| `vin` | Required, min 8 characters, auto-uppercased |
| `mileage` | Required, integer ≥ 0 |
| `status` | Required, enum value |
| `type` | Required, enum value |
| `fuelType` | Required, one of allowed values |
| `assignedDriver` | Optional |
| `notes` | Optional |

---

#### `PUT /api/v1/vehicles/{id}`

Update an existing vehicle's data.

**Headers:** `Authorization: Bearer <token>`

**Request Body:** (same schema as POST, `id` from path param)
```json
{
  "plateNumber": "ABC-1029",
  "vin": "4T1B11HK5PU102941",
  "make": "Toyota",
  "model": "Camry",
  "year": 2023,
  "type": "sedan",
  "status": "in_maintenance",
  "mileage": 19500,
  "fuelType": "Gasoline",
  "assignedDriver": "Marcus Vance",
  "notes": "Scheduled for 20k km service. Tire rotation required."
}
```

**Success Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": "vh-001",
    "plateNumber": "ABC-1029",
    "vin": "4T1B11HK5PU102941",
    "make": "Toyota",
    "model": "Camry",
    "year": 2023,
    "type": "sedan",
    "status": "in_maintenance",
    "mileage": 19500,
    "fuelType": "Gasoline",
    "assignedDriver": "Marcus Vance",
    "lastServiceDate": "2026-08-15",
    "notes": "Scheduled for 20k km service. Tire rotation required."
  }
}
```

**Frontend Usage:** [`vehicle_form_screen.dart`](file:///d:/vms/vms_frontend/lib/screens/vehicles/vehicle_form_screen.dart) → `_saveVehicle()` (edit mode) → `repo.updateVehicle(vehicle)`.

---

#### `DELETE /api/v1/vehicles/{id}`

Permanently remove a vehicle from the fleet.

**Headers:** `Authorization: Bearer <token>`

**Success Response:** `200 OK`
```json
{
  "success": true,
  "message": "Vehicle vh-001 deleted successfully"
}
```

**Error Response:** `404 Not Found`
```json
{
  "success": false,
  "error": "Vehicle not found with id: vh-001"
}
```

**Frontend Usage:** [`vehicle_list_screen.dart`](file:///d:/vms/vms_frontend/lib/screens/vehicles/vehicle_list_screen.dart) → `_handleDelete()` → shows `ConfirmationDialog` → `repo.deleteVehicle(id)`.

---

### 3. Dashboard KPIs

#### `GET /api/v1/vehicles/stats`

Retrieve fleet-wide aggregated statistics for dashboard KPI cards.

**Success Response:** `200 OK`
```json
{
  "success": true,
  "data": {
    "totalCount": 8,
    "activeCount": 5,
    "maintenanceCount": 2,
    "outOfServiceCount": 1
  }
}
```

**Frontend Usage:** [`vehicle_list_screen.dart`](file:///d:/vms/vms_frontend/lib/screens/vehicles/vehicle_list_screen.dart) → `_buildMetricCards()` → currently reads from `repository.totalCount`, `repository.activeCount`, etc.

---

## Mock Data (Full Seed Dataset)

**Source:** [`lib/data/mock_data.dart`](file:///d:/vms/vms_frontend/lib/data/mock_data.dart)

Use this data to seed your backend database. All 8 vehicles are listed below in JSON format:

```json
[
  {
    "id": "vh-001",
    "plateNumber": "ABC-1029",
    "vin": "4T1B11HK5PU102941",
    "make": "Toyota",
    "model": "Camry",
    "year": 2023,
    "type": "sedan",
    "status": "active",
    "mileage": 18200,
    "fuelType": "Gasoline",
    "assignedDriver": "Marcus Vance",
    "lastServiceDate": "2026-08-15",
    "notes": "Standard executive fleet vehicle. Pristine condition."
  },
  {
    "id": "vh-002",
    "plateNumber": "FL-8821",
    "vin": "1FTVW1EV4PW882190",
    "make": "Ford",
    "model": "F-150 Lightning",
    "year": 2024,
    "type": "electric",
    "status": "active",
    "mileage": 9450,
    "fuelType": "Electric",
    "assignedDriver": "David Miller",
    "lastServiceDate": "2026-09-02",
    "notes": "Assigned to site engineering team. Equipped with mobile power bank."
  },
  {
    "id": "vh-003",
    "plateNumber": "VAN-4011",
    "vin": "WD3PE7CC4NP401123",
    "make": "Mercedes-Benz",
    "model": "Sprinter 2500",
    "year": 2022,
    "type": "van",
    "status": "in_maintenance",
    "mileage": 68900,
    "fuelType": "Diesel",
    "assignedDriver": "Fleet Logistics Pool",
    "lastServiceDate": "2026-10-20",
    "notes": "Undergoing scheduled 60k transmission fluid flush and brake pad replacement."
  },
  {
    "id": "vh-004",
    "plateNumber": "EV-9034",
    "vin": "5YJ3E1EB8NF903412",
    "make": "Tesla",
    "model": "Model Y",
    "year": 2023,
    "type": "electric",
    "status": "active",
    "mileage": 22100,
    "fuelType": "Electric",
    "assignedDriver": "Elena Rostova",
    "lastServiceDate": "2026-07-11",
    "notes": "Regular shuttle vehicle between North and South HQ campuses."
  },
  {
    "id": "vh-005",
    "plateNumber": "CRV-3319",
    "vin": "2HKRW2H87MH331984",
    "make": "Honda",
    "model": "CR-V Hybrid",
    "year": 2021,
    "type": "suv",
    "status": "active",
    "mileage": 45600,
    "fuelType": "Hybrid",
    "assignedDriver": "Carlos Rivera",
    "lastServiceDate": "2026-06-30",
    "notes": "Field inspections support vehicle."
  },
  {
    "id": "vh-006",
    "plateNumber": "TRK-5502",
    "vin": "JALC4W168L7550219",
    "make": "Isuzu",
    "model": "NPR-HD Box Truck",
    "year": 2020,
    "type": "truck",
    "status": "out_of_service",
    "mileage": 112400,
    "fuelType": "Diesel",
    "assignedDriver": null,
    "lastServiceDate": "2026-04-10",
    "notes": "Alternator failure; awaiting OEM replacement parts from supplier."
  },
  {
    "id": "vh-007",
    "plateNumber": "BUS-1204",
    "vin": "1GC4GVC74P1120489",
    "make": "Chevrolet",
    "model": "Express 3500 Passenger",
    "year": 2023,
    "type": "bus",
    "status": "active",
    "mileage": 31800,
    "fuelType": "Gasoline",
    "assignedDriver": "James Wilson",
    "lastServiceDate": "2026-09-18",
    "notes": "Used for scheduled employee campus transit routes."
  },
  {
    "id": "vh-008",
    "plateNumber": "EV-5541",
    "vin": "KM8KRDA23PU554109",
    "make": "Hyundai",
    "model": "Ioniq 5",
    "year": 2024,
    "type": "electric",
    "status": "in_maintenance",
    "mileage": 14300,
    "fuelType": "Electric",
    "assignedDriver": "Linda Chen",
    "lastServiceDate": "2026-10-28",
    "notes": "Firmware recall update and battery management system calibration in progress."
  }
]
```

**Mock Admin User:**
```json
{
  "id": "usr_admin_001",
  "name": "Sarah Connor",
  "email": "admin@vms.com",
  "password": "admin123",
  "role": "Fleet Manager",
  "avatarUrl": null
}
```

---

## Frontend Routes

| Route Path | Screen | Description | Auth Required |
|---|---|---|---|
| `/login` | `LoginScreen` | Admin authentication page | ❌ |
| `/vehicles` | `VehicleListScreen` | Fleet inventory, KPIs, search & filter | ✅ |
| `/vehicles/new` | `VehicleFormScreen` | Register a new vehicle form | ✅ |
| `/vehicles/edit` | `VehicleFormScreen` | Edit existing vehicle (receives `Vehicle` as argument) | ✅ |
| `/drivers` | — | 🔜 Coming Soon (placeholder) | ✅ |
| `/maintenance` | — | 🔜 Coming Soon (placeholder) | ✅ |
| `/analytics` | — | 🔜 Coming Soon (placeholder) | ✅ |

**Initial Route:** `/login`  
**Route Generator:** [`app_routes.dart`](file:///d:/vms/vms_frontend/lib/core/routes/app_routes.dart)

---

## Local Storage (Hive)

**Service:** [`hive_service.dart`](file:///d:/vms/vms_frontend/lib/core/storage/hive_service.dart)

| Box Name | Key | Value Type | Purpose |
|---|---|---|---|
| `vms_storage` | `auth_token` | `String` | JWT Bearer token from login response |
| `vms_storage` | `auth_user` | `String` | Serialized user JSON (planned) |

**Operations Available:**
- `getAuthToken()` → retrieve stored JWT
- `setAuthToken(String token)` → persist JWT
- `removeAuthToken()` → clear JWT on logout
- `clearAll()` → wipe all stored data

---

## UI / Design System

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#1E40AF` | Buttons, links, active states |
| `primaryHover` | `#1D4ED8` | Hover states |
| `primaryLight` | `#DBEAFE` | Light primary backgrounds |
| `background` | `#F8FAFC` | Page background |
| `surface` | `#FFFFFF` | Card & panel backgrounds |
| `surfaceMuted` | `#F1F5F9` | Table header, muted areas |
| `border` | `#E2E8F0` | Card & input borders |
| `success` / `successLight` | `#16A34A` / `#DCFCE7` | Active status |
| `warning` / `warningLight` | `#D97706` / `#FEF3C7` | In Maintenance status |
| `error` / `errorLight` | `#DC2626` / `#FEE2E2` | Out of Service, delete actions |
| `sidebarBg` | `#0F172A` | Dark sidebar background |

### Responsive Breakpoints

| Breakpoint | Width | Layout |
|---|---|---|
| Mobile | < 640px | Single column, bottom nav/drawer |
| Tablet | 640px – 1024px | Two-column, drawer navigation |
| Desktop | ≥ 1024px | Persistent sidebar + content area |

### Layout Constants

| Constant | Value |
|---|---|
| Sidebar Expanded Width | 260px |
| Sidebar Collapsed Width | 72px |
| Top Bar Height | 64px |
| Max Content Width | 1400px |

---

## Planned Modules (Future)

The sidebar navigation already shows these as "Coming Soon" badges:

| Module | Route | Likely Backend Endpoints |
|---|---|---|
| **Drivers** | `/drivers` | `GET/POST/PUT/DELETE /api/v1/drivers` |
| **Maintenance** | `/maintenance` | `GET/POST/PUT/DELETE /api/v1/maintenance-records` |
| **Analytics** | `/analytics` | `GET /api/v1/analytics/fleet-summary`, `/api/v1/analytics/cost-breakdown` |

---

## Backend Integration Checklist

Use this checklist when building the Spring Boot backend:

### Database Schema (SQL Reference)

```sql
-- Users Table
CREATE TABLE users (
    id          VARCHAR(50)  PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,  -- BCrypt hashed
    role        VARCHAR(50)  NOT NULL DEFAULT 'Fleet Manager',
    avatar_url  VARCHAR(500),
    created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- Vehicles Table
CREATE TABLE vehicles (
    id                VARCHAR(50)  PRIMARY KEY,
    plate_number      VARCHAR(20)  NOT NULL UNIQUE,
    vin               VARCHAR(17)  NOT NULL UNIQUE,
    make              VARCHAR(50)  NOT NULL,
    model             VARCHAR(100) NOT NULL,
    year              INT          NOT NULL CHECK (year >= 1980),
    type              VARCHAR(20)  NOT NULL,  -- sedan, suv, truck, van, bus, electric
    status            VARCHAR(20)  NOT NULL DEFAULT 'active',  -- active, in_maintenance, out_of_service
    mileage           INT          NOT NULL DEFAULT 0 CHECK (mileage >= 0),
    fuel_type         VARCHAR(30)  NOT NULL,
    assigned_driver   VARCHAR(100),
    last_service_date DATE,
    notes             TEXT,
    created_at        TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- Seed Admin User (password: admin123, BCrypt hashed)
INSERT INTO users (id, name, email, password, role)
VALUES ('usr_admin_001', 'Sarah Connor', 'admin@vms.com',
        '$2a$10$example_bcrypt_hash_here', 'Fleet Manager');
```

### Integration Checklist

- [ ] **Auth Endpoints** — `POST /auth/login` returning JWT + user object
- [ ] **JWT Filter** — Validate `Authorization: Bearer <token>` on all `/vehicles/**` routes
- [ ] **CORS** — Allow `http://localhost:*` origins for Flutter web dev
- [ ] **Vehicle CRUD** — `GET`, `POST`, `PUT`, `DELETE` on `/api/v1/vehicles`
- [ ] **Vehicle Stats** — `GET /api/v1/vehicles/stats` with aggregated counts
- [ ] **Search** — Case-insensitive text search across `plateNumber`, `make`, `model`, `vin`, `assignedDriver`
- [ ] **Filtering** — Query params for `status` and `type` enum filtering
- [ ] **Pagination** — Spring Data `Pageable` with `page`, `size`, `sort` params
- [ ] **Validation** — `@Valid` annotations matching frontend rules (see form validation table above)
- [ ] **Error Responses** — Uniform `{ success, error/errors, data }` envelope
- [ ] **Seed Data** — Import the 8 mock vehicles JSON above into the database
- [ ] **Enum Mapping** — Map `in_maintenance` ↔ `VehicleStatus.inMaintenance`, `out_of_service` ↔ `VehicleStatus.outOfService`

### API Response Envelope Pattern

All endpoints should follow this consistent response structure:

```json
// Success (single item)
{ "success": true, "data": { ... } }

// Success (paginated list)
{ "success": true, "data": { "content": [...], "totalElements": N, "totalPages": N, "currentPage": N, "pageSize": N } }

// Success (action confirmation)
{ "success": true, "message": "..." }

// Error (single)
{ "success": false, "error": "..." }

// Error (validation, multiple fields)
{ "success": false, "errors": { "field": "message", ... } }
```

---

## License

Private project — not published to pub.dev.
