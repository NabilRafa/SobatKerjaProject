# Sobat Kerja

Aplikasi pencarian & penawaran kerja untuk pekerja informal (tukang, buruh, dll) yang menghubungkan **Worker** dan **Employer**. Terdiri dari backend REST API (Node.js/Express + Prisma + MySQL) dan aplikasi mobile (Flutter).

```
.
├── backend/     -> REST API (Express + Prisma + MySQL)
└── frontend/    -> Aplikasi Flutter (Android/iOS/Web)
```

---

## 1. Prasyarat

Pastikan sudah terinstall di komputer kamu:

| Tools | Versi disarankan |
|---|---|
| Node.js | v18 atau lebih baru (dites di v22) |
| npm | ikut Node.js |
| MySQL | 8.x (bisa via XAMPP/Laragon/Docker) |
| Flutter SDK | ^3.6.0 (channel stable) |
| Android Studio / Xcode | untuk emulator/simulator (opsional jika pakai HP fisik) |

Cek versi:
```bash
node -v
npm -v
flutter --version
mysql --version
```

---

## 2. Menjalankan Backend

### 2.1 Masuk ke folder backend & install dependency

```bash
cd backend
npm install
```

### 2.2 Buat database MySQL

Buat database kosong dulu, misal namanya `sobat_kerja`:

```sql
CREATE DATABASE sobat_kerja;
```

### 2.3 Konfigurasi environment variable

Buat file `.env` di dalam folder `backend/` (sejajar dengan `package.json`) dengan isi berikut, sesuaikan dengan konfigurasi kamu:

```env
# Koneksi database MySQL
DATABASE_URL="mysql://USER:PASSWORD@localhost:3306/sobat_kerja"

# Secret untuk signing JWT (bebas, ganti dengan string acak yang panjang)
JWT_SECRET="ganti-dengan-secret-yang-aman"

# Port server backend
PORT=5000

# Cloudinary (untuk upload foto profil, portfolio, dsb)
CLOUDINARY_CLOUD_NAME="..."
CLOUDINARY_API_KEY="..."
CLOUDINARY_API_SECRET="..."

# Email (untuk kirim OTP verifikasi akun)
EMAIL_USER="email-kamu@gmail.com"
EMAIL_PASS="app-password-gmail"
```

> **Catatan:**
> - `CLOUDINARY_*` didapat dari dashboard [cloudinary.com](https://cloudinary.com) (free tier cukup untuk development).
> - `EMAIL_PASS` untuk Gmail sebaiknya pakai **App Password**, bukan password akun biasa (karena Gmail memblokir login SMTP biasa).
> - Jika sementara belum butuh fitur upload foto atau kirim OTP, kamu tetap bisa isi dengan nilai dummy asal formatnya valid, tapi fitur terkait tidak akan berfungsi.

### 2.4 Migrasi database & generate Prisma Client

```bash
npx prisma migrate deploy
npx prisma generate
```

> Kalau kamu sedang develop dan ingin migrasi baru otomatis ter-apply setiap ada perubahan schema, gunakan `npx prisma migrate dev` sebagai gantinya.

### 2.5 (Opsional) Seed data dummy

Repo ini sudah punya `prisma/seed.js` yang membuat akun contoh:

| Role | Email | Password |
|---|---|---|
| Worker | worker@sobatkerja.com | worker123 |
| Employer | employer@sobatkerja.com | employer123 |
| Admin | admin@sobatkerja.com | admin123 |

Jalankan:
```bash
node prisma/seed.js
```

### 2.6 Jalankan server

```bash
npm run dev
```

Kalau berhasil, akan muncul log:
```
Server running on port 5000
```

Cek dengan buka browser / Postman ke:
```
GET http://localhost:5000/health
```
Harus mengembalikan `{ "status": "ok" }`.

---

## 3. Menjalankan Frontend (Flutter)

### 3.1 Masuk ke folder frontend & install dependency

```bash
cd frontend
flutter pub get
```

### 3.2 Konfigurasi environment variable

Copy `.env.example` menjadi `.env` di dalam folder `frontend/` (sejajar dengan `pubspec.yaml`):

```bash
cp .env.example .env
```

Lalu sesuaikan `API_BASE_URL` di dalamnya supaya menunjuk ke backend yang sudah kamu jalankan:

```env
API_BASE_URL=http://10.0.2.2:5000/api
```

Sesuaikan host/IP-nya menurut media testing (HP/emulator tidak bisa pakai `localhost` milik komputer):

| Menjalankan di | Isi `API_BASE_URL` |
|---|---|
| Android Emulator | `http://10.0.2.2:5000/api` |
| iOS Simulator | `http://localhost:5000/api` |
| HP fisik (Android/iOS) via Wi-Fi | `http://<IP-lokal-komputer>:5000/api` (HP dan komputer harus satu jaringan Wi-Fi) |
| Chrome/Web | `http://localhost:5000/api` |

Cara cek IP lokal komputer:
- **Windows**: `ipconfig` → lihat `IPv4 Address`
- **macOS/Linux**: `ifconfig` atau `ip addr` → lihat interface Wi-Fi/Ethernet

> `.env` sudah masuk `.gitignore` sehingga tidak ikut ter-commit. Setiap kali `API_BASE_URL` berubah, jalankan ulang `flutter run` (hot reload tidak membaca ulang file `.env`).
>
> Pastikan backend (`npm run dev`) sudah berjalan **sebelum** membuka aplikasi Flutter, karena splash/login screen langsung memanggil API.

### 3.3 Jalankan aplikasi

Cek device yang tersedia:
```bash
flutter devices
```

Jalankan ke device tertentu:
```bash
flutter run
```

Atau pilih device tertentu secara eksplisit, contoh emulator Android:
```bash
flutter run -d emulator-5554
```

Atau ke Chrome:
```bash
flutter run -d chrome
```

---

## 4. Ringkasan Alur Menjalankan dari Nol

```bash
# Terminal 1 - Backend
cd backend
npm install
# buat .env sesuai instruksi di atas
npx prisma migrate deploy
npx prisma generate
node prisma/seed.js        # opsional, buat akun contoh
npm run dev

# Terminal 2 - Frontend
cd frontend
flutter pub get
cp .env.example .env        # lalu edit API_BASE_URL sesuai media testing
flutter run
```

---

## 5. Troubleshooting

| Masalah | Kemungkinan penyebab & solusi |
|---|---|
| `Error: P1001: Can't reach database server` | Pastikan MySQL sudah jalan, dan `DATABASE_URL` di `.env` sudah benar (user/password/nama db) |
| Flutter tidak bisa connect ke API / timeout | `API_BASE_URL` di `.env` masih `localhost`/IP lama, atau HP & komputer tidak satu jaringan Wi-Fi. Restart `flutter run` setelah mengubah `.env` |
| App error `Unable to load asset: .env` | File `.env` belum dibuat (lihat langkah 3.2), atau belum masuk `flutter: assets:` di `pubspec.yaml` |
| Login berhasil tapi fitur upload foto/CV gagal | Cek kredensial `CLOUDINARY_*` di `.env` |
| OTP verifikasi email tidak terkirim | Cek `EMAIL_USER`/`EMAIL_PASS`, pastikan pakai App Password Gmail, bukan password biasa |
| `npx prisma migrate deploy` gagal karena drift | Jalankan `npx prisma migrate reset` (⚠️ akan menghapus semua data) lalu migrate ulang |
