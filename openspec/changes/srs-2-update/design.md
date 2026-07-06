## Context

Project E-Ticketing Helpdesk adalah Flutter app dengan Riverpod state management, GoRouter
routing, dan Supabase sebagai backend (Auth, PostgreSQL, Storage, Realtime). Arsitektur saat ini
sudah memiliki layer separation `core/data/presentation` namun belum ada domain/use-case layer.

Perubahan ini mencakup 9 area berbeda (multi-attachment, tracking/history, user management,
settings screen, create ticket untuk Helpdesk/Admin, dashboard stats, ticket list filter,
profile edit, local notification). Semua perubahan bersifat additive terhadap kode yang sudah ada;
tidak ada refactor besar pada kode yang sudah berfungsi benar.

Perubahan Supabase (tabel, trigger, kolom, RLS) **tidak dilakukan otomatis** — developer
mengatur secara manual via Supabase Dashboard.

---

## Goals / Non-Goals

**Goals:**
- Implementasi semua requirement baru SRS 2.0.0 yang belum ada (kategori ❌) atau belum lengkap (⚠️/🔁)
- Tidak mengubah kode yang sudah berfungsi dan sesuai spesifikasi (kategori ✅)
- Tetap menggunakan stack yang sudah ada (Supabase, Riverpod, GoRouter)
- Memberikan panduan Supabase schema yang harus dijalankan manual oleh developer

**Non-Goals:**
- Migrasi data otomatis
- FCM (Firebase Cloud Messaging) — digantikan flutter_local_notifications + Supabase Realtime
- Penambahan layer domain/use-case (clean architecture penuh)
- Internasionalisasi / multi-bahasa
- Granular notification preferences
- Web/Desktop support

---

## Decisions

### D1 — Multi-attachment: Tabel Terpisah vs Array Column

**Pilihan A (dipilih):** Tabel `ticket_attachments` (id, ticket_id, file_url, file_name, file_size, created_at)  
**Pilihan B (ditolak):** Array column `image_urls text[]` di tabel `tickets`

**Rationale:** Tabel terpisah lebih fleksibel untuk query, RLS, dan penambahan metadata attachment
di masa depan. Array column lebih sederhana tapi sulit di-query per-file dan tidak bisa di-delete
selectively dengan mudah. Field `image_url` lama di tabel `tickets` dipertahankan (nullable)
untuk kompatibilitas data lama, tapi tidak digunakan untuk tiket baru.

**Implementasi Flutter:** `TicketAttachmentModel` baru, method `uploadAttachments(List<File>)` dan
`getAttachments(ticketId)` di `TicketRepository`, UI upload dengan preview grid (maks. 5 file).

---

### D2 — Ticket History: Trigger Postgres vs Aplikasi

**Pilihan A (dipilih):** Postgres trigger `on_ticket_update` → insert ke `ticket_history`  
**Pilihan B (ditolak):** Tulis history dari kode Flutter setelah setiap update

**Rationale:** Trigger lebih reliable karena tidak bisa "lupa" dipanggil saat ada update dari
sumber lain (Dashboard Supabase, RPC, dsb.). Sesuai BR-005. Kode Flutter hanya read-only
terhadap `ticket_history`.

**Schema `ticket_history`:**
```sql
create table ticket_history (
  id uuid default gen_random_uuid() primary key,
  ticket_id uuid references tickets(id) on delete cascade,
  changed_by uuid references profiles(id),
  field_changed text,          -- 'status', 'assigned_to', dll
  old_value text,
  new_value text,
  created_at timestamptz default now()
);
```

**Trigger (manual di Supabase):**
```sql
create or replace function log_ticket_changes()
returns trigger language plpgsql as $$
begin
  if old.status is distinct from new.status then
    insert into ticket_history(ticket_id, changed_by, field_changed, old_value, new_value)
    values (new.id, auth.uid(), 'status', old.status, new.status);
  end if;
  if old.assigned_to is distinct from new.assigned_to then
    insert into ticket_history(ticket_id, changed_by, field_changed, old_value, new_value)
    values (new.id, auth.uid(), 'assigned_to', old.assigned_to::text, new.assigned_to::text);
  end if;
  return new;
end;
$$;

create trigger on_ticket_update
after update on tickets
for each row execute function log_ticket_changes();
```

**Tracking Screen:** Timeline vertical, setiap entry menampilkan: perubahan field, nilai lama →
baru, siapa yang mengubah (nama dari profiles), dan timestamp.

---

### D3 — User Management: Soft Delete via is_active Flag

**Pilihan A (dipilih):** `is_active boolean default true` di tabel `profiles` + RLS policy  
**Pilihan B (ditolak):** Disable user di Supabase Auth (supabase.auth.admin.deleteUser)

**Rationale:** Soft delete lebih aman, reversible, dan tidak memerlukan service role key di client.
RLS policy menolak semua operasi dari user dengan `is_active = false`.

**RLS policy (manual di Supabase — tambahkan ke semua tabel yang di-RLS):**
```sql
-- Contoh untuk tabel tickets:
create policy "only active users"
on tickets for all
using (
  exists (
    select 1 from profiles
    where profiles.id = auth.uid()
    and profiles.is_active = true
  )
);
```

**Admin capabilities:** List semua user, filter by role, ubah role (User/Helpdesk/Admin), toggle
`is_active`. Tidak ada delete permanen dari UI.

---

### D4 — Local Notification: flutter_local_notifications + Supabase Realtime

**Pilihan A (dipilih):** `flutter_local_notifications` dipicu dari Supabase Realtime stream  
**Pilihan B (ditolak):** Firebase Cloud Messaging (FCM)

**Rationale:** FCM membutuhkan setup service account Google + APNs certificate untuk iOS — overhead
signifikan untuk scope praktikum. `flutter_local_notifications` dapat menampilkan notifikasi sistem
(notification drawer) saat app foreground dan background ringan (app masih di memori). Cukup untuk
memenuhi BR-003 "Supabase Realtime / FCM / Local Notification" (pilih salah satu).

**Implementasi:** `NotificationService.listenToNotifications()` yang sudah ada direfactor untuk
memanggil `flutterLocalNotificationsPlugin.show()` selain banner. Inisialisasi plugin dilakukan
di `main.dart`.

---

### D5 — Create Ticket oleh Helpdesk/Admin: Dropdown Reporter

**Keputusan:** Hapus blokir di `router_provider.dart` (baris 70-73). Form `create_ticket_screen`
memiliki conditional widget: jika role Helpdesk/Admin, tampilkan dropdown "Pilih Pelapor" (user)
yang datanya dari provider `userListProvider`. Field `reporter_id` dikirim ke Supabase; `user_id`
tetap diisi dengan ID pembuat tiket (Helpdesk/Admin) untuk audit trail.

**Schema change (manual):** Tambah kolom `reporter_id uuid references profiles(id) nullable`
di tabel `tickets`. Kolom bersifat nullable agar tiket lama tidak terpengaruh.

---

### D6 — Settings Screen vs Profile Screen

**Keputusan:** Buat `settings_screen.dart` baru (route `/settings`). Dark mode toggle DIPINDAH
dari `profile_screen.dart` ke `settings_screen.dart`. Profile Screen menjadi dedicated untuk
informasi & edit profil. Settings dapat diakses dari AppBar/Drawer semua screen utama.

---

### D7 — Filter Tiket by Assignee (Admin)

**Keputusan:** Tambahkan `_helpdeskFilter` state ke `TicketsListScreen` khusus untuk role Admin.
Tampilkan dropdown filter kedua (Helpdesk) di samping filter status yang sudah ada. Data helpdesk
diambil dari `helpdeskUsersProvider` yang sudah tersedia.

---

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| Tabel `ticket_history` belum ada saat app dijalankan → crash di tracking screen | Tracking screen menampilkan error graceful + instruksi untuk menjalankan migration manual |
| `image_url` lama di `ticket_detail_screen` masih dipakai untuk tiket lama | Kode detail screen menampilkan `image_url` lama DAN attachments baru secara kondisional |
| `flutter_local_notifications` memerlukan izin notifikasi di Android 13+ / iOS | Tambahkan permission request di `main.dart` saat app pertama kali dibuka |
| Kolom `reporter_id` nullable → tiket lama tidak punya reporter | UI menampilkan fallback "—" jika `reporter_id` null |
| Perubahan ProfileModel (tambah field) → existing data null | Semua field baru di ProfileModel dibuat nullable dengan default null |

---

## Migration Plan (Manual oleh Developer)

Urutan eksekusi SQL di Supabase Dashboard (SQL Editor):

1. Tambah kolom di `profiles`: `is_active`, `phone_number`, `avatar_url`
2. Tambah kolom di `tickets`: `reporter_id`
3. Buat tabel `ticket_attachments`
4. Buat tabel `ticket_history`
5. Buat function `log_ticket_changes()`
6. Buat trigger `on_ticket_update`
7. Update RLS policies (opsional, sesuai kebutuhan)

> Setiap langkah SQL disertakan lengkap di file `specs/` masing-masing capability.

---

## Open Questions

- Apakah avatar user disimpan di bucket `avatars` yang terpisah dari bucket `tickets`, atau
  digabung? (Rekomendasi: pisahkan ke bucket `avatars` untuk isolasi RLS yang lebih bersih)
- Apakah tracking screen menampilkan perubahan `assigned_to` juga, atau hanya perubahan `status`?
  (Rekomendasi: tampilkan keduanya untuk kelengkapan audit trail)
