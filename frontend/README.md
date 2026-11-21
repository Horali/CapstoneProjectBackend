# Frontend — Tim 2-A

Semua kode frontend ada di folder ini. Kode backend (Go) ada di akar repo.

- Yang di-commit hanya kode sumber. Hasil build (`frontend/dist/`) dan `node_modules/` tidak di-commit (sudah ada di `.gitignore`).
- Hasil build ditaruh di `frontend/dist/`. Docker menyajikannya lewat `docker compose --profile frontend up -d frontend` (lihat `PANDUAN.md`).
- Panggilan ke API mengikuti `openapi.yaml` di akar repo. Selama backend belum jadi, pakai data tiruan (mock) dari kontrak itu.
- Alamat frontend harus ada di `CORS_ALLOWED_ORIGINS` di `.env` supaya bisa memanggil API.
