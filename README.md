# E-Ticketing Helpdesk Mobile Application

Aplikasi mobile Flutter untuk sistem e-ticketing helpdesk yang memungkinkan pengguna (customer/user) untuk membuat tiket support dan petugas (admin/helpdesk) untuk mengelola tiket dengan fitur real-time notifications, comments, dan status tracking.

---

## 📋 Daftar Isi

1. [Informasi Umum](#informasi-umum)
2. [Fitur Utama](#fitur-utama)
3. [Teknologi & Package](#teknologi--package)
4. [Struktur Folder & Arsitektur](#struktur-folder--arsitektur)
5. [Data Models](#data-models)
6. [Alur Kerja Aplikasi](#alur-kerja-aplikasi)
7. [Sistem Autentikasi](#sistem-autentikasi)
8. [Database & Backend](#database--backend)
9. [State Management](#state-management)
10. [Routing & Navigation](#routing--navigation)
11. [UI/UX & Theme](#uiux--theme)
12. [Testing](#testing)

---

## 📱 Informasi Umum

- **Nama Aplikasi**: E-Ticketing Helpdesk
- **Platform Target**: Android, iOS, Web, Windows, macOS, Linux
- **Flutter SDK**: ^3.11.0
- **Status**: Development (Version **2.1.0**)
- **Publish**: Tidak dipublikasikan (Private Package)
- **Type**: Multi-platform mobile application dengan role-based access control

---

## 🎯 Fitur Utama

### 1. **Sistem Autentikasi (Authentication & Authorization)**
   - **Login** (FR-001): User dapat login dengan email dan password
   - **Register** (FR-003): User baru dapat membuat akun dengan email, password, dan nama lengkap
   - **Logout**: User dapat keluar dari aplikasi
   - **Reset Password**: User dapat mereset password melalui email
   - **Role-Based Access Control**: Tiga level role:
     - **User**: Pelanggan yang membuat tiket
     - **Helpdesk**: Petugas yang menangani tiket
     - **Admin**: Administrator dengan akses penuh

### 2. **Manajemen Tiket (Ticket Management)**
   - **Buat Tiket** (FR-005): User dapat membuat tiket support dengan:
     - Judul tiket (required)
     - Deskripsi detail (required)
     - Lampiran/File (gambar, pdf, doc, dll - maksimal 5 file) (optional)
     - Status awal: Open
   - **Lihat Daftar Tiket** (FR-010): 
     - **User**: Hanya melihat tiket miliknya sendiri
     - **Helpdesk**: Hanya melihat tiket yang di-assign ke mereka
     - **Admin**: Melihat semua tiket (Dapat difilter berdasarkan Petugas Helpdesk melalui Bottom Sheet Pencarian interaktif)
     - **Hapus Massal (Multi-select Delete)**: Menghapus tiket dengan mode multi-select via *long press*
     - Sorted by created_at (terbaru pertama)
   - **Detail Tiket** (FR-006): 
     - Tampilkan informasi tiket lengkap
     - Informasi penugasan (assigned_to)
   - **Update Status Tiket** (FR-006): Admin/Helpdesk dapat mengubah status:
     - Open → In Progress → Resolved → Closed
   - **Penugasan Tiket** (FR-006): **Admin saja** yang dapat menugaskan tiket ke Helpdesk:
     - Dropdown list Helpdesk tersedia (tidak perlu input ID manual)
     - Notification otomatis ke Helpdesk dan ticket owner
   - **Upload Lampiran**: User dapat upload gambar/file saat membuat tiket

### 3. **Sistem Komentar (Comments)**
   - **Tambah Komentar** (FR-005): User dan Helpdesk dapat menambahkan komentar pada tiket
   - **Lihat Komentar**: Semua pihak terkait dapat melihat komentar
   - **Real-time Updates**: Komentar di-update secara real-time menggunakan PostgreSQL Changes

### 4. **Notifikasi (Notifications)**
   - **Real-time Notifications** (FR-007): 
     - Notifikasi otomatis ketika status tiket berubah
     - Notifikasi ketika tiket ditugaskan
       - Penerima: ticket owner & helpdesk assignee (jika ada)
     - Notifikasi ketika ada komentar baru
       - Penerima: ticket owner (jika bukan yang mengomentari), helpdesk assignee (jika bukan yang mengomentari), dan **semua Admin** (admins dipantau untuk audit/monitoring)
   - **Notification List**: User dapat melihat daftar notifikasi dengan:
     - Badge unread count di AppBar
     - Sorted by created_at (terbaru pertama)
   - **Mark as Read**: User dapat menandai notifikasi sebagai sudah dibaca
   - **Delete Notification**: User dapat menghapus notifikasi
   - **Soft Delete Tiket** (BR-002): Admin dapat menghapus tiket dari sistem secara logic (`is_deleted` = true) untuk menjaga konsistensi audit trail riwayat tiket.
   - **Push Notification Service** (FR-008): 
     - Terintegrasi penuh dengan **Firebase Cloud Messaging (FCM)** untuk push notification di level sistem/OS (terima notifikasi walaupun aplikasi ditutup).
     - Menggunakan **Supabase Edge Functions** (`send-push-notification`) yang dipicu otomatis oleh webhook database PostgreSQL (Database Webhooks) setiap ada notifikasi baru di tabel `notifications`.
     - Notifikasi langsung me-refresh state badge dan data aplikasi saat user membukanya, baik dari background maupun foreground.

### 5. **Profile Management** *(Diperluas)*
   - **Lihat Profile**: User dapat melihat informasi profil mereka:
     - Nama Lengkap (Full Name)
     - Email (read-only)
     - Role
     - Nomor Telepon (opsional)
   - **Edit Profil**: User dapat mengubah:
     - Nama Lengkap
     - Nomor Telepon
     - **Foto Avatar**: Upload foto profil dari Kamera atau Galeri (disimpan di Supabase Storage)
   - **Update Password**: User dapat mengubah password melalui fitur reset password
   - **Logout**: User dapat keluar dari aplikasi

### 6. **Dashboard**
   - **Overview Statistik**:
     - Total tiket
     - Tiket terbuka (Open)
     - Tiket ditugaskan (Assigned)
     - Tiket sedang diproses (In Progress)
     - Tiket selesai (Closed/Resolved)
   - **Quick Actions**:
     - Akses ke daftar tiket
     - Akses ke profile
     - Akses ke notifikasi
   - **Pull-to-Refresh**: User dapat refresh data dengan menarik dari bawah

### 7. **Manajemen Pengguna (User Management)** *(Baru - Admin Only)*
   - Halaman khusus **Admin** untuk mengelola semua pengguna terdaftar
   - **Lihat Daftar Pengguna**: Tampilkan semua user dengan nama, email, role, dan status aktif
   - **Ubah Role**: Admin dapat mengubah role pengguna (User / Helpdesk / Admin) via popup menu
   - **Toggle Aktif/Nonaktif**: Admin dapat menonaktifkan atau mengaktifkan kembali akun pengguna
   - **Proteksi Self-Edit**: Admin tidak dapat mengubah role atau menonaktifkan akun sendiri
   - Avatar user ditampilkan dengan inisial atau foto profil jika ada
   - Route: `/users` (dilindungi, hanya Admin)

### 8. **Tracking Riwayat Tiket (Ticket History)** *(Baru)*
   - Tampilkan riwayat perubahan tiket secara kronologis dalam bentuk **timeline**
   - Mencatat setiap perubahan:
     - **Perubahan Status**: Open → In Progress → Resolved → Closed
     - **Perubahan Assignee**: siapa yang ditugaskan
   - Menampilkan: waktu perubahan, field yang berubah, nilai lama → nilai baru, dan nama user yang mengubah
   - Data diisi otomatis oleh **PostgreSQL Trigger** (`on_ticket_update`) ke tabel `ticket_history`
   - Route: `/ticket/:id/tracking`

### 9. **Pengaturan Aplikasi (Settings)** *(Baru)*
   - **Mode Gelap/Terang**: Toggle dark mode yang disimpan persisten menggunakan `SharedPreferences`
   - **Akses Profil**: Shortcut ke halaman profil
   - **Keluar Akun**: Tombol logout dengan konfirmasi dialog
   - **Informasi Aplikasi**: Versi aplikasi dan informasi developer
   - Route: `/settings`

---

## 🛠️ Teknologi & Package

### Core Framework
- **flutter**: SDK Framework
- **flutter_test**: Testing framework

### State Management & Routing
- **flutter_riverpod** (^2.3.6): State management & dependency injection
- **go_router** (^7.0.0): Navigation & routing dengan deep-link support

### Backend & Database
- **supabase_flutter** (^2.12.4): Backend-as-a-Service untuk authentication, database, storage, dan real-time

### UI & Design
- **cupertino_icons** (^1.0.8): iOS-style icons
- Material Design 3: Built-in dengan Flutter

### Utilities
- **file_picker** (^11.0.2): Untuk memilih semua jenis file (gambar, pdf, dokumen) dari device
- **image_picker** (^1.1.1): Untuk mengambil gambar dari kamera/galeri
- **intl** (^0.20.2): Untuk formatting tanggal, waktu, dan lokalisasi
- **path** (^1.8.3): Untuk manipulasi path file
- **shared_preferences** (^2.1.1): Untuk menyimpan preferensi user secara lokal (tema dark/light)
- **flutter_local_notifications** (^18.0.1): Untuk menampilkan notifikasi lokal pada perangkat saat foreground (dipadukan dengan FCM)
- **firebase_core** (^3.6.0) & **firebase_messaging** (^15.1.3): Untuk integrasi push notification Firebase Cloud Messaging (FCM)

### Development
- **flutter_lints** (^6.0.0): Lint rules untuk code quality
- **flutter_launcher_icons** (^0.14.4): Auto-generate app icons untuk semua platform Android dan iOS

### Build & Compilation
- **gradle** (Android): Build automation tool (konfigurasi di android/build.gradle.kts)
- **Xcode** (iOS): Untuk build di macOS dan iOS

---

## 📁 Struktur Folder & Arsitektur

Aplikasi menggunakan **Clean Architecture** dengan separation of concerns:

```
lib/
├── main.dart                              # Entry point aplikasi
├── core/
│   ├── providers/
│   │   ├── router_provider.dart          # Go Router configuration & routing logic
│   │   ├── auth_provider.dart            # Auth state management (AuthNotifier)
│   │   ├── supabase_provider.dart        # Supabase client instance provider
│   │   └── theme_provider.dart           # [NEW] Dark/Light theme state dengan SharedPreferences
│   ├── theme/
│   │   └── theme.dart                    # Light & Dark theme configuration
│   ├── notification/
│   │   ├── notification_service.dart     # General local notification initialization
│   │   └── fcm_service.dart              # Firebase Cloud Messaging handler (token & listeners)
│   └── utils/
│       └── date_formatter.dart           # Utility untuk format tanggal
├── data/
│   ├── models/
│   │   ├── ticket_model.dart            # Tiket data model dengan fromJson & toJson
│   │   ├── profile_model.dart           # User profile model (+ isActive, phoneNumber, avatarUrl, email)
│   │   ├── comment_model.dart           # Comment data model
│   │   ├── notification_model.dart      # Notification data model
│   │   ├── ticket_attachment_model.dart # [NEW] Model lampiran tiket (dari tabel ticket_attachments)
│   │   └── ticket_history_model.dart    # [NEW] Model riwayat perubahan tiket
│   ├── repositories/
│   │   ├── auth_repository.dart         # Auth business logic (sign in, sign up, logout, update profile)
│   │   ├── ticket_repository.dart       # Ticket CRUD & operations (+ multi-attachment, reporter)
│   │   ├── notification_repository.dart # Notification operations
│   │   ├── history_repository.dart      # [NEW] Ambil riwayat perubahan tiket dari ticket_history
│   │   └── user_repository.dart         # [NEW] Manajemen pengguna oleh Admin (get all, update role, toggle active)
│   └── providers/
│       └── provider.dart                # Riverpod providers untuk state management
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart           # Initial loading screen
│   │   ├── login_screen.dart            # Login page
│   │   ├── register_screen.dart         # Registration page
│   │   ├── reset_password_screen.dart   # Password reset request page
│   │   ├── update_password_screen.dart  # Password reset completion page
│   │   ├── dashboard_screen.dart        # Main dashboard dengan statistik
│   │   ├── profile_screen.dart          # User profile page (+ edit nama, telepon, avatar)
│   │   ├── tickets_list_screen.dart     # List of tickets
│   │   ├── create_ticket_screen.dart    # Create new ticket page (+ multi-attachment, pilih pelapor)
│   │   ├── ticket_detail_screen.dart    # Ticket detail & comments
│   │   ├── notifications_screen.dart    # Notifications list page
│   │   ├── tracking_ticket_screen.dart  # [NEW] Riwayat perubahan tiket (timeline)
│   │   ├── user_management_screen.dart  # [NEW] Kelola pengguna (Admin only)
│   │   └── settings_screen.dart         # [NEW] Pengaturan aplikasi (tema, profil, logout)
│   └── widgets/
│       ├── bottom_refresh_listener.dart # Custom widget untuk pull-to-refresh
│       └── attachment_grid.dart         # [NEW] Grid preview lampiran tiket
├── android/                             # Android native code & build config
├── ios/                                 # iOS native code & build config
├── linux/                               # Linux native code & build config
├── macos/                               # macOS native code & build config
├── web/                                 # Web platform files
├── windows/                             # Windows native code & build config
└── pubspec.yaml                         # Project dependencies & configuration
```

### Arsitektur Layer

**1. Presentation Layer** (`lib/presentation/`)
- Berisi UI screens dan widgets
- Mengkonsumsi state dari Riverpod providers
- Handling user interactions
- Dependent pada data layer melalui providers

**2. Data Layer** (`lib/data/`)
- **Models**: Data structures yang merepresentasikan entities
- **Repositories**: Interface untuk business logic, data fetching, dan manipulation
- **Providers**: Riverpod providers untuk state management dan dependency injection

**3. Core Layer** (`lib/core/`)
- **Providers**: Core state management (auth, router, supabase client)
- **Theme**: Konfigurasi UI theme (light/dark)
- **Notification**: Notification service dan UI components
- **Utils**: Helper functions

---

## 💾 Data Models

### 1. **TicketModel**
```dart
class TicketModel {
  final String id;              // UUID dari Supabase
  final String? userId;         // ID pembuat tiket
  final String title;           // Judul tiket (required)
  final String? description;    // Deskripsi tiket
  final String status;          // Open, In Progress, Resolved, Closed
  final String? imageUrl;       // URL lampiran gambar/file
  final DateTime createdAt;     // Waktu pembuatan
  final String? assignedTo;     // UUID petugas yang ditugaskan
}
```

### 2. **ProfileModel** *(Diperluas)*
```dart
class ProfileModel {
  final String id;              // User ID dari auth.users
  final String? fullName;       // Nama lengkap user
  final String role;            // Role: User, Helpdesk, Admin
  final bool isActive;          // Status aktif akun (default: true)
  final String? phoneNumber;    // Nomor telepon (opsional)
  final String? avatarUrl;      // URL foto profil di Supabase Storage
  final String? email;          // Email user (dari profiles atau auth)
}
```

### 3. **CommentModel**
```dart
class CommentModel {
  final String id;              // UUID komentar
  final String ticketId;        // ID tiket yang dikomentari
  final String? userId;         // ID pembuat komentar
  final String message;         // Isi komentar
  final DateTime createdAt;     // Waktu komentar dibuat
}
```

### 4. **NotificationModel**
```dart
class NotificationModel {
  final String id;              // UUID notifikasi
  final String title;           // Judul notifikasi
  final String message;         // Pesan notifikasi
  final String? ticketId;       // ID tiket terkait (optional)
  final bool isRead;            // Status sudah dibaca
  final DateTime createdAt;     // Waktu notifikasi dibuat
  
  // Helper method untuk display "2h ago" style timestamps
  String timeAgo() { ... }
}
```

### 5. **TicketAttachmentModel** *(Baru)*
```dart
class TicketAttachmentModel {
  final String id;              // UUID lampiran
  final String ticketId;        // ID tiket terkait
  final String fileUrl;         // URL publik file di Supabase Storage
  final String? fileName;       // Nama file asli
  final int? fileSize;          // Ukuran file dalam bytes
  final DateTime createdAt;     // Waktu upload
}
```

### 6. **TicketHistoryModel** *(Baru)*
```dart
class TicketHistoryModel {
  final String id;              // UUID entri history
  final String ticketId;        // ID tiket yang berubah
  final String? changedBy;      // UUID user yang melakukan perubahan
  final String fieldChanged;    // Field yang berubah: 'status', 'assigned_to', dst.
  final String? oldValue;       // Nilai sebelum perubahan
  final String? newValue;       // Nilai setelah perubahan
  final DateTime createdAt;     // Waktu perubahan
  
  // Human-readable label
  String get fieldLabel { ... } // 'Status', 'Assignee', dst.
}
```

### 7. **AuthState** (State Management)
```dart
class AuthState {
  final User? user;             // Supabase User object
  final String? username;       // Nama user dari profile
  final String role;            // Role user
  final bool isLoading;         // Loading indicator
  final String? error;          // Error message
  final String? phoneNumber;    // Nomor telepon user
  final String? avatarUrl;      // URL foto profil user
}
```

---

## 🔄 Alur Kerja Aplikasi

### **User Journey - Membuat Tiket (Happy Path)**

1. **Splash Screen**: Muncul saat aplikasi dimulai
   - Cek session user dari Supabase auth
   - Redirect ke login atau dashboard

2. **Login/Register**: User autentikasi
   - Email & Password validation
   - Profile data di-fetch dari `profiles` table
   - Role ditentukan dari Supabase

3. **Dashboard**: Landing page setelah login
   - Tampilkan greeting dengan username
   - Statistik tiket (Total, Open, In Progress, Closed)
   - Button untuk buat tiket (hanya untuk users)
   - Notification badge dengan unread count

4. **Create Ticket**: User membuat tiket baru
   - Input: Title (required), Description (required)
   - Optional: **Upload hingga 5 lampiran gambar** (kamera atau galeri)
   - Lampiran di-upload ke Supabase Storage (tabel `ticket_attachments`)
   - **Helpdesk/Admin** wajib memilih **pelapor (user)** dari dropdown saat membuat tiket atas nama user
   - Tiket disimpan dengan status "Open"
   - Auto-refresh tickets list

5. **Tickets List**: Tampilkan daftar tiket
   - **User**: Hanya tiket miliknya sendiri
   - **Helpdesk**: Hanya tiket yang di-assign ke mereka
   - **Admin**: Semua tiket
   - Sorted by created_at (terbaru pertama)
   - Tap untuk buka detail

6. **Ticket Detail**: Detail tiket & comments
  - Tampilkan informasi tiket lengkap
  - List comments dengan user info
  - User/Helpdesk dapat add comment
  - **Admin dapat**: ubah status, assign tiket ke Helpdesk
  - **Helpdesk dapat**: ubah status tiket mereka
  - Setiap action trigger notification otomatis:
    - Comment: notifikasi dikirim ke ticket owner (kecuali komentator), helpdesk assignee (jika ada dan bukan komentator), dan semua Admin
    - Assign: notifikasi dikirim ke ticket owner dan helpdesk assignee
    - Status update: notifikasi dikirim ke ticket owner dan assignee

### **Real-time Features**

```
User A membuat/edit tiket
    ↓
Supabase PostgreSQL Changes event
    ↓
Real-time stream di client
    ↓
Riverpod provider update
    ↓
UI refresh otomatis (jika listener aktif)
```

---

## 🔐 Sistem Autentikasi

### **Authentication Flow**

```
Email + Password
    ↓
supabase.auth.signInWithPassword() / signUp()
    ↓
Supabase Auth menerbitkan JWT token
    ↓
AuthRepository menyimpan token di secure storage
    ↓
AuthNotifier update state (user, username, role)
    ↓
GoRouter redirect ke dashboard
```

### **Authorization (Role-Based Access Control)**

| Feature | User | Helpdesk | Admin |
|---------|------|----------|-------|
| Buat Tiket (atas nama sendiri) | ✅ | ❌ | ❌ |
| **Buat Tiket atas nama User** | ❌ | ✅ | ✅ |
| Lihat Tiket Milik Sendiri | ✅ | ❌ | ❌ |
| Lihat Tiket Assign ke Mereka | ❌ | ✅ | ❌ |
| Lihat Semua Tiket | ❌ | ❌ | ✅ |
| Ubah Status Tiket | ❌ | ✅ | ✅ |
| **Assign Tiket** | ❌ | ❌ | ✅ |
| Comment Tiket | ✅ | ✅ | ✅ |
| Lihat Notifications | ✅ | ✅ | ✅ |
| **Kelola Pengguna (User Management)** | ❌ | ❌ | ✅ |
| **Tracking Riwayat Tiket** | ✅ | ✅ | ✅ |
| **Ubah Role Pengguna** | ❌ | ❌ | ✅ |
| **Nonaktifkan Pengguna** | ❌ | ❌ | ✅ |

### **Password Reset Flow**

1. User klik "Lupa Password?" di login screen
2. Masukkan email → `supabase.auth.resetPasswordForEmail()`
3. Supabase kirim email dengan reset link
4. User klik link → deep-link ke app dengan `code` query parameter
5. GoRouter detect code → redirect ke `/reset-callback?code=...`
6. UpdatePasswordScreen: User masukkan password baru
7. `supabase.auth.updateUser()` update password
8. Auto redirect ke login

---

## 🗄️ Database & Backend

### **Backend Service**: Supabase (Backend-as-a-Service)

#### **Inisialisasi di main.dart**
```dart
await Supabase.initialize(
  url: 'https://xfnwlwbdlepsunsvkfen.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

#### **Database Tables**

1. **auth.users** (Supabase built-in)
   - id (UUID)
   - email
   - password_hash
   - metadata (JSON)

2. **profiles** (Custom table)
   ```sql
   id (UUID, PK, FK to auth.users)
   full_name (text)
   role (text) CHECK (role IN ('User', 'Helpdesk', 'Admin'))
   is_active (boolean, default true) -- Status aktif akun
   phone_number (text, nullable)     -- Nomor telepon
   avatar_url (text, nullable)       -- URL foto profil di Supabase Storage
   email (text, nullable)            -- Email (sinkron dari auth.users)
   created_at (timestamp)
   ```

3. **tickets** (Custom table)
   ```sql
   id (UUID, PK)
   user_id (UUID, FK to profiles)
   title (text)
   description (text)
   status (text) CHECK (status IN ('Open', 'In Progress', 'Resolved', 'Closed'))
   image_url (text)              -- legacy, digantikan ticket_attachments
   assigned_to (UUID, FK to profiles)
   created_at (timestamp)
   ```

4. **comments** (Custom table)
   ```sql
   id (UUID, PK)
   ticket_id (UUID, FK to tickets)
   user_id (UUID, FK to profiles)
   message (text)
   created_at (timestamp)
   ```

5. **notifications** (Custom table)
   ```sql
   id (UUID, PK)
   user_id (UUID, FK to profiles)
   title (text)
   message (text)
   ticket_id (UUID, FK to tickets, nullable)
   is_read (boolean)
   created_at (timestamp)
   ```

6. **ticket_attachments** (Custom table) *(Baru)*
   ```sql
   id (UUID, PK)
   ticket_id (UUID, FK to tickets)
   file_url (text)               -- URL publik di Supabase Storage
   file_name (text, nullable)    -- Nama file asli
   file_size (integer, nullable) -- Ukuran file dalam bytes
   created_at (timestamp)
   ```

7. **ticket_history** (Custom table) *(Baru)*
   ```sql
   id (UUID, PK)
   ticket_id (UUID, FK to tickets)
   changed_by (UUID, FK to profiles, nullable) -- User yang melakukan perubahan
   field_changed (text)          -- Field yang berubah: 'status', 'assigned_to', dst.
   old_value (text, nullable)    -- Nilai sebelum perubahan
   new_value (text, nullable)    -- Nilai sesudah perubahan
   created_at (timestamp)
   -- Diisi otomatis oleh PostgreSQL Trigger: on_ticket_update
   ```

#### **Storage Buckets**

- **tickets** bucket: Menyimpan attachments
  - Path: `attachments/{userId}_{timestamp}_{filename}`
  - Permissions: Authenticated users dapat upload
  - Public URL untuk read access

#### **Row Level Security (RLS)**

- Users hanya dapat melihat tiket mereka sendiri atau (jika admin/helpdesk) semua tiket
- Users hanya dapat melihat notifications mereka
- Comments hanya visible untuk owner, ticket creator, dan assignee

#### **Real-time Subscriptions**

```dart
// Listen to notification changes
_supabase
    .channel('public:notifications')
    .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        // Handle new notification
      },
    )
    .subscribe();
```

---

## 🎛️ State Management

### **Technology**: Riverpod (flutter_riverpod ^2.3.6)

Riverpod dipilih karena:
- ✅ Compile-time safety (tidak seperti Provider)
- ✅ Easy dependency injection
- ✅ Support untuk FutureProvider, StreamProvider, StateNotifier
- ✅ Auto-caching dan refresh management

### **Provider Types**

#### **1. Plain Providers** (Dependencies)
```dart
// Repository instances
final authRepoProvider = Provider((ref) => AuthRepository(...));
final ticketRepoProvider = Provider((ref) => TicketRepository(...));

// Singleton services
final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);
final notificationServiceProvider = Provider((ref) => NotificationService(...));
```

#### **2. StateNotifierProvider** (Mutable State)
```dart
// Auth state management
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepoProvider);
  final supabase = ref.watch(supabaseProvider);
  return AuthNotifier(repo, supabase);
});

// Usage: ref.read(authNotifierProvider.notifier).login(email, password)
```

#### **3. FutureProvider** (Async Data - Single Load)
```dart
// Tickets list dengan filter berdasarkan role
final ticketsStreamProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final repo = ref.watch(ticketRepoProvider);
  final auth = ref.watch(authNotifierProvider);

  final role = auth.role.toLowerCase();
  
  // Admin: lihat semua tiket
  if (role == 'admin') {
    return await repo.getTickets();
  }
  
  // Helpdesk: hanya lihat tiket yang di-assign ke mereka
  if (role == 'helpdesk' && user != null) {
    return await repo.getTicketsAssignedToHelpdesk(user.id);
  }

  // User: hanya lihat tiket milik sendiri
  return await repo.getTicketsForUser(user!.id);
});

// Helpdesk users list untuk dropdown assign
final helpdeskUsersProvider = FutureProvider.autoDispose<List<ProfileModel>>((ref) {
  final repo = ref.watch(authRepoProvider);
  return repo.getHelpdeskUsers();
});

// Daftar admin (untuk notifikasi)
final adminUsersProvider = FutureProvider.autoDispose<List<ProfileModel>>((ref) {
  final repo = ref.watch(authRepoProvider);
  return repo.getAdminUsers();
});

// Daftar semua pengguna (untuk User Management screen)
final userListProvider = FutureProvider.autoDispose<List<ProfileModel>>((ref) {
  final repo = ref.watch(userRepoProvider);
  return repo.getAllUsers();
});

// Dropdown pelapor: user aktif dengan role 'User' (untuk Helpdesk/Admin create ticket)
final userListForDropdownProvider = FutureProvider.autoDispose<List<ProfileModel>>((ref) {
  final repo = ref.watch(userRepoProvider);
  return repo.getUsersWithRoleUser();
});

// History perubahan tiket per ticketId
final ticketHistoryProvider = FutureProvider.autoDispose.family<List<TicketHistoryModel>, String>((ref, ticketId) {
  final repo = ref.watch(historyRepoProvider);
  return repo.getTicketHistory(ticketId);
});

// Lampiran tiket per ticketId
final attachmentsProvider = FutureProvider.autoDispose.family<List<TicketAttachmentModel>, String>((ref, ticketId) {
  final repo = ref.watch(ticketRepoProvider);
  return repo.getAttachments(ticketId);
});

// Usage: ref.watch(ticketsStreamProvider) → AsyncValue<List<dynamic>>
//        ref.watch(helpdeskUsersProvider) → AsyncValue<List<ProfileModel>>
```

#### **4. StreamProvider** (Real-time Data)
```dart
// Real-time notifications
final notificationsStreamProvider = StreamProvider.autoDispose<List<NotificationModel>>((ref) {
  final repo = ref.watch(notificationRepoProvider);
  final user = ref.watch(authNotifierProvider).user;
  return repo.getNotificationsStream(user!.id);
});

// Real-time comments
final commentsProvider = StreamProvider.autoDispose.family<List<CommentModel>, String>((ref, ticketId) {
  final repo = ref.watch(ticketRepoProvider);
  return repo.getCommentsStream(ticketId);
});
```

#### **5. Family Providers** (Parameterized)
```dart
// Fetch profile by ID
final profileProvider = FutureProvider.family<ProfileModel?, String>((ref, id) {
  final repo = ref.watch(authRepoProvider);
  return repo.getProfileById(id);
});

// Usage: ref.watch(profileProvider(userId))
```

### **AsyncValue Handling** (UI Pattern)

```dart
ticketsAsync.when(
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
  data: (tickets) => ListView(...),
);
```

### **Invalidate & Refresh**

```dart
// Force refresh data
ref.invalidate(ticketsStreamProvider);

// Auto-dispose saat widget unmount
final autoDisposeProvider = FutureProvider.autoDispose(...)
```

---

## 🧭 Routing & Navigation

### **Technology**: Go Router (go_router ^7.0.0)

#### **Route Configuration**

```dart
GoRouter(
  initialLocation: '/splash',
  
  // Global redirect logic untuk auth & deep-links
  redirect: (context, state) {
    final auth = ref.read(authNotifierProvider);
    final isLoggedIn = ref.read(supabaseProvider).auth.currentSession != null;
    
    // Deep-link handling untuk password reset
    if (uri.queryParameters.containsKey('code')) {
      return '/reset-callback?${uri.query}';
    }
    
    // Auth guard
    if (!isLoggedIn && !isAuthPage) return '/login';
    if (isLoggedIn && isAuthPage) return '/dashboard';
    
    return null;
  },
  
  routes: [
    GoRoute(path: '/splash', builder: (ctx, state) => SplashScreen()),
    GoRoute(path: '/login', builder: (ctx, state) => LoginScreen()),
    GoRoute(path: '/register', builder: (ctx, state) => RegisterScreen()),
    GoRoute(path: '/dashboard', builder: (ctx, state) => DashboardScreen()),
    GoRoute(
      path: '/ticket/:id',
      builder: (ctx, state) {
        final id = state.pathParameters['id']!;
        return TicketDetailScreen(id: id);
      },
    ),
    // ... other routes
  ],
);
```

#### **Route List**

| Route | Screen | Role | Purpose |
|-------|--------|------|---------|
| `/` | SplashScreen | All | Initial load |
| `/splash` | SplashScreen | All | Loading indicator |
| `/login` | LoginScreen | Guest | Login page |
| `/register` | RegisterScreen | Guest | Registration |
| `/reset` | ResetPasswordScreen | Guest | Reset password request |
| `/reset-callback` | UpdatePasswordScreen | Guest | Reset password completion |
| `/dashboard` | DashboardScreen | Authenticated | Main dashboard |
| `/profile` | ProfileScreen | Authenticated | User profile (edit nama, telepon, avatar) |
| `/notifications` | NotificationsScreen | Authenticated | Notifications list |
| `/tickets` | TicketsListScreen | Authenticated | Tickets list |
| `/create-ticket` | CreateTicketScreen | Authenticated | Create new ticket (+ pilih pelapor) |
| `/ticket/:id` | TicketDetailScreen | Authenticated | Ticket details |
| `/ticket/:id/tracking` | TrackingTicketScreen | Authenticated | **[Baru]** Riwayat perubahan tiket |
| `/users` | UserManagementScreen | Admin only | **[Baru]** Kelola pengguna |
| `/settings` | SettingsScreen | Authenticated | **[Baru]** Pengaturan aplikasi |

#### **Navigation Examples**

```dart
// Push to new screen
context.push('/profile');

// Go to screen (replace current)
context.go('/dashboard');

// Deep-link
context.go('/ticket/abc-123');

// With parameters
context.push('/ticket/${ticketId}');
```

---

## 🎨 UI/UX & Theme

### **Design System**: Material Design 3

#### **Theme Configuration** (`core/theme/theme.dart`)

```dart
class AppThemes {
  static const primaryColor = Colors.blueAccent;
  
  // Light Theme
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: primaryColor,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
  
  // Dark Theme (similar configuration)
  static final dark = ThemeData(...);
}
```

#### **Key UI Components**

1. **AppBar**: Centered title, blue accent background
2. **Input Fields**: Outlined border dengan border radius 12
3. **Buttons**: Full-width elevated button dengan consistent styling
4. **Notification Badge**: Red circular badge di notification icon
5. **Forms**: Validation feedback dengan error messages
6. **Refresh**: Pull-to-refresh listener di dashboard & tickets list
7. **Role Badge**: Badge warna berbeda untuk setiap role (Admin=merah, Helpdesk=oranye, User=biru)
8. **Active Badge**: Badge Aktif/Nonaktif di User Management screen
9. **Timeline**: Visual timeline entry di Tracking screen

#### **Custom Widgets**

```dart
// BottomRefreshListener: Pull-to-refresh functionality
// Digunakan di DashboardScreen untuk refresh tickets
class BottomRefreshListener extends StatelessWidget {
  final Function() onBottomReached;
  final Widget child;
  
  @override
  Widget build(context) {
    // Listen saat user scroll ke bawah
    // Trigger refresh pada Riverpod provider
  }
}

// NotificationBanner: Floating notification display
// Dipetik ketika ada status change atau action event

// AttachmentGrid: Grid preview lampiran tiket [NEW]
// Digunakan di CreateTicketScreen & TicketDetailScreen
// Menampilkan thumbnail gambar dengan tombol hapus
```

---

## 🧪 Testing

### **Test Framework**: Flutter Test (flutter_test)

#### **Test Files**

1. **widget_test.dart**: Basic smoke test
   - Verifikasi MyApp dapat build tanpa error
   - Test Go Router integration dengan override
   - Use Riverpod ProviderScope untuk testing

2. **auth_flow_test.dart**: Authentication flow tests
   - Fake Auth Notifier untuk testing tanpa network
   - Test login flow
   - Test register flow
   - Test navigation setelah auth

#### **Testing Pattern**

```dart
// Fake repository untuk testing
class FakeAuthRepo implements AuthRepoInterface {
  @override
  Future<AuthResponse> signIn(...) async => throw UnimplementedError();
  @override
  Future<AuthResponse> signUp(...) async => throw UnimplementedError();
}

// Custom notifier untuk testing
class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier() : super(FakeAuthRepo(), null, skipInit: true);
  
  @override
  Future<bool> login(String email, String password) async {
    state = state.copyWith(username: 'Test User');
    return true;
  }
}

// Usage di test
testWidgets('Login flow test', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authNotifierProvider.overrideWithValue(FakeAuthNotifier())],
      child: MyApp(),
    ),
  );
  
  // Test widget interactions
  expect(find.byType(LoginScreen), findsOneWidget);
});
```

### **Testing Strategy**

- ✅ Widget tests untuk UI components
- ✅ Unit tests untuk repositories & models (dengan Supabase mocks)
- ⚠️ Integration tests untuk real-time features (memerlukan test Supabase instance)

---

## 🚀 Build & Deployment

### **Android Build**

```bash
flutter build apk          # Build APK
flutter build appbundle    # Build App Bundle untuk Play Store
```

Build configuration: `android/app/build.gradle.kts`
- Target SDK: Latest (dari build.gradle.kts)
- Min SDK: Sesuai Flutter requirements

### **iOS Build**

```bash
flutter build ios          # Build untuk development
flutter build ipa          # Build untuk App Store
```

Build configuration: `ios/Runner.xcodeproj`
- Xcode workspace di `ios/Runner.xcworkspace`

### **Platform Support**

- ✅ Android (build/android/)
- ✅ iOS (build/ios/)
- ✅ Web (build/web/)
- ✅ Windows (build/windows/)
- ✅ macOS (build/macos/)
- ✅ Linux (build/linux/)

---

## 📊 Database Schema Summary

```
AUTH.USERS (Supabase built-in)
├── id (UUID, PK)
├── email
└── metadata (JSON)

PROFILES
├── id (UUID, PK, FK)
├── full_name (text)
├── role (enum: User, Helpdesk, Admin)
├── is_active (boolean, default true)   [NEW]
├── phone_number (text, nullable)        [NEW]
├── avatar_url (text, nullable)          [NEW]
├── email (text, nullable)               [NEW]
└── created_at

TICKETS
├── id (UUID, PK)
├── user_id (UUID, FK)
├── title (text)
├── description (text)
├── status (enum: Open, In Progress, Resolved, Closed)
├── image_url (text)   -- legacy
├── assigned_to (UUID, FK)
└── created_at

COMMENTS
├── id (UUID, PK)
├── ticket_id (UUID, FK)
├── user_id (UUID, FK)
├── message (text)
└── created_at

NOTIFICATIONS
├── id (UUID, PK)
├── user_id (UUID, FK)
├── title (text)
├── message (text)
├── ticket_id (UUID, FK, nullable)
├── is_read (boolean)
└── created_at

TICKET_ATTACHMENTS  [NEW]
├── id (UUID, PK)
├── ticket_id (UUID, FK)
├── file_url (text)
├── file_name (text, nullable)
├── file_size (integer, nullable)
└── created_at

TICKET_HISTORY  [NEW]
├── id (UUID, PK)
├── ticket_id (UUID, FK)
├── changed_by (UUID, FK, nullable)
├── field_changed (text)
├── old_value (text, nullable)
├── new_value (text, nullable)
└── created_at
-- Diisi otomatis oleh PostgreSQL Trigger: on_ticket_update
```

---

## 📦 Dependencies Quick Reference

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Core framework |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |
| `go_router` | ^7.0.0 | Navigation & routing |
| `supabase_flutter` | ^2.12.4 | Backend & auth |
| `flutter_riverpod` | ^2.3.6 | State management |
| `intl` | ^0.20.2 | Date & localization |
| `image_picker` | ^1.1.1 | Image selection & avatar upload |
| `path` | ^1.8.3 | Path utilities |
| `shared_preferences` | ^2.1.1 | **[NEW]** Simpan preferensi tema lokal |
| `flutter_local_notifications` | ^18.0.1 | Push notification lokal |
| `firebase_core` & `firebase_messaging` | latest | Push notification OS via FCM |
| `flutter_launcher_icons` | ^0.14.4 | (Dev) Auto-generate logo/ikon aplikasi |
| `flutter_lints` | ^6.0.0 | (Dev) Code quality linting |

---

## 🔗 Key Files to Review

- **Entry Point**: [lib/main.dart](lib/main.dart)
- **Auth Logic**: [lib/data/repositories/auth_repository.dart](lib/data/repositories/auth_repository.dart)
- **Ticket Logic**: [lib/data/repositories/ticket_repository.dart](lib/data/repositories/ticket_repository.dart)
- **Routing**: [lib/core/providers/router_provider.dart](lib/core/providers/router_provider.dart)
- **State Management**: [lib/data/providers/provider.dart](lib/data/providers/provider.dart)
- **Theme**: [lib/core/theme/theme.dart](lib/core/theme/theme.dart)
- **Theme Provider**: [lib/core/providers/theme_provider.dart](lib/core/providers/theme_provider.dart) *(Baru)*
- **User Management**: [lib/presentation/screens/user_management_screen.dart](lib/presentation/screens/user_management_screen.dart) *(Baru)*
- **Ticket Tracking**: [lib/presentation/screens/tracking_ticket_screen.dart](lib/presentation/screens/tracking_ticket_screen.dart) *(Baru)*
- **Settings**: [lib/presentation/screens/settings_screen.dart](lib/presentation/screens/settings_screen.dart) *(Baru)*
- **History Repo**: [lib/data/repositories/history_repository.dart](lib/data/repositories/history_repository.dart) *(Baru)*
- **User Repo**: [lib/data/repositories/user_repository.dart](lib/data/repositories/user_repository.dart) *(Baru)*
- **Screens**: [lib/presentation/screens/](lib/presentation/screens/)

---

## 📝 Catatan Pengembangan

### **Fitur yang Sudah Diimplementasikan**
- ✅ Multi-platform support (Android, iOS, Web, Windows, macOS, Linux)
- ✅ Supabase authentication & authorization
- ✅ Role-based access control (User, Helpdesk, Admin)
- ✅ Ticket CRUD operations dengan role-based filtering:
  - User hanya lihat tiket miliknya
  - Helpdesk hanya lihat tiket yang di-assign ke mereka
  - Admin lihat semua tiket
- ✅ **Admin-only ticket assignment** dengan dropdown Helpdesk list
- ✅ Real-time notifications & comments
  - ✅ **Admin menerima notifikasi** untuk tiket baru dan semua komentar (monitoring & audit)
  - ✅ **Helpdesk menerima notifikasi** ketika tiket di-assign ke mereka dan ketika ada komentar pada tiket yang mereka tangani
- ✅ **Multi-attachment upload** (hingga 5 lampiran per tiket) ke tabel `ticket_attachments`
- ✅ Password reset dengan deep-link support
- ✅ **Dark mode** dengan persistensi via `SharedPreferences` (toggle di Settings)
- ✅ Pull-to-refresh functionality
- ✅ Notification badge dengan unread count
- ✅ **User Management** (Admin only): lihat semua user, ubah role, toggle aktif/nonaktif
- ✅ **Ticket History Tracking**: timeline riwayat perubahan status & assignee via PostgreSQL trigger
- ✅ **Profile Update**: edit nama, nomor telepon, dan upload foto avatar
- ✅ **Settings Screen**: toggle dark mode, akses profil, logout
- ✅ **Helpdesk/Admin dapat membuat tiket** atas nama user (dengan dropdown pilih pelapor)
- ✅ Integrasi **Firebase Cloud Messaging (FCM)** untuk system-level push notification
- ✅ **Supabase Edge Functions** (Database Webhooks) untuk mengirim notifikasi push secara otomatis
- ✅ Kustomisasi **App Name** dan **App Logo** menggunakan `flutter_launcher_icons`
- ✅ **File Attachment Lengkap** (FR-005): Mendukung lampiran berupa PDF, DOCX, dan format lainnya.
- ✅ **Soft Delete Tiket** (BR-002): Penghapusan tiket khusus Admin tanpa merusak riwayat tiket.
- ✅ **Dashboard "Assigned" Stat**: Menampilkan metrik khusus untuk tiket yang telah ditugaskan.
- ✅ **Helpdesk Filter** (FR-007): Admin dapat menyaring daftar tiket berdasarkan petugas Helpdesk yang menangani.

### **Potential Improvements**
- 🔲 APNs untuk iOS push notifications (memerlukan Apple Developer Account)
- 🔲 Offline support dengan local caching
- 🔲 Advanced search & filtering tiket
- 🔲 File attachment types selain gambar (PDF, DOC, etc)
- 🔲 Ticket priority levels (Low, Medium, High, Critical)
- 🔲 SLA tracking & escalation otomatis
- 🔲 Email notifications
- 🔲 Analytics & reporting dashboard
- 🔲 Pagination untuk daftar tiket & notifikasi
- 🔲 Ekspor laporan tiket (PDF/Excel)

---

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Docs](https://supabase.com/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [Go Router Guide](https://pub.dev/packages/go_router)

---

## 📝 Implementation Notes

### **Recent Changes (v1.0.0 Updates)**

#### **1. Role-Based Ticket Visibility**
- **User**: Lihat hanya tiket yang mereka buat sendiri
- **Helpdesk**: Lihat hanya tiket yang di-assign ke mereka (implementasi di `TicketRepository.getTicketsAssignedToHelpdesk()`)
- **Admin**: Lihat semua tiket
- **Implementation**: Logic di `ticketsStreamProvider` (provider.dart) yang check role dan call method yang sesuai

#### **2. Admin-Only Ticket Assignment**
- Hanya **Admin** yang dapat assign tiket ke Helpdesk
- UI Change: Dropdown selection dengan Helpdesk list (tidak perlu input ID manual)
- **New Provider**: `helpdeskUsersProvider` - FutureProvider yang fetch list all Helpdesk users
- **New Repository Method**: `AuthRepository.getHelpdeskUsers()` - query profiles dengan role = 'Helpdesk'
- **Updated Screen**: `ticket_detail_screen.dart` - dropdown dialog untuk assign, hanya visible untuk Admin

#### **3. Admin Notifications**
- `TicketRepository.createTicket()` mengirim notifikasi ke semua users dengan role `Admin` saat tiket baru dibuat.
- `TicketRepository.addComment()` menambahkan semua Admin sebagai penerima notifikasi ketika ada komentar baru.
- `AuthRepository.getAdminUsers()` ditambahkan untuk mengambil daftar Admin dari tabel `profiles`.

---

### **Recent Changes (v2.0.0 Updates)**

#### **1. User Management (Admin)**
- Halaman baru `/users` untuk Admin mengelola semua pengguna
- Admin dapat mengubah role (User/Helpdesk/Admin) dan toggle aktif/nonaktif akun
- **New Files**: `user_management_screen.dart`, `user_repository.dart`
- **New Providers**: `userRepoProvider`, `userListProvider`
- **DB Changes**: Kolom `is_active` ditambahkan ke tabel `profiles`

#### **2. Ticket History Tracking**
- Timeline riwayat perubahan status dan assignee tiket di halaman `/ticket/:id/tracking`
- Data diisi otomatis oleh **PostgreSQL Trigger** `on_ticket_update` ke tabel `ticket_history`
- **New Files**: `tracking_ticket_screen.dart`, `history_repository.dart`, `ticket_history_model.dart`
- **New Providers**: `historyRepoProvider`, `ticketHistoryProvider`
- **DB Changes**: Tabel baru `ticket_history`

#### **3. Multi-Attachment Upload**
- Tiket sekarang mendukung hingga **5 lampiran gambar** per tiket
- Lampiran disimpan di tabel baru `ticket_attachments` (bukan field `image_url` lagi)
- **New Files**: `ticket_attachment_model.dart`, `attachment_grid.dart` widget
- **New Providers**: `attachmentsProvider`
- **DB Changes**: Tabel baru `ticket_attachments`

#### **4. Profile Update**
- User kini dapat mengedit nama lengkap, nomor telepon, dan foto avatar
- Avatar diupload ke Supabase Storage
- **Updated**: `profile_screen.dart`, `auth_repository.dart` (tambah `uploadAvatar()`, `updateProfile(phoneNumber)`)
- **DB Changes**: Kolom `phone_number`, `avatar_url`, `email` ditambahkan ke tabel `profiles`

#### **5. Settings Screen & Theme Persistence**
- Halaman pengaturan baru di `/settings` dengan toggle dark/light mode
- Preferensi tema disimpan persisten menggunakan `SharedPreferences`
- **New Files**: `settings_screen.dart`, `theme_provider.dart`
- **New Package**: `shared_preferences ^2.1.1`

#### **6. Helpdesk/Admin Create Ticket**
- Helpdesk dan Admin kini dapat membuat tiket atas nama user lain
- Dropdown pilih pelapor (user aktif dengan role 'User') ditambahkan di `create_ticket_screen.dart`
- **New Provider**: `userListForDropdownProvider`

#### **7. flutter_local_notifications**
- Package `flutter_local_notifications ^18.0.1` ditambahkan untuk notifikasi lokal
- **New Package**: `flutter_local_notifications ^18.0.1`

#### **8. Files Added/Modified (v2.0.0)**
| File | Status | Keterangan |
|------|--------|------------|
| `lib/core/providers/theme_provider.dart` | **NEW** | ThemeModeNotifier dengan SharedPreferences |
| `lib/data/models/ticket_attachment_model.dart` | **NEW** | Model lampiran tiket |
| `lib/data/models/ticket_history_model.dart` | **NEW** | Model riwayat perubahan tiket |
| `lib/data/repositories/history_repository.dart` | **NEW** | Ambil ticket_history dari Supabase |
| `lib/data/repositories/user_repository.dart` | **NEW** | Manajemen pengguna (Admin) |
| `lib/presentation/screens/settings_screen.dart` | **NEW** | Halaman pengaturan |
| `lib/presentation/screens/user_management_screen.dart` | **NEW** | Kelola pengguna (Admin only) |
| `lib/presentation/screens/tracking_ticket_screen.dart` | **NEW** | Timeline riwayat tiket |
| `lib/presentation/widgets/attachment_grid.dart` | **NEW** | Widget grid preview lampiran |
| `lib/data/providers/provider.dart` | Modified | Tambah historyRepoProvider, userRepoProvider, ticketHistoryProvider, attachmentsProvider, userListProvider, userListForDropdownProvider |
| `lib/core/providers/router_provider.dart` | Modified | Tambah route /ticket/:id/tracking, /users, /settings |
| `lib/data/models/profile_model.dart` | Modified | Tambah isActive, phoneNumber, avatarUrl, email |
| `lib/presentation/screens/profile_screen.dart` | Modified | Edit nama, telepon, upload avatar |
| `lib/presentation/screens/create_ticket_screen.dart` | Modified | Multi-attachment, dropdown pelapor |
| `pubspec.yaml` | Modified | Tambah shared_preferences, flutter_local_notifications |

---

### **Recent Changes (v2.1.0 Updates)**

#### **1. Firebase Cloud Messaging (FCM) Integration**
- Push notification level OS (sistem) agar notifikasi masuk walaupun aplikasi ditutup/background.
- Badge dashboard dan stream di-invalidate secara instan jika notifikasi masuk saat aplikasi foreground.
- **New Files**: `lib/core/notification/fcm_service.dart`.
- **Packages**: `firebase_core`, `firebase_messaging`.
- **Backend**: Menggunakan **Supabase Edge Functions** (`send-push-notification`) yang dipicu oleh Webhook ke tabel `notifications`.

#### **2. App Branding & Logo**
- Merubah nama aplikasi menjadi **E-Ticketing Helpdesk**.
- Membuat launcher icon (logo aplikasi) otomatis menggunakan package `flutter_launcher_icons`.

---

**Dibuat untuk: Dokumentasi Laporan Pembuatan Aplikasi E-Ticketing Helpdesk**
**Last Updated**: Juli 3, 2026 (v2.1.0)
