## MODIFIED Requirements

### Requirement: Profile Screen menjadi editable
Profile Screen SHALL memungkinkan user mengedit nama lengkap, nomor telepon, dan foto profil/avatar.
Data disimpan ke tabel `profiles`; avatar diupload ke Supabase Storage bucket `avatars`.

#### Scenario: User melihat profil saat ini
- **WHEN** user membuka Profile Screen
- **THEN** tampil nama lengkap, email (read-only), role (read-only), nomor telepon, dan foto avatar

#### Scenario: User mengedit nama
- **WHEN** user mengubah teks di field nama dan menekan "Simpan"
- **THEN** nama diperbarui di tabel `profiles`; `AuthState.username` diperbarui via `_refreshProfile`

#### Scenario: User mengedit nomor telepon
- **WHEN** user mengisi atau mengubah nomor telepon dan menekan "Simpan"
- **THEN** `phone_number` diperbarui di tabel `profiles`

#### Scenario: User mengupload avatar
- **WHEN** user memilih foto dari galeri/kamera dan menekan "Simpan"
- **THEN** foto diupload ke Supabase Storage bucket `avatars/` dengan path `{userId}/avatar.jpg`;
  `avatar_url` di tabel `profiles` diperbarui dengan URL publik

#### Scenario: Simpan profil gagal (network error)
- **WHEN** penyimpanan gagal karena error jaringan
- **THEN** SnackBar menampilkan pesan error; data lokal tidak berubah

### Requirement: ProfileModel mendukung field baru
`ProfileModel` SHALL menyimpan `isActive`, `phoneNumber`, dan `avatarUrl` dari tabel `profiles`.
Semua field baru bersifat nullable untuk kompatibilitas dengan data profil lama.

#### Scenario: Profil dengan semua field baru
- **WHEN** `ProfileModel.fromJson` dipanggil dengan data yang berisi semua field baru
- **THEN** semua field ter-parse dengan benar tanpa error

#### Scenario: Profil lama tanpa field baru
- **WHEN** `ProfileModel.fromJson` dipanggil dengan data tanpa field baru (null)
- **THEN** field nullable default null; tidak ada error

### Requirement: Dark mode toggle dihapus dari Profile Screen
Toggle dark/light mode dipindah ke Settings Screen.

#### Scenario: Profile Screen tidak menampilkan toggle dark mode
- **WHEN** user membuka Profile Screen
- **THEN** tidak ada switch/toggle theme mode di halaman ini
