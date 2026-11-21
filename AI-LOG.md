# AI-LOG — Tim 2-A

Catatan setiap bantuan AI (sesuai Templat Proposal bagian J). Isi tetap berasal dari modul, wawancara, dan keputusan tim; setiap hasil AI dicek dan harus bisa dijelaskan oleh anggota yang memakainya.

| No | Tanggal | Anggota | Bagian / berkas | Bantuan AI | Yang dicek atau diubah tim |
|----|---------|---------|-----------------|------------|----------------------------|
| 1 | 21 Nov 2026 | Faiz | Notulensi wawancara | Membuat transkrip dari takarir otomatis rekaman Zoom, membandingkannya dengan notulensi, dan mengusulkan koreksi | Tim memilih koreksi yang dipakai; kata-kata asli notulensi dipertahankan |
| 2 | 22 Nov 2026 | Faiz | `docs/draf-tabel-endpoint.md` | Menyusun draf 10 tabel dan 28 endpoint dari Modul 2 bagian 3–5 dan hasil wawancara | Anggota membaca seluruh draf dan mencocokkan nama kolom dengan Kamus Data Bersama sebelum disetujui |
| 3 | 22 Nov 2026 | Faiz | E3 Kontrak API (`docs/e3-kontrak-api.md`) | Menyusun tabel 31 endpoint dan daftar kode 409 dari draf endpoint, Modul 2, dan Kamus Data Bersama | Bahasa diubah menjadi lebih formal dengan istilah teknis yang umum; isi tabel dicek sebelum disetujui |
| 4 | 22 Nov 2026 | Faiz | `openapi.yaml` | Menulis spesifikasi OpenAPI 3.0 dari tabel E3, lalu memvalidasinya dan membandingkannya otomatis dengan E3 (31 endpoint, 0 perbedaan) | Isi spesifikasi dicek agar sama dengan E3 |
| 5 | 22 Nov 2026 | Faiz | E6 Validasi (`docs/e6-validasi.md`) dan perbaikan kecil `openapi.yaml` | Menyusun 17 aturan validasi dari Modul 2, Kamus Data Bersama, dan `openapi.yaml`; menambahkan 3 pola dan batas `alasan` ke `openapi.yaml` | Aturan dicek terhadap modul dan Kamus; aturan tambahan (batas alasan 500 karakter, password baru harus berbeda, field tidak dikenal ditolak) disetujui tim |
| 6 | 22 Nov 2026 | Faiz | F Rencana tantangan T2 Keamanan (`docs/f-tantangan-t2.md`) | Mengubah 5 butir T2 di Modul 2 bagian 7 menjadi 6 target yang dapat diperiksa, beserta checklist OWASP API Top 10 (7 butir) | Rencana disetujui tim, termasuk batasan penguncian per akun dan pengecualian rekap koordinator dari tes anonimitas |
