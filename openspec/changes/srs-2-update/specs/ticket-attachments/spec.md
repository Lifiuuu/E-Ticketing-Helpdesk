## ADDED Requirements

### Requirement: Multi-attachment upload saat membuat tiket
User SHALL dapat melampirkan hingga 5 file (gambar) saat membuat tiket. File disimpan ke Supabase
Storage bucket `tickets/attachments/` dan relasi disimpan ke tabel `ticket_attachments`.
Field `image_url` di tabel `tickets` TIDAK diisi untuk tiket baru.

#### Scenario: Upload satu attachment
- **WHEN** user memilih satu gambar dari galeri atau kamera di form Create Ticket
- **THEN** preview thumbnail gambar tampil di form; file siap diupload saat submit

#### Scenario: Upload multiple attachments (maks. 5)
- **WHEN** user menambahkan attachment ke-6
- **THEN** sistem menampilkan pesan error "Maksimal 5 lampiran" dan menolak penambahan

#### Scenario: Submit tiket dengan attachment
- **WHEN** user menekan tombol Submit dengan attachment yang dipilih
- **THEN** semua file diupload terlebih dahulu, URL yang berhasil disimpan ke `ticket_attachments`,
  lalu tiket dibuat; jika salah satu upload gagal, tiket tidak dibuat dan error ditampilkan

#### Scenario: Submit tiket tanpa attachment
- **WHEN** user menekan Submit tanpa memilih attachment
- **THEN** tiket berhasil dibuat tanpa attachment (attachment bersifat opsional)

### Requirement: Tampilan attachments di detail tiket
Semua attachment milik sebuah tiket SHALL ditampilkan di `ticket_detail_screen` sebagai grid
thumbnail yang dapat di-tap untuk membuka full-screen viewer.

#### Scenario: Tiket dengan attachments baru (tabel ticket_attachments)
- **WHEN** user membuka detail tiket yang punya attachment di tabel `ticket_attachments`
- **THEN** grid thumbnail tampil di bawah deskripsi; setiap thumbnail bisa di-tap full-screen

#### Scenario: Tiket lama dengan image_url tunggal
- **WHEN** user membuka detail tiket lama yang hanya punya `image_url` (bukan dari tabel baru)
- **THEN** gambar lama ditampilkan sebagai satu attachment; tidak ada error/crash

#### Scenario: Tiket tanpa attachment
- **WHEN** tiket tidak punya attachment sama sekali
- **THEN** section attachment tidak tampil (hidden, bukan menampilkan placeholder kosong)

### Requirement: Hapus attachment yang dipilih sebelum submit
User SHALL dapat menghapus attachment yang sudah dipilih di form Create Ticket sebelum submit.

#### Scenario: Hapus attachment dari preview
- **WHEN** user menekan tombol "×" di atas thumbnail attachment yang dipilih
- **THEN** attachment tersebut dihapus dari daftar preview; jumlah attachment berkurang
