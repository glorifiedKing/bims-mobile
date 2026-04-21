# BIMS Mobile Application: Completed Features Report

This document outlines the features and functionalities that have been successfully developed and integrated into the BIMS mobile application. The app has been designed to support various user types, ensuring secure access and tailored experiences for each group.

## 1. Public Access Features
These features are available to the general public without requiring an account or login.

### Public Permit Verification
A dedicated public-facing feature has been built to allow anyone to verify the authenticity of a building permit quickly and easily.
*   **QR Code Scanning:** Users can instantly scan a QR code printed on a physical permit to verify it digitally.
*   **Manual Entry:** For cases where scanning isn't possible, users can manually enter the permit's unique serial number.
*   **Permit Status Retrieval:** The system retrieves and displays detailed, verified information about the permit, providing confidence in its legitimacy.
*   **Clear Error Messaging:** If a permit is invalid, expired, or simply not found, the system provides user-friendly error messages rather than confusing technical terms.

*[Insert Screenshot: Verify Permit Scanner/Entry]*
*[Insert Screenshot: Valid Permit Detail View]*
*[Insert Screenshot: Invalid Permit Error Message]*

---

## 2. Secure Access and Onboarding (Authentication)
The application handles three distinct types of users, each with their own dedicated, secure entry points to ensure privacy and proper access control.

### Client Onboarding
*   **Account Creation (Registration):** Standard users (Clients) can create a new account via a streamlined registration process.
*   **Secure Login & Logout:** Returning clients can securely access their portal and effectively log out with a persistent action button.

*[Insert Screenshot: Client Registration Screen]*
*[Insert Screenshot: Client Login Screen]*

### Professional Onboarding
*   **Dedicated Registration:** A specialized registration flow tailored specifically for Industry Professionals, capturing their unique credentials.
*   **Professional Login:** A separate, secure login portal specifically for professionals, directing them to their specialized dashboard.

*[Insert Screenshot: Professional Registration Screen]*
*[Insert Screenshot: Professional Login Screen]*

### System Administrator (BCO) Access
*   **BCO Login:** A highly secure login interface designated for Building Control Officers (BCO), navigating directly to an administrative tracking dashboard.

*[Insert Screenshot: BCO Login Screen]*

---

## 3. Client Portal
Once a standard client logs in, they have access to a fully functional self-service portal to manage their building projects.

### Client Dashboard
The first screen the client sees upon logging in, acting as a central command center with quick summaries and navigation links to essential areas.

*[Insert Screenshot: Client Dashboard]*

### Application Management
Clients can easily submit and monitor their requests within the app.
*   **View All Applications:** A list view of all past and current building applications submitted by the client (with intuitive filters like PENDING and APPROVED).
*   **New Application Submission:** A guided flow allowing the client to initiate a brand-new application directly from their phone.
*   **Application Details:** Clients can click into any specific application to review its detailed status, history, and submitted information.

*[Insert Screenshot: Client Applications List]*
*[Insert Screenshot: Application Details View]*

### Permit Management
Clients can view the official permits they have been granted.
*   **Permit Library:** A repository displaying all active and past permits associated with the client.
*   **Detailed Permit View:** Full specific details of any selected permit, which matches the data available via the Public Verification tool.

*[Insert Screenshot: Client Permits List]*

### Financials & Invoices
*   **Invoice Tracking:** Clients can see a list of all system-generated invoices related to their applications or permits.
*   **Intelligent Downloading:** Integrates secure native PDF launching, allowing clients to securely view and save actual receipts and invoice slips natively to their phones.

*[Insert Screenshot: Client Invoices List]*

### Profile Management
*   **View Profile:** Displaying the personal information and contact details associated with the account.
*   **Edit Profile:** Clients have the ability to update their personal information as needed.

*[Insert Screenshot: Client Profile]*

---

## 4. Professional Portal
An entirely isolated and distinct user experience built for Industry Professionals, backed by its own specific data connections (APIs) and logic.

### Professional Dashboard
Upon successful professional login, the user is presented with a specialized dashboard tailored to professional workflows and overviews (distinct from the standard client dashboard).

*[Insert Screenshot: Professional Dashboard]*

### Professional Profile Management
*   **Specialized Profile View:** A profile screen that houses professional-specific data and credentials.

*[Insert Screenshot: Professional Profile Screen]*

---

## 5. BCO (Building Control Officer) Portal
A comprehensive administrative interface optimized for regulatory and compliance agents acting inside the system. 

### BCO Dashboard & RBAC
*   **Central Operating Dashboard:** Quick access navigation points displaying crucial statistics like Unpaid Invoices or General Applications metrics.
*   **Role-Based Access Control (RBAC):** Restricts interface links dynamically according to the officer's exact designated role (e.g., controlling access across Stop Orders, Checklists, Calendar, AI Camera tooling, etc.).

### Robust Application Auditing
*   **BCO Application List:** Full paginated records letting officers jump immediately to "PENDING" or "APPROVED" projects.
*   **Application Detail Reviewing:** BCO officers have rich auditing interfaces where they can verify applicant status, view location profiles, inspect detailed audit trails, or run deep checklist protocols over the entry.
*   **Document Attachments Access:** Embedded seamlessly into details, BCOs can tap and extract PDFs/drawings/blueprints bound directly to the application securely via `url_launcher`.

### Express Penalties Control
*   **Penalties Overlook:** A scalable list filtering Penalties precisely by ALL, UNPAID, PAID, APPEALED, VOIDED, OVERDUE.
*   **Issue Penalties Dynamically:** Advanced form generator that dynamically maps internal `Hive` metadata bridging correct location hierarchies, building classifications, and enactment offences resulting in completely automated calculation bounds for "Tentative Fine Amounts" prior to executing.
*   **Detailed Infraction Viewing:** Drill down views capturing complete demographic snapshots to assess the offence variables instantly.

### Automated Toolkit Integrations
*   **AI Edge Camera Inspection:** Empowers officers with Google Gemini (Firebase Vertex AI) logic linking immediately to their camera or gallery. Snapped photographs undergo instantaneous scan requests diagnosing construction environments for structural measurements, security compliance, wheelchair ramping margins, and emergency path viability natively in-app.
*   **Stop Work Orders & Calendars:** Direct offline-ready caching pipelines mapped dynamically cascading down Region > District > Parishes enabling inspectors to correctly submit stop order flags in realtime.


---

### Summary of Technical Underpinnings
While this report focuses on user-facing features, it's worth noting that significant foundational work has been completed:
*   **Independent Systems:** The Client, Professional, and BCO portals operate completely independently, ensuring professional data is strictly separated from standard client data.
*   **Robust Navigation:** A solid routing architecture (App Router) has been implemented to ensure smooth, logical transitions between all the screens.
*   **Data Models & Logic:** The underlying data models (Permits, Invoices, Attachments, Penalties) and Business Logic Components (Blocs) handle complex pagination limitations seamlessly without risking data duplication.
*   **Persistent Offline Lookups:** Substantial auxiliary endpoints leverage `Hive` noSQL caching preserving memory-intensive definitions locally reducing API lag.
