# Panduan Docker Tim dan Pembagian Port

> **DRAF v0.1** · Berlaku untuk semua tim MyIF Capstone · Syarat dasar terkait: BASE-04, BASE-08, BASE-09, BASE-10 ([README](README.md))

## 1. Gambaran

Setiap tim memiliki **satu paket Docker sendiri**: aplikasi Go dan database PostgreSQL sendiri, dijalankan dengan satu perintah.
Karena 14 tim berbagi satu server (VPS) dan sebagian juga menjalankannya di laptop yang sama dengan tim lain, **setiap tim mendapat angka port, nama proyek, nama database, kata sandi, dan kunci JWT yang berbeda**.
Angka-angka itu ditetapkan koordinator dan sudah ditulis di berkas `.env` milik tim. Tim tidak perlu, dan tidak boleh, memilih port sendiri.

Isi paket (folder `tim/` pada templat):

| Berkas | Fungsi |
|---|---|
| `Dockerfile` | Membangun aplikasi Go menjadi citra kecil (dua tahap, berjalan sebagai pengguna non-root, zona waktu Asia/Jakarta) |
| `docker-compose.yml` | Menjalankan `db` (PostgreSQL 16) dan `app`; profil opsional `test` (database tes) dan `frontend` (penyaji hasil build frontend) |
| `.env.example` | Contoh bentuk `.env`; **nilai asli dari koordinator** |
| `db/migrations/*.sql` | Skrip skema dan seed; dijalankan otomatis berurutan saat database pertama kali dibuat |
| `.dockerignore`, `.gitignore` | Menjaga `.env` dan berkas tak perlu keluar dari citra dan repo |

## 2. Pembagian port

Rumus (n = nomor tim, 1 sampai 14; 1-A = 1, 1-B = 2, 2-A = 3, dan seterusnya sampai 7-B = 14):

| Layanan | Rumus | Rentang | Dapat diakses dari |
|---|---|---|---|
| Aplikasi backend (`APP_PORT`) | 8100 + n | 8101 – 8114 | publik (untuk frontend dan demo) |
| Database (`DB_PORT`) | 5500 + n | 5501 – 5514 | hanya `127.0.0.1` pada mesin itu sendiri |
| Database tes (`TEST_DB_PORT`) | 5600 + n | 5601 – 5614 | hanya `127.0.0.1` |
| Frontend (`FE_PORT`) | 3100 + n | 3101 – 3114 | publik |

Tabel lengkap:

| Tim | No | Aplikasi (`APP_PORT`) | Database (`DB_PORT`) | DB tes (`TEST_DB_PORT`) | Frontend (`FE_PORT`) | Proyek Compose |
|---|---|---|---|---|---|---|
| 1-A | 1 | 8101 | 5501 | 5601 | 3101 | `capstone-m1a` |
| 1-B | 2 | 8102 | 5502 | 5602 | 3102 | `capstone-m1b` |
| 2-A | 3 | 8103 | 5503 | 5603 | 3103 | `capstone-m2a` |
| 2-B | 4 | 8104 | 5504 | 5604 | 3104 | `capstone-m2b` |
| 3-A | 5 | 8105 | 5505 | 5605 | 3105 | `capstone-m3a` |
| 3-B | 6 | 8106 | 5506 | 5606 | 3106 | `capstone-m3b` |
| 4-A | 7 | 8107 | 5507 | 5607 | 3107 | `capstone-m4a` |
| 4-B | 8 | 8108 | 5508 | 5608 | 3108 | `capstone-m4b` |
| 5-A | 9 | 8109 | 5509 | 5609 | 3109 | `capstone-m5a` |
| 5-B | 10 | 8110 | 5510 | 5610 | 3110 | `capstone-m5b` |
| 6-A | 11 | 8111 | 5511 | 5611 | 3111 | `capstone-m6a` |
| 6-B | 12 | 8112 | 5512 | 5612 | 3112 | `capstone-m6b` |
| 7-A | 13 | 8113 | 5513 | 5613 | 3113 | `capstone-m7a` |
| 7-B | 14 | 8114 | 5514 | 5614 | 3114 | `capstone-m7b` |

Rentang ini sengaja menghindari port yang lazim dipakai di laptop dan server: 5432 (PostgreSQL bawaan), 5433, 5434, 3000, 5173, dan 8080.

## 3. Langkah untuk tim

1. Minta berkas `.env` tim Anda kepada koordinator (mis. `3-A.env`). **Hanya berkas milik tim Anda.**
2. Salin isi paket `tim/` ke akar repo (sejajar dengan `go.mod`), dan simpan berkas dari koordinator sebagai **`.env`**.
3. Pastikan paket `main` Anda berada di `./cmd/server`. Bila berbeda, ubah `MAIN_PKG` di `.env` (mis. `MAIN_PKG=.`).
4. Pastikan `GO_VERSION` di `.env` tidak lebih rendah daripada baris `go` di `go.mod`.
5. Jalankan:

```bash
docker compose up -d --build --wait
```

6. Periksa: buka `http://localhost:<APP_PORT>/healthz` (mis. `http://localhost:8105/healthz` untuk tim 3-A).
7. Matikan dengan `docker compose down` (data tetap ada) atau `docker compose down -v` (data dihapus, skrip migrasi dijalankan ulang).

Perintah yang sering dipakai:

| Tujuan | Perintah |
|---|---|
| Lihat log aplikasi | `docker compose logs -f app` |
| Bangun ulang setelah mengubah kode | `docker compose up -d --build app` |
| Masuk ke psql | `docker compose exec db psql -U capstone -d <DB_NAME>` |
| Jalankan database tes | `docker compose --profile test up -d --wait db_test` |
| Sajikan frontend hasil build | `docker compose --profile frontend up -d frontend` |

## 4. Kontrak antara paket dan kode Go

Agar paket yang sama dapat dipakai semua tim, aplikasi **membaca konfigurasi dari variabel lingkungan**, bukan menuliskannya di kode:

| Variabel | Nilai di dalam container | Dipakai untuk |
|---|---|---|
| `PORT` | `8080` (tetap) | port yang didengarkan `http.Server` |
| `DATABASE_URL` | `postgres://…@db:5432/<DB_NAME>?sslmode=disable` | `sql.Open("pgx", …)` |
| `JWT_SECRET` | dari `.env` | menandatangani dan memverifikasi JWT HS256 |
| `CORS_ALLOWED_ORIGINS` | dari `.env` | asal frontend yang diizinkan |
| `TZ` | `Asia/Jakarta` | zona waktu proses |

Aplikasi wajib menyediakan `GET /healthz` (BASE-09); Compose memakainya untuk menentukan aplikasi sudah sehat.

## 5. Kesalahan yang sering terjadi

- **Memakai `localhost:5501` di dalam `DATABASE_URL` aplikasi.** Di dalam container, `localhost` adalah container aplikasi itu sendiri. Database dijangkau lewat nama layanan **`db`** dan port **`5432`**. Port `DB_PORT` hanya untuk akses dari luar (laptop atau alat database).
- **Mengubah angka port di `docker-compose.yml`.** Jangan. Semua angka dibaca dari `.env`. Mengubahnya membuat tim bentrok di server bersama.
- **Mengubah skrip `db/migrations` tetapi skema tidak berubah.** Skrip hanya dijalankan saat volume masih kosong. Jalankan `docker compose down -v` lalu `up` lagi (data lokal hilang). Untuk perubahan skema di server, buat skrip migrasi baru, jangan menyunting yang lama.
- **Meng-commit `.env`.** Berkas itu berisi kata sandi dan kunci JWT. Hanya `.env.example` yang boleh masuk repo.
- **Versi Go citra lebih rendah daripada `go.mod`.** Build gagal atau mencoba mengunduh toolchain lain. Samakan `GO_VERSION`.
- **Aplikasi membaca file (mis. `openapi.yaml`) dari disk saat berjalan.** Citra akhir hanya berisi program. Sematkan berkas itu dengan `//go:embed`.
- **`docker compose up` gagal dengan "port is already allocated".** Ada proses lain memakai port tim Anda. Periksa dengan `docker ps` apakah Anda menjalankan paket tim lain; angka port tim tidak boleh diganti.

## 7. Yang sudah diuji

Paket ini diuji dengan aplikasi Go contoh dan Docker 29: validasi `docker compose config` untuk tim sampel, **dua tim berjalan bersamaan** (1-A pada 8101/5501 dan 7-B pada 8114/5514) dengan `/healthz` sehat pada keduanya, zona waktu Asia/Jakarta di dalam container, skrip migrasi berjalan otomatis pada database tes, dan database yang hanya terikat ke 127.0.0.1. Belum diuji: build dengan aplikasi tim sungguhan (pustaka pgx dan sebagainya), dan penerapan di VPS.
