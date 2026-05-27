# Internship Tracker iOS Feature Patch

Bu paket mevcut SwiftUI + SwiftData projesine şu özellikleri eklemek için hazırlandı:

1. Staj İlanları / Kariyer Tavsiyeleri ekranı
2. Remotive public API üzerinden ilan çekme
3. Yeni ilan algılanınca local notification oluşturma
4. Test bildirimi gönderme
5. Cihaz konumuna erişme
6. Şirket/adres arama
7. Haritada marker gösterme
8. Apple Maps ile yol tarifi başlatma



## 3) Location permission ekle

Xcode > Target > Info bölümüne şu key'i ekleyin:

`Privacy - Location When In Use Usage Description`

Önerilen açıklama:

`Şirket konumlarını haritada göstermek ve yol tarifi oluşturmak için konumunu kullanıyoruz.`

Raw plist key adı:

`NSLocationWhenInUseUsageDescription`

## 4) Bildirim izni

Uygulama açılışında notification izni istenir. Test için:

- Staj İlanları ekranı > "Test bildirimi gönder"
- Uygulamayı arka plana alın
- Yaklaşık 2 saniye sonra bildirim gelmeli

## 5) API bildirimi nasıl çalışır?

İlk API çekişinde mevcut ilanlar "görülmüş" kabul edilir ve bildirim gönderilmez.
Sonraki çekişlerde yeni ilan id'leri bulunursa local notification planlanır.

Demo için:
- "İlan bildirim geçmişini sıfırla" butonuna basabilirsiniz.
- Sonra tekrar ilanları yenileyebilirsiniz.

## 6) Not

Bu kodlar iOS 17+ SwiftUI/SwiftData projesi için yazıldı. Proje SwiftData kullandığı için zaten iOS 17 hedefli olması beklenir.
