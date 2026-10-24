import os
import sys
import base64
import subprocess
from PIL import Image

WORKSPACE_DIR = r"d:\upApp\smartrent-flutter-main"
USER_UPLOADED_DIR = r"C:\Users\DELL 3561 G11\.gemini\antigravity-ide\brain\5164a424-573c-4b35-9c39-08255a74f98a\.user_uploaded"
CHROME_PATH = r"C:\Program Files\Google\Chrome\Application\chrome.exe"

# Screen definitions
SCREENS_CONFIG = [
    {
        "id": "01_home_fleet",
        "raw_file": "media_1792796674242.png",
        "badge": "🚗 أسطول سيارات حديث ومتنوع",
        "title_main": "استأجر سيارتك المثالية",
        "title_highlight": "بأفضل الأسعار",
        "subtitle": "تصفح مئات السيارات الحديثة واحجز في ثوانٍ مع خيارات تسليم مرنة",
        "status_theme": "dark", # dark means white text on dark background
        "status_bg": "rgba(10, 59, 103, 0.98)",
        "screen_bg": "#0A3C6E",
        "ambient_color": "rgba(56, 189, 248, 0.28)"
    },
    {
        "id": "02_booking_details",
        "raw_file": "media_1792796673757.png",
        "badge": "⏱️ حجز مرن وسريع",
        "title_main": "حدد مواعيدك وخطتك",
        "title_highlight": "بمنتهى السهولة",
        "subtitle": "اختر عدد الأيام، تاريخ ووقت الاستلام، وباقة التأمين بضغطة زر",
        "status_theme": "dark",
        "status_bg": "rgba(11, 88, 155, 0.98)",
        "screen_bg": "#0B589B",
        "ambient_color": "rgba(96, 165, 250, 0.28)"
    },
    {
        "id": "03_filters_and_sorting",
        "raw_file": "media_1792796674014.png",
        "badge": "🔍 فلاتر وبحث متقدم",
        "title_main": "تصفية ذكية تناسب",
        "title_highlight": "كافة احتياجاتك",
        "subtitle": "فرز فوري حسب السعر، الشعبية، توصيل السيارة، وتوفرها الفوري",
        "status_theme": "dark",
        "status_bg": "rgba(5, 34, 60, 0.98)",
        "screen_bg": "#05223C",
        "ambient_color": "rgba(129, 140, 248, 0.28)"
    },
    {
        "id": "04_digital_wallet",
        "raw_file": "media_1792796674059.png",
        "badge": "💳 محفظة رقمية آمنة",
        "title_main": "إدارة رصيدك ومدفوعاتك",
        "title_highlight": "بكل أمان وموثوقية",
        "subtitle": "شحن فوري للرصيد، مدفوعات إلكترونية سريعة، ومتابعة سجل العمليات",
        "status_theme": "dark",
        "status_bg": "rgba(18, 99, 168, 0.98)",
        "screen_bg": "#1263A8",
        "ambient_color": "rgba(52, 211, 153, 0.25)"
    },
    {
        "id": "05_support_and_contact",
        "raw_file": "media_1792796673912.png",
        "badge": "🤝 دعم وخدمة متواصلة",
        "title_main": "فريق الدعم في خدمتك",
        "title_highlight": "على مدار الساعة",
        "subtitle": "تواصل معنا مباشرة عبر الهاتف والبريد، وفريقنا دائماً جاهز لمساعدتك",
        "status_theme": "light", # light means dark text on light background
        "status_bg": "rgba(238, 238, 238, 0.98)",
        "screen_bg": "#EEEEEE",
        "ambient_color": "rgba(56, 189, 248, 0.25)"
    }
]

def crop_and_prepare_app_screen(raw_path, temp_out_path):
    """
    Crops Android status bar (top ~48px) and Android nav bar (bottom ~29px)
    from (472, 1024) image.
    """
    im = Image.open(raw_path)
    # The clean Flutter app content is from y=48 to y=995
    cropped = im.crop((0, 48, 472, 995))
    cropped.save(temp_out_path, format="PNG")
    with open(temp_out_path, "rb") as f:
        return base64.b64encode(f.read()).decode("utf-8")

def generate_html(config, img_b64, width=1206, height=2622):
    # Proportions based on target resolution
    scale = width / 1206.0
    
    status_text_color = "#FFFFFF" if config["status_theme"] == "dark" else "#0F172A"
    status_icon_color = "#FFFFFF" if config["status_theme"] == "dark" else "#0F172A"
    
    html = f"""<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Alexandria:wght@400;500;600;700;800;900&family=Cairo:wght@600;700;800;900&display=swap" rel="stylesheet">
<style>
  * {{
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }}
  body {{
    width: {width}px;
    height: {height}px;
    overflow: hidden;
    background: radial-gradient(circle at 50% 12%, #0E447E 0%, #082548 42%, #020F21 100%);
    font-family: 'Alexandria', 'Cairo', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    color: #FFFFFF;
    position: relative;
    display: flex;
    flex-direction: column;
    align-items: center;
  }}
  /* Ambient decorative glows */
  .glow-top {{
    position: absolute;
    top: -180px;
    left: 50%;
    transform: translateX(-50%);
    width: 950px;
    height: 700px;
    background: radial-gradient(circle, {config['ambient_color']} 0%, rgba(14, 165, 233, 0) 70%);
    filter: blur(90px);
    pointer-events: none;
  }}
  .glow-mid {{
    position: absolute;
    top: 700px;
    left: 50%;
    transform: translateX(-50%);
    width: 1100px;
    height: 1200px;
    background: radial-gradient(circle, rgba(14, 116, 222, 0.22) 0%, rgba(3, 18, 41, 0) 70%);
    filter: blur(100px);
    pointer-events: none;
  }}
  .grid-pattern {{
    position: absolute;
    inset: 0;
    background-image: linear-gradient(rgba(255, 255, 255, 0.025) 1px, transparent 1px),
                      linear-gradient(90deg, rgba(255, 255, 255, 0.025) 1px, transparent 1px);
    background-size: 55px 55px;
    mask-image: linear-gradient(to bottom, black 35%, transparent 85%);
    pointer-events: none;
  }}

  /* Header Marketing Copy */
  .header-container {{
    position: relative;
    z-index: 10;
    width: 100%;
    padding: 130px 70px 0;
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
  }}
  .tag-badge {{
    display: inline-flex;
    align-items: center;
    gap: 12px;
    padding: 12px 32px;
    border-radius: 999px;
    background: rgba(255, 255, 255, 0.08);
    backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.18);
    box-shadow: 0 8px 30px rgba(0, 0, 0, 0.25);
    font-size: 26px;
    font-weight: 600;
    color: #7DD3FC;
    letter-spacing: 0.3px;
    margin-bottom: 28px;
  }}
  .main-title {{
    font-size: 64px;
    font-weight: 800;
    line-height: 1.25;
    color: #FFFFFF;
    text-shadow: 0 4px 25px rgba(0, 0, 0, 0.5);
    margin-bottom: 20px;
    max-width: 1080px;
  }}
  .main-title span {{
    background: linear-gradient(135deg, #38BDF8 0%, #60A5FA 60%, #93C5FD 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }}
  .sub-title {{
    font-size: 31px;
    font-weight: 400;
    color: #CBD5E1;
    line-height: 1.48;
    max-width: 950px;
    margin-bottom: 50px;
  }}

  /* Phone Mockup Frame (iPhone 16 Pro) */
  .phone-wrapper {{
    position: relative;
    z-index: 10;
    width: 960px;
    height: 1880px;
    border-radius: 84px;
    background: linear-gradient(145deg, #94A3B8, #334155 25%, #0F172A 70%, #64748B);
    padding: 13px;
    box-shadow: 0 50px 120px rgba(0, 0, 0, 0.8), 0 20px 40px rgba(0, 0, 0, 0.6);
  }}
  .phone-inner {{
    position: relative;
    width: 100%;
    height: 100%;
    border-radius: 72px;
    background: {config['screen_bg']};
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }}

  /* Native iOS Status Bar */
  .ios-status-bar {{
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 75px;
    padding: 0 44px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    z-index: 50;
    background: {config['status_bg']};
    backdrop-filter: blur(12px);
    font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
  }}
  .status-time {{
    font-size: 27px;
    font-weight: 700;
    letter-spacing: -0.4px;
    color: {status_text_color};
    padding-left: 6px;
  }}
  .dynamic-island {{
    position: absolute;
    left: 50%;
    top: 13px;
    transform: translateX(-50%);
    width: 215px;
    height: 48px;
    background: #000000;
    border-radius: 24px;
    display: flex;
    align-items: center;
    justify-content: flex-end;
    padding-right: 16px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.4);
  }}
  .camera-lens {{
    width: 16px;
    height: 16px;
    border-radius: 50%;
    background: radial-gradient(circle, #173252 35%, #030810 100%);
    border: 1px solid #1E293B;
  }}
  .status-icons {{
    display: flex;
    align-items: center;
    gap: 10px;
    color: {status_icon_color};
    padding-right: 6px;
  }}
  .cellular {{
    display: flex;
    align-items: flex-end;
    gap: 3px;
    height: 19px;
  }}
  .bar {{
    width: 4px;
    background: {status_icon_color};
    border-radius: 1px;
  }}
  .battery {{
    width: 33px;
    height: 17px;
    border: 2px solid {status_icon_color};
    border-radius: 5px;
    padding: 2px;
    display: flex;
    align-items: center;
    position: relative;
    margin-right: 2px;
  }}
  .battery::after {{
    content: '';
    position: absolute;
    right: -5px;
    top: 3.5px;
    width: 3px;
    height: 6px;
    background: {status_icon_color};
    border-radius: 0 2px 2px 0;
  }}
  .battery-level {{
    height: 100%;
    width: 82%;
    background: {status_icon_color};
    border-radius: 2px;
  }}

  /* App Screen Cropped Image */
  .app-screen-img {{
    width: 100%;
    height: 100%;
    object-fit: cover;
    object-position: top center;
    display: block;
    padding-top: 52px;
  }}

  /* iOS Home Indicator */
  .home-indicator {{
    position: absolute;
    bottom: 14px;
    left: 50%;
    transform: translateX(-50%);
    width: 250px;
    height: 7px;
    background: {"rgba(255, 255, 255, 0.7)" if config["status_theme"] == "dark" else "rgba(0, 0, 0, 0.6)"};
    border-radius: 100px;
    z-index: 60;
  }}
</style>
</head>
<body>
  <div class="glow-top"></div>
  <div class="glow-mid"></div>
  <div class="grid-pattern"></div>

  <div class="header-container">
    <div class="tag-badge">{config['badge']}</div>
    <h1 class="main-title">{config['title_main']} <span>{config['title_highlight']}</span></h1>
    <p class="sub-title">{config['subtitle']}</p>
  </div>

  <div class="phone-wrapper">
    <div class="phone-inner">
      <div class="ios-status-bar">
        <div class="status-time">9:41</div>
        <div class="dynamic-island">
          <div class="camera-lens"></div>
        </div>
        <div class="status-icons">
          <div class="cellular">
            <div class="bar" style="height: 6px;"></div>
            <div class="bar" style="height: 10px;"></div>
            <div class="bar" style="height: 14px;"></div>
            <div class="bar" style="height: 18px;"></div>
          </div>
          <span style="font-size: 19px; font-weight: 700; margin-left: 2px;">5G</span>
          <div class="battery">
            <div class="battery-level"></div>
          </div>
        </div>
      </div>

      <img class="app-screen-img" src="data:image/png;base64,{img_b64}" alt="App Screen" />

      <div class="home-indicator"></div>
    </div>
  </div>
</body>
</html>"""
    return html

def main():
    print("=== Starting App Store Screenshots Generation ===")
    
    # 1. Output directories
    dir_6_3 = os.path.join(WORKSPACE_DIR, "app_store_screenshots", "iphone_6.3_inch_1206x2622")
    dir_6_1 = os.path.join(WORKSPACE_DIR, "app_store_screenshots", "iphone_6.1_inch_1179x2556")
    temp_dir = os.path.join(WORKSPACE_DIR, "app_store_screenshots", ".temp")
    
    os.makedirs(dir_6_3, exist_ok=True)
    os.makedirs(dir_6_1, exist_ok=True)
    os.makedirs(temp_dir, exist_ok=True)
    
    for idx, cfg in enumerate(SCREENS_CONFIG, start=1):
        raw_path = os.path.join(USER_UPLOADED_DIR, cfg["raw_file"])
        temp_crop_path = os.path.join(temp_dir, f"crop_{cfg['id']}.png")
        
        print(f"\nProcessing [{idx}/{len(SCREENS_CONFIG)}]: {cfg['id']} ({cfg['raw_file']})")
        img_b64 = crop_and_prepare_app_screen(raw_path, temp_crop_path)
        
        # A. Generate 1206x2622 (6.3" display)
        html_content_63 = generate_html(cfg, img_b64, width=1206, height=2622)
        html_file_63 = os.path.join(temp_dir, f"render_{cfg['id']}_1206x2622.html")
        with open(html_file_63, "w", encoding="utf-8") as f:
            f.write(html_content_63)
            
        out_png_63 = os.path.join(dir_6_3, f"{cfg['id']}.png")
        cmd_63 = [
            CHROME_PATH,
            "--headless=new",
            "--disable-gpu",
            "--run-all-compositor-stages-before-draw",
            f"--screenshot={out_png_63}",
            "--window-size=1206,2622",
            f"file:///{html_file_63}"
        ]
        res = subprocess.run(cmd_63, capture_output=True, text=True)
        if os.path.exists(out_png_63):
            size_63 = Image.open(out_png_63).size
            print(f"  -> Generated 6.3\" screenshot: {out_png_63} -> Size: {size_63}")
        else:
            print(f"  -> ERROR generating 6.3\" screenshot! Stderr: {res.stderr}")

        # B. Generate 1179x2556 (6.1" display) by scaling or direct render
        # High quality bicubic resize from 1206x2622 or direct render:
        # Direct resize of the 1206x2622 ensures identical pixel layout perfectly fitted
        out_png_61 = os.path.join(dir_6_1, f"{cfg['id']}.png")
        im_63 = Image.open(out_png_63)
        im_61 = im_63.resize((1179, 2556), Image.Resampling.LANCZOS)
        im_61.save(out_png_61, format="PNG", quality=98)
        print(f"  -> Generated 6.1\" screenshot: {out_png_61} -> Size: {im_61.size}")

    print("\n=== All App Store screenshots generated successfully! ===")

if __name__ == "__main__":
    main()
