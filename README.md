# LaundryHub

## Arsitektur Sistem

LaundryHub merupakan sistem yang terintegrasi antara aplikasi mobile, website, backend, dan database. Aplikasi mobile digunakan oleh Customer dan Owner untuk mengelola layanan laundry, sedangkan website dapat diakses melalui https://laundryhub.my.id/. Seluruh data pengguna, layanan, pesanan, dan transaksi disimpan pada database yang sama dan dikelola melalui backend/API yang berfungsi sebagai penghubung antara aplikasi mobile dan website. Dengan menggunakan backend dan database yang terpusat, setiap perubahan data pada salah satu platform akan otomatis tersinkronisasi dan dapat diakses secara real-time pada platform lainnya.


## Website

Aplikasi web dapat diakses melalui:

https://laundryhub.my.id/

## Cara Menjalankan Project Flutter

### 1. Clone Repository

```bash
git clone https://github.com/Dsharlendita/UPDATE_TUBESMOBILE_KELOMPOK3.git
cd UPDATE_TUBESMOBILE_KELOMPOK3
```

### 2. Install Dependency

```bash
flutter pub get
```

### 3. Jalankan Aplikasi

Pastikan emulator atau perangkat Android telah terhubung.

```bash
flutter run
```

## Akun Demo

### Customer

#### Akun 1

Email:

```text
dsharlendita@gmail.com
```

Password:

```text
aquarius
```

Keterangan:

* Dapat melakukan reset password.
* Email terdaftar dan valid.

#### Akun 2

Email:

```text
ani@customer.com
```

Password:

```text
password
```

Keterangan:
Akun menggunakan email dummy sehingga fitur reset password tidak dapat digunakan karena email pemulihan tidak dapat dikirim.

#### Akun 3

Email:

```text
budi@laundry.com
```

Password:

```text
password
```

### Owner

Gunakan akun owner yang tersedia pada database aplikasi untuk mengakses fitur administrasi dan manajemen laundry
