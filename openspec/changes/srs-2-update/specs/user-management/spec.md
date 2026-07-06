## ADDED Requirements

### Requirement: Admin dapat melihat daftar semua pengguna
Admin SHALL dapat mengakses screen `UserManagementScreen` (route `/users`) yang menampilkan
daftar semua pengguna terdaftar (dari tabel `profiles`) dengan nama, email, role, dan status aktif.

#### Scenario: Akses user management
- **WHEN** Admin menekan menu "Kelola Pengguna" dari Dashboard atau sidebar
- **THEN** sistem navigasi ke `/users` dan menampilkan daftar semua pengguna

#### Scenario: Role non-Admin mencoba akses
- **WHEN** User atau Helpdesk mencoba mengakses `/users`
- **THEN** GoRouter redirect ke `/dashboard` (blokir di router)

### Requirement: Admin dapat mengubah role pengguna
Admin SHALL dapat mengubah role pengguna (User / Helpdesk / Admin) dari `UserManagementScreen`.

#### Scenario: Ubah role pengguna
- **WHEN** Admin memilih pengguna dan mengubah role melalui dropdown/dialog
- **THEN** field `role` di tabel `profiles` diupdate; daftar pengguna direfresh

#### Scenario: Admin mencoba mengubah role dirinya sendiri
- **WHEN** Admin memilih akunnya sendiri untuk diubah role-nya
- **THEN** sistem menampilkan pesan "Tidak dapat mengubah role akun sendiri" dan menolak perubahan

### Requirement: Admin dapat menonaktifkan / mengaktifkan pengguna
Admin SHALL dapat toggle status aktif pengguna via field `is_active` di tabel `profiles`.
Pengguna yang nonaktif masih ada di database tapi tidak bisa mengakses sistem.

#### Scenario: Nonaktifkan pengguna
- **WHEN** Admin menekan toggle "Nonaktifkan" pada baris pengguna yang aktif
- **THEN** `is_active` di profiles diset `false`; status pengguna di UI berubah menjadi "Nonaktif"

#### Scenario: Aktifkan kembali pengguna
- **WHEN** Admin menekan toggle "Aktifkan" pada baris pengguna nonaktif
- **THEN** `is_active` diset `true`; status berubah menjadi "Aktif"

#### Scenario: Admin mencoba menonaktifkan diri sendiri
- **WHEN** Admin mencoba menonaktifkan akunnya sendiri
- **THEN** sistem menampilkan pesan "Tidak dapat menonaktifkan akun sendiri" dan menolak aksi

### Requirement: Pengguna nonaktif tidak dapat mengakses sistem
Pengguna dengan `is_active = false` SHALL gagal melakukan operasi apapun yang membutuhkan
autentikasi meskipun JWT-nya masih valid, karena RLS policy di Supabase menolak request mereka.

#### Scenario: Pengguna nonaktif mencoba login
- **WHEN** pengguna nonaktif berhasil autentikasi di Supabase Auth (JWT valid)
  tapi `is_active = false` di profiles
- **THEN** `getMyProfile()` mengembalikan data dengan `is_active = false`; AuthNotifier
  memuat `isActive = false` ke state; router redirect ke `/login` dengan pesan error

#### Scenario: Request data dari pengguna nonaktif
- **WHEN** pengguna nonaktif mencoba mengakses tabel yang dilindungi RLS policy `is_active`
- **THEN** Supabase mengembalikan empty result atau permission error
