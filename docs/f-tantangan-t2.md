# F Rencana Tantangan SE — T2 Keamanan — Tim 2-A (draf)

> **DRAF** (Minggu, 22 Nov 2026) untuk bagian F proposal. Sumber: Modul 2 bagian 7 (lima butir T2 untuk Tim A), `docs/e3-kontrak-api.md`, `docs/e6-validasi.md`, dan **Kamus Data Bersama**.
> Bagian E8 menjelaskan ancaman dan mitigasinya; bagian F menjelaskan cara tim membuktikan bahwa mitigasi tersebut benar-benar berjalan.

## Jalur tantangan

**T2 Keamanan**

## Cara kerja umum

- Semua tes ditulis dengan `go test` dan `net/http/httptest`, dijalankan terhadap database tes (PostgreSQL pada port 5603) yang diisi data seed fiktif.
- Waktu "sekarang" disuntikkan ke logika bisnis (Kamus bagian 7), sehingga tes penguncian 15 menit dan token kedaluwarsa tidak perlu menunggu waktu sebenarnya.
- Tes dijalankan otomatis di GitHub Actions pada setiap push ke `main` (gratis untuk repo privat dalam batas menit bulanan), sehingga hasilnya dapat diperiksa orang lain.
- Semua bukti dikumpulkan di laporan tantangan pada minggu ke-4.

## Tabel F

| Yang akan dibuktikan | Cara mengukur | Target | Alat | Bukti yang dilampirkan |
|---|---|---|---|---|
| 1. Mahasiswa lain dan dosen non-pembimbing tidak dapat membaca kelompok atau hasil evaluasi kelompok ini (IDOR) | Tes integrasi login sebagai mahasiswa dari kelompok lain dan sebagai dosen yang bukan pembimbing, lalu mencoba membaca data kelompok dan hasil evaluasi: `/bimbingan/{kode_kelompok}`, `/putaran-evaluasi/{id}/rekap`, dan endpoint koordinator yang memuat kode kelompok. | Semua percobaan ditolak (403 atau 404) dan tidak ada data kelompok lain di body respons. | `go test`, `httptest`, database tes | `idor_test.go` dan keluaran `go test -v` |
| 2. Semua endpoint koordinator menolak mahasiswa dan dosen (pemisahan peran) | Tes berbasis tabel yang dibuat dari matriks peran–endpoint di E5: 31 endpoint × 4 kondisi (mahasiswa, dosen, koordinator, tanpa token). | Setiap kombinasi sesuai matriks. 21 endpoint khusus koordinator mengembalikan 403 untuk mahasiswa dan dosen, dan semua endpoint selain login dan `/healthz` mengembalikan 401 tanpa token. | `go test` (table-driven), `httptest` | `peran_test.go`, matriks E5, dan keluaran `go test -v` |
| 3. Identitas penilai tidak bocor di mana pun | Tes mengisi evaluasi dari beberapa akun koordinator (dosen koordinator dan asdos) dengan data seed, lalu mencari kode dan nama setiap penilai di body respons hasil evaluasi mahasiswa, di respons error (403, 404, 409, 422), di file ekspor CSV kelompok, dan di log aplikasi. Respons rekap koordinator dan dosen pembimbing tidak termasuk, karena mereka boleh melihat identitas penilai. | 0 kemunculan kode atau nama penilai pada respons untuk mahasiswa, file ekspor, dan log. Hasil evaluasi baru tersedia setelah putaran ditutup dan mahasiswa sudah dinilai (selain itu 409 `HASIL_BELUM_TERSEDIA`). | `go test`, `httptest`, pencarian string | `anonimitas_test.go` dan keluaran `go test -v` |
| 4. Login dikunci sementara setelah gagal beruntun | Tes login dengan password salah 3 kali, lalu login dengan password yang benar; waktu dimajukan 15 menit melalui jam yang disuntikkan, lalu login lagi. | Percobaan ke-4 mendapat 429 `TERLALU_BANYAK_PERMINTAAN` walaupun password benar; setelah 15 menit login berhasil (200). Pesan untuk identitas yang tidak ada dan password yang salah sama persis. | `go test`, jam palsu | `login_test.go` dan keluaran `go test -v` |
| 5. Token JWT yang kedaluwarsa atau dimanipulasi ditolak | Tes mengirim token yang sudah lewat `exp` (2 jam), token dengan header `alg` diganti (`none`, `HS512`, `RS256`), token dengan tanda tangan diubah, dan token yang ditandatangani dengan kunci lain. | 100% token tersebut ditolak dengan 401 `TIDAK_TERAUTENTIKASI`; server hanya menerima HS256. | `go test`, pustaka JWT | `jwt_test.go` dan keluaran `go test -v` |
| 6. Checklist ringkas OWASP API Security Top 10 (2023) | Setiap butir yang relevan dipetakan ke tes atau konfigurasi yang membuktikannya. | Minimal 7 butir dengan bukti (modul meminta minimal 6): API1, API2, API3, API4, API5, API8, API9. | Checklist Markdown, tes 1–5 | `docs/owasp-checklist.md` |

## Rincian checklist OWASP (untuk butir 6)

| Butir OWASP API 2023 | Bukti |
|---|---|
| API1 Broken Object Level Authorization | Tes butir 1 (IDOR); endpoint mahasiswa tidak menggunakan ID di path (`/kelompok-saya`, `/hasil-saya`). |
| API2 Broken Authentication | Tes butir 4 (penguncian login) dan butir 5 (JWT); password disimpan sebagai hash bcrypt. |
| API3 Broken Object Property Level Authorization | Field yang tidak dikenal ditolak (400, lihat E6); IPK dan minat hanya dikirim ke koordinator; hasil evaluasi untuk mahasiswa tidak memuat identitas penilai (butir 3). |
| API4 Unrestricted Resource Consumption | Batas ukuran body (JSON 1 MB, CSV 2 MB) dan `per_halaman` maksimal 100, diuji dengan tes validasi E6. |
| API5 Broken Function Level Authorization | Tes butir 2 (matriks peran–endpoint). |
| API8 Security Misconfiguration | Kunci JWT dan password database hanya dari variabel lingkungan; respons error tidak memuat stack trace atau pesan SQL; dicek dengan tes yang memicu error. |
| API9 Improper Inventory Management | Semua endpoint tercatat di `openapi.yaml`; tes membandingkan daftar route di router dengan `openapi.yaml`. |

## Batasan yang disadari

- Penguncian berlaku per akun, sehingga orang yang mengetahui NRP seseorang dapat sengaja mengunci akun tersebut selama 15 menit. Risiko ini diterima untuk lingkup proyek kelas karena dampaknya hanya sementara.
- Butir API6, API7, dan API10 tidak relevan: aplikasi tidak memiliki alur bisnis sensitif yang dapat diotomasi, tidak mengambil URL dari pengguna, dan tidak memanggil API pihak ketiga.
