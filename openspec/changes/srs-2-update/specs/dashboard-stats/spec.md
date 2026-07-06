## MODIFIED Requirements

### Requirement: Dashboard menampilkan 5 statistik status tiket
Dashboard SHALL menampilkan 5 kartu statistik: Total, Open, Assigned, In Progress, dan Closed.
Status "Resolved" digabung ke Closed untuk penyederhanaan tampilan.

#### Scenario: Dashboard Admin menampilkan 5 kartu
- **WHEN** Admin membuka Dashboard
- **THEN** tampil 5 kartu: Total (semua tiket), Open, Assigned (status == 'Assigned'),
  In Progress (status == 'In Progress'), Closed (status == 'Closed' atau 'Resolved')

#### Scenario: Dashboard Helpdesk menampilkan statistik tiket yang ditangani
- **WHEN** Helpdesk membuka Dashboard
- **THEN** 5 kartu menampilkan statistik dari tiket yang di-assign ke Helpdesk tersebut saja

#### Scenario: Dashboard User menampilkan statistik tiket miliknya
- **WHEN** User membuka Dashboard
- **THEN** 5 kartu menampilkan statistik dari tiket milik user tersebut saja

### Requirement: Ticket status lifecycle mencakup "Assigned"
Daftar status valid tiket SHALL mencakup: Open, Assigned, In Progress, Resolved, Closed.
Status "Assigned" digunakan saat tiket sudah di-assign ke helpdesk tetapi belum mulai dikerjakan.

#### Scenario: Admin assign helpdesk ke tiket Open
- **WHEN** Admin mengassign helpdesk ke tiket berstatus Open
- **THEN** status tiket berubah otomatis menjadi "Assigned" bersamaan dengan assignment

#### Scenario: Filter tiket by status Assigned
- **WHEN** user memilih filter "Assigned" di Tickets List
- **THEN** hanya tiket berstatus "Assigned" yang ditampilkan
