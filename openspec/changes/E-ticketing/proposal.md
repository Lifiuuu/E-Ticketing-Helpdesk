# Proposal: Frontend E-Ticketing Helpdesk Mobile App

## 1. Pendahuluan
Membangun aplikasi mobile (frontend) berbasis Flutter untuk sistem E-Ticketing Helpdesk. [cite_start]Aplikasi ini ditujukan untuk pelaporan, monitoring, dan penyelesaian masalah IT[cite: 10]. 

## 2. Tujuan
[cite_start]Menyediakan antarmuka pengguna yang responsif, konsisten, dan mudah digunakan di platform Android dan iOS[cite: 110, 112, 113, 115]. [cite_start]Aplikasi akan berinteraksi dengan RESTful API dan mengelola *state* di sisi klien[cite: 13, 14, 30].

## 3. Ruang Lingkup (Scope)
[cite_start]Sistem ini melayani 3 tipe pengguna (Admin, Helpdesk, User) [cite: 40] dengan fitur utama:
* [cite_start]**Authentikasi:** Login, Logout, Register, Reset Password[cite: 44, 45, 47, 50, 53].
* [cite_start]**Manajemen Tiket (User):** Membuat tiket, upload lampiran, melihat daftar dan detail tiket, serta memberikan komentar[cite: 57, 63, 64, 65, 66, 67].
* [cite_start]**Manajemen Tiket (Admin/Helpdesk):** Melihat semua tiket, filter, update status, dan *assign* tiket[cite: 70, 73, 74, 75, 76].
* [cite_start]**Dashboard & Statistik:** Menampilkan ringkasan total dan status tiket[cite: 85, 87, 88].
* [cite_start]**Riwayat & Tracking:** Memantau status penanganan tiket secara *real-time*[cite: 92, 99, 103, 104].
* [cite_start]**Notifikasi:** Menampilkan pemberitahuan pembaruan tiket[cite: 78, 82].

## 4. Di Luar Ruang Lingkup (Out of Scope)
* Pengembangan *Backend* API dan skema Database (Fokus murni *Frontend*).