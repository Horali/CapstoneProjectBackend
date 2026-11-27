Status: active
Needs user: no
Updated: 2026-11-27
Agent: Claude desktop app, Opus 5.5, side session of local_0804fd86

## Goal and why

The dosen reviewed the proposal and asked for changes. Rewrite the evaluation parts and split the ERD role "dosen" into "dosen" and "koordinator". Deadline: 2026-11-27 23:59.

## Decisions (accepted by Faiz)

1. Roles: `mahasiswa`, `dosen` (pembimbing only), `koordinator`. A koordinator is a dosen koordinator OR an asdos.
2. ERD: new box `koordinator` (id, kode_koordinator, nama, email, kode_dosen optional). `kode_dosen` filled = dosen koordinator; empty = asdos. `riwayat_keanggotaan.oleh` and `evaluasi.penilai` link to `koordinator`.
3. Login identity: NRP (mahasiswa), `kode_dosen` (dosen), `kode_koordinator` (koordinator, e.g. `ASD01`, 2–10 letters/digits). Koordinator accounts come from seed data.
4. Asdos has full koordinator rights.
5. Evaluation: done AFTER the capstone by the koordinator role. No peer rating. Each koordinator rates each mahasiswa of a published group; the app shows the average.
6. Criteria stay: kontribusi_teknis, komunikasi, tanggung_jawab (1–5) + komentar (optional, max 300).
7. Dosen pembimbing does not rate. Pembimbing sees results of own groups (with rater names).
8. Mahasiswa sees own result after the round closes, without rater names.
9. M2-15 ("kontribusi timpang") is removed.
10. E2 (Ais's section) is edited last.

## New evaluation endpoints (E3 rows 24–30, total stays 31)

24 POST /putaran-evaluasi (koordinator) · 25 GET /putaran-evaluasi (semua) · 26 POST /putaran-evaluasi/{id}/tutup (koordinator) · 27 GET /putaran-evaluasi/{id}/formulir (koordinator: list of mahasiswa + own scores) · 28 PUT /putaran-evaluasi/{id}/evaluasi/{nrp} (koordinator, upsert) · 29 GET /putaran-evaluasi/{id}/hasil-saya (mahasiswa, 409 HASIL_BELUM_TERSEDIA) · 30 GET /putaran-evaluasi/{id}/rekap (koordinator all, dosen own groups).

## Next steps

See the plan in the session. Order: repo docs + openapi → proposal text → diagrams → E2 → AI-LOG, commit, push.

## Where to look

`docs/e3-kontrak-api.md`, `openapi.yaml`, `docs/e6-validasi.md`, `docs/f-tantangan-t2.md`.
