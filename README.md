# SakuBijak

Aplikasi pencatat keuangan mahasiswa: PHP + MySQL, Tailwind CSS (CDN), JavaScript, Chart.js.

## Cara menjalankan (XAMPP/Laragon)
1. Salin folder `sakubijak/` ke `htdocs` (XAMPP) atau `www` (Laragon).
2. Impor `database.sql` lewat phpMyAdmin (database `sakubijak` dibuat otomatis). File ini menghapus tabel lama lalu membuat ulang tabel beserta 13 kategori bawaan.
3. Sesuaikan kredensial di `config/database.php` bila perlu.
4. Buka `http://localhost/sakubijak/`, daftar akun baru. Akun baru dimulai kosong: saldo Rp0, tanpa transaksi, anggaran, atau target tabungan.

Butuh PHP 8.0+ dan koneksi internet (Tailwind, Google Fonts, dan Chart.js dimuat dari CDN).

## Catatan
- Saldo = pemasukan − pengeluaran − setoran tabungan (semua dihitung dari tabel `transactions`).
- Setoran tabungan disimpan sebagai transaksi `saving`, sehingga saldo, progres target, dan riwayat selalu konsisten.
- Semua formulir dikirim sebagai POST biasa (tanpa JSON/API) dan diproses di `includes/actions.php`, lalu halaman dimuat ulang.
- Semua data dikaitkan ke `user_id`; setiap aksi mengecek sesi dan token CSRF.
- Kata sandi memakai `password_hash()` / `password_verify()`.

## Struktur database
`users`, `categories` (data acuan), `budgets` (per kategori, per bulan, per tahun), `savings` (target tabungan), `transactions`.
Semua tabel punya `id`, `created_at`, `updated_at`; data pengguna punya `user_id`.

## Ekspor ke Firebase (JSON)
Jalankan dari terminal di folder proyek:

    php export_firebase.php

Hasil di `firebase_export/`: `sakubijak_realtime_db.json` (satu file untuk Realtime Database > Import JSON) dan satu file per tabel.
Skrip ini hanya bisa dijalankan lewat terminal dan tidak mengekspor `password_hash`.

## Pembaruan: Anggaran Fixed/Flexible dan Ekspor PDF

- Pada modal **Atur anggaran**, pilih **Pengeluaran Wajib (Fixed)** untuk dana yang harus dikunci (contoh: kos, UKT, internet), atau **Pengeluaran Fleksibel (Flexible)** untuk kebutuhan yang lebih luwes.
- Saldo bebas mengurangi sisa dana anggaran Fixed yang belum digunakan. Saat transaksi pada kategori Fixed dicatat, dana terkunci berkurang sesuai nominal transaksi agar tidak dihitung dua kali.
- Pada halaman **Transaksi**, tombol **Ekspor PDF** mengunduh laporan untuk bulan yang sedang dipilih (default bulan berjalan).

### Database untuk instalasi lama

Jika database SakuBijak sudah pernah dibuat, jalankan file `migration_fixed_flexible.sql` satu kali melalui phpMyAdmin. Untuk instalasi baru, impor `database.sql` seperti biasa; kolom `jenis_anggaran` sudah termasuk di skema terbaru.
