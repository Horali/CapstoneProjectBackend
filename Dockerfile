# syntax=docker/dockerfile:1
# Dockerfile untuk aplikasi Go tim. Salin ke akar repo (sejajar dengan go.mod).
#
# Anggapan: paket main berada di ./cmd/server. Kalau lokasi Anda berbeda, ubah MAIN_PKG
# di berkas .env (mis. MAIN_PKG=. bila main.go ada di akar repo). Jangan ubah Dockerfile-nya.
# Versi Go harus >= baris "go" di go.mod Anda (ubah GO_VERSION di .env bila perlu).

ARG GO_VERSION=1.23

# ---- tahap 1: kompilasi ----
FROM golang:${GO_VERSION}-alpine AS build
WORKDIR /src

# go.mod/go.sum disalin lebih dulu supaya lapisan "go mod download" ter-cache
# selama dependensi tidak berubah (build ulang jadi cepat).
COPY go.mod go.sum* ./
RUN go mod download

COPY . .
ARG MAIN_PKG=./cmd/server
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/server ${MAIN_PKG}

# ---- tahap 2: citra akhir yang kecil ----
FROM alpine:3.20
# ca-certificates: perlu untuk memanggil HTTPS (mis. API GitHub, modul 7).
# tzdata: agar time.LoadLocation("Asia/Jakarta") bekerja (modul 4 dan 6).
RUN apk add --no-cache ca-certificates tzdata \
 && adduser -D -u 10001 app
ENV TZ=Asia/Jakarta
USER app
WORKDIR /app
COPY --from=build /out/server /app/server

# Di DALAM container aplikasi selalu mendengarkan port 8080 (variabel PORT).
# Port di luar (milik tim) diatur di docker-compose.yml lewat APP_PORT; kode tidak perlu tahu.
EXPOSE 8080
ENTRYPOINT ["/app/server"]
