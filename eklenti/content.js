// Video İndirici — sayfadaki videoları bulur, üzerlerine indirme düğmesi koyar.
(() => {
  const EN_KUCUK_GENISLIK = 180; // küçük önizleme/avatar videolarını atla
  const dugmeler = new Map();     // video -> düğme
  let panel = null;

  const OK_SVG =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" ' +
    'stroke-linecap="round" stroke-linejoin="round">' +
    '<path d="M12 4v11"/><path d="M8 11l4 4 4-4"/><path d="M5 20h14"/></svg>';

  function mesajGonder(m) {
    return chrome.runtime.sendMessage(m).catch(() => ({ hata: "sunucu-yok" }));
  }

  // Akış sayfalarında (Twitter/X, LinkedIn, Instagram ana sayfa) sayfa adresi
  // genel olduğundan, tıklanan videonun ait olduğu gönderinin linkini bul.
  function videoUrlBul(video) {
    const host = location.hostname;
    try {
      if (/(^|\.)(x|twitter)\.com$/.test(host)) {
        const makale = video.closest("article");
        const yol = makale && [...makale.querySelectorAll("a[href]")]
          .map((a) => a.getAttribute("href"))
          .find((h) => /^\/[^/]+\/status\/\d+$/.test(h));
        if (yol) return location.origin + yol;
      }
      if (/(^|\.)linkedin\.com$/.test(host)) {
        // Gönderi kimliği (urn:li:activity:...) sarmalayan öğelerin
        // herhangi bir data- özniteliğinde olabilir; ata zincirini tara.
        for (let e = video; e && e !== document.body; e = e.parentElement) {
          for (const oz of e.attributes || []) {
            const es = String(oz.value).match(/urn:li:(?:activity|ugcPost):(\d+)/);
            if (es) {
              return "https://www.linkedin.com/feed/update/urn:li:activity:" +
                es[1] + "/";
            }
          }
          // Gönderiye giden bağlantı da işimizi görür
          const a = e.querySelector &&
            e.querySelector("a[href*='/feed/update/urn:li:activity:'],a[href*='/posts/']");
          if (a) return new URL(a.getAttribute("href"), location.origin).href;
        }
      }
      if (/(^|\.)instagram\.com$/.test(host) && location.pathname === "/") {
        const makale = video.closest("article");
        const a = makale &&
          makale.querySelector("a[href*='/reel/'],a[href*='/p/']");
        if (a) return new URL(a.getAttribute("href"), location.origin).href;
      }
    } catch { /* bulunamazsa sayfa adresi kullanılır */ }
    return location.href;
  }

  // Eklenti kaldırılır/güncellenirse açık sekmelerde kalan düğme ve panel
  // DOM'da yetim kalıp tıklamaları engelleyebilir — kendimizi temizleyelim.
  let zamanlayici = null;
  function temizle() {
    clearInterval(zamanlayici);
    for (const [, d] of dugmeler) d.remove();
    dugmeler.clear();
    panelKapat();
  }

  function dugmeOlustur(video) {
    const d = document.createElement("div");
    d.className = "vi-dugme";
    d.innerHTML = OK_SVG;
    d.title = "Videoyu indir";
    d.addEventListener("click", (e) => {
      e.preventDefault();
      e.stopPropagation();
      panelAc(video, d);
    });
    document.documentElement.appendChild(d);
    dugmeler.set(video, d);
  }

  function konumla() {
    for (const [video, d] of dugmeler) {
      if (!video.isConnected) {
        d.remove();
        dugmeler.delete(video);
        continue;
      }
      const r = video.getBoundingClientRect();
      // Yeterince büyük ve görünür alandaki her videoda düğmeyi göster.
      // (Eski davranışta düğme yalnızca fare tam videonun üstündeyken
      //  görünüyordu; YouTube oynatıcısı bu koordinat testini bozup düğmeyi
      //  hiç göstermiyordu. Artık görünür alandaysa hep gösteriyoruz.)
      const gorunur = r.width >= EN_KUCUK_GENISLIK && r.height >= 100 &&
        r.bottom > 40 && r.top < innerHeight - 20;
      d.classList.toggle("vi-gorunur", gorunur);
      if (gorunur) {
        d.style.top = Math.max(r.top + 10, 8) + "px";
        d.style.left = Math.min(r.right, innerWidth) - 44 + "px";
      }
    }
  }

  // Fare videonun üstündeyken düğmeyi tam belirginleştir (opsiyonel vurgu).
  document.addEventListener("mousemove", (e) => {
    for (const [video, d] of dugmeler) {
      const r = video.getBoundingClientRect();
      const ustunde =
        e.clientX >= r.left && e.clientX <= r.right &&
        e.clientY >= r.top && e.clientY <= r.bottom;
      d.classList.toggle("vi-vurgu", ustunde || d.contains(e.target));
    }
  }, { passive: true, capture: true });

  function tara() {
    if (!chrome.runtime?.id) return temizle(); // eklenti kaldırılmış
    document.querySelectorAll("video").forEach((v) => {
      if (!dugmeler.has(v)) dugmeOlustur(v);
    });
    konumla();
  }

  function panelKapat() {
    if (panel) {
      panel.remove();
      panel = null;
    }
  }

  async function panelAc(video, dugme) {
    panelKapat();
    panel = document.createElement("div");
    panel.className = "vi-panel";
    const r = dugme.getBoundingClientRect();
    panel.style.top = Math.min(r.bottom + 8, innerHeight - 120) + "px";
    panel.style.left = Math.max(8, r.right - 270) + "px";
    panel.innerHTML =
      '<div class="vi-yukleniyor"><div class="vi-donen"></div>' +
      '<span class="vi-durum">Video bilgisi alınıyor…</span></div>';
    document.documentElement.appendChild(panel);

    const hedef = videoUrlBul(video);
    const yanit = await mesajGonder({
      tip: "formatlar", url: hedef, ref: document.referrer,
    });
    if (!panel) return;
    if (yanit.hata) return hataGoster(yanit.hata);

    panel.textContent = "";
    const baslik = document.createElement("div");
    baslik.className = "vi-baslik";
    baslik.textContent = yanit.baslik || "Video";
    panel.appendChild(baslik);

    const kutu = document.createElement("div");
    kutu.className = "vi-secenekler";
    panel.appendChild(kutu);

    const ekle = (etiket, govde, birincil) => {
      const s = document.createElement("button");
      s.className = "vi-secenek" + (birincil ? " vi-birincil" : "");
      s.textContent = etiket;
      s.onclick = () => indir(hedef, govde, yanit.baslik || "");
      kutu.appendChild(s);
    };
    const secenekler = yanit.secenekler || [{ etiket: "En iyi kalite" }];
    secenekler.forEach((s, i) => {
      const { etiket, ...govde } = s;
      ekle(etiket, govde, i === 0);
    });
    ekle("Sadece ses (MP3)", { sadeceSes: true }, false);
  }

  function hataGoster(h) {
    if (!panel) return;
    const metin = h === "sunucu-yok"
      ? "Yerel sunucu çalışmıyor — PKD klasöründeki baslat.command'ı çalıştır."
      : "Video çözümlenemedi. Girişli içerikse siteye giriş yaptığından emin ol.";
    panel.innerHTML = '<div class="vi-durum"></div>';
    panel.firstChild.textContent = metin;
    setTimeout(panelKapat, 6000);
  }

  async function indir(hedef, govde, baslik) {
    if (!panel) return;
    panel.innerHTML =
      '<div class="vi-tamam">⬇ İndirme başladı</div>' +
      '<div class="vi-durum" style="margin-top:4px">Bitince bildirim gelecek. ' +
      "Bu sayfayı kapatabilirsin.</div>";
    const y = await mesajGonder({
      tip: "indir", url: hedef, ref: document.referrer, baslik, ...govde,
    });
    if (y && y.hata) return hataGoster(y.hata);
    setTimeout(panelKapat, 3000);
  }

  document.addEventListener("click", (e) => {
    if (panel && !panel.contains(e.target)) panelKapat();
  }, true);
  addEventListener("scroll", () => { konumla(); panelKapat(); },
    { passive: true, capture: true });
  addEventListener("resize", konumla, { passive: true });

  // YouTube gibi SPA sitelerde sayfa yeniden yüklenmeden gezinilir;
  // yeni oynatıcı gelince hemen yeniden tara.
  window.addEventListener("yt-navigate-finish", () => setTimeout(tara, 300));
  window.addEventListener("popstate", () => setTimeout(tara, 300));

  zamanlayici = setInterval(tara, 1000);
  tara();
})();
