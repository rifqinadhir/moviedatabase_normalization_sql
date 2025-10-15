/*
=================================================
Program ini dibuat untuk mengelola data film sebuah perusahaan penyedia layanan streaming 
=================================================
*/

--CREATE DATABASE gc_1

--Query di bawah untuk membuat tabel staging dengan nama movies.
CREATE TABLE movies (
	id VARCHAR(100) PRIMARY KEY,
	title TEXT,
	type TEXT,
	description TEXT,
	release_year INTEGER,
	age_certification TEXT,
	runtime INTEGER,
	genres TEXT[],
	production_countries TEXT[]	
);

--Query di bawah untuk memasukkan data ke dalam tabel movies setelah file movies.csv dipindahkan ke file tmp.
COPY movies(id,title,type,description,release_year,age_certification,runtime,genres,production_countries)
FROM '/tmp/movies.csv'
DELIMITER ','
CSV HEADER;

--Membuat tabel yang sudah di bersihkan (Dimana jika pada suatu baris semua kolom bernilai null maka baris tersebut dihilangkan)
CREATE TABLE movies_cleaned AS
SELECT * FROM movies
WHERE NOT (
    id IS NULL AND
	title IS NULL AND
	type IS NULL AND
	description IS NULL AND
	release_year IS NULL AND
	age_certification IS NULL AND
	runtime IS NULL AND
	genres IS NULL AND
	production_countries IS NULL
);

--Menghapus baris jika kolom id kosong (karena id adalah primary key jadi tidak boleh kosong)
DELETE FROM movies_cleaned
WHERE id IS NULL;

--Menghapus baris jika kolom title kosong (karena title sama pentingnya dengan id meskipun bukan primary key)
DELETE from movies_cleaned
WHERE title IS NULL;

--Mengganti kolom description yang kosong dengan 'no_description'
UPDATE movies_cleaned
SET description = 'no_description'
WHERE description IS NULL;

--Menganti kolom yang kosong dengan 'not_rated'
UPDATE movies_cleaned
SET age_certification = 'not_rated'
WHERE age_certification IS NULL;

--Untuk melihat tabel yang sudah di bersihkan
SELECT * FROM movies_cleaned;

--Normalisasi
--Tabel 1
--Membuat tabel utama tanpa kolom yang bersifat array
CREATE TABLE movies_utama (
    id VARCHAR(100) PRIMARY KEY,
    title TEXT,
    type TEXT,
    description TEXT,
    release_year INTEGER,
    age_certification TEXT,
    runtime INTEGER
);

--Memasukkan data dari tabel yang sudah dibersihkan 'movie_cleaned'
INSERT INTO movies_utama (id, title, type, description, release_year, age_certification, runtime)
SELECT id, title, type, description, release_year, age_certification, runtime
FROM movies_cleaned;

--Untuk melihat data tabel 'movies_utama'
SELECT * FROM movies_utama;

--Tabel 2
--Membuat tabel 'genres' yang berisi movie id dan genrenya
--Primary keynya adalah gabungan movies_id dan genres_name
--Foreign keynya adalah movies_id yang terhubung dengan id pada tabel movies_utama
CREATE TABLE genres (
    movies_id VARCHAR(100),
    genres_name TEXT,
    PRIMARY KEY (movies_id, genres_name),
    FOREIGN KEY (movies_id) REFERENCES movies_utama(id)
);

--Memasukkan data id(berasal dari tabel id di movies_cleaned) dan genre(hasil dari array yang dipecah) ke tabel genres
--LATERAL UNNEST digunakan untuk memisahkan kolom yang bersifat array menjadi baris
INSERT INTO genres (movies_id, genres_name)
SELECT id, genre
FROM movies_cleaned,
	LATERAL UNNEST(genres) AS genre;

--Untuk menampilkan tabel genres
SELECT * FROM genres;

--Tabel 3
--Membuat tabel 'countries' yang berisi movie id dan country name
--Primary keynya adalah gabungan movies_id dan countries_name
--Foreign keynya adalah movies_id yang terhubung dengan id pada tabel movies_utama
CREATE TABLE countries (
    movies_id TEXT,
    countries_name TEXT,
    PRIMARY KEY (movies_id, countries_name),
    FOREIGN KEY (movies_id) REFERENCES movies_utama(id)
);

--Memasukkan data id(berasal dari tabel id di movies_cleaned) dan country(hasil dari array yang dipecah) ke tabel countries
--LATERAL UNNEST digunakan untuk memisahkan kolom yang bersifat array menjadi baris
INSERT INTO countries (movies_id, countries_name)
SELECT id, country
FROM movies_cleaned,
	LATERAL UNNEST(production_countries) AS country;

--Untuk Menampilkan data tabel countries
SELECT * FROM countries;

--Analisis
--1. Menampilkan semua film dengan genre dan negara produksinya.
--Mengambil kolom title dari tabel movies_utama, kolom genres_name dari tabel genres, dan kolom countries name dari tabel countries
--Menggabungkan tabel movies utama dengan genres dan countries berdasarkan kecocokan movies_id
SELECT 
  movies_utama.title,
  genres.genres_name,
  countries.countries_name
FROM movies_utama
JOIN genres ON movies_utama.id = genres.movies_id
JOIN countries ON movies_utama.id = countries.movies_id;

--2. Genre film yang paling populer.
--Pilih kolom yang digunakan sebagai acuan yaitu kolom genre_name
--Kemudian hitung jumlah baris untuk setiap genre
--Kelompokkan berdasarkan nilai dari setiap genres
--Urutkan dari yang terbesar kemudian tampilkan 1 baris pertama
SELECT
	genres_name,
	COUNT(*)
FROM genres
GROUP BY genres_name
ORDER BY COUNT(*) DESC
LIMIT 1;

--3. Negara yang paling banyak membuat film
--Pilih kolom yang digunakan sebagai acuan yaitu kolom countries_name
--Kemudian hitung jumlah baris untuk setiap negara
--Kelompokkan berdasarkan nama negara
--Urutkan dari yang terbesar kemudian tampilkan 1 baris pertama
SELECT 
    countries_name,
    COUNT(*)
FROM countries
GROUP BY countries_name
ORDER BY COUNT(*) DESC
LIMIT 1;