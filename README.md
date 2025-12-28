# VGTec - Pavement Damage Detector

<p align="center">
  <img src="assets/images/logo.png" alt="VGTec Logo" width="150">
</p>

<p align="center">
  <strong>Aplikasi Mobile Dengan Sistem Identifikasi, Perhitungan Dimensi, Dan Kebutuhan Aspal Pada Kerusakan Jalan Lentur Berbasis Deep Learning Serta Integrasi Sensor Ultrasonic Dan Infrared</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#installation">Installation</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#download">Download</a>
</p>

---

## 📱 About

**VGTec** adalah aplikasi mobile untuk identifikasi dan analisis kerusakan jalan lentur (flexible pavement) menggunakan teknologi deep learning. Aplikasi ini dilengkapi dengan kemampuan perhitungan dimensi kerusakan dan estimasi kebutuhan material aspal untuk perbaikan.

## ✨ Features

### 🔍 Identifikasi Kerusakan
- Deteksi otomatis jenis kerusakan jalan menggunakan kamera smartphone
- Klasifikasi berbagai tipe kerusakan (retak, lubang, dll)
- Computer vision berbasis deep learning

### 📐 Perhitungan Dimensi
- Pengukuran panjang, lebar, dan kedalaman kerusakan
- Integrasi sensor ultrasonic untuk akurasi tinggi
- Kalkulasi volume kerusakan otomatis

### 🧮 Estimasi Kebutuhan Aspal
- Perhitungan kebutuhan material berdasarkan dimensi kerusakan
- Estimasi biaya perbaikan
- Laporan detail untuk perencanaan maintenance

### 🧠 Deep Learning YOLOv11
- Model neural network terbaru untuk deteksi objek
- Akurasi tinggi dalam berbagai kondisi pencahayaan
- Real-time processing pada perangkat mobile

### 📡 Integrasi Sensor
- **Sensor Ultrasonic**: Pengukuran kedalaman yang presisi
- **Sensor Infrared**: Deteksi kondisi permukaan jalan
- Konektivitas Bluetooth untuk integrasi hardware

### 🌍 Fitur Tambahan
- GPS tracking untuk lokasi kerusakan
- Cloud sync untuk backup data
- Dashboard analitik visual
- Enkripsi data untuk keamanan

## 🛠️ Tech Stack

### Mobile App
- **Framework**: Flutter
- **Language**: Dart
- **AI/ML**: TensorFlow Lite, YOLOv11
- **Database**: Drift (SQLite), Supabase
- **Maps**: Google Maps Flutter
- **Camera**: Camera, Image Picker

### Backend
- **Cloud**: Supabase
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage

### Hardware Integration
- ESP32 / Arduino
- HC-SR04 Ultrasonic Sensor
- IR Infrared Sensor
- Bluetooth Module

## 📋 Requirements

- Android 7.0 (Nougat) atau lebih tinggi
- Minimal 100MB ruang penyimpanan
- Kamera dengan resolusi minimal 720p
- GPS untuk fitur lokasi
- Bluetooth (untuk koneksi sensor eksternal)

## 🚀 Installation

### From APK
1. Download APK terbaru dari [Releases](../../releases)
2. Aktifkan "Install from Unknown Sources" di pengaturan Android
3. Buka file APK dan install
4. Berikan izin yang diperlukan (kamera, lokasi, storage)

### Build from Source
```bash
# Clone repository
git clone https://github.com/royhairul/vgtec_app.git
cd vgtec_app

# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

## 📁 Project Structure

```
vgtec_app/
├── lib/
│   ├── models/          # Data models
│   ├── screens/         # UI screens
│   ├── services/        # Business logic & API
│   ├── widgets/         # Reusable components
│   └── main.dart        # Entry point
├── assets/
│   ├── images/          # App images & icons
│   └── models/          # ML model files
├── website/             # Download landing page
│   ├── index.html
│   ├── styles.css
│   └── script.js
└── pubspec.yaml         # Dependencies
```

## 🌐 Website

Landing page untuk download aplikasi tersedia di folder `/website`. Website ini menampilkan:
- Informasi fitur aplikasi
- Download APK terbaru dari GitHub Releases
- Panduan instalasi
- Riwayat semua versi release

### Menjalankan Website Lokal
Buka `website/index.html` di browser atau gunakan live server.

## 📸 Screenshots

*Coming soon*

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## 🙏 Acknowledgments

- Flutter Team for the amazing framework
- Ultralytics for YOLOv11
- Supabase for backend infrastructure

---

<p align="center">
  Made with ❤️ for better road infrastructure
</p>
