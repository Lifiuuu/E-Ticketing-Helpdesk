## 1. Persiapan Supabase (Manual oleh Developer)

- [x] 1.1 Tambah kolom `is_active boolean default true`, `phone_number text`, `avatar_url text` ke tabel `profiles`
- [x] 1.2 Tambah kolom `reporter_id uuid references profiles(id)` (nullable) ke tabel `tickets`
- [x] 1.3 Buat tabel `ticket_attachments` (id uuid PK, ticket_id uuid FK, file_url text, file_name text, file_size bigint, created_at timestamptz)
- [x] 1.4 Buat tabel `ticket_history` (id uuid PK, ticket_id uuid FK, changed_by uuid FK profiles, field_changed text, old_value text, new_value text, created_at timestamptz)
- [x] 1.5 Buat Postgres function `log_ticket_changes()` dan trigger `on_ticket_update` pada tabel `tickets`
- [x] 1.6 Buat bucket Supabase Storage `avatars` (public) untuk foto profil
- [x] 1.7 (Opsional) Update RLS policy agar user dengan `is_active = false` diblokir

## 2. Dependencies & Konfigurasi

- [x] 2.1 Tambah `flutter_local_notifications` ke `pubspec.yaml` dan jalankan `flutter pub get`
- [x] 2.2 Tambah permission `POST_NOTIFICATIONS` di `android/app/src/main/AndroidManifest.xml`
- [x] 2.3 Tambah `NSUserNotificationsUsageDescription` di `ios/Runner/Info.plist`

## 3. Model Layer

- [x] 3.1 Buat `lib/data/models/ticket_attachment_model.dart` (id, ticketId, fileUrl, fileName, fileSize, createdAt)
- [x] 3.2 Buat `lib/data/models/ticket_history_model.dart` (id, ticketId, changedBy, fieldChanged, oldValue, newValue, createdAt)
- [x] 3.3 Update `lib/data/models/profile_model.dart`: tambah field nullable `isActive`, `phoneNumber`, `avatarUrl`; update `fromJson`
- [x] 3.4 Update `lib/data/models/ticket_model.dart`: tambah field nullable `reporterId`; update `fromJson` dan `toJson`

## 4. Repository Layer

- [x] 4.1 Update `lib/data/repositories/ticket_repository.dart`:
  - Tambah method `uploadAttachments(String ticketId, List<File> files) → Future<void>`
  - Tambah method `getAttachments(String ticketId) → Future<List<TicketAttachmentModel>>`
  - Update `createTicket()` untuk menerima `List<File> attachments` dan `String? reporterId`
  - Update `assignTicket()` untuk sekaligus mengubah status tiket menjadi "Assigned"
- [x] 4.2 Buat `lib/data/repositories/history_repository.dart`:
  - Method `getTicketHistory(String ticketId) → Future<List<TicketHistoryModel>>`
- [x] 4.3 Buat `lib/data/repositories/user_repository.dart`:
  - Method `getAllUsers() → Future<List<ProfileModel>>`
  - Method `updateUserRole(String userId, String role) → Future<void>`
  - Method `setUserActive(String userId, bool isActive) → Future<void>`
- [x] 4.4 Update `lib/data/repositories/auth_repository.dart`:
  - Update `getMyProfile()` agar membaca kolom `is_active`, `phone_number`, `avatar_url`
  - Tambah method `updateProfile(String fullName, String? phoneNumber) → Future<void>`
  - Tambah method `uploadAvatar(File avatar) → Future<String>` (upload ke bucket `avatars`)
- [x] 4.5 Tambah `AuthRepoInterface` dengan method baru yang ditambahkan

## 5. Provider Layer

- [x] 5.1 Update `lib/data/providers/provider.dart`:
  - Tambah `historyRepoProvider`
  - Tambah `userRepoProvider`
  - Tambah `ticketHistoryProvider` (FutureProvider.family per ticketId)
  - Tambah `attachmentsProvider` (FutureProvider.family per ticketId)
  - Tambah `userListProvider` (FutureProvider untuk semua user, khusus admin)
  - Tambah `userListForDropdownProvider` (FutureProvider untuk user role User saja, buat dropdown pelapor)

## 6. Routing

- [x] 6.1 Update `lib/core/providers/router_provider.dart`:
  - Hapus blokir `/create-ticket` untuk role admin dan helpdesk (baris 70-73)
  - Tambah route `/ticket/:id/tracking` → `TrackingTicketScreen`
  - Tambah route `/users` → `UserManagementScreen` (hanya admin, redirect jika bukan admin)
  - Tambah route `/settings` → `SettingsScreen`

## 7. Notification Service

- [x] 7.1 Update `lib/core/notification/notification_service.dart`:
  - Inisialisasi `FlutterLocalNotificationsPlugin` sebagai singleton
  - Buat method `initLocalNotifications()` dengan Android channel "E-Ticketing Helpdesk"
  - Update `listenToNotifications()` untuk memanggil `showLocalNotification()` saat ada notif baru
  - Buat method `showLocalNotification(String title, String body)`
  - Handle tap notifikasi (navigate ke `/notifications`)
- [x] 7.2 Update `lib/main.dart`:
  - Panggil `initLocalNotifications()` sebelum `runApp()`
  - Request permission notifikasi

## 8. Screen — Create Ticket (Perubahan)

- [x] 8.1 Update `lib/presentation/screens/create_ticket_screen.dart`:
  - Ganti single `File? _attachmentFile` menjadi `List<File> _attachmentFiles`
  - Tambah tombol "+" untuk menambah attachment (maks. 5); tampilkan grid preview thumbnail
  - Tambah tombol "×" di setiap thumbnail untuk menghapus dari list
  - Tambah validasi: jika sudah 5 file, tombol "+" dinonaktifkan + pesan error
  - Tambah conditional widget: jika role Helpdesk/Admin, tampilkan dropdown "Pilih Pelapor"
    yang menggunakan `userListForDropdownProvider`
  - Tambah validasi: Helpdesk/Admin harus pilih pelapor sebelum submit
  - Update `_submit()` untuk memanggil `createTicket()` dengan `reporterId` dan `attachments`

## 9. Screen — Dashboard (Perubahan)

- [x] 9.1 Update `lib/presentation/screens/dashboard_screen.dart`:
  - Tambah `_StatCard` untuk status "Assigned" (hitung `tickets.where((t) => t.status == 'Assigned').length`)
  - Sesuaikan layout Row menjadi Wrap atau 2 baris untuk menampung 5 kartu
  - Tambah ikon Settings di AppBar yang navigate ke `/settings`
  - Tampilkan tombol "Kelola Pengguna" di dashboard hanya untuk Admin (navigate ke `/users`)

## 10. Screen — Tickets List (Perubahan)

- [x] 10.1 Update `lib/presentation/screens/tickets_list_screen.dart`:
  - Tambah state `String? _helpdeskFilter` (hanya digunakan jika role Admin)
  - Tambah conditional dropdown "Filter by Helpdesk" di AppBar jika role Admin,
    menggunakan `helpdeskUsersProvider`
  - Update logika filter: kombinasikan `_statusFilter` DAN `_helpdeskFilter`
  - Tambah status "Assigned" ke daftar opsi filter status yang sudah ada

## 11. Screen — Ticket Detail (Perubahan)

- [x] 11.1 Update `lib/presentation/screens/ticket_detail_screen.dart`:
  - Ganti tampilan single `image_url` dengan widget `AttachmentGrid` yang membaca `attachmentsProvider(ticketId)`
  - Tambah fallback: jika `attachmentsProvider` kosong tapi `ticket.imageUrl` ada, tampilkan `imageUrl` lama
  - Tambah tombol/link "Riwayat Perubahan" di AppBar atau body yang navigate ke `/ticket/:id/tracking`
  - Update logic `assignTicket()` agar juga mengubah status tiket menjadi "Assigned"

## 12. Screen — Tracking Tiket (BARU)

- [x] 12.1 Buat `lib/presentation/screens/tracking_ticket_screen.dart`:
  - ConsumerStatefulWidget, menerima `ticketId` sebagai parameter
  - Load data via `ticketHistoryProvider(ticketId)`
  - Tampilkan timeline vertikal (gunakan `ListView.builder` dengan line connector)
  - Setiap entri: ikon status/field, "field lama → baru", nama pengguna (via `profileProvider`), timestamp
  - Handle loading, error (termasuk error "tabel tidak ditemukan"), dan empty state

## 13. Screen — User Management (BARU)

- [x] 13.1 Buat `lib/presentation/screens/user_management_screen.dart`:
  - ConsumerStatefulWidget, hanya accessible oleh Admin (sudah diblokir di router)
  - Load data via `userListProvider`
  - Tampilkan list user: nama, email, role (badge), status aktif/nonaktif
  - Dropdown untuk ubah role (User/Helpdesk/Admin) per baris; disabled untuk akun sendiri
  - Toggle switch untuk aktif/nonaktif per baris; disabled untuk akun sendiri
  - Tampilkan konfirmasi dialog sebelum ubah role atau nonaktifkan

## 14. Screen — Settings (BARU)

- [x] 14.1 Buat `lib/presentation/screens/settings_screen.dart`:
  - ConsumerWidget sederhana
  - Tampilkan toggle dark/light mode (pindah dari profile screen), menggunakan `themeModeProvider`
  - Tombol "Lihat Profil" → navigate ke `/profile`
  - Tombol "Keluar" → `authNotifier.logout()` + navigate ke `/login`

## 15. Screen — Profile (Perubahan)

- [x] 15.1 Update `lib/presentation/screens/profile_screen.dart`:
  - Hapus toggle dark mode
  - Ubah tampilan nama menjadi editable `TextFormField`
  - Tambah `TextFormField` untuk nomor telepon
  - Tambah widget avatar: tampilkan avatar dari `auth.avatarUrl` (jika ada) atau ikon default;
    tap untuk pick gambar dari galeri/kamera → preview lokal
  - Tambah tombol "Simpan Perubahan": panggil `authRepoProvider.updateProfile()` dan
    `authRepoProvider.uploadAvatar()` jika ada gambar baru
  - Update `AuthState` dan `ProfileModel` setelah simpan via `_refreshProfile`

## 16. Widget Bersama

- [x] 16.1 Buat `lib/presentation/widgets/attachment_grid.dart`:
  - Terima `List<TicketAttachmentModel>` sebagai parameter
  - Tampilkan grid thumbnail 3-column; tap untuk full-screen viewer

## 17. Verifikasi Akhir

- [x] 17.1 Jalankan `flutter analyze` dan pastikan tidak ada error
- [x] 17.2 Test alur create ticket sebagai User (multi-attachment)
- [x] 17.3 Test alur create ticket sebagai Helpdesk (dropdown pelapor)
- [x] 17.4 Test alur create ticket sebagai Admin (dropdown pelapor)
- [x] 17.5 Test tracking screen dengan tiket yang sudah diupdate statusnya
- [x] 17.6 Test user management: ubah role + nonaktifkan user
- [x] 17.7 Test settings screen: toggle dark/light mode + logout
- [x] 17.8 Test profile edit: ubah nama, telepon, avatar
- [x] 17.9 Test notifikasi lokal saat ada perubahan status tiket
- [x] 17.10 Test dashboard menampilkan 5 statistik (termasuk Assigned)
- [x] 17.11 Test filter tiket by helpdesk (khusus Admin)
