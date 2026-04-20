# Technical Design: E-Ticketing Helpdesk Frontend

## 1. Arsitektur Aplikasi
[cite_start]Menggunakan **Clean Architecture**  untuk menjaga *maintainability*. Struktur direktori utama:
* `lib/core/`: Berisi *network client* (Dio/http), *theme*, *constants*, dan *utils*.
* `lib/domain/`: Berisi *Entities* dan *Repositories interfaces*.
* `lib/data/`: Berisi *Models*, *Data Sources* (Remote/API & Local), dan implementasi *Repository*.
* `lib/presentation/`: Berisi UI (*Screens*, *Widgets*) dan State Management.

## 2. Kebutuhan Non-Fungsional (NFR)
* [cite_start]**Performance:** Menerapkan *Lazy Loading* / *Pagination* pada halaman `List Tiket`[cite: 108, 123].
* [cite_start]**Theme:** Mendukung implementasi `Dark Mode` dan `Light Mode`[cite: 130].
* [cite_start]**Compatibility:** Responsif untuk berbagai ukuran layar perangkat *mobile*[cite: 116].

## 3. Daftar UI/UX Screen
[cite_start]Aplikasi akan memiliki halaman berikut[cite: 119]:
1.  [cite_start]Splash Screen [cite: 120]
2.  [cite_start]Login & Register Screen [cite: 121]
3.  [cite_start]Dashboard (Statistik) [cite: 122]
4.  [cite_start]List Tiket (Riwayat & Tracking) [cite: 123]
5.  [cite_start]Detail Tiket (dengan fitur komentar) [cite: 124]
6.  [cite_start]Create Tiket (dengan fitur upload gambar/kamera) [cite: 127]
7.  [cite_start]Profile Screen [cite: 128]