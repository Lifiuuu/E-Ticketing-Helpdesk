## MODIFIED Requirements

### Requirement: Helpdesk dapat membuat tiket
Helpdesk SHALL dapat mengakses form Create Ticket. Form menampilkan dropdown "Pilih Pelapor"
(daftar user dengan role User) yang wajib dipilih. Tiket dibuat dengan `user_id` = ID helpdesk
(pembuat) dan `reporter_id` = ID user yang dipilih dari dropdown.

#### Scenario: Helpdesk mengakses Create Ticket
- **WHEN** Helpdesk menekan tombol buat tiket
- **THEN** sistem navigasi ke `/create-ticket` (tidak diblokir router)

#### Scenario: Form Create Ticket untuk Helpdesk menampilkan dropdown pelapor
- **WHEN** Helpdesk berada di halaman Create Ticket
- **THEN** form menampilkan field tambahan "Pilih Pelapor" berupa dropdown berisi daftar
  semua user dengan role User; field ini wajib diisi

#### Scenario: Helpdesk submit tiket dengan pelapor dipilih
- **WHEN** Helpdesk mengisi judul, deskripsi, memilih pelapor, lalu menekan Submit
- **THEN** tiket dibuat dengan `reporter_id` = user yang dipilih; notifikasi dikirim ke admin

#### Scenario: Helpdesk submit tiket tanpa memilih pelapor
- **WHEN** Helpdesk menekan Submit tanpa memilih pelapor
- **THEN** validasi gagal dengan pesan "Pilih pelapor terlebih dahulu"

### Requirement: Admin dapat membuat tiket
Admin SHALL dapat mengakses form Create Ticket dengan dropdown "Pilih Pelapor" yang sama
seperti Helpdesk.

#### Scenario: Admin mengakses Create Ticket
- **WHEN** Admin menekan tombol buat tiket
- **THEN** sistem navigasi ke `/create-ticket` (tidak diblokir router)

#### Scenario: Form Create Ticket untuk Admin
- **WHEN** Admin berada di halaman Create Ticket
- **THEN** form menampilkan field "Pilih Pelapor" dengan daftar semua user role User

#### Scenario: Admin submit tiket dengan pelapor dipilih
- **WHEN** Admin memilih pelapor dan submit
- **THEN** tiket berhasil dibuat dengan `reporter_id` yang sesuai

### Requirement: User membuat tiket (tidak berubah)
User SHALL tetap dapat membuat tiket tanpa dropdown pelapor. `reporter_id` diisi otomatis
dengan ID user yang login.

#### Scenario: User membuat tiket
- **WHEN** User mengakses Create Ticket dan mengisi form
- **THEN** form tidak menampilkan dropdown pelapor; tiket dibuat dengan `reporter_id` = user.id
