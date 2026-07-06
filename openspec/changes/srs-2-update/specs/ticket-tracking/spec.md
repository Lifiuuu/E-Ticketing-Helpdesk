## ADDED Requirements

### Requirement: Halaman Tracking Tiket
Sistem SHALL menyediakan screen `TrackingTicketScreen` (route `/ticket/:id/tracking`) yang
menampilkan timeline vertikal seluruh perubahan status dan assignee tiket, dibaca dari tabel
`ticket_history` yang diisi otomatis oleh Postgres trigger.

#### Scenario: Buka tracking tiket dengan riwayat
- **WHEN** user menekan tombol "Lihat Tracking" di `ticket_detail_screen`
- **THEN** sistem navigasi ke `/ticket/:id/tracking` dan menampilkan timeline vertikal
  dengan semua entri riwayat diurutkan dari terlama ke terbaru

#### Scenario: Setiap entri history ditampilkan
- **WHEN** timeline tracking ditampilkan
- **THEN** setiap entri menampilkan: field yang diubah (Status/Assignee), nilai lama → nilai baru,
  nama pengguna yang mengubah (dari tabel profiles), dan waktu perubahan (format relatif atau DD MMM YYYY HH:mm)

#### Scenario: Tracking tiket tanpa history
- **WHEN** tiket belum pernah diubah (baru dibuat)
- **THEN** screen menampilkan pesan "Belum ada riwayat perubahan" alih-alih error

#### Scenario: Filter by role — User
- **WHEN** User membuka tracking tiket miliknya
- **THEN** seluruh history tiket ditampilkan (status & assignee changes)

#### Scenario: Filter by role — Helpdesk
- **WHEN** Helpdesk membuka tracking tiket yang ditugaskan kepadanya
- **THEN** seluruh history tiket tersebut ditampilkan

#### Scenario: Filter by role — Admin
- **WHEN** Admin membuka tracking tiket mana pun
- **THEN** seluruh history tiket tersebut ditampilkan

### Requirement: Navigasi ke Tracking dari Detail Tiket
Dari `ticket_detail_screen`, harus ada aksi/tombol yang navigasi ke halaman tracking.

#### Scenario: Tombol tracking tersedia di detail
- **WHEN** user berada di detail tiket
- **THEN** terdapat tombol/link "Riwayat Perubahan" atau ikon history di AppBar atau body
  yang me-navigate ke `/ticket/:id/tracking`

### Requirement: Data history dibaca dari Supabase
`HistoryRepository` SHALL membaca data dari tabel `ticket_history` di Supabase, diurutkan
berdasarkan `created_at` ascending.

#### Scenario: Load history sukses
- **WHEN** `HistoryRepository.getTicketHistory(ticketId)` dipanggil
- **THEN** mengembalikan `List<TicketHistoryModel>` yang terurut dari terlama ke terbaru

#### Scenario: Tabel ticket_history belum ada
- **WHEN** tabel `ticket_history` belum dibuat di Supabase
- **THEN** tracking screen menampilkan pesan error yang informatif, tidak crash
