# 🌱 ZingiraNakama - Connecting Land to Purpose

## 📋 Table of Contents
- [Overview](#overview)
- [Live Demo](#live-demo)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Local Development Setup](#local-development-setup)
- [Deployment](#deployment)
- [Contact](#contact)

---

## 🎯 Overview

**ZingiraNakama** is a revolutionary platform that bridges the gap between local land restorers and organizations seeking to establish environmental restoration projects. The platform facilitates connections for carbon credit generation, biodiversity restoration, and sustainable land management initiatives.

### The Problem We Solve

- **For Local Restorers:** Difficulty accessing carbon credit markets and finding legitimate restoration partners
- **For Organizations:** Challenges in locating suitable land for restoration projects and connecting with verified landowners
- **For Both:** Complex and tedious carbon credit calculation processes

### Our Solution

A digital marketplace that:
- Connects landowners directly with restoration project operators
- Streamlines the matching process between supply (land) and demand (projects)
- Provides a transparent platform for collaboration
- Enables participation in environmental restoration and carbon markets

---

## 🚀 Live Demo

### 🌐 Web Application
**URL:** [https://final-plp-project-five.vercel.app/](https://final-plp-project-five.vercel.app/)

### 📱 Mobile APK
**Download:** [APK Link - Coming Soon]

### 🎥 Demo Video
**Watch:** [Demo Video Link - Coming Soon]

### 📊 Pitch Deck
**View:** [https://www.canva.com/design/DAGy231ZyAM/D8q7egXXyCYtuRSt5QrLOQ/edit?utm_content=DAGy231ZyAM&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton]

---

## ✨ Features

### ✅ Implemented Features

#### For Local Restorers
- **User Registration & Authentication**
  - Multi-step registration with personal information
  - Project support type selection (Forest, Agroforestry, Wetlands, Mangroves) Arbitrary examples for demo
  - Terms & Privacy acceptance(No terms generated yet)
  - JWT-based secure authentication

- **Land Management**
  - Add land listings with detailed information (title, size, location, restoration types)
  - Dual unit support (Acres ↔ Hectares conversion)
  - Edit land profiles
  - Soft delete with validation (cannot delete if pending/accepted requests exist)
  - Availability toggle (Available/Unavailable)

- **Match Request Management**
  - View incoming collaboration requests from organizations
  - Accept or decline requests
  - Automatic land status updates upon acceptance
  - Permanent decision tracking
  - One accepted collaboration per land parcel

- **Notifications**
  - Real-time in-app notifications for new requests
  - Unread notification count badge
  - Mark as read functionality

- **Profile Management**
  - Edit personal information
  - Update location (county/subcounty)
  - Modify supported restoration types with validation
  - Email change capability

#### For Partner Organizations
- **User Registration & Authentication**
  - Streamlined 2-step registration
  - Organization information capture
  - Secure authentication

- **Land Discovery**
  - Browse available land listings (randomized display)
  - Advanced filtering:
    - By county
    - By restoration type
    - By land size (min-max range)
  - View detailed land information
  - Global unit toggle (Acres/Hectares)

- **Collaboration Requests**
  - Request collaboration on available lands
  - "Request Sent" status tracking
  - View-only match request history
  - Status tracking (Pending, Accepted, Declined, Land No Longer Available)

- **Notifications**
  - Acceptance/decline notifications
  - In-app notification center
  - Unread count tracking

- **Profile Management**
  - Edit organization name and email
  - Account settings

#### System-Wide Features
- **Responsive Design**
  - Desktop-optimized layouts (>1024px)
  - Tablet-friendly views (600-1024px)
  - Mobile-responsive interface (<600px)
  - Bottom navigation for mobile
  - Sidebar navigation for desktop/tablet

- **Data Management**
  - Kenya counties and subcounties (seeded data for 7 major counties i.e Nairobi, Mombasa, Kisumu, Nakuru, Kiambu, Machakos and Kakamega)
  - 4 restoration types (Forest, Agroforestry, Wetlands, Mangroves)
  - Automatic unit conversions (1 acre = 0.404686 hectares)

- **Business Logic**
  - Role-based access control
  - Soft delete with relationship integrity
  - Automatic status updates on match acceptance
  - Validation rules for data consistency
  - Email notifications via automated system (on acceptance)

---

### 🚧 Features Not Implemented (MVP Scope)

- ❌ Password reset/recovery functionality
- ❌ Email verification for new accounts
- ❌ In-app messaging between matched parties
- ❌ Advanced analytics dashboard
- ❌ Super Admin panel
- ❌ USSD offline application
- ❌ Multiple image uploads per land listing
- ❌ Document upload for land verification
- ❌ Rating/review system for completed projects
- ❌ Payment integration
- ❌ Subscription tiers

---

## 🔮 Proposed Future Integrations

### Phase 1: Enhanced Collaboration (Q1 2026)
- **In-App Messaging System**
  - Real-time chat between matched parties
  - File sharing capabilities
  - Message history and archiving

- **Document Management**
  - Land title verification
  - Project agreement templates
  - Digital contract signing

- **Project Tracking**
  - Milestone tracking
  - Progress reporting with photo documentation
  - Timeline management

### Phase 2: Market Expansion (Q2 2026)
- **Payment Integration**
  - Escrow services for secure transactions
  - Multi-currency support (KES, USD, EUR)
  - Mobile money integration (M-Pesa, Airtel Money)

- **Subscription Tiers**
  - Free tier with basic matching
  - Premium tier with priority listing and analytics
  - Enterprise tier with dedicated support and API access

### Phase 3: Scale & Sustainability (Q3 2026)
- **USSD Application**
  - Offline access for rural areas with limited internet
  - SMS-based notifications
  - USSD menu-driven navigation

- **Mobile Apps (Native)**
  - Android app (Google Play Store)
  - iOS app (Apple App Store)
  - Offline mode with sync capabilities

- **AI/ML Integration**
  - Smart matching algorithm based on project success patterns
  - Predictive analytics for carbon credit potential
  - Automated land suitability assessment using satellite data

- **Blockchain Integration**
  - Smart contracts for automated payments

---

## 🛠 Tech Stack

### Frontend
- **Framework:** Flutter 3.27.1
- **Language:** Dart
- **State Management:** Provider
- **HTTP Client:** http package
- **Local Storage:** shared_preferences
- **Image Handling:** image_picker, cloudinary_public
- **Deployment:** Vercel

### Backend
- **Framework:** Django 5.2
- **API:** Django REST Framework
- **Authentication:** JWT (djangorestframework-simplejwt)
- **Database ORM:** Django ORM
- **Server:** Gunicorn
- **Static Files:** WhiteNoise
- **Deployment:** Render

### Database
- **Production:** PostgreSQL (Supabase)
- **Development:** PostgreSQL (Local)
- **ORM:** Django ORM

### Infrastructure & DevOps
- **Version Control:** Git & GitHub
- **Frontend Hosting:** Vercel
- **Backend Hosting:** Render
- **Database Hosting:** Supabase
- **Image Storage:** Cloudinary (configured, not yet implemented)
- **CI/CD:** Render auto-deploy on Git push

### Development Tools
- **IDE:** VS Code
- **API Testing:** Python requests library, Postman-ready
- **Database Management:** pgAdmin 4
- **Design:** Material Design 3 principles

---

## 🏗 Architecture

### System Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Client Layer                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Web (PWA)   │  │   Android    │  │     iOS      │      │
│  │   Vercel     │  │  APK/Google  │  │  (Future)    │      │
│  │              │  │     Play     │  │              │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTPS/REST API
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                   Application Layer                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │            Django REST Framework                     │   │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────────┐  │   │
│  │  │   Auth     │  │   Lands    │  │   Matches    │  │   │
│  │  │  Endpoints │  │  Endpoints │  │  Endpoints   │  │   │
│  │  └────────────┘  └────────────┘  └──────────────┘  │   │
│  │  ┌────────────┐  ┌────────────┐  ┌──────────────┐  │   │
│  │  │   Users    │  │Notifications│  │   Profile    │  │   │
│  │  │  Endpoints │  │  Endpoints │  │  Endpoints   │  │   │
│  │  └────────────┘  └────────────┘  └──────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                    Deployed on Render                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ ORM
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                     Data Layer                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              PostgreSQL Database                     │   │
│  │  ┌────────┐  ┌────────┐  ┌────────┐  ┌──────────┐  │   │
│  │  │ Users  │  │ Lands  │  │ Match  │  │ Notifs   │  │   │
│  │  │        │  │        │  │ Requests│  │          │  │   │
│  │  └────────┘  └────────┘  └────────┘  └──────────┘  │   │
│  │  ┌────────┐  ┌────────┐  ┌────────┐                │   │
│  │  │Counties│  │ Sub-   │  │Restore │                │   │
│  │  │        │  │counties│  │ Types  │                │   │
│  │  └────────┘  └────────┘  └────────┘                │   │
│  └──────────────────────────────────────────────────────┘   │
│                  Hosted on Supabase                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Future Integration
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  External Services (Future)                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Cloudinary  │  │    SMTP      │  │   M-Pesa     │      │
│  │   (Images)   │  │   (Email)    │  │  (Payments)  │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### Database Schema

**9 Core Tables:**
1. **users** - Authentication and profile data (role-based)
2. **counties** - Kenya counties (47 seeded)
3. **subcounties** - Kenya subcounties (73 seeded for major counties)
4. **restoration_types** - Available restoration types (4 seeded)
5. **user_restoration_types** - Junction table (user ↔ restoration types)
6. **land_listings** - Land parcel information
7. **land_restoration_types** - Junction table (land ↔ restoration types)
8. **match_requests** - Collaboration requests and status
9. **notifications** - In-app notification system

---

## 🚦 Getting Started

### Prerequisites

- **Python 3.10+** installed
- **PostgreSQL 14+** installed and running
- **Flutter SDK 3.27+** installed
- **Node.js 16+** (for Vercel CLI)
- **Git** for version control

---

## 💻 Local Development Setup

### Backend Setup (Django)

#### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/zingira-nakama.git
cd zingira-nakama/backend
```

#### 2. Create Virtual Environment
```bash
python -m venv venv

# Windows
venv\Scripts\activate

# Mac/Linux
source venv/bin/activate
```

#### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

#### 4. Configure Environment Variables

Create a `.env` file in the `backend` folder:
```env
DEBUG=True
SECRET_KEY=your-local-secret-key-change-this
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/zingira_db
ALLOWED_HOSTS=localhost,127.0.0.1
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

#### 5. Create PostgreSQL Database
```bash
# Open PostgreSQL command line or pgAdmin
psql -U postgres

# Create database
CREATE DATABASE zingira_db;

# Exit
\q
```

#### 6. Run Migrations
```bash
python manage.py makemigrations
python manage.py migrate
```

#### 7. Seed Initial Data
```bash
python manage.py seed_data
```

This seeds:
- 47 Kenya counties
- 73 subcounties (for 7 major counties)
- 4 restoration types

#### 8. Create Superuser (Optional)
```bash
python manage.py createsuperuser
```

Follow prompts to create admin account.

#### 9. Run Development Server
```bash
python manage.py runserver
```

Backend will be available at: `http://127.0.0.1:8000/`

API endpoints: `http://127.0.0.1:8000/api/`

Admin panel: `http://127.0.0.1:8000/admin/`

---

### Frontend Setup (Flutter)

#### 1. Navigate to Frontend Folder
```bash
cd ../frontend
```

#### 2. Install Flutter Dependencies
```bash
flutter pub get
```

#### 3. Configure API URL for Local Development

Open `lib/config/constants.dart`:
```dart
// For web/desktop
static const String baseUrl = 'http://localhost:8000/api';

// For Android emulator
static const String baseUrl = 'http://10.0.2.2:8000/api';

// For iOS simulator
static const String baseUrl = 'http://127.0.0.1:8000/api';

// For physical device (replace with your computer's IP)
static const String baseUrl = 'http://192.168.1.100:8000/api';
```

#### 4. Run Flutter Application

**For Web:**
```bash
flutter run -d chrome
```

**For Android Emulator:**
```bash
# Start Android emulator first, then:
flutter run
```

**For Physical Device:**
```bash
# Enable USB debugging on device, connect via USB, then:
flutter run
```

#### 5. Hot Reload

While the app is running, press:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

---

### Testing the Application Locally

#### Create Test Users

1. **Register as Local Restorer:**
   - Navigate to Sign Up
   - Select "Local Restorer"
   - Complete 3-step registration
   - Login with credentials

2. **Register as Organization:**
   - Navigate to Sign Up
   - Select "Project Operator"
   - Complete 2-step registration
   - Login with credentials

#### Test Full Workflow

1. **As Restorer:**
   - Add a land listing
   - View your land listings
   - Check dashboard

2. **As Organization:**
   - Browse available lands
   - Filter by county/type
   - Request collaboration on a land

3. **Back as Restorer:**
   - Check notifications (new request)
   - Go to Matches
   - View request details
   - Accept the request

4. **Back as Organization:**
   - Check notifications (acceptance)
   - View match status
   - Check email for contact details (if email configured)

---

## 🚀 Deployment

### Production Deployment URLs

- **Frontend (Web):** https://final-plp-project-five.vercel.app/
- **Backend (API):** https://zingiranakama-proj2.onrender.com/api/
- **Database:** Supabase (PostgreSQL)

### Deployment Architecture
```
┌──────────────────┐
│   Vercel (CDN)   │  ← Flutter Web Build
│   Global Edge    │
└────────┬─────────┘
         │ HTTPS
         ▼
┌──────────────────┐
│  Render (Server) │  ← Django + Gunicorn
│   Auto-deploy    │
└────────┬─────────┘
         │ PostgreSQL Connection
         ▼
┌──────────────────┐
│  Supabase (DB)   │  ← PostgreSQL Database
│  Auto-backup     │
└──────────────────┘
```

### Deployment Notes

**Render (Backend):**
- Free tier: Sleeps after 15 min inactivity
- First request after sleep: ~30 seconds wake time
- Auto-deploys on GitHub push
- Environment variables managed in Render dashboard

**Vercel (Frontend):**
- Free tier: Unlimited bandwidth, 100GB/month
- Instant global deployment
- Automatic HTTPS
- Auto-deploys on GitHub push

**Supabase (Database):**
- Free tier: 500MB storage, unlimited time
- Daily backups
- Connection pooling enabled
- Located in Southeast Asia region (low latency for Kenya)

---

## 📱 Mobile APK Build

### Build Android APK
```bash
cd frontend
flutter build apk --release
```

**Output:** `frontend/build/app/outputs/flutter-apk/app-release.apk`

### Distribute APK

Upload to:
- Google Drive
- Dropbox
- Firebase App Distribution
- GitHub Releases

Users must enable "Install from Unknown Sources" on Android to install.

### Future: Google Play Store

For production release:
1. Create Google Play Developer account ($25 one-time fee)
2. Generate signed APK with keystore
3. Upload to Play Console
4. Submit for review

---


## 📞 Contact

### Project Maintainer

**Name:** Chrysanthus Mambo Jumaa  
**Email:** chrysanthusjumaa@gmail.com  
**GitHub:** [@Chrysanthus-Jumaa](https://github.com/yourusername)  
**LinkedIn:** [Chrysanthus Jumaa](https://www.linkedin.com/in/chrysanthus-mambo-jumaa-53b011332?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app)

### Project Links

- **GitHub Repository:** [https://github.com/Chrysanthus-Jumaa/FINAL_PLP_PROJECT.git](https://github.com/Chrysanthus-Jumaa/FINAL_PLP_PROJECT.git)
- **Live Demo:** [https://final-plp-project-five.vercel.app/](https://final-plp-project-five.vercel.app/)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **PLP Academy** - For the intensive bootcamp training
- **Django Community** - For excellent documentation and support
- **Flutter Team** - For the powerful cross-platform framework
- **Supabase** - For free PostgreSQL hosting
- **Render & Vercel** - For free deployment platforms
- **Open Source Community** - For the amazing tools and libraries

---

## 📊 Project Statistics

- **Development Time:** 8+ hours intensive coding
- **Lines of Code:** ~15,000+ (Backend + Frontend)
- **API Endpoints:** 16
- **Database Tables:** 9
- **Screens:** 18 (Flutter)
- **Models:** 9 (Django)
- **Reusable Components:** 15+ (Flutter widgets)

---

## 🎯 Project Goals Achieved

✅ Full-stack application with decoupled architecture  
✅ Role-based authentication and authorization  
✅ Complete CRUD operations for land listings  
✅ Match request system with status tracking  
✅ Real-time notifications  
✅ Responsive design (mobile, tablet, desktop)  
✅ Production deployment (web + API)  
✅ Comprehensive documentation  
✅ Clean, maintainable codebase  

---

## 🌟 Star This Project

If you find this project useful, please consider giving it a ⭐ on GitHub!

---


**Built with ❤️ for environmental restoration and sustainable development**