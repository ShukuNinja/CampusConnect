# 🎓 CampusConnect

> One app that connects **Students**, **Teachers**, and **ISM (Institution Support/Admin)** on a single campus — chat, mentorship, complaints, notifications, and analytics, all in real time.

🔗 **Live app:** [https://campusconnecttemp.web.app](https://campusconnecttemp.web.app)
📦 **Repository:** [github.com/ShukuNinja/CampusConnect](https://github.com/ShukuNinja/CampusConnect)

---

## ✨ About

CampusConnect is a cross‑platform Flutter application (Android · iOS · Web) that brings an entire campus into one place. Instead of scattering communication across WhatsApp groups, notice boards, and email threads, everyone signs in with a **role** and gets an experience built for them:

- **👨‍🎓 Students** — find and message teachers, join group chats, raise complaints, and track their status.
- **👩‍🏫 Teachers** — set their availability/location, mentor students, respond to conversations, and manage groups.
- **🛡️ ISM (Institution Support / Admin)** — handle complaints, broadcast notifications, and view campus analytics dashboards.

Authentication is backed by **Firebase Auth**, all data lives in **Cloud Firestore** in real time, push notifications run through **Firebase Cloud Messaging**, and every new account now goes through **email OTP verification powered by [Brevo](https://www.brevo.com/)** before it is created.

---

## 🔐 Email OTP Verification (Brevo)

Sign‑up is now a two‑step, verified flow. **No Firebase account is created until the emailed one‑time code is confirmed.**

```
Fill sign-up form
        │
        ▼
Generate 6-digit OTP  ──►  Send via Brevo API  ──►  📧 user's inbox
        │
        ▼
OTP verification screen  ──►  user enters code
        │
        ├─ ❌ wrong / expired  → error, stay on screen (Resend available)
        │
        └─ ✅ correct
                 │
                 ▼
   Create Firebase Auth user  +  Firestore role/profile docs
                 │
                 ▼
        Routed into the app by role
```

**Key files**
- `lib/services/email_otp_service.dart` — generates the code, sends it through Brevo's transactional email API, and verifies it (10‑minute expiry).
- `lib/otp_verification_page.dart` — reusable verification screen with resend support.
- `lib/signup_student_page.dart`, `lib/signup_teacher_page.dart`, `lib/signup_ism_page.dart` — call `sendOtp(...)` first, then create the account only via the `onVerified` callback.

### Configuration

The Brevo credentials are supplied at build/run time via `--dart-define` (they are **never** hard‑coded in the repo):

```bash
flutter run \
  --dart-define=BREVO_API_KEY=xkeysib-your-key-here \
  --dart-define=BREVO_SENDER_EMAIL=no-reply@yourdomain.com \
  --dart-define=BREVO_SENDER_NAME="CampusConnect"
```

For a web build/deploy:

```bash
flutter build web \
  --dart-define=BREVO_API_KEY=xkeysib-your-key-here \
  --dart-define=BREVO_SENDER_EMAIL=no-reply@yourdomain.com
firebase deploy --only hosting
```

1. Create a free key at **[app.brevo.com](https://app.brevo.com) → SMTP & API → API Keys**.
2. Verify your sender address/domain in Brevo (**Senders & IP**).
3. Pass the values with `--dart-define` as shown above.

> ⚠️ **Security note:** because this is a client‑only Flutter app, the Brevo key ships inside the built bundle. That is fine for a demo/coursework build. For production, move the send‑OTP call behind a small backend (e.g. a Firebase **Cloud Function** / Callable Function) so the API key stays server‑side, and store the OTP hash + expiry in Firestore rather than in memory.

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
   │                                   │  send OTP (Brevo)
   │                                   ▼
   │                          OtpVerificationPage
   │                                   │  verify + create account
   ▼                                   ▼
RoleRouter ── reads `users/{uid}.role` from Firestore
   ├─ student → StudentHome
   ├─ teacher → TeacherHome
   └─ ism     → ISMHome
```

- **`AuthGate` / `RoleRouter`** decide what a signed‑in user sees based on their `role` field in the `users` collection.
- **Login pages** verify the account's role matches the selected role before entering.
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
| **Email / OTP**  | [Brevo](https://www.brevo.com/) transactional email API |
| **Charts**       | [`fl_chart`](https://pub.dev/packages/fl_chart) for analytics dashboards |
| **Local storage**| [`shared_preferences`](https://pub.dev/packages/shared_preferences) (remembers selected role) |
| **Networking**   | [`http`](https://pub.dev/packages/http) (Brevo API calls) |
| **Hosting**      | Firebase Hosting (web build) |
| **Platforms**    | Android · iOS · Web |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.8.1`
- A Firebase project (Auth + Firestore enabled) — this repo is wired to `campusconnecttemp`
- A Brevo account + API key

### Run locally

```bash
# 1. Install dependencies
flutter pub get

# 2. Run with Brevo credentials
flutter run \
  --dart-define=BREVO_API_KEY=xkeysib-your-key-here \
  --dart-define=BREVO_SENDER_EMAIL=no-reply@yourdomain.com
```

### Build & deploy the web app

```bash
flutter build web --dart-define=BREVO_API_KEY=xkeysib-your-key-here
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
├── signup_*_page.dart            # Per-role signup (now OTP-gated)
├── otp_verification_page.dart    # ✉️  Email OTP entry screen
├── services/
│   └── email_otp_service.dart    # ✉️  Brevo send + OTP generate/verify
├── *_home.dart                   # Student / Teacher / ISM dashboards
├── chat_page.dart, group_chat_page.dart, conversations_page.dart  # Messaging
├── *_complaint*.dart             # Complaint raising & tracking
├── ism_analytics_page.dart       # Admin analytics (fl_chart)
└── ...                           # Profiles, groups, notifications
```

---

## 📜 License

This project is for educational / campus use. Add a license file if you intend to distribute it.
