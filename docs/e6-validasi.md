# E6 Validasi dan Penanganan Error — Tim 2-A (draf)

> **DRAF** (Minggu, 22 Nov 2026) untuk bagian E6 proposal. Sumber: `docs/e3-kontrak-api.md`, `openapi.yaml`, Modul 2 bagian 5, dan **Kamus Data Bersama**.
> Kolom "Sumber" hanya ada di berkas ini sebagai catatan tim; tabel di proposal hanya memuat tiga kolom templat.

## Aturan umum

- Semua error menggunakan format `{ "error": { "kode": "...", "pesan": "...", "detail": { ... } } }`. Untuk 422, `detail` berisi pesan per field, misalnya `{ "nama": "wajib diisi", "ukuran_min": "tidak boleh lebih besar dari ukuran_maks" }`.
- Semua kesalahan pada satu request dilaporkan sekaligus, bukan hanya kesalahan pertama.
- Teks di-*trim* (spasi di awal dan akhir dibuang) sebelum diperiksa. Panjang teks dihitung dalam rune, sehingga huruf seperti "é" dihitung satu karakter.
- Body yang bukan JSON yang valid, field dengan tipe yang salah (misalnya teks untuk skor), `Content-Type` yang salah, field yang tidak dikenal, atau body yang melebihi batas ukuran (JSON 1 MB, CSV 2 MB) menghasilkan **400 PERMINTAAN_RUSAK** (sesuai Kamus: "JSON rusak atau tipe salah").
- JSON yang sah tetapi isinya melanggar aturan (kosong, di luar rentang, format salah) menghasilkan **422 VALIDASI_GAGAL**.
- File CSV harus UTF-8, dipisahkan koma, dan baris pertama berisi nama kolom (Kamus bagian 5). Impor bersifat parsial: baris valid diproses, baris yang salah dilaporkan, dan mengimpor file yang sama dua kali tidak membuat data ganda.
- Parameter path dengan format yang salah (misalnya `kode_kelompok` atau `id` putaran) menghasilkan **404 TIDAK_DITEMUKAN**, karena data tersebut memang tidak ada.
- Pelanggaran aturan bisnis menggunakan kode 409 yang sudah ada di E3 dan tidak diulang di sini.
- Input yang salah tidak boleh menghasilkan 500.

## Tabel E6

| Masukan | Aturan validasi | Status dan kode galat | Sumber |
|---|---|---|---|
| Login: `identitas`, `sandi` | Keduanya wajib diisi. `identitas` berupa NRP (10 digit) atau `kode_dosen` (2–10 huruf/angka). | 422 VALIDASI_GAGAL. Identitas atau password salah: 401 TIDAK_TERAUTENTIKASI dengan pesan yang sama untuk keduanya. Setelah 3 kali gagal: 429 TERLALU_BANYAK_PERMINTAAN selama 15 menit. | Kamus, keputusan tim |
| Ganti password: `sandi_lama`, `sandi_baru` | Keduanya wajib diisi. `sandi_baru` minimal 8 karakter dan berbeda dari `sandi_lama`. `sandi_lama` harus cocok. | 422 VALIDASI_GAGAL | Kamus, usulan tim |
| CSV mahasiswa: file | File CSV yang dapat dibaca dengan header `nrp,nama,email,angkatan`. | File rusak atau kosong: 400 PERMINTAAN_RUSAK. Header tidak sesuai: 422 VALIDASI_GAGAL. | Modul (M2-01) |
| CSV mahasiswa: setiap baris | `nrp` 10 digit, `nama` 1–100 karakter, `email` berformat email, `angkatan` berupa tahun 4 digit. NRP yang sudah ada dengan nama atau email berbeda dianggap gagal. NRP yang sama dengan data sama dilewati (tidak menambah data). | 200 dengan laporan impor; baris yang gagal dicantumkan di `gagal` beserta nomor baris dan alasannya. | Modul (M2-01) |
| CSV minat: file dan setiap baris | Header `nrp,preferensi_peran,minat1,minat2,minat3`. `nrp` 10 digit dan sudah terdaftar. `preferensi_peran` dan `minat1` wajib diisi. | File rusak: 400 PERMINTAAN_RUSAK. Header tidak sesuai: 422 VALIDASI_GAGAL. Baris salah: dicantumkan di laporan impor. | Modul (M2-14) |
| Pengaturan periode: `ukuran_min`, `ukuran_maks` | Keduanya minimal 1 dan `ukuran_min` ≤ `ukuran_maks`. | 422 VALIDASI_GAGAL | Modul aturan 2 |
| `periode` (path, query, dan body) | Pola `TTTT-S`, misalnya `2026-1` (S bernilai 1 atau 2). | Body atau query: 422 VALIDASI_GAGAL. Path: 404 TIDAK_DITEMUKAN. | Kamus |
| Kelompok baru: `kode_kelompok`, `nama` | `kode_kelompok` berpola `CP-TTTT-S-nn`, misalnya `CP-2026-1-07`. `nama` 1–100 karakter. | 422 VALIDASI_GAGAL. Kode sudah dipakai: 409 (lihat E3). | Kamus, usulan tim |
| Ubah kelompok: `nama`, `pembimbing`, `ketua_nrp` | Minimal satu field dikirim. `nama` 1–100 karakter. `pembimbing` adalah `kode_dosen` yang terdaftar. `ketua_nrp` 10 digit atau `null`. | 422 VALIDASI_GAGAL. Ketua bukan anggota: 409 (lihat E3). | Modul (M2-02, M2-05) |
| Tambah anggota: `nrp` | Array berisi minimal 1 NRP, setiap NRP 10 digit dan tidak ada yang ganda. | 422 VALIDASI_GAGAL. NRP tidak terdaftar: 404 TIDAK_DITEMUKAN. | Modul (M2-03) |
| Pindah anggota: `nrp`, `ke_kelompok` | `nrp` 10 digit. `ke_kelompok` berpola `CP-TTTT-S-nn` dan berbeda dari kelompok asal. | 422 VALIDASI_GAGAL. Mahasiswa atau kelompok tidak ada: 404 TIDAK_DITEMUKAN. | Modul (M2-03, M2-08) |
| `alasan` perubahan anggota | Wajib diisi (1–500 karakter) jika kelompok sudah terbit. Boleh kosong jika kelompok masih draf. | 422 VALIDASI_GAGAL | Modul aturan 6 |
| Putaran evaluasi baru: `nama`, `periode` | `nama` 1–100 karakter. `periode` berpola `TTTT-S`. | 422 VALIDASI_GAGAL | Modul (M2-10) |
| Evaluasi: daftar target | Harus menilai setiap anggota kelompok lain tepat satu kali. Tidak boleh menilai diri sendiri. Tidak boleh menilai mahasiswa di luar kelompok. | 422 VALIDASI_GAGAL | Modul aturan 7 |
| Evaluasi: skor | `kontribusi_teknis`, `komunikasi`, dan `tanggung_jawab` wajib diisi dengan bilangan bulat 1–5. | 422 VALIDASI_GAGAL | Modul (M2-11) |
| Evaluasi: `komentar` | Opsional, maksimal 300 karakter. | 422 VALIDASI_GAGAL | Modul (M2-11) |
| Pagination: `halaman`, `per_halaman` | `halaman` minimal 1. `per_halaman` 1–100 (default 20). | 422 VALIDASI_GAGAL | Kamus |
