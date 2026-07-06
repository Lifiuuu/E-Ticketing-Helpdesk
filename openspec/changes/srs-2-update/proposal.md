## Why

Project E-Ticketing Helpdesk saat ini dibangun berdasarkan SRS versi lama yang belum mencakup
tracking/history tiket, manajemen pengguna oleh Admin, multi-attachment, setting screen terpisah,
dan push notification — semua fitur ini kini diwajibkan oleh SRS versi 2.0.0 (18 Juni 2026).
Update diperlukan sebelum presentasi/demo praktikum DIV Teknik Informatika Universitas Airlangga.

## What Changes

- **BARU** — Multi-attachment tiket: ganti field tunggal `image_url` di tabel `tickets` menjadi
  tabel relasi `ticket_attachments` (maks. 3–5 file per tiket); model, repository, dan UI
  create/detail diperbarui.
- **BARU** — Tracking & History tiket: tabel `ticket_history` (append-only via Postgres trigger),
  model `TicketHistoryModel`, `HistoryRepository`, `trackingTicketProvider`, dan screen baru
  `tracking_ticket_screen.dart` (route `/ticket/:id/tracking`).
- **BARU** — User Management (Admin): screen baru `user_management_screen.dart` (route
  `/users`) untuk lihat daftar pengguna, ubah role, dan toggle is_active.
- **BARU** — Setting Screen: screen baru `settings_screen.dart` (route `/settings`) berisi
  dark/light mode toggle dan link ke profile; toggle dipindah dari Profile ke sini.
- **UBAH** — Create Ticket: izinkan Helpdesk & Admin membuat tiket dengan memilih user pelapor
  dari dropdown; hapus blokir router untuk role tersebut.
- **UBAH** — Dashboard statistik: tambah kartu "Assigned" sebagai status terpisah (FR-009).
- **UBAH** — Tickets list: tambah filter by assignee/helpdesk (khusus Admin).
- **UBAH** — Profile Screen: tambah fitur edit nama & avatar (upload ke Supabase Storage).
- **UBAH** — Notification: integrasikan `flutter_local_notifications` + Supabase Realtime agar
  notifikasi muncul saat app di-foreground maupun background ringan (tanpa FCM).
- **UBAH** — ProfileModel: tambah field `isActive`, `phoneNumber`, `avatarUrl`.
- **UBAH** — TicketModel: hapus field `imageUrl`, ganti dengan `List<TicketAttachment>`.

## Capabilities

### New Capabilities

- `ticket-attachments`: Multi-file attachment per tiket (tabel `ticket_attachments`, upload ke
  Supabase Storage `tickets/attachments/`, maks. 5 file, preview di detail & create ticket).
- `ticket-tracking`: Tracking & riwayat perubahan status tiket berbasis tabel `ticket_history`
  yang diisi otomatis oleh Postgres trigger; screen tracking menampilkan timeline status.
- `user-management`: Admin dapat melihat daftar semua pengguna, mengubah role, dan
  mengaktifkan/menonaktifkan akun (flag `is_active` di tabel `profiles`).
- `settings-screen`: Layar Setting terpisah dari Profile; berisi dark/light mode toggle, link ke
  Profile, dan tombol logout.
- `local-notification`: Notifikasi in-device via `flutter_local_notifications` dipicu oleh
  Supabase Realtime saat ada perubahan status atau komentar baru pada tiket milik/ditangani user.

### Modified Capabilities

- `ticket-create`: Helpdesk & Admin kini bisa membuat tiket (tidak diblokir router); form
  menambahkan dropdown "Pilih Pelapor" (user) yang wajib diisi oleh Helpdesk/Admin.
- `dashboard-stats`: Tambah kartu statistik "Assigned" di samping Open/InProgress/Closed;
  Dashboard Service menghitung jumlah tiket berstatus "Assigned" secara terpisah.
- `ticket-list`: Admin mendapat opsi filter tambahan berupa filter by assignee (helpdesk).
- `profile-edit`: Profile Screen berubah dari read-only menjadi editable (nama, avatar/foto,
  nomor telepon); data disimpan ke tabel `profiles` dan avatar ke Supabase Storage.

## Impact

**Kode Flutter:**
- `lib/data/models/`: tambah `ticket_attachment_model.dart`, `ticket_history_model.dart`;
  ubah `ticket_model.dart`, `profile_model.dart`
- `lib/data/repositories/`: ubah `ticket_repository.dart` (multi-attach, buat tiket dengan
  reporter dropdown); tambah `history_repository.dart`, `user_repository.dart`
- `lib/data/providers/provider.dart`: tambah provider untuk history, tracking, user list
- `lib/presentation/screens/`: tambah `tracking_ticket_screen.dart`,
  `user_management_screen.dart`, `settings_screen.dart`; ubah `create_ticket_screen.dart`,
  `dashboard_screen.dart`, `tickets_list_screen.dart`, `ticket_detail_screen.dart`,
  `profile_screen.dart`
- `lib/core/providers/router_provider.dart`: hapus blokir create-ticket untuk Helpdesk/Admin;
  tambah route `/ticket/:id/tracking`, `/users`, `/settings`
- `lib/core/notification/notification_service.dart`: integrasikan `flutter_local_notifications`

**Dependencies baru (pubspec.yaml):**
- `flutter_local_notifications` (local push)

**Supabase (manual oleh developer):**
- Tabel baru `ticket_attachments` (id, ticket_id, file_url, file_name, created_at)
- Tabel baru `ticket_history` (id, ticket_id, changed_by, field_changed, old_value, new_value, created_at)
- Kolom baru di `profiles`: `is_active` (boolean default true), `phone_number` (text nullable), `avatar_url` (text nullable)
- Kolom baru di `tickets`: `reporter_id` (uuid, FK ke profiles) — untuk membedakan pembuat tiket dari pelapor saat Helpdesk/Admin yang submit
- Postgres trigger `on_ticket_update` → insert ke `ticket_history`
- RLS policy update: blokir user dengan `is_active = false`

> **Catatan**: Tidak ada migrasi otomatis. Semua perubahan Supabase dilakukan manual oleh developer.
