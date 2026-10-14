Nama : Alia Julyanti (240605110165)
       Nadya Clarisa Azzahra (240605110166)
# SpotNgafe

Aplikasi rekomendasi kafe terdekat untuk mahasiswa nugas di Malang berbasis Flutter dan Dart. Aplikasi berfokus pada dua fitur inti:
1. Algoritma Haversine di perangkat untuk menghitung jarak dan mengurutkan kafe terdekat tanpa mengirim koordinat pengguna ke server.
2. Crowdsourcing status kepadatan kafe (Sepi, Sedang, Penuh) dengan agregasi 2 jam dan anti-spam cooldown 30 menit.

---

## Arsitektur Tiga Lapisan (Folder Structure)

Proyek ini dipisahkan secara ketat ke dalam tiga lapisan:

- **lib/core/**
  - `geo/haversine.dart`: Fungsi murni rumus Haversine (R = 6371.0 km, clamp a ke 0.0..1.0). Koordinat pengguna tidak pernah disimpan atau dikirim ke server.
  - `utils/formatters.dart`: Pemformatan jarak (meter / km), kisaran harga (Rp.. rb), dan waktu relatif (X menit lalu).
- **lib/domain/**
  - `crowd_aggregator.dart`: Logika agregasi laporan 2 jam terakhir (suara terbanyak menang, pemecah seri memilih laporan terbaru, pengabaian laporan kedaluwarsa) dan anti-spam cooldown 30 menit per pengguna per kafe.
  - `cafe_filter.dart`: Logika penyaringan radius (1/3/5/10 km), fasilitas (Wi-Fi, Colokan), dan harga termurah (dibandingkan dengan priceMin kafe).
- **lib/data/**
  - `models/`: Model `Cafe`, `CrowdReport`, dan enum `CrowdLevel`.
  - `repositories/`: `CafeRepository` (kontrak abstrak), `FirestoreCafeRepository` (implementasi Cloud Firestore), dan `SeedCafeRepository` (data awal lokal 10 kafe Malang dan laporan contoh untuk pengujian tanpa Firebase).
  - `services/`: `AuthService` (Firebase Anonymous Auth dan UID lokal sementara) dan `LocationService` (pemeriksaan GPS dan izin lokasi via Geolocator).
- **lib/ui/**
  - `theme/app_theme.dart`: Tema terang Material 3 dengan palet warna hijau petrol (#1F5F5B), latar (#F7F6F2), dan tipografi Roboto.
  - `screens/`: Splash, Izin Lokasi, Beranda, dan Detail Kafe.
  - `widgets/`: Kartu kafe, chip kepadatan, lembar filter, dan lembar lapor kepadatan.
- **test/**
  - `haversine_test.dart`: Pengujian rumus Haversine (jarak nol, simetri, koordinat Malang yang diketahui, clamping).
  - `crowd_aggregator_test.dart`: Pengujian agregasi suara terbanyak, penanganan seri, jendela 2 jam, hasil null jika kosong, dan cooldown 30 menit.
  - `cafe_filter_test.dart`: Pengujian penyaringan Wi-Fi, colokan, radius, dan jenjang harga.

---

## Cara Menjalankan Aplikasi

Pastikan Flutter SDK (versi >= 3.0.0) telah terpasang di komputer Anda.

1. Buka terminal di direktori proyek ini:
   ```bash
   flutter pub get
   ```

2. Jalankan pengujian unit dan logika domain:
   ```bash
   flutter test
   ```

3. Jalankan aplikasi pada emulator atau perangkat fisik Android:
   ```bash
   flutter run
   ```

Secara default, konstanta `useFirebase` pada `lib/main.dart` bernilai `false`. Aplikasi akan langsung berjalan menggunakan `SeedCafeRepository` dengan 10 kafe di seputaran Lowokwaru, Suhat, Klojen, dan Dinoyo Malang.

---

## Cara Mengaktifkan Firebase (Cloud Firestore & Auth)

Jika Anda ingin menghubungkan aplikasi ke Firebase sungguhan:

1. Pasang Firebase CLI dan FlutterFire CLI:
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   ```

2. Hubungkan proyek Flutter dengan Firebase Project Anda:
   ```bash
   flutterfire configure
   ```
   Perintah ini akan membuat `firebase_options.dart` dan meletakkan `google-services.json` ke dalam folder `android/app/`.

3. Pasang aturan keamanan Firestore:
   Salin isi file `firestore.rules` ke Firebase Console -> Cloud Firestore -> Rules, atau jalankan:
   ```bash
   firebase deploy --only firestore:rules
   ```

4. Aktifkan Anonymous Authentication di Firebase Console:
   Buka Firebase Console -> Authentication -> Sign-in method -> aktifkan penyedia **Anonymous**.

5. Ubah konfigurasi di `lib/main.dart`:
   Ganti nilai konstanta:
   ```dart
   const bool useFirebase = true;
   ```

6. Jalankan kembali aplikasi:
   ```bash
   flutter run
   ```

---

## Asumsi yang Digunakan

1. **Format Koordinat & Jarak**:
   Koordinat kafe menggunakan derajat desimal standar WGS84. Algoritma Haversine menghitung jarak geodesik lingkaran besar dengan asumsi radius bumi rata-rata 6371.0 km.
2. **Ketiadaan Lokasi**:
   Jika pengguna menolak izin lokasi atau GPS perangkat dimatikan, aplikasi tidak menggunakan lokasi tiruan/palsu (mocking). Daftar kafe ditampilkan apa adanya tanpa label jarak dan tanpa urutan jarak, disertai banner opsi untuk mengaktifkan izin lokasi.
3. **Penyaringan Harga**:
   Penyaringan harga (di bawah Rp20 rb, Rp20-40 rb, di atas Rp40 rb) dicocokkan terhadap harga menu terendah kafe (`priceMin`), sesuai ketentuan instruksi teknis.
4. **Agregasi Status Kepadatan**:
   Status kepadatan dihitung secara dinamis di klien dari laporan-laporan yang masuk dalam kurun waktu 2 jam terakhir (tidak disimpan sebagai status statis di dokumen kafe).
5. **Anti-Spam Cooldown**:
   Batasan pelaporan adalah satu laporan per kafe setiap 30 menit untuk pengguna yang sama. Pemeriksaan dilakukan berdasarkan riwayat laporan pengguna (`userId`) untuk kafe tersebut (`cafeId`).
