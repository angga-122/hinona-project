-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 12, 2026 at 01:13 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_hinona_pos`
--

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `detail_transaksi`
--

CREATE TABLE `detail_transaksi` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `transaksi_id` bigint(20) UNSIGNED NOT NULL,
  `menu_id` bigint(20) UNSIGNED NOT NULL,
  `jumlah` int(11) NOT NULL,
  `harga` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `detail_transaksi`
--

INSERT INTO `detail_transaksi` (`id`, `transaksi_id`, `menu_id`, `jumlah`, `harga`, `subtotal`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 2, 18000.00, 36000.00, '2026-10-11 07:29:10', '2026-10-11 07:29:10'),
(2, 1, 2, 1, 22000.00, 22000.00, '2026-10-11 07:29:10', '2026-10-11 07:29:10'),
(3, 2, 4, 1, 10000.00, 10000.00, '2026-10-11 09:06:23', '2026-10-11 09:06:23'),
(4, 2, 9, 1, 3.00, 3.00, '2026-10-11 09:06:23', '2026-10-11 09:06:23'),
(5, 2, 8, 1, 10000.00, 10000.00, '2026-10-11 09:06:23', '2026-10-11 09:06:23'),
(6, 2, 6, 1, 20000.00, 20000.00, '2026-10-11 09:06:23', '2026-10-11 09:06:23'),
(7, 3, 1, 1, 18000.00, 18000.00, '2026-10-11 09:17:26', '2026-10-11 09:17:26'),
(8, 3, 9, 1, 3.00, 3.00, '2026-10-11 09:17:26', '2026-10-11 09:17:26'),
(9, 3, 4, 1, 10000.00, 10000.00, '2026-10-11 09:17:26', '2026-10-11 09:17:26'),
(10, 4, 6, 1, 20000.00, 20000.00, '2026-10-11 09:18:16', '2026-10-11 09:18:16'),
(11, 4, 2, 1, 22000.00, 22000.00, '2026-10-11 09:18:16', '2026-10-11 09:18:16'),
(12, 5, 2, 1, 22000.00, 22000.00, '2026-10-11 09:47:41', '2026-10-11 09:47:41'),
(13, 5, 3, 1, 20000.00, 20000.00, '2026-10-11 09:47:41', '2026-10-11 09:47:41'),
(14, 5, 16, 1, 15000.00, 15000.00, '2026-10-11 09:47:41', '2026-10-11 09:47:41'),
(15, 5, 4, 1, 10000.00, 10000.00, '2026-10-11 09:47:41', '2026-10-11 09:47:41'),
(16, 5, 12, 1, 25000.00, 25000.00, '2026-10-11 09:47:41', '2026-10-11 09:47:41'),
(17, 5, 11, 1, 25000.00, 25000.00, '2026-10-11 09:47:41', '2026-10-11 09:47:41'),
(18, 5, 5, 1, 18000.00, 18000.00, '2026-10-11 09:47:41', '2026-10-11 09:47:41'),
(19, 5, 10, 1, 20000.00, 20000.00, '2026-10-11 09:47:41', '2026-10-11 09:47:41'),
(20, 5, 14, 1, 15000.00, 15000.00, '2026-10-11 09:47:41', '2026-10-11 09:47:41'),
(21, 5, 6, 1, 20000.00, 20000.00, '2026-10-11 09:47:41', '2026-10-11 09:47:41'),
(22, 6, 1, 1, 18000.00, 18000.00, '2026-10-11 09:58:52', '2026-10-11 09:58:52'),
(25, 7, 1, 1, 18000.00, 18000.00, '2026-10-11 22:59:43', '2026-10-11 22:59:43'),
(26, 7, 8, 2, 10000.00, 20000.00, '2026-10-11 22:59:43', '2026-10-11 22:59:43'),
(28, 8, 1, 2, 18000.00, 36000.00, '2026-10-12 02:25:46', '2026-10-12 02:25:46');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` varchar(255) NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` smallint(5) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `kategori`
--

CREATE TABLE `kategori` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nama_kategori` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `kategori`
--

INSERT INTO `kategori` (`id`, `nama_kategori`, `created_at`, `updated_at`) VALUES
(1, 'Coffee', '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(2, 'Non Coffee', '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(3, 'Tea', '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(4, 'Food', '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(5, 'Snack', '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(6, 'Cake', '2026-10-12 02:29:19', '2026-10-12 02:29:19');

-- --------------------------------------------------------

--
-- Table structure for table `meja`
--

CREATE TABLE `meja` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nomor_meja` varchar(255) NOT NULL,
  `kode_qr` varchar(255) NOT NULL,
  `aktif` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `meja`
--

INSERT INTO `meja` (`id`, `nomor_meja`, `kode_qr`, `aktif`, `created_at`, `updated_at`) VALUES
(1, 'Meja 1', 'HINONA-MEJA-1', 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(2, 'Meja 2', 'HINONA-MEJA-2', 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(3, 'Meja 3', 'HINONA-MEJA-3', 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(4, 'Meja 4', 'HINONA-MEJA-4', 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(5, 'Meja 5', 'HINONA-MEJA-5', 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(6, 'Meja 6', 'HINONA-MEJA-6', 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(7, 'Meja 7', 'HINONA-MEJA-7', 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(8, 'Meja 8', 'HINONA-MEJA-8', 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(9, 'Meja 9', 'HINONA-MEJA-9', 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(10, 'Meja 10', 'HINONA-MEJA-10', 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(11, 'Meja 11', 'HINONA-MEJA-11', 1, '2026-10-11 02:15:42', '2026-10-11 02:15:42');

-- --------------------------------------------------------

--
-- Table structure for table `menu`
--

CREATE TABLE `menu` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `kategori_id` bigint(20) UNSIGNED NOT NULL,
  `nama_menu` varchar(255) NOT NULL,
  `harga` decimal(12,2) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `gambar` varchar(255) DEFAULT NULL,
  `aktif` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `menu`
--

INSERT INTO `menu` (`id`, `kategori_id`, `nama_menu`, `harga`, `deskripsi`, `gambar`, `aktif`, `created_at`, `updated_at`) VALUES
(1, 1, 'Americano', 18000.00, 'Espresso dengan air', NULL, 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(2, 1, 'Coffee Latte', 22000.00, 'Espresso dengan susu', NULL, 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(3, 2, 'Chocolate', 20000.00, 'Minuman cokelat', NULL, 1, '2026-10-11 00:28:36', '2026-10-11 07:30:00'),
(4, 3, 'Ice Tea', 10000.00, 'Es teh', NULL, 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(5, 4, 'French Fries', 18000.00, 'Kentang goreng', NULL, 0, '2026-10-11 00:28:36', '2026-10-11 09:51:15'),
(6, 5, 'Croissant', 20000.00, 'Croissant butter', NULL, 1, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(8, 1, 'kopi susu', 10000.00, 'y', NULL, 1, '2026-10-11 01:58:03', '2026-10-11 01:58:03'),
(9, 1, 't', 3.00, '3', NULL, 0, '2026-10-11 02:04:15', '2026-10-11 09:22:07'),
(10, 4, 'nasgor goreng', 20000.00, NULL, NULL, 1, '2026-10-11 09:21:49', '2026-10-11 09:21:49'),
(11, 4, 'ayam penyet', 25000.00, NULL, NULL, 1, '2026-10-11 09:22:26', '2026-10-11 09:22:26'),
(12, 4, 'ayam geprek', 25000.00, NULL, NULL, 1, '2026-10-11 09:22:45', '2026-10-11 09:22:45'),
(13, 2, 'matcha', 20000.00, NULL, NULL, 1, '2026-10-11 09:23:04', '2026-10-11 09:23:04'),
(14, 5, 'kentang goreng', 15000.00, NULL, NULL, 1, '2026-10-11 09:23:46', '2026-10-11 09:23:46'),
(15, 3, 'lemon tea', 15000.00, NULL, NULL, 1, '2026-10-11 09:24:06', '2026-10-11 09:24:06'),
(16, 2, 'jus jeruk', 15000.00, NULL, NULL, 1, '2026-10-11 09:24:35', '2026-10-11 09:24:35'),
(17, 2, 'jus magga', 15000.00, NULL, NULL, 1, '2026-10-11 09:24:51', '2026-10-11 09:24:51'),
(18, 2, 'jus alpukat', 15000.00, NULL, NULL, 1, '2026-10-11 09:25:15', '2026-10-11 09:25:15'),
(19, 2, 'air mineral', 5000.00, NULL, NULL, 1, '2026-10-11 09:51:49', '2026-10-11 09:51:49'),
(20, 4, 'Ayam Goreng', 20000.00, NULL, NULL, 1, '2026-10-12 02:28:42', '2026-10-12 02:28:42');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_09_29_165008_create_personal_access_tokens_table', 1),
(5, '2026_09_29_165155_create_kategoris_table', 1),
(6, '2026_09_29_165156_create_menus_table', 1),
(7, '2026_09_29_165157_create_mejas_table', 1),
(8, '2026_09_29_165158_create_transaksis_table', 1),
(9, '2026_09_29_165159_create_detail_transaksis_table', 1),
(10, '2026_09_29_173257_create_pelanggans_table', 1),
(11, '2026_09_29_173655_add_role_to_users_table', 1),
(12, '2026_09_30_000000_create_sessions_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `pelanggan`
--

CREATE TABLE `pelanggan` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nama` varchar(255) DEFAULT NULL,
  `no_hp` varchar(255) DEFAULT NULL,
  `meja_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 'App\\Models\\User', 1, 'hinona-pos', '1bfcc8c166d5022def03271885bb43235ee40edff4d2288b2ee02a106e00e6a5', '[\"*\"]', NULL, NULL, '2026-10-11 00:51:44', '2026-10-11 00:51:44'),
(2, 'App\\Models\\User', 1, 'hinona-pos', '77ed33f97b9774421ee08a3b2fcc7e711336e65b81abd346e8fa8d46cd2226af', '[\"*\"]', NULL, NULL, '2026-10-11 00:57:27', '2026-10-11 00:57:27'),
(3, 'App\\Models\\User', 1, 'hinona-pos', '4b275921360df74c594f0d9fb069e43c9ac639383a894ef697c66b2edd20ed56', '[\"*\"]', NULL, NULL, '2026-10-11 01:00:34', '2026-10-11 01:00:34'),
(4, 'App\\Models\\User', 1, 'hinona-pos', 'bec895f3a52d3411f4c1edcbce769d3cf0eccd9eae852ba19a0772e93c3044aa', '[\"*\"]', NULL, NULL, '2026-10-11 01:33:29', '2026-10-11 01:33:29'),
(5, 'App\\Models\\User', 1, 'hinona-pos', '3ef269d7cffa8e4915aa5fe303b8a73313c50de245149d305a24b0274cc1fb11', '[\"*\"]', '2026-10-11 02:04:17', NULL, '2026-10-11 01:38:02', '2026-10-11 02:04:17'),
(6, 'App\\Models\\User', 1, 'hinona-pos', 'a9fa6480db14b5fcc080ee0f3977f5e6bd42d3eda025eb57138d65d0c5f6f716', '[\"*\"]', '2026-10-11 02:15:43', NULL, '2026-10-11 02:14:41', '2026-10-11 02:15:43'),
(7, 'App\\Models\\User', 1, 'hinona-pos', '7ccc4c4905a88281b18fd49189b80b32e7e77996f3b6849d8c6bb8e8e44580d6', '[\"*\"]', '2026-10-11 07:10:54', NULL, '2026-10-11 07:10:51', '2026-10-11 07:10:54'),
(8, 'App\\Models\\User', 2, 'hinona-pos', '10fc76e4769396f6a340db1dd8950f69b8ece5b03b352ad36507922c2a6eecfc', '[\"*\"]', '2026-10-11 07:13:06', NULL, '2026-10-11 07:13:06', '2026-10-11 07:13:06'),
(9, 'App\\Models\\User', 3, 'hinona-pos', '2e0d274accf6c890c5f7e3bcdcfb57f52be949bf75aca143bff1aa880d19226c', '[\"*\"]', '2026-10-11 07:13:33', NULL, '2026-10-11 07:13:33', '2026-10-11 07:13:33'),
(10, 'App\\Models\\User', 1, 'hinona-pos', '8c96285842e6a94a08cea1571e81bbcc1e46bcf0f47c1d25af55714c52ec76e2', '[\"*\"]', '2026-10-11 07:26:33', NULL, '2026-10-11 07:26:21', '2026-10-11 07:26:33'),
(12, 'App\\Models\\User', 2, 'hinona-pos', '88903c11f744b588bc4cfedc1f0a43d9765c476741cd3a0a63f9a33c8c568606', '[\"*\"]', '2026-10-11 08:14:08', NULL, '2026-10-11 08:12:52', '2026-10-11 08:14:08'),
(13, 'App\\Models\\User', 3, 'hinona-pos', 'c7762ad850aa21fa536aa51fdde378af885eacf70282d13da3d2f410c89e23a1', '[\"*\"]', '2026-10-11 09:04:40', NULL, '2026-10-11 09:00:11', '2026-10-11 09:04:40'),
(14, 'App\\Models\\User', 2, 'hinona-pos', '8bd074e3227a4935ef56a07823268f6a15958dc6ad1dd7399eaa13d572b55b95', '[\"*\"]', '2026-10-11 09:07:51', NULL, '2026-10-11 09:07:03', '2026-10-11 09:07:51'),
(15, 'App\\Models\\User', 3, 'hinona-pos', '9d8f3ae8999b17af32e23d4cb37c140466a66b70d0b00e11edbc4e4a6fe6f848', '[\"*\"]', '2026-10-11 09:10:21', NULL, '2026-10-11 09:08:18', '2026-10-11 09:10:21'),
(16, 'App\\Models\\User', 2, 'hinona-pos', '2029f3a4fd1e63dfa234d34dd5a503e9d9ad3893be4d9e6337dd11dba074d468', '[\"*\"]', '2026-10-11 09:17:49', NULL, '2026-10-11 09:16:58', '2026-10-11 09:17:49'),
(17, 'App\\Models\\User', 2, 'hinona-pos', 'b3091184f3a5d493d37a672632d42fd38151c0cddf8287064184c71e38745662', '[\"*\"]', '2026-10-11 09:19:20', NULL, '2026-10-11 09:18:37', '2026-10-11 09:19:20'),
(18, 'App\\Models\\User', 1, 'hinona-pos', 'bf2edbd0fb0766ff6a1fe35aecf9ed1a0e083f66fcecb853a9fea65f170eb8e7', '[\"*\"]', '2026-10-11 09:25:17', NULL, '2026-10-11 09:19:39', '2026-10-11 09:25:17'),
(19, 'App\\Models\\User', 2, 'hinona-pos', 'b6971dc45fc29b587b7d0f42afef23a4fea8f45980b8085a64cdc17d0e5f5a53', '[\"*\"]', '2026-10-11 09:49:20', NULL, '2026-10-11 09:48:20', '2026-10-11 09:49:20'),
(20, 'App\\Models\\User', 3, 'hinona-pos', '28a1b1054fe67a5949a1f34a32e4e033c9ae243a9143e3685bd6d82e5584fc15', '[\"*\"]', '2026-10-11 09:49:43', NULL, '2026-10-11 09:49:42', '2026-10-11 09:49:43'),
(21, 'App\\Models\\User', 1, 'hinona-pos', '3e3ffd79ba047fed893f91264ac37bb4d6d340f866a3c1b32d1916135fceeb91', '[\"*\"]', '2026-10-11 09:51:51', NULL, '2026-10-11 09:50:53', '2026-10-11 09:51:51'),
(24, 'App\\Models\\User', 3, 'hinona-pos', '85175aff0d4901ff1e5fa174761cdb434f39495f02fad7726612a30a0e30fca5', '[\"*\"]', '2026-10-11 23:01:04', NULL, '2026-10-11 23:00:39', '2026-10-11 23:01:04'),
(25, 'App\\Models\\User', 2, 'hinona-pos', '3cfcb1beb783dac017cdf8982138cec666e0827f696a7996fd5d134600cfe8e1', '[\"*\"]', '2026-10-12 02:26:16', NULL, '2026-10-12 02:25:31', '2026-10-12 02:26:16'),
(26, 'App\\Models\\User', 3, 'hinona-pos', 'ce778487c55b56570405d0d83882cfcddf999a3f75f8c6ed39723835aaa4f04e', '[\"*\"]', '2026-10-12 02:26:45', NULL, '2026-10-12 02:26:45', '2026-10-12 02:26:45'),
(27, 'App\\Models\\User', 1, 'hinona-pos', 'd88741dc02a7e4bdfa4b56fbd30bc2ace9f545be8f2b77eebe2d54827c7fd47e', '[\"*\"]', '2026-10-12 02:30:04', NULL, '2026-10-12 02:28:07', '2026-10-12 02:30:04');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` text NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('6JwGp8oqp9YPJSHtHWG7QqJVBUtrph6IDs87DQbM', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'eyJfdG9rZW4iOiJHdzFHbUx2TFpjQ2NUMElta2JTcWVXSjZqUXRRYUpSVk1rOTU0RFpyIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1791731523),
('T3UQMreKTIRvtYHzjt8lCjtQPKRTsSOt4QxDWnc2', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', 'eyJfdG9rZW4iOiJsbmhvb1lTTEpTUDBSSm1vVWJVV0s4Ykt6MTZyT3hvaXE0SjBHSGM4IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1791731523);

-- --------------------------------------------------------

--
-- Table structure for table `transaksi`
--

CREATE TABLE `transaksi` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `meja_id` bigint(20) UNSIGNED DEFAULT NULL,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `uang_bayar` decimal(12,2) NOT NULL DEFAULT 0.00,
  `kembalian` decimal(12,2) NOT NULL DEFAULT 0.00,
  `metode_pembayaran` varchar(255) DEFAULT NULL,
  `status` enum('menunggu','diproses','selesai','dibatalkan') NOT NULL DEFAULT 'menunggu',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `transaksi`
--

INSERT INTO `transaksi` (`id`, `user_id`, `meja_id`, `total`, `uang_bayar`, `kembalian`, `metode_pembayaran`, `status`, `created_at`, `updated_at`) VALUES
(1, 2, 2, 58000.00, 100000.00, 42000.00, 'tunai', 'selesai', '2026-10-11 07:29:10', '2026-10-11 08:13:36'),
(2, 2, 2, 40003.00, 40003.00, 0.00, 'qris', 'selesai', '2026-10-11 09:06:23', '2026-10-11 09:07:28'),
(3, 2, NULL, 28003.00, 50000.00, 21997.00, 'tunai', 'selesai', '2026-10-11 09:17:26', '2026-10-11 09:17:43'),
(4, 2, 2, 42000.00, 42000.00, 0.00, 'tunai', 'selesai', '2026-10-11 09:18:16', '2026-10-11 09:18:53'),
(5, 2, 2, 190000.00, 190000.00, 0.00, 'tunai', 'selesai', '2026-10-11 09:47:41', '2026-10-11 09:48:54'),
(6, 2, 2, 18000.00, 50000.00, 32000.00, 'tunai', 'selesai', '2026-10-11 09:58:52', '2026-10-11 09:59:41'),
(7, 2, 6, 38000.00, 100000.00, 62000.00, 'tunai', 'selesai', '2026-10-11 22:58:48', '2026-10-11 22:59:51'),
(8, 2, 6, 36000.00, 50000.00, 14000.00, 'tunai', 'selesai', '2026-10-12 02:24:24', '2026-10-12 02:25:55');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'kasir',
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `role`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Admin Hinona', 'admin@hinona.test', NULL, '$2y$12$ecoH92Pu0Ywmavp1Jxh0Eu.onKYdzNII0HgG6Ygj5XSntBc7.i3BW', 'admin', NULL, '2026-10-11 00:28:35', '2026-10-11 00:28:35'),
(2, 'Kasir Hinona', 'kasir@hinona.test', NULL, '$2y$12$MsjOqTdb3im2je2zXFTSBuoMMAN3HcYZLVPqKBi1JeiE.rv4kX6DK', 'kasir', NULL, '2026-10-11 00:28:36', '2026-10-11 00:28:36'),
(3, 'Manager Hinona', 'manager@hinona.test', NULL, '$2y$12$u1VJGAQDABrXB6jQmL33m.afcJLWUyHWkI4bWUDd3uthC/Cphdl0K', 'manager', NULL, '2026-10-11 00:28:36', '2026-10-11 00:28:36');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `detail_transaksi_transaksi_id_foreign` (`transaksi_id`),
  ADD KEY `detail_transaksi_menu_id_foreign` (`menu_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  ADD KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `kategori`
--
ALTER TABLE `kategori`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `meja`
--
ALTER TABLE `meja`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `meja_nomor_meja_unique` (`nomor_meja`),
  ADD UNIQUE KEY `meja_kode_qr_unique` (`kode_qr`);

--
-- Indexes for table `menu`
--
ALTER TABLE `menu`
  ADD PRIMARY KEY (`id`),
  ADD KEY `menu_kategori_id_foreign` (`kategori_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pelanggan_meja_id_foreign` (`meja_id`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `transaksi_user_id_foreign` (`user_id`),
  ADD KEY `transaksi_meja_id_foreign` (`meja_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `kategori`
--
ALTER TABLE `kategori`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `meja`
--
ALTER TABLE `meja`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `menu`
--
ALTER TABLE `menu`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `pelanggan`
--
ALTER TABLE `pelanggan`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `transaksi`
--
ALTER TABLE `transaksi`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `detail_transaksi`
--
ALTER TABLE `detail_transaksi`
  ADD CONSTRAINT `detail_transaksi_menu_id_foreign` FOREIGN KEY (`menu_id`) REFERENCES `menu` (`id`),
  ADD CONSTRAINT `detail_transaksi_transaksi_id_foreign` FOREIGN KEY (`transaksi_id`) REFERENCES `transaksi` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `menu`
--
ALTER TABLE `menu`
  ADD CONSTRAINT `menu_kategori_id_foreign` FOREIGN KEY (`kategori_id`) REFERENCES `kategori` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pelanggan`
--
ALTER TABLE `pelanggan`
  ADD CONSTRAINT `pelanggan_meja_id_foreign` FOREIGN KEY (`meja_id`) REFERENCES `meja` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `transaksi`
--
ALTER TABLE `transaksi`
  ADD CONSTRAINT `transaksi_meja_id_foreign` FOREIGN KEY (`meja_id`) REFERENCES `meja` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `transaksi_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
