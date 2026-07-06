# E-Ticketing Helpdesk Mobile Application

Aplikasi mobile Flutter untuk sistem e-ticketing helpdesk yang memungkinkan pengguna (customer) membuat tiket bantuan dan petugas (helpdesk/admin) mengelola tiket dengan fitur real-time notifications, comments, dan status tracking terintegrasi dengan Supabase.

## 📱 Screenshots
*(Kamu bisa menambahkan tautan gambar screenshot aplikasimu di sini nanti)*

## ✨ Fitur Utama
- **Role-Based Access Control**: Mendukung 3 Role (User, Helpdesk, Admin)
- **Real-time Updates**: Komentar dan status tiket terupdate secara real-time
- **Push Notifications**: Terintegrasi dengan Firebase Cloud Messaging (FCM)
- **File Attachments**: Mendukung upload lampiran gambar/dokumen
- **Ticket Tracking**: Melacak riwayat perubahan tiket (Audit Trail)
- **Dashboard & Analytics**: Statistik ringkas jumlah tiket berdasarkan status
- **Dark/Light Mode**: Mendukung pengaturan tema tampilan dinamis

---

## 🚀 Getting Started

Proyek ini merupakan titik awal untuk aplikasi Flutter.
Jika ini adalah proyek Flutter pertamamu, beberapa sumber daya berikut dapat membantumu:

- [Lab: Tulis aplikasi Flutter pertamamu](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Contoh Flutter yang berguna](https://docs.flutter.dev/cookbook)

Untuk bantuan lebih lanjut terkait pengembangan Flutter, lihat [dokumentasi online](https://docs.flutter.dev/), yang menawarkan tutorial, contoh, panduan pengembangan mobile, dan referensi API lengkap.

---

## 🛠️ Persyaratan Sistem (Prerequisites)
Sebelum menjalankan project ini, pastikan kamu telah menginstal:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.11.0 atau lebih baru)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / VS Code dengan plugin Flutter & Dart
- Akun [Supabase](https://supabase.com) (Untuk Database & Auth)
- Akun [Firebase](https://firebase.google.com) (Untuk Push Notifications)

## 📦 Instalasi & Menjalankan Aplikasi

1. Clone repositori ini ke komputer lokalmu:
   ```bash
   git clone https://github.com/Lifiuuu/projectmobile.git
   cd projectmobile
   ```

2. Unduh semua dependensi package:
   ```bash
   flutter pub get
   ```

3. (Opsional) Setup konfigurasi:
   Pastikan konfigurasi URL dan Anon Key Supabase di dalam file `lib/main.dart` sudah sesuai dengan proyek Supabase-mu.

4. Jalankan aplikasi di emulator atau perangkat yang terhubung:
   ```bash
   flutter run
   ```

## 🏗️ Build (Release)

Untuk membuat file instalasi (APK) siap rilis untuk Android:
```bash
flutter build apk --release
```
File APK hasil *build* dapat ditemukan di direktori `build/app/outputs/flutter-apk/app-release.apk`.

## 📚 Arsitektur & State Management
Proyek ini diorganisir dengan rapi menggunakan **Riverpod** sebagai state management utama.
- `lib/core/` : Utilitas, tema, notifikasi, dan konfigurasi provider dasar.
- `lib/data/` : Model data dan Repositori (logika bisnis & pemanggilan API Supabase).
- `lib/presentation/` : Antarmuka pengguna (UI/Screens) dan Widget.

Sistem navigasi dikelola menggunakan package **GoRouter** untuk mendukung *deep-linking* dan *redirect* berbasis otentikasi.

---
Dibuat dengan ❤️ menggunakan Flutter.
