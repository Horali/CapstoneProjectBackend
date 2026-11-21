# Draf daftar tabel dan endpoint — Tim 2-A

> **DRAF** (Minggu, 22 Nov 2026). Dipakai untuk E2, E3, E4, E5, E6, E9, F, dan `openapi.yaml`.
> Sumber: Modul 2 bagian 3–5, rekaman wawancara 20 Nov, dan bagian 4 dokumen pembagian tugas.
> Nama pengenal (nrp, kode_dosen, kode_kelompok) dan format error **harus dicek dengan Kamus Data Bersama** (berkasnya belum ada di repo).

## 1. Daftar tabel

| No | Tabel | Kolom utama | Aturan penting | Sumber |
|----|-------|-------------|----------------|--------|
| 1 | `pengguna` | id, email, kata_sandi_hash, peran (koordinator/dosen/mahasiswa), harus_ganti_sandi, gagal_login, terkunci_sampai | email UNIQUE; peran CHECK | BASE-01, wawancara (sandi default, kunci setelah 3x salah) |
| 2 | `mahasiswa` | nrp (PK), pengguna_id, nama, email, angkatan, ipk (boleh kosong) | IPK hanya boleh dilihat koordinator | M2-01, wawancara (IPK disimpan, CV tidak) |
| 3 | `dosen` | kode_dosen (PK), pengguna_id, nama, email | asumsi: data dosen dari seed | modul bagian 2 |
| 4 | `periode` | kode (PK, mis. 2026-gasal), nama, ukuran_min (default 3), ukuran_maks (default 4) | CHECK ukuran_min ≤ ukuran_maks. Gabungan "Periode" + "PengaturanKelompok" | modul bagian 3, wawancara (ukuran bisa diatur) |
| 5 | `kelompok` | kode_kelompok (PK), periode, nama, ketua_nrp (opsional), pembimbing (kode_dosen), status (draf/terbit) | status CHECK; FK ke dosen dan mahasiswa | modul bagian 3 |
| 6 | `keanggotaan` | periode, nrp, kode_kelompok, peran_tim (opsional) | **PRIMARY KEY (periode, nrp)** → satu mahasiswa satu kelompok per periode, dijaga database | aturan bisnis 1, wawancara (tukar peran boleh) |
| 7 | `riwayat_keanggotaan` | id, waktu, nrp, dari_kelompok, ke_kelompok, oleh (pengguna_id), alasan | hanya bertambah (tidak ada UPDATE/DELETE) | M2-08 |
| 8 | `putaran_evaluasi` | id, periode, nama, dibuka, ditutup (kosong = masih buka) | putaran tertutup tidak bisa diubah | M2-10 |
| 9 | `evaluasi` | putaran_id, penilai_nrp, target_nrp, skor_kontribusi_teknis, skor_komunikasi, skor_tanggung_jawab, komentar | PK (putaran_id, penilai_nrp, target_nrp); skor CHECK 1–5; komentar ≤ 300; CHECK penilai ≠ target | M2-11, aturan bisnis 7 |
| 10 | `minat_mahasiswa` | periode, nrp, studi_kasus, peran (pasangan, bisa beberapa baris berperingkat) | Sebaiknya (M2-14) | wawancara (minat = studi kasus + peran) |

## 2. Daftar endpoint

Format: `METODE /path — peran — kebutuhan`. Semua kecuali login dan healthz butuh JWT.

### Dasar
| No | Endpoint | Peran | Kebutuhan |
|----|----------|-------|-----------|
| 1 | `GET /healthz` | publik | BASE-09 |
| 2 | `POST /auth/login` | publik | BASE-01 (kunci 15 menit setelah 3x salah, sesi 2 jam) |
| 3 | `POST /auth/ganti-sandi` | semua | wajib saat login pertama |
| 4 | `GET /saya` | semua | data akun sendiri + peran |

### Mahasiswa, dosen, periode
| No | Endpoint | Peran | Kebutuhan |
|----|----------|-------|-----------|
| 5 | `POST /mahasiswa/impor` (CSV nrp,nama,email,angkatan) | koordinator | M2-01 (laporan per baris; impor ulang tidak menambah data; NRP sama tapi data beda = gagal) |
| 6 | `GET /mahasiswa?belum_berkelompok=true` | koordinator | M2-04 |
| 7 | `GET /dosen` | koordinator | untuk memilih pembimbing (M2-05) |
| 8 | `GET /periode/{kode}/pengaturan`, `PUT /periode/{kode}/pengaturan` | koordinator | ukuran min/maks per periode |
| 9 | `POST /minat/impor` (CSV) | koordinator | M2-14 (Sebaiknya); ditampilkan di endpoint 6 |

### Kelompok
| No | Endpoint | Peran | Kebutuhan |
|----|----------|-------|-----------|
| 10 | `POST /kelompok` | koordinator | M2-02 |
| 11 | `GET /kelompok` (ringkasan: jumlah anggota, kurang/lebih batas) | koordinator | M2-04 |
| 12 | `PATCH /kelompok/{kode}` (nama, pembimbing, ketua) | koordinator | M2-02, M2-05 |
| 13 | `DELETE /kelompok/{kode}` | koordinator | M2-02 (hanya draf → 409 bila sudah terbit) |
| 14 | `POST /kelompok/{kode}/anggota` (satu atau banyak nrp) | koordinator | M2-03 (409 KELOMPOK_PENUH, 409 SUDAH_BERKELOMPOK) |
| 15 | `POST /keanggotaan/pindah` (nrp, ke_kelompok, alasan) | koordinator | M2-03, **atomik** (E4); alasan wajib setelah terbit (422); 409 PUTARAN_BERJALAN |
| 16 | `DELETE /kelompok/{kode}/anggota/{nrp}` (alasan di body bila sudah terbit) | koordinator | M2-03, M2-08 |
| 17 | `GET /kelompok/{kode}/riwayat` | koordinator | M2-08 |
| 18 | `POST /kelompok/terbitkan` | koordinator | M2-06, **atomik** (E4); 409 SYARAT_PENERBITAN_TIDAK_TERPENUHI + daftar pelanggaran |
| 19 | `GET /kelompok/ekspor.csv` | koordinator | M2-09 (kode_kelompok,nama,pembimbing,nrp) |
| 20 | `GET /kelompok-saya` | mahasiswa | M2-07 (hanya setelah terbit) |
| 21 | `GET /bimbingan` dan `GET /bimbingan/{kode}` | dosen | modul bagian 2 (hanya kelompok bimbingannya → uji IDOR) |

### Evaluasi
| No | Endpoint | Peran | Kebutuhan |
|----|----------|-------|-----------|
| 22 | `POST /putaran-evaluasi` | koordinator | M2-10 |
| 23 | `POST /putaran-evaluasi/{id}/tutup` | koordinator | M2-10 (409 PUTARAN_DITUTUP bila sudah) |
| 24 | `GET /putaran-evaluasi` | semua (sesuai peran) | daftar putaran |
| 25 | `GET /putaran-evaluasi/{id}/formulir` | mahasiswa | daftar anggota yang harus dinilai |
| 26 | `PUT /putaran-evaluasi/{id}/evaluasi-saya` (semua anggota sekaligus) | mahasiswa | M2-11 (kurang satu / menilai diri sendiri → 422; boleh kirim ulang selama buka) |
| 27 | `GET /putaran-evaluasi/{id}/ringkasan-saya` | mahasiswa | M2-12 (setelah ditutup, penilai ≥ 2, **tanpa identitas penilai**) |
| 28 | `GET /putaran-evaluasi/{id}/rekap` | koordinator; dosen (kelompok bimbingan saja) | M2-13 (siapa belum mengisi + rekap per anggota); M2-15 penanda timpang (selisih > 1,0) |

## 3. Yang perlu dicek tim

- Cocokkan nama kolom dan format error dengan **Kamus Data Bersama**.
- Asal data dosen: seed (asumsi). Kalau kamus/koordinator punya format impor dosen, tambah endpoint impor dosen.
- Koordinator dianggap satu akun dengan peran `koordinator` (bukan dosen biasa).
- Kolom `mitra` di matriks E5: semua ✗ (modul ini tidak punya peran mitra).
