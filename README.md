# 🎓 CampusConnect

> Real-time campus app connecting **students**, **teachers** & **admin** — chat, mentorship, complaints & analytics. Built with **Flutter + Firebase**.

`flutter` · `firebase` · `firestore` · `dart` · `firebase-auth` · `firebase-cloud-messaging` · `cross-platform` · `campus-app`

🔗 **Live app:** [https://campusconnecttemp.web.app](https://campusconnecttemp.web.app)
📦 **Repository:** [github.com/ShukuNinja/CampusConnect](https://github.com/ShukuNinja/CampusConnect)

---

## ✨ About

CampusConnect is a cross‑platform Flutter application (Android · iOS · Web) that brings an entire campus into one place. Instead of scattering communication across WhatsApp groups, notice boards, and email threads, everyone signs in with a **role** and gets an experience built for them:

- **👨‍🎓 Students** — find and message teachers, join group chats, raise complaints, and track their status.
- **👩‍🏫 Teachers** — set their availability/location, mentor students, respond to conversations, and manage groups.
- **🛡️ ISM (Institution Support / Admin)** — resolve complaints, broadcast notifications, and view live analytics dashboards.

Everything runs in **real time** on Firebase — **Firebase Auth** for sign-in, **Cloud Firestore** for data, and **Firebase Cloud Messaging** for push notifications — so a message sent, a complaint raised, or a notice broadcast shows up instantly across every device.

---

## 🧭 App Flow

```
main.dart
   │  (reads saved role from SharedPreferences)
   ▼
RoleSelectPage ── choose Student / Teacher / ISM
   ▼
Login<Role>Page ──────────────► "Create new account"
   │  (Firebase Auth sign-in)          │
   │                                   ▼
   │                            Signup<Role>Page
   │                                   │  create Auth user + Firestore docs
   ▼                                   ▼
RoleRouter ── reads `users/{uid}.role` from Firestore
   ├─ student → StudentHome
   ├─ teacher → TeacherHome
   └─ ism     → ISMHome
```

- **`AuthGate` / `RoleRouter`** decide what a signed‑in user sees based on their `role` field in the `users` collection.
- **Login pages** verify the account's role matches the selected role before entering.
- **Signup pages** create a Firebase Auth account and write the role + profile documents to Firestore.
- **Home pages** branch into feature screens (chat, complaints, analytics, profiles, notifications, etc.).

### Firestore data model (high level)

| Collection    | Purpose                                              |
|---------------|------------------------------------------------------|
| `users`       | Role routing: `{ role, email }` keyed by Auth UID    |
| `students`    | Student profiles (name, regno, dept, passing year)   |
| `teachers`    | Teacher profiles (name, dept, availability, location)|
| `isms`        | ISM/admin profiles                                   |
| conversations / groups / complaints / notifications | Feature data driving chat, group chat, complaints and alerts |

---

## 🛠️ Tech Stack

| Layer            | Technology |
|------------------|------------|
| **Framework**    | [Flutter](https://flutter.dev/) 3.32 · Dart 3.8 |
| **Language**     | Dart |
| **Auth**         | Firebase Authentication (email/password) |
| **Database**     | Cloud Firestore (real‑time) |
| **Push**         | Firebase Cloud Messaging (`firebase_messaging`) |
| **Charts**       | [`fl_chart`](https://pub.dev/packages/fl_chart) for analytics dashboards |
| **Local storage**| [`shared_preferences`](https://pub.dev/packages/shared_preferences) (remembers selected role) |
| **Networking**   | [`http`](https://pub.dev/packages/http) |
| **Hosting**      | Firebase Hosting (web build) |
| **Platforms**    | Android · iOS · Web |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.8.1`
- A Firebase project (Auth + Firestore enabled) — this repo is wired to `campusconnecttemp`

### Run locally

```bash
flutter pub get
flutter run
```

### Build & deploy the web app

```bash
flutter build web
firebase deploy --only hosting
```

---

## 📁 Project Structure

```
lib/
├── main.dart                     # App entry, Firebase init, role bootstrap
├── auth_gate.dart                # Auth state → RoleRouter or role select
├── role_router.dart              # Routes signed-in user by Firestore role
├── role_select_page.dart         # Choose Student / Teacher / ISM
├── login_*_page.dart             # Per-role login
├── signup_*_page.dart            # Per-role signup
├── *_home.dart                   # Student / Teacher / ISM dashboards
├── chat_page.dart, group_chat_page.dart, conversations_page.dart  # Messaging
├── *_complaint*.dart             # Complaint raising & tracking
├── ism_analytics_page.dart       # Admin analytics (fl_chart)
└── ...                           # Profiles, groups, notifications
```

---

## 🗺️ Roadmap

- ✉️ **Email OTP verification at signup** (planned) — verify a user's email with a one-time code before the account is created.

---

## 📜 License

This project is for educational / campus use. Add a license file if you intend to distribute it.
