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
- **Status**: Development (Version 1.0.0+1)
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
     - Lampiran/Gambar (optional)
     - Status awal: Open
   - **Lihat Daftar Tiket** (FR-010): 
     - **User**: Hanya melihat tiket miliknya sendiri
     - **Helpdesk**: Hanya melihat tiket yang di-assign ke mereka
     - **Admin**: Melihat semua tiket
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
   - **Push Notification Service** (FR-008): Menggunakan PostgreSQL real-time subscription

### 5. **Profile Management**
   - **Lihat Profile**: User dapat melihat informasi profil mereka:
     - Nama Lengkap (Full Name)
     - Email
     - Role
   - **Update Password**: User dapat mengubah password melalui fitur reset password
   - **Logout**: User dapat keluar dari aplikasi

### 6. **Dashboard**
   - **Overview Statistik**:
     - Total tiket
     - Tiket terbuka (Open)
     - Tiket sedang diproses (In Progress)
     - Tiket selesai (Closed/Resolved)
   - **Quick Actions**:
     - Akses ke daftar tiket
     - Akses ke profile
     - Akses ke notifikasi
   - **Pull-to-Refresh**: User dapat refresh data dengan menarik dari bawah

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
- **image_picker** (^1.1.1): Untuk memilih dan mengambil gambar dari device
- **intl** (^0.20.2): Untuk formatting tanggal, waktu, dan lokalisasi
- **path** (^1.8.3): Untuk manipulasi path file

### Development
- **flutter_lints** (^6.0.0): Lint rules untuk code quality

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
│   │   └── supabase_provider.dart        # Supabase client instance provider
│   ├── theme/
│   │   └── theme.dart                    # Light & Dark theme configuration
│   ├── notification/
│   │   ├── notification_service.dart     # Real-time notification service
│   │   └── notification_banner.dart      # Notification UI banner widget
│   └── utils/
│       └── date_formatter.dart           # Utility untuk format tanggal
├── data/
│   ├── models/
│   │   ├── ticket_model.dart            # Tiket data model dengan fromJson & toJson
│   │   ├── profile_model.dart           # User profile model
│   │   ├── comment_model.dart           # Comment data model
│   │   └── notification_model.dart      # Notification data model
│   ├── repositories/
│   │   ├── auth_repository.dart         # Auth business logic (sign in, sign up, logout)
│   │   ├── ticket_repository.dart       # Ticket CRUD & operations
│   │   └── notification_repository.dart # Notification operations
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
│   │   ├── profile_screen.dart          # User profile page
│   │   ├── tickets_list_screen.dart     # List of tickets
│   │   ├── create_ticket_screen.dart    # Create new ticket page
│   │   ├── ticket_detail_screen.dart    # Ticket detail & comments
│   │   └── notifications_screen.dart    # Notifications list page
│   └── widgets/
│       └── bottom_refresh_listener.dart # Custom widget untuk pull-to-refresh
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

### 2. **ProfileModel**
```dart
class ProfileModel {
  final String id;              // User ID dari auth.users
  final String? fullName;       // Nama lengkap user
  final String role;            // Role: User, Helpdesk, Admin
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

### 5. **AuthState** (State Management)
```dart
class AuthState {
  final User? user;             // Supabase User object
  final String? username;       // Nama user dari profile
  final String role;            // Role user
  final bool isLoading;         // Loading indicator
  final String? error;          // Error message
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
   - Optional: Upload attachment/gambar
   - File di-upload ke Supabase Storage
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
| Buat Tiket | ✅ | ❌ | ❌ |
| Lihat Tiket Milik Sendiri | ✅ | ❌ | ❌ |
| Lihat Tiket Assign ke Mereka | ❌ | ✅ | ❌ |
| Lihat Semua Tiket | ❌ | ❌ | ✅ |
| Ubah Status Tiket | ❌ | ✅ | ✅ |
| **Assign Tiket** | ❌ | ❌ | ✅ |
| Comment Tiket | ✅ | ✅ | ✅ |
| Lihat Notifications | ✅ | ✅ | ✅ |

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
   created_at (timestamp)
   ```

3. **tickets** (Custom table)
   ```sql
   id (UUID, PK)
   user_id (UUID, FK to profiles)
   title (text)
   description (text)
   status (text) CHECK (status IN ('Open', 'In Progress', 'Resolved', 'Closed'))
   image_url (text)
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
| `/profile` | ProfileScreen | Authenticated | User profile |
| `/notifications` | NotificationsScreen | Authenticated | Notifications list |
| `/tickets` | TicketsListScreen | Authenticated | Tickets list |
| `/create-ticket` | CreateTicketScreen | User | Create new ticket |
| `/ticket/:id` | TicketDetailScreen | Authenticated | Ticket details |

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
└── created_at

TICKETS
├── id (UUID, PK)
├── user_id (UUID, FK)
├── title (text)
├── description (text)
├── status (enum: Open, In Progress, Resolved, Closed)
├── image_url (text)
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
| `image_picker` | ^1.1.1 | Image selection |
| `path` | ^1.8.3 | Path utilities |
| `flutter_lints` | ^6.0.0 | Code quality linting |

---

## 🔗 Key Files to Review

- **Entry Point**: [lib/main.dart](lib/main.dart)
- **Auth Logic**: [lib/data/repositories/auth_repository.dart](lib/data/repositories/auth_repository.dart)
- **Ticket Logic**: [lib/data/repositories/ticket_repository.dart](lib/data/repositories/ticket_repository.dart)
- **Routing**: [lib/core/providers/router_provider.dart](lib/core/providers/router_provider.dart)
- **State Management**: [lib/data/providers/provider.dart](lib/data/providers/provider.dart)
- **Theme**: [lib/core/theme/theme.dart](lib/core/theme/theme.dart)
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
- ✅ Image upload to Supabase Storage
- ✅ Password reset dengan deep-link support
- ✅ Dark mode support
- ✅ Pull-to-refresh functionality
- ✅ Notification badge dengan unread count

### **Potential Improvements**
- 🔲 Push notifications (FCM for Android, APNs for iOS)
- 🔲 Offline support dengan local caching
- 🔲 Advanced search & filtering
- 🔲 File attachment types (PDF, DOC, etc)
- 🔲 Ticket priority levels
- 🔲 SLA tracking & escalation
- 🔲 Email notifications
- 🔲 Analytics & reporting

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
- Sebelumnya: Admin dan Helpdesk bisa assign
- UI Change: Dropdown selection dengan Helpdesk list (tidak perlu input ID manual)
- **New Provider**: `helpdeskUsersProvider` - FutureProvider yang fetch list all Helpdesk users
- **New Repository Method**: `AuthRepository.getHelpdeskUsers()` - query profiles dengan role = 'Helpdesk'
- **Updated Screen**: `ticket_detail_screen.dart` - dropdown dialog untuk assign, hanya visible untuk Admin
- **Database Query**: SELECT * FROM profiles WHERE role = 'Helpdesk' ORDER BY full_name

#### **3. Files Modified**
- `lib/data/repositories/auth_repository.dart`: Tambah method `getHelpdeskUsers()`
 - `lib/data/repositories/auth_repository.dart`: Tambah method `getHelpdeskUsers()` dan `getAdminUsers()`
- `lib/data/providers/provider.dart`: Update `ticketsStreamProvider` logic, tambah `helpdeskUsersProvider`
 - `lib/data/providers/provider.dart`: Update `ticketsStreamProvider` logic, tambah `helpdeskUsersProvider` dan `adminUsersProvider`
- `lib/data/repositories/ticket_repository.dart`: Tambah method `getTicketsAssignedToHelpdesk()`
 - `lib/data/repositories/ticket_repository.dart`: Tambah method `getTicketsAssignedToHelpdesk()` dan update `createTicket()` & `addComment()` untuk mengirim notifikasi kepada Admin serta owner/assignee
- `lib/presentation/screens/ticket_detail_screen.dart`: Update assign dropdown UI, restrict ke Admin only
- `test/auth_flow_test.dart`: Update FakeAuthRepo dengan method `getHelpdeskUsers()`
- `README.md`: Update dokumentasi (file ini)

#### **4. Admin Notifications (New)**
- **Tujuan**: Pastikan Admin memantau aktivitas penting (tiket baru & komentar) untuk oversight dan auditing.
- **Perubahan utama**:
  - `TicketRepository.createTicket()` sekarang mengirim notifikasi ke semua users dengan role `Admin` saat tiket baru dibuat.
  - `TicketRepository.addComment()` sekarang juga menambahkan semua Admin sebagai penerima notifikasi ketika ada komentar baru pada tiket.
  - `AuthRepository.getAdminUsers()` ditambahkan untuk mengambil daftar Admin dari tabel `profiles`.


---

**Dibuat untuk: Dokumentasi Laporan Pembuatan Aplikasi E-Ticketing Helpdesk**
**Last Updated**: April 20, 2026
