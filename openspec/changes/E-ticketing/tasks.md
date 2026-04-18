# Tasks: Implementasi E-Ticketing Helpdesk

## Phase 1: Inisialisasi & Setup Struktur
 - [x] Buat struktur folder *Clean Architecture* di dalam direktori `lib/` (`core`, `domain`, `data`, `presentation`).
 - [x] [cite_start]Konfigurasi `core/theme/` untuk *Dark Mode* dan *Light Mode*[cite: 130].
 - [x] Buat *routing* dasar untuk navigasi antar halaman (menggunakan GoRouter atau auto_route).
 - [x] [cite_start]Buat halaman `Splash Screen`[cite: 120].

## Phase 2: Modul Authentikasi
 - [x] [cite_start]Buat UI `Login Screen` dengan input username dan password[cite: 46, 121].
 - [x] [cite_start]Buat UI `Register Screen` [cite: 50] [cite_start]dan `Reset Password`[cite: 53].
 - [x] [cite_start]Implementasikan *state management* dan integrasikan dengan *dummy* API untuk proses *Login* dan *Logout*[cite: 47].

## Phase 3: Dashboard & Profil
 - [x] [cite_start]Buat UI `Dashboard` yang menampilkan ringkasan data statistik (Total tiket, Status tiket)[cite: 85, 87, 88].
 - [x] [cite_start]Buat UI `Profile Screen`[cite: 128].

## Phase 4: Manajemen Tiket (Sisi User)
 - [x] [cite_start]Buat UI `Create Tiket` dengan *form input* dan tombol *upload* gambar/kamera[cite: 63, 64, 127].
 - [x] [cite_start]Buat UI `List Tiket` yang menampilkan riwayat dan status *tracking*[cite: 65, 92, 99]. [cite_start]Implementasikan *lazy loading* pada daftar ini[cite: 108].
 - [x] [cite_start]Buat UI `Detail Tiket` yang menampilkan data lengkap beserta fitur kolom komentar/reply[cite: 66, 67, 124].

## Phase 5: Manajemen Tiket (Sisi Admin/Helpdesk)
 - [x] [cite_start]Modifikasi `List Tiket` untuk mendukung tampilan semua tiket bagi role Admin/Helpdesk[cite: 73].
 - [x] [cite_start]Tambahkan fitur *Filter* tiket[cite: 74].
 - [x] [cite_start]Tambahkan opsi atau modal pop-up di `Detail Tiket` khusus admin untuk Update Status dan Assign Tiket[cite: 75, 76].

## Phase 6: Notifikasi & Finalisasi
- [x] [cite_start]Integrasikan UI pop-up atau *banner* untuk menampilkan pemberitahuan status tiket terbaru[cite: 82].
- [x] [cite_start]Pastikan navigasi dari notifikasi mengarah langsung ke halaman `Detail Tiket` terkait[cite: 83].