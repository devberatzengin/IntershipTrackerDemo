# 📋 Internship Tracker

> Staj başvurularını takip eden, iş ilanlarını listeleyen ve şirket konumlarını haritada gösteren iOS uygulaması.

![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![iOS](https://img.shields.io/badge/iOS-17%2B-blue?logo=apple)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-purple)
![SwiftData](https://img.shields.io/badge/SwiftData-ORM-green)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20%2B%20MVVM-red)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## 📸 Ekran Görüntüleri
<img width="400" height="800" alt="WhatsApp Image 2026-06-03 at 17 35 10" src="https://github.com/user-attachments/assets/85ecb31e-17c3-4024-a0c0-36f4f48a79e2" />
<img width="400" height="800" alt="WhatsApp Image 2026-06-03 at 17 35 15" src="https://github.com/user-attachments/assets/f0ca28b3-fb04-4821-8000-ec81543868f4" />
<img width="400" height="800" alt="WhatsApp Image 2026-06-03 at 17 35 18" src="https://github.com/user-attachments/assets/40846d68-b0b8-493f-8d88-75b221dc37c2" />
<img width="400" height="800" alt="WhatsApp Image 2026-06-03 at 17 35 14" src="https://github.com/user-attachments/assets/484a9cb3-8771-40e4-bf12-d6e2ec5d42a8" />
<img width="400" height="800" alt="WhatsApp Image 2026-06-03 at 17 35 11" src="https://github.com/user-attachments/assets/1476f5b9-6158-4177-b1bd-400c095f648c" />
<img width="400" height="800" alt="WhatsApp Image 2026-06-03 at 17 35 16" src="https://github.com/user-attachments/assets/9200152f-8f15-47fd-92d7-c50b0ba49b77" />

---

## 🚀 Özellikler

| Özellik | Açıklama |
|--------|----------|
| 📝 **Başvuru Takibi** | Staj başvurularını duruma göre takip edin: Beklemede, Mülakat, Teklif, Red |
| 🌐 **İş İlanları** | [Remotive Public API](https://remotive.com/api/remote-jobs) üzerinden gerçek zamanlı uzaktan ilanlar |
| 🔔 **Bildirimler** | Yeni ilan algılandığında otomatik local notification |
| 🗺️ **Harita** | Apple Maps ile şirket konumu görüntüleme ve yol tarifi |
| 💾 **Kalıcı Depolama** | SwiftData ile cihaz üzerinde yerel veri saklama |
| 🧪 **Test Bildirimi** | "Test bildirimi gönder" butonu ile bildirim sistemini deneme |

---

## 🛠️ Teknolojiler

- **Dil:** Swift 5.9
- **UI Framework:** SwiftUI
- **Veri Katmanı:** SwiftData
- **Ağ:** URLSession
- **Harita:** MapKit & Apple Maps
- **Bildirimler:** UserNotifications Framework
- **Mimari:** Clean Architecture + MVVM
- **Minimum iOS:** iOS 17

---

## 🏗️ Mimari

Proje **Clean Architecture** prensiplerine uygun, katmanlı bir yapıda geliştirilmiştir:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│     SwiftUI View + ViewModel        │
├─────────────────────────────────────┤
│           Domain Layer              │
│       Use Cases + Protocols         │
├─────────────────────────────────────┤
│            Data Layer               │
│   Repository + Remote + Local       │
└─────────────────────────────────────┘
```

- **View:** Yalnızca UI bileşenlerini barındırır, iş mantığı içermez
- **ViewModel:** `@Observable` ile reaktif veri akışını yönetir
- **Repository:** Yerel (SwiftData) ve uzak (Remotive API) veri kaynaklarını soyutlar

---

## ⚙️ Kurulum

### Gereksinimler

- Xcode 15+
- iOS 17+ simülatör veya gerçek cihaz
- macOS Ventura veya üzeri

### Adımlar

```bash
# 1. Repoyu klonlayın
git clone https://github.com/devberatzengin/IntershipTrackerDemo.git

# 2. Proje dizinine girin
cd IntershipTrackerDemo

# 3. Xcode ile açın
open "Internship Tracker.xcodeproj"
```

### İzinler

Xcode → Target → Info bölümüne aşağıdaki anahtarı ekleyin:

| Key | Value |
|-----|-------|
| `NSLocationWhenInUseUsageDescription` | Şirket konumlarını haritada göstermek ve yol tarifi oluşturmak için konumunuzu kullanıyoruz. |

---

## 🔔 Bildirim Sistemi

Uygulama açılışında notification izni istenir.

**Nasıl çalışır?**
1. İlk API çekişinde mevcut ilanlar "görülmüş" kabul edilir — bildirim **gönderilmez**
2. Sonraki yenilemede yeni ilan id'leri tespit edilirse local notification tetiklenir
3. **Test için:** Staj İlanları ekranı → "Test bildirimi gönder" → Uygulamayı arka plana alın → ~2 saniye sonra bildirim gelir

> 💡 Bildirim geçmişini sıfırlamak için "İlan bildirim geçmişini sıfırla" butonunu kullanabilirsiniz.

---

## 🌐 API

Bu proje [Remotive Public API](https://remotive.com/api/remote-jobs) kullanmaktadır.

```
GET https://remotive.com/api/remote-jobs
```

- Ücretsiz, kayıt gerektirmez
- Gerçek zamanlı uzaktan çalışma ilanları döner

---

## 📁 Proje Yapısı

```
Internship Tracker/
├── App/
│   └── InternshipTrackerApp.swift
├── Presentation/
│   ├── Applications/          # Başvuru listesi ve detay ekranları
│   ├── Jobs/                  # Remotive ilanları ekranı
│   ├── Map/                   # Harita ekranı
│   └── Settings/              # Ayarlar
├── Domain/
│   ├── Models/                # Uygulama modelleri
│   └── UseCases/              # İş mantığı
├── Data/
│   ├── Remote/                # API servisleri
│   └── Local/                 # SwiftData repository
└── Core/
    └── Extensions/            # Yardımcı uzantılar
```

---


## 👤 Geliştirici

- GitHub: [@devberatzengin](https://github.com/devberatzengin)
- GitHub: [@omer-damar](https://github.com/omer-damar)

---

> *"I know, I misspelled it, it should have been internship, but oh well."* 😄
