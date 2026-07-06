## ADDED Requirements

### Requirement: Settings Screen tersedia sebagai halaman terpisah
Sistem SHALL menyediakan `SettingsScreen` (route `/settings`) yang berisi:
- Toggle dark/light mode (dipindah dari Profile Screen)
- Tombol Logout
- Link navigasi ke Profile Screen

#### Scenario: Buka Settings dari AppBar
- **WHEN** user menekan ikon Settings (gear) di AppBar screen utama (Dashboard, Tickets)
- **THEN** sistem navigasi ke `/settings`

#### Scenario: Toggle dark mode dari Settings
- **WHEN** user mengaktifkan switch "Mode Gelap" di Settings Screen
- **THEN** aplikasi berpindah ke dark theme; preferensi disimpan ke SharedPreferences

#### Scenario: Toggle light mode dari Settings
- **WHEN** user menonaktifkan switch "Mode Gelap" di Settings Screen
- **THEN** aplikasi berpindah ke light theme; preferensi disimpan ke SharedPreferences

#### Scenario: Logout dari Settings
- **WHEN** user menekan tombol "Keluar" di Settings Screen
- **THEN** AuthNotifier.logout() dipanggil dan user diarahkan ke `/login`

#### Scenario: Navigasi ke Profile dari Settings
- **WHEN** user menekan "Lihat Profil" di Settings Screen
- **THEN** sistem navigasi ke `/profile`

### Requirement: Dark mode toggle dihapus dari Profile Screen
Toggle dark/light mode yang sebelumnya ada di Profile Screen SHALL dihapus dari sana
karena dipindah ke Settings Screen.

#### Scenario: Profile Screen tanpa toggle theme
- **WHEN** user membuka Profile Screen
- **THEN** tidak ada toggle dark/light mode di halaman ini; hanya info profil dan form edit
