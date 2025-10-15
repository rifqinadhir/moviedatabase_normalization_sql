# **Database Normalization and Analytical Querying with SQL and PostgreSQL**

---

## Overview
Project ini berfokus pada pembuatan database film yang terstruktur dan efisien menggunakan SQL dan PostgreSQL. Data dari file CSV dimuat ke tabel staging, dibersihkan dari nilai kosong atau duplikat, lalu dinormalisasi dari 1NF hingga 3NF dengan memecah kolom array (genres, countries) menjadi tabel relasional. Setelah struktur database terbentuk dan relasi antar tabel diatur dengan primary key dan foreign key, dibuat query analitik untuk menggali insight seperti genre paling populer dan negara produksi terbanyak.

---

## File Description
- erd_movie.png: Berisi diagram ERD yang menunjukkan struktur tabel hasil normalisasi dan relasi antar tabel.
- movies.csv: File data mentah berisi informasi film yang digunakan sebagai input sebelum proses cleaning dan normalisasi.
- normalized_movie_database: Folder yang berisi seluruh script SQL untuk staging, data cleaning, normalisasi 1NF–3NF, dan query analitik.

---

## Steps
1. Pembuatan Database dan Tabel Staging
- Membuat database (opsional)
- Membuat tabel movies sebagai staging
- Memuat data dari movies.csv menggunakan COPY

2. Data Cleaning
- Menghapus baris yang seluruh kolomnya NULL
- Menghapus baris dengan id dan title kosong
- Mengganti description kosong → no_description
- Mengganti age_certification kosong → not_rated

3. Normalisasi ke 3NF
  - Membuat tabel utama movies_utama tanpa kolom array
- Membuat tabel relasional:
- genres (movies_id, genres_name)
- countries (movies_id, countries_name)
- Memecah kolom array menggunakan LATERAL UNNEST
- Menerapkan PRIMARY KEY dan FOREIGN KEY

---

## Final Database Structure
- movies_utama → Data film utama
- genres → Relasi film dan genre
- countries → Relasi film dan negara produksi

---

## Analysis
1. Menampilkan semua film beserta genre dan negara produksinya
2. Menentukan genre film yang paling populer
3. Menentukan negara dengan jumlah produksi film terbanyak

---

## Result
- Genre terpopuler: (hasil query)
- Negara produksi terbanyak: (hasil query)

---

## Tools & Technologies
- PostgreSQL
- SQL (DDL, DML, SELECT)
- pgAdmin 

---

## 👤 Author
Rifqi Nadhir Aziz

