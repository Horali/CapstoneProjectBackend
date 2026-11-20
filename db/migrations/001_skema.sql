-- Skrip skema tim. Dijalankan otomatis oleh Postgres saat volume masih kosong,
-- berurutan menurut nama berkas: 001_..., 002_..., dst. Beri awalan angka agar urutannya jelas.
--
-- Contoh penamaan:
--   001_skema.sql      tabel dan indeks
--   002_constraint.sql constraint tambahan (mis. exclusion constraint untuk modul 6)
--   900_seed.sql       data seed fiktif (JANGAN data mahasiswa/dosen asli)
--
-- Hapus komentar ini dan isi dengan skema Anda. Berkas boleh dipecah sesuka tim.
SELECT 1;
