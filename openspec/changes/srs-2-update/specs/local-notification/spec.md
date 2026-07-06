## ADDED Requirements

### Requirement: Notifikasi lokal via flutter_local_notifications
Sistem SHALL menampilkan notifikasi sistem (di notification drawer device) saat ada entri baru
di tabel `notifications` yang dimiliki user yang sedang login, menggunakan
`flutter_local_notifications` yang dipicu dari Supabase Realtime stream.

#### Scenario: Notifikasi lokal saat app foreground
- **WHEN** ada notifikasi baru masuk (status tiket berubah atau komentar baru)
  dan app sedang aktif di foreground
- **THEN** `flutter_local_notifications` menampilkan heads-up notification di notification drawer
  DAN in-app banner tetap tampil seperti biasa

#### Scenario: Notifikasi lokal saat app background ringan (suspended)
- **WHEN** ada notifikasi baru dan app ada di background (masih di memori)
- **THEN** `flutter_local_notifications` menampilkan notifikasi di notification drawer device

#### Scenario: Tap notifikasi dari notification drawer
- **WHEN** user menekan notifikasi di notification drawer
- **THEN** app dibuka/resumed dan navigate ke `NotificationsScreen` (/notifications)

### Requirement: Izin notifikasi diminta saat pertama kali
Sistem SHALL meminta izin notifikasi (Android 13+ POST_NOTIFICATIONS, iOS permission)
saat aplikasi pertama kali dijalankan, sebelum mencoba menampilkan notifikasi lokal.

#### Scenario: Izin diberikan
- **WHEN** user memberikan izin notifikasi saat pertama kali app dibuka
- **THEN** notifikasi lokal dapat ditampilkan; tidak ada prompt ulang

#### Scenario: Izin ditolak
- **WHEN** user menolak izin notifikasi
- **THEN** app tetap berjalan normal; in-app banner tetap berfungsi;
  tidak ada crash atau error yang mengganggu

### Requirement: Inisialisasi flutter_local_notifications di main.dart
Plugin `flutter_local_notifications` SHALL diinisialisasi di `main()` sebelum `runApp()`,
dengan channel notifikasi yang terdefinisi untuk Android.

#### Scenario: App berhasil start dengan plugin terinisialisasi
- **WHEN** app dijalankan
- **THEN** plugin terinisialisasi tanpa error; channel "E-Ticketing Helpdesk" tersedia di Android
