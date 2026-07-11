# Sıfırdan Kurulum Rehberi

Bilgisayardan anlamayanlar için adım adım. Yaklaşık 5-10 dakika sürer.
Kurulum bir kere yapılır, sonrasında her şey tek tıkla çalışır.

---

## MAC KULLANIYORSAN

### 1. Terminal'i aç
Klavyede **Cmd + Boşluk** tuşlarına bas, açılan arama kutusuna
**Terminal** yaz, Enter'a bas. Siyah/beyaz bir yazı penceresi açılacak.
Korkma, sadece aşağıdakileri yapıştıracaksın.

### 2. Aşağıdaki TEK satırı KOPYALA, Terminal'e YAPIŞTIR, Enter'a bas

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/hakan-svg/video-indirici/main/mac-kur.sh)"
```

Gerisini kurulum kendisi halleder. Sadece şunlar olabilir:

- Mac **"komut satırı araçları kurulsun mu?"** penceresi açarsa
  **Yükle**'ye tıkla ve bekle — kurulum kendiliğinden devam eder.
- **Şifreni sorarsa** yaz (yazarken ekranda görünmez, normaldir), Enter'a bas.
- **"Terminal, Chrome'u denetlemek istiyor"** diye sorarsa **Tamam**'a tıkla.

Sonunda **"✅ Kurulum bitti"** yazısını göreceksin; Chrome'da eklenti
sayfası, Finder'da da **eklenti** klasörü kendiliğinden açılır.
Terminal'i kapatabilirsin.

---

## WINDOWS KULLANIYORSAN

### 1. Python kur
https://www.python.org/downloads/ adresinden **Download Python**'a tıkla,
indirilen dosyayı aç. **ÖNEMLİ:** Kurulum ekranının en altındaki
**"Add python.exe to PATH"** kutusunu mutlaka İŞARETLE, sonra
**Install Now**'a tıkla.

### 2. ffmpeg kur
Başlat menüsüne **cmd** yaz, **Komut İstemi**'ni aç, şunu yapıştır, Enter:

```
winget install Gyan.FFmpeg
```

### 3. Programı indir
https://github.com/hakan-svg/video-indirici adresine gir →
yeşil **Code** düğmesi → **Download ZIP**. İnen ZIP'e sağ tıkla →
**Tümünü ayıkla** → çıkan **video-indirici** klasörünü
**Belgeler**'in içine taşı.

### 4. Kur
Klasörün içindeki **kur.bat** dosyasına çift tıkla, bitmesini bekle.
("Windows bilgisayarınızı korudu" uyarısı çıkarsa **Ek bilgi →
Yine de çalıştır**.) Sonra **otomatik-baslat-kur.bat**'a çift tıkla.
Son olarak **baslat.bat**'a çift tıkla (bir kereliğine; bundan sonra
bilgisayar her açıldığında kendiliğinden çalışır).

---

## CHROME EKLENTİSİNİ EKLE (Mac ve Windows'ta aynı)

1. Chrome'un adres çubuğuna şunu yaz, Enter'a bas: `chrome://extensions`
2. Sağ üst köşedeki **Geliştirici modu** anahtarını aç (maviye dönsün)
3. Sol üstte beliren **Paketlenmemiş öğe yükle** düğmesine tıkla
4. **video-indirici** klasörünün içindeki **eklenti** klasörünü seç → **Seç**
5. Araç çubuğunda puzzle (🧩) simgesine tıkla → **Video İndirici**'nin
   yanındaki raptiyeye tıkla ki hep görünsün

---

## KULLANIM

1. Video olan herhangi bir sayfayı aç (YouTube, Twitter, Instagram…)
2. Araç çubuğundaki **Video İndirici** simgesine tıkla
3. 1-2 saniye içinde videonun adı ve kalite düğmeleri gelir
   (örn. **1080p**, **720p**, **Sadece ses**)
4. İstediğin kaliteye tıkla → video **İndirilenler / VideoIndirici**
   klasörüne iner. Bitince popup'ta yeşil ✅ görürsün.

**Instagram veya girişli içerik inmezse:** popup'ın altındaki
**"Chrome çerezlerini kullan"** kutusunu işaretleyip tekrar dene.

## SORUN OLURSA

- **"Yerel sunucu çalışmıyor" diyorsa:** video-indirici klasöründeki
  **baslat.command**'a (Mac) / **baslat.bat**'a (Windows) çift tıkla.
- **Video bulunamadı diyorsa:** sayfayı yenileyip videoyu bir kez
  oynatmayı dene, sonra tekrar simgeye tıkla.
