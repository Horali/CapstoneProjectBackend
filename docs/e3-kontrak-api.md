# E3 Kontrak API — Tim 2-A (draf)

> **DRAF** (Minggu, 22 Nov 2026) untuk bagian E3 proposal. Sumber: `docs/draf-tabel-endpoint.md`, Modul 2 bagian 4–6, rekaman wawancara 20 Nov, dan **Kamus Data Bersama** (folder dosen).
> `openapi.yaml` nanti ditulis langsung dari tabel ini supaya isinya sama persis.

## Konvensi (dari Kamus Data Bersama)

- Semua path diawali `/api/v1`. Request dan response menggunakan JSON, dengan nama field `snake_case` berbahasa Indonesia.
- ID yang muncul di API: `nrp` (10 digit), `kode_dosen`, `kode_kelompok` (`CP-<periode>-nn`, mis. `CP-2026-1-07`), `periode` (`TTTT-S`, mis. `2026-1`).
- Login menggunakan **NRP atau kode_dosen dan password**. Token JWT HS256 berlaku selama 2 jam dan berisi `sub`, `peran`, serta `exp`.
- Endpoint yang mengembalikan daftar menggunakan pagination melalui query `halaman` dan `per_halaman` (default 20, maksimal 100).
- Format error: `{ "error": { "kode": "...", "pesan": "...", "detail": { ... } } }`.
- Kode error umum: 400 `PERMINTAAN_RUSAK`, 401 `TIDAK_TERAUTENTIKASI`, 403 `DILARANG`, 404 `TIDAK_DITEMUKAN`, 422 `VALIDASI_GAGAL`, 429 `TERLALU_BANYAK_PERMINTAAN`. Kode 409 khusus modul ini (lihat bawah). Input yang salah tidak boleh menghasilkan 500.

## Tabel E3

Semua endpoint selain login dan `/healthz` memerlukan token. Status 401 dikembalikan jika token tidak ada atau tidak valid, dan 403 jika peran pengguna tidak memiliki akses.

| No | Metode | Alur (path) | Peran | Kebutuhan | Berhasil | Galat yang mungkin |
|----|--------|-------------|-------|-----------|----------|--------------------|
| 1 | GET | `/healthz` | publik | BASE-09 | 200 | 503 (database tidak dapat dihubungi) |
| 2 | POST | `/api/v1/auth/login` | publik | BASE-01 | 200 | 400, 401, 422, 429 `TERLALU_BANYAK_PERMINTAAN` (terkunci setelah 3x salah) |
| 3 | POST | `/api/v1/auth/ganti-sandi` | semua | BASE-01 | 204 | 401, 422 |
| 4 | GET | `/api/v1/saya` | semua | BASE-01 | 200 | 401 |
| 5 | POST | `/api/v1/mahasiswa/impor` | koordinator | M2-01 | 200 (laporan impor) | 400, 401, 403, 422 |
| 6 | GET | `/api/v1/mahasiswa?belum_berkelompok=true` | koordinator | M2-04, M2-14 | 200 | 401, 403 |
| 7 | GET | `/api/v1/dosen` | koordinator | M2-05 | 200 | 401, 403 |
| 8 | GET | `/api/v1/periode/{periode}/pengaturan` | koordinator | M2-04 | 200 | 401, 403, 404 |
| 9 | PUT | `/api/v1/periode/{periode}/pengaturan` | koordinator | M2-04 | 200 | 401, 403, 404, 422 |
| 10 | POST | `/api/v1/kelompok` | koordinator | M2-02 | 201 | 401, 403, 422, 409 `KODE_KELOMPOK_SUDAH_ADA` |
| 11 | GET | `/api/v1/kelompok` | koordinator | M2-04 | 200 (ringkasan: jumlah anggota, kurang/lebih batas) | 401, 403 |
| 12 | GET | `/api/v1/kelompok/{kode_kelompok}` | koordinator | M2-04 | 200 | 401, 403, 404 |
| 13 | PATCH | `/api/v1/kelompok/{kode_kelompok}` | koordinator | M2-02, M2-05 | 200 | 401, 403, 404, 422, 409 `KETUA_BUKAN_ANGGOTA` |
| 14 | DELETE | `/api/v1/kelompok/{kode_kelompok}` | koordinator | M2-02 | 204 | 401, 403, 404, 409 `KELOMPOK_SUDAH_TERBIT` |
| 15 | POST | `/api/v1/kelompok/{kode_kelompok}/anggota` | koordinator | M2-03 | 200 | 401, 403, 404, 422 (alasan kosong setelah terbit), 409 `KELOMPOK_PENUH`, 409 `SUDAH_BERKELOMPOK`, 409 `PUTARAN_BERJALAN` |
| 16 | POST | `/api/v1/keanggotaan/pindah` | koordinator | M2-03, M2-08 | 200 | 401, 403, 404, 422 (alasan kosong setelah terbit), 409 `KELOMPOK_PENUH`, 409 `PUTARAN_BERJALAN` |
| 17 | DELETE | `/api/v1/kelompok/{kode_kelompok}/anggota/{nrp}` | koordinator | M2-03, M2-08 | 204 | 401, 403, 404, 422 (alasan kosong setelah terbit), 409 `PUTARAN_BERJALAN` |
| 18 | GET | `/api/v1/kelompok/{kode_kelompok}/riwayat` | koordinator | M2-08 | 200 | 401, 403, 404 |
| 19 | POST | `/api/v1/kelompok/terbitkan` | koordinator | M2-06 | 200 | 401, 403, 409 `SYARAT_PENERBITAN_TIDAK_TERPENUHI` (detail: pelanggaran per kelompok) |
| 20 | GET | `/api/v1/kelompok/ekspor` | koordinator | M2-09 | 200 (`text/csv`: kode_kelompok,nama,pembimbing,nrp) | 401, 403 |
| 21 | GET | `/api/v1/kelompok-saya` | mahasiswa | M2-07 | 200 | 401, 403, 404 (belum terbit atau belum berkelompok) |
| 22 | GET | `/api/v1/bimbingan` | dosen | M2-07 | 200 | 401, 403 |
| 23 | GET | `/api/v1/bimbingan/{kode_kelompok}` | dosen | M2-07 | 200 | 401, 403 (bukan bimbingannya), 404 |
| 24 | POST | `/api/v1/putaran-evaluasi` | koordinator | M2-10 | 201 | 401, 403, 422 |
| 25 | GET | `/api/v1/putaran-evaluasi` | semua | M2-10 | 200 | 401 |
| 26 | POST | `/api/v1/putaran-evaluasi/{id}/tutup` | koordinator | M2-10 | 200 | 401, 403, 404, 409 `PUTARAN_DITUTUP` |
| 27 | GET | `/api/v1/putaran-evaluasi/{id}/formulir` | mahasiswa | M2-11 | 200 (daftar anggota yang dinilai) | 401, 403, 404, 409 `PUTARAN_DITUTUP` |
| 28 | PUT | `/api/v1/putaran-evaluasi/{id}/evaluasi-saya` | mahasiswa | M2-11 | 200 | 401, 403, 404, 422 (kurang satu anggota, menilai diri sendiri, skor di luar 1–5, komentar > 300 karakter), 409 `PUTARAN_DITUTUP` |
| 29 | GET | `/api/v1/putaran-evaluasi/{id}/ringkasan-saya` | mahasiswa | M2-12 | 200 (rata-rata per kriteria + komentar, **tanpa identitas penilai**) | 401, 403, 404, 409 `RINGKASAN_BELUM_TERSEDIA` (putaran belum ditutup atau penilai < 2) |
| 30 | GET | `/api/v1/putaran-evaluasi/{id}/rekap` | koordinator, dosen (kelompok bimbingan saja) | M2-13, M2-15 | 200 (belum mengisi, rekap per anggota, penanda timpang) | 401, 403, 404 |
| 31 | POST | `/api/v1/minat/impor` | koordinator | M2-14 | 200 (laporan impor) | 400, 401, 403, 422 |

## Kode 409 yang dipakai

| Kode | Kapan | Sumber |
|------|-------|--------|
| `KELOMPOK_PENUH` | menempatkan/memindahkan ke kelompok yang sudah mencapai ukuran_maks | modul (aturan 2) |
| `SUDAH_BERKELOMPOK` | menempatkan mahasiswa yang sudah punya kelompok di periode itu | modul (aturan 3) |
| `SYARAT_PENERBITAN_TIDAK_TERPENUHI` | ada kelompok draf yang melanggar syarat; tak satu pun terbit | modul (aturan 4) |
| `PUTARAN_BERJALAN` | mengubah anggota kelompok yang sedang dalam putaran evaluasi terbuka | modul (aturan 6) |
| `PUTARAN_DITUTUP` | mengubah atau mengisi putaran yang sudah ditutup | modul (aturan 8) |
| `KELOMPOK_SUDAH_TERBIT` | menghapus kelompok yang sudah terbit (hanya draf boleh dihapus) | usulan tim (M2-02) |
| `KODE_KELOMPOK_SUDAH_ADA` | membuat kelompok dengan kode yang sudah dipakai | usulan tim |
| `KETUA_BUKAN_ANGGOTA` | menetapkan ketua yang bukan anggota kelompok itu | usulan tim |
| `RINGKASAN_BELUM_TERSEDIA` | ringkasan diminta sebelum putaran ditutup atau penilai kurang dari 2 | usulan tim (aturan 9) |

## Cek kelengkapan

Semua kebutuhan Wajib (M2-01 s.d. M2-13) punya minimal satu endpoint. Sebaiknya: M2-14 (no. 31, ditampilkan di no. 6) dan M2-15 (no. 30).

## Catatan desain (untuk dijelaskan saat demo)

- Endpoint mahasiswa tidak menggunakan kode kelompok di path (`/kelompok-saya`, `/evaluasi-saya`), sehingga mahasiswa tidak dapat mengakses kelompok lain dengan mengganti ID (mencegah IDOR).
- Dosen hanya mengakses `/bimbingan/...`; server memeriksa bahwa kelompok tersebut merupakan kelompok bimbingannya, dan mengembalikan 403 jika bukan.
- Pindah anggota dan terbitkan kelompok adalah operasi atomik (lihat E4).
