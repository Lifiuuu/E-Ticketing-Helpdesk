## MODIFIED Requirements

### Requirement: Admin dapat memfilter tiket berdasarkan helpdesk yang ditugaskan
Untuk role Admin, `TicketsListScreen` SHALL menyediakan filter tambahan berupa dropdown
"Filter by Helpdesk" di samping filter status yang sudah ada.

#### Scenario: Admin melihat filter by helpdesk
- **WHEN** Admin membuka Tickets List
- **THEN** tampil dua filter: filter status (sudah ada) DAN dropdown "Semua Helpdesk" yang
  berisi daftar helpdesk yang terdaftar

#### Scenario: Admin memilih helpdesk tertentu
- **WHEN** Admin memilih nama helpdesk dari dropdown filter
- **THEN** daftar tiket difilter hanya menampilkan tiket yang di-assign ke helpdesk tersebut;
  filter status tetap bisa dikombinasikan

#### Scenario: Admin reset filter helpdesk
- **WHEN** Admin memilih "Semua Helpdesk" (pilihan default)
- **THEN** filter helpdesk dihapus; semua tiket tampil kembali (tetap tunduk filter status)

#### Scenario: Helpdesk dan User tidak melihat filter by helpdesk
- **WHEN** Helpdesk atau User membuka Tickets List
- **THEN** dropdown filter helpdesk tidak tampil; hanya filter status yang tersedia
