# Soat — Redmi (MIUI) uslubidagi Flutter ilova

Redmi 14 default soat ilovasiga o'xshash, qora fon + apelsin rang aksentli soat ilovasi.

## Imkoniyatlari
- **Soat** — katta raqamli soat, sana, dunyo soatlari (Toshkent, Moskva, London va h.k.)
- **Uyg'otqich** — qo'shish/o'chirish, vaqt tanlash, hafta kunlari bo'yicha takrorlash, yoqish/o'chirish switch
- **Sekundomer** — bo'lak (lap) vaqtlari bilan
- **Taymer** — aylana progress, tayyor presetlar (1, 3, 5, 10, 20, 30 daqiqa) va o'zingiz vaqt tanlash

## Ishga tushirish

1. Flutter SDK o'rnatilgan bo'lishi kerak (3.x versiya): https://docs.flutter.dev/get-started/install
2. Arxivni oching va papkaga kiring:
   ```bash
   cd redmi_clock
   ```
3. `android/local.properties.example` faylini `android/local.properties` deb nomlab, o'z SDK yo'llaringizni yozing:
   ```
   sdk.dir=/Users/username/Library/Android/sdk
   flutter.sdk=/Users/username/development/flutter
   ```
4. Paketlarni o'rnating:
   ```bash
   flutter pub get
   ```
5. Qurilma yoki emulyatorda ishga tushiring:
   ```bash
   flutter run
   ```
6. APK yig'ish uchun:
   ```bash
   flutter build apk --release
   ```
   Tayyor fayl: `build/app/outputs/flutter-apk/app-release.apk`

## Muhim eslatmalar

- **Uyg'otqich** tizim bildirishnomalari (`flutter_local_notifications`) orqali ishlaydi. Android 12+ da aniq vaqt uchun "Alarms & reminders" ruxsatini so'raydi — birinchi ishga tushirishda tizim ruxsat so'rovini ko'rsatadi.
- Ilova birinchi marta ochilganda bildirishnoma ruxsatini so'raydi — buni albatta tasdiqlang, aks holda uyg'otqich chalinmaydi.
- Ilova nomi va paket nomi (`com.redmiclock.app`) — kerak bo'lsa `android/app/build.gradle` va `AndroidManifest.xml` da o'zgartirishingiz mumkin.
- Ilova ikonkasi avtomatik generatsiya qilingan oddiy soat belgisi — xohlasangiz `flutter_launcher_icons` paketi orqali o'zingiznikini qo'yishingiz mumkin.

## Papka tuzilishi

```
lib/
  main.dart              - ilova kirish nuqtasi, pastki navigatsiya
  theme/app_theme.dart   - MIUI uslubidagi rang sxemasi
  models/alarm.dart      - Alarm modeli
  services/              - bildirishnoma va saqlash xizmatlari
  screens/
    clock_screen.dart
    alarm_screen.dart
    edit_alarm_screen.dart
    stopwatch_screen.dart
    timer_screen.dart
```

Omad tilaymiz! 🕐
