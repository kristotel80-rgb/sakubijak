-- SakuBijak - skema database (versi dengan tabel kategori & anggaran per bulan)
-- Impor lewat phpMyAdmin atau: mysql -u root < database.sql
--
-- PERINGATAN: baris DROP TABLE di bawah menghapus tabel lama beserta isinya.
-- Ini dibutuhkan karena struktur tabel berubah dari versi sebelumnya.

CREATE DATABASE IF NOT EXISTS sakubijak
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sakubijak;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS budgets;
DROP TABLE IF EXISTS savings;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

-- Pengguna
CREATE TABLE users (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nama          VARCHAR(80)  NOT NULL,
  email         VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Kategori (data acuan bersama, bukan data pengguna)
CREATE TABLE categories (
  id         INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  nama       VARCHAR(50) NOT NULL,
  tipe       ENUM('pemasukan','pengeluaran','tabungan') NOT NULL,
  ikon       VARCHAR(30) NOT NULL DEFAULT 'dots',
  warna      VARCHAR(7)  NOT NULL DEFAULT '#8D9F94',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_category (nama, tipe)
) ENGINE=InnoDB;

INSERT INTO categories (id, nama, tipe, ikon, warna) VALUES
  (1,  'Makan',         'pengeluaran', 'utensils',  '#344B3D'),
  (2,  'Transportasi',  'pengeluaran', 'bus',       '#4F7A5E'),
  (3,  'Kos',           'pengeluaran', 'home',      '#7FA88C'),
  (4,  'Tugas/Skripsi', 'pengeluaran', 'book',      '#A9C5B0'),
  (5,  'Hiburan',       'pengeluaran', 'film',      '#C9A66B'),
  (6,  'Belanja',       'pengeluaran', 'bag',       '#8D9F94'),
  (7,  'Kesehatan',     'pengeluaran', 'heart',     '#6B8F8A'),
  (8,  'Lainnya',       'pengeluaran', 'dots',      '#B7C4A3'),
  (9,  'Uang Saku',     'pemasukan',   'wallet',    '#3D8B62'),
  (10, 'Beasiswa',      'pemasukan',   'cap',       '#3D8B62'),
  (11, 'Gaji',          'pemasukan',   'briefcase', '#3D8B62'),
  (12, 'Lainnya',       'pemasukan',   'dots',      '#3D8B62'),
  (13, 'Tabungan',      'tabungan',    'coins',     '#344B3D');

-- Target tabungan
CREATE TABLE savings (
  id             INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id        INT UNSIGNED NOT NULL,
  nama_target    VARCHAR(100) NOT NULL,
  target_nominal BIGINT UNSIGNED NOT NULL,
  created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_savings_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_savings_user (user_id)
) ENGINE=InnoDB;

-- Anggaran per kategori, per bulan, per tahun (satu batas untuk satu kategori di satu bulan)
CREATE TABLE budgets (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id         INT UNSIGNED NOT NULL,
  category_id     INT UNSIGNED NOT NULL,
  batas_anggaran  BIGINT UNSIGNED NOT NULL,
  jenis_anggaran  ENUM('fixed','flexible') NOT NULL DEFAULT 'flexible',
  bulan           TINYINT UNSIGNED NOT NULL,
  tahun           SMALLINT UNSIGNED NOT NULL,
  created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_budget_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_budget_category FOREIGN KEY (category_id) REFERENCES categories(id),
  UNIQUE KEY uq_budget (user_id, category_id, bulan, tahun),
  INDEX idx_budget_period (user_id, tahun, bulan)
) ENGINE=InnoDB;

-- Transaksi: tipe = pemasukan | pengeluaran | tabungan (setoran ke target tabungan)
CREATE TABLE transactions (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id     INT UNSIGNED NOT NULL,
  category_id INT UNSIGNED NOT NULL,
  savings_id  INT UNSIGNED NULL,
  tipe        ENUM('pemasukan','pengeluaran','tabungan') NOT NULL,
  nominal     BIGINT UNSIGNED NOT NULL,
  deskripsi   VARCHAR(120) NOT NULL,
  tanggal     DATE NOT NULL,
  created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_tx_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_tx_category FOREIGN KEY (category_id) REFERENCES categories(id),
  CONSTRAINT fk_tx_savings FOREIGN KEY (savings_id) REFERENCES savings(id) ON DELETE CASCADE,
  INDEX idx_tx_user_date (user_id, tanggal),
  INDEX idx_tx_user_tipe (user_id, tipe)
) ENGINE=InnoDB;
