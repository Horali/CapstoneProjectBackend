# Pembagian Tugas Proposal — Tim 2-A (Modul 2, T2 Keamanan)

Tim: **Orang 1** (Backend), **Orang 2** (Backend), **Orang 3** (Backend + Frontend).
Ganti "Orang 1/2/3" dengan nama masing-masing.

Yang dikumpulkan: **Proposal_2-A.pdf** (bagian A–L) **dan `openapi.yaml` di repo** (harus sama dengan E3).

---

## FASE 1 — Kerjakan duluan (malam ini / besok)

Hanya hal penting yang **tidak menunggu orang lain**, tapi **membuka jalan** untuk bagian lain.

### Orang 1 (Backend): "tulang punggung" KASAR
Tidak perlu final, cukup draf supaya yang lain bisa mulai.

- [ ] **Daftar tabel.** Hampir sudah ada di modul bagian 3 "Data utama": kelompok, keanggotaan, riwayat_keanggotaan, pengaturan_kelompok, putaran_evaluasi, evaluasi, masukan_minat, ditambah tabel pengguna (mahasiswa/dosen/akun). Cukup tulis nama tabel + kolom penting.
- [ ] **Daftar endpoint kasar.** Untuk setiap kebutuhan M2-01 sampai M2-15, tulis 1 baris: `METODE /path — siapa yang boleh — M2-xx`.
  Contoh format: `POST /api/v1/mahasiswa/impor — koordinator — M2-01`
- [ ] Taruh di satu file bersama (mis. Google Docs / `docs/draf-tulang-punggung.md`) dan kabari grup.

> Kenapa satu orang? Semua bagian teknis bergantung pada dua daftar ini. Kalau dikerjakan ramai-ramai, hasilnya jadi beda-beda versi. Nanti cukup direview bareng.

### Orang 2 (Backend): urusan dosen + bagian C dan D
- [ ] **Kirim pesan klarifikasi ke dosen** (draf ada di bawah). Ini paling mendesak karena jawabannya mengubah isi D1, D3, dan E.
- [ ] **Minta dokumen yang belum kita punya:** Kamus Data Bersama, Rubrik Proposal, data seed fiktif, berkas `.env` tim 2-A.
- [ ] **Rapikan notulensi** (hapus catatan iseng seperti "hell naw", "i guess bro", "(?)"; perbaiki salah ketik, mis. "npr" → "nrp").
- [ ] Isi **C1** (kondisi sekarang), **C2** (hasil wawancara), dan **C3** (6 pertanyaan modul + jawabannya; tulis "dijawab dosen, 20 Nov 2026").

### Orang 3 (Backend + Frontend): data tim + sketsa layar
- [ ] **Kumpulkan data anggota:** nama lengkap, NRP, email, siapa ketua.
- [ ] **Buat repo privat tim** (catat alamatnya untuk halaman judul).
- [ ] **Daftar halaman** untuk wireframe (E12): login, ganti kata sandi pertama kali, daftar mahasiswa belum berkelompok, papan susun kelompok, terbitkan kelompok, ekspor, halaman mahasiswa ("kelompok sedang dibuat" lalu kelompoknya). Sketsa kasar saja dulu.
- [ ] Ambil **logo dan warna** dari Classroom.

---

## FASE 2 — Setelah tulang punggung + jawaban dosen ada

Bagian yang saling bergantung dipegang orang yang sama sebisa mungkin.

| Orang | Bagian | Bergantung pada |
|---|---|---|
| **Orang 1** | **E3** tabel kontrak API + **`openapi.yaml`** (paling berat) | daftar endpoint (punya sendiri) |
| | **E6** validasi dan kode galat | endpoint (punya sendiri) + Kamus Data |
| | **F** rencana tantangan T2 (ubah tiap butir T2 di modul jadi target yang bisa diukur) | endpoint (punya sendiri) |
| **Orang 2** | **D1–D5** ruang lingkup, di luar lingkup, asumsi, kriteria keberhasilan | jawaban dosen |
| | **E2** ERD + DDL (CREATE TABLE lengkap dengan constraint) | daftar tabel Orang 1 |
| | **E4** operasi atomik (pindah anggota, terbitkan semua) + diagram urutan | E2 (punya sendiri) |
| | **E11** minimal 2 keputusan desain | E2/E4 (punya sendiri) |
| **Orang 3** | **B** peran dan hak akses | modul + wawancara |
| | **E1** arsitektur (Go net/http, pgx, struktur folder, diagram) | — |
| | **E5** login/JWT + **matriks peran × endpoint** (tidak boleh ada sel kosong) | daftar endpoint Orang 1 |
| | **E8** tabel keamanan, **E9** strategi pengujian | E5 |
| | **E10** deploy (port tim 2-A: app 8103, db 5503, db tes 5603, FE 3103; lihat `tim/PANDUAN.md`) | — |
| | **E12** wireframe final | — |
| | (E7 pekerjaan latar: tulis "tidak ada") | — |

**Kenapa seimbang:** Orang 1 bagiannya sedikit tapi `openapi.yaml` paling berat. Orang 2 bagiannya banyak tapi C/D sebagian besar menyalin dari modul dan notulensi. Orang 3 banyak bagian kecil, ditambah wireframe karena dia frontend.

---

## FASE 3 — Penutup (hari terakhir, kerjakan bareng ±1 jam)

- [ ] **A** Ringkasan (maks 150 kata). Ditulis **terakhir**, oleh Orang 1.
- [ ] **G** rencana kerja + pembagian tugas, **H** risiko, **I** rencana umpan balik + skenario uji (dari Q25: impor, susun kelompok, ekspor).
- [ ] **J** penggunaan AI, dan isi **`AI-LOG.md`** (termasuk bantuan AI untuk membuat pembagian tugas ini).
- [ ] **Saling review:** Orang 1 cek E2 milik Orang 2, Orang 2 cek E5 milik Orang 3, Orang 3 cek E3 milik Orang 1.
- [ ] **K** daftar periksa (ERD = DDL, setiap M2 Wajib punya endpoint, `openapi.yaml` = E3), **L** tanda tangan.
- [ ] Hapus semua teks petunjuk dan sorotan kuning, lalu ekspor ke **Proposal_2-A.pdf**.

---

## Draf pesan klarifikasi ke dosen (untuk Orang 2)

> Selamat [pagi/siang], Pak. Kami tim 2-A (Modul 2). Terima kasih atas wawancaranya. Ada beberapa hal yang ingin kami pastikan sebelum menulis proposal:
>
> 1. Fitur evaluasi (M2-10 s.d. M2-13) di modul berprioritas Wajib, tetapi saat wawancara Bapak menyebut evaluasi bisa ditunda. Apakah evaluasi tetap dikerjakan, atau boleh kami masukkan ke "di luar ruang lingkup"?
> 2. Ukuran kelompok: semester gasal 4 dan genap 7 orang. Berapa ukuran minimalnya? Apakah boleh kami buat bisa diatur per periode?
> 3. Apakah kelompok boleh diterbitkan tanpa pembimbing, atau sistem wajib menolak bila pembimbing belum ada?
> 4. Setelah kelompok terbit, modul mengizinkan pemindahan anggota dengan alasan. Apakah fitur ini tetap ada, atau pemindahan dilarang sama sekali (hanya tukar peran)?
> 5. Apakah IPK mahasiswa perlu diimpor dan ditampilkan di layar penyusunan?
> 6. Untuk ekspor, apakah file CSV (bisa dibuka di Excel) sudah cukup?
> 7. Kata sandi awal formatnya seperti apa, dan berapa lama akun dikunci setelah 3x salah kata sandi?
> 8. Boleh kami minta Kamus Data Bersama, rubrik proposal, data seed, dan berkas `.env` tim 2-A?
>
> Terima kasih, Pak.

---

## Catatan penting
- Jangan tunggu bagian yang belum jelas. Tulis asumsi di **D4**, nanti diperbaiki setelah dosen menjawab.
- Jangan memakai data mahasiswa/dosen asli. Jangan menaruh kata sandi, `.env`, atau kunci JWT di repo.
- Isi harus dari tim sendiri. AI boleh membantu, tetapi catat di `AI-LOG.md` dan pastikan bisa dijelaskan.
