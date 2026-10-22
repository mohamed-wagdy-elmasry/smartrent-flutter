# Static Pages Implementation Guide
## Privacy Policy, Contact Us, and About Us Pages for Flutter Projects

This guide provides a complete implementation pattern for adding Privacy Policy, Contact Us, and About Us pages to Flutter mobile applications. It includes two approaches: asset-based HTML files and URL-based WebView loading.

---

## 📋 Table of Contents
1. [Overview](#overview)
2. [Implementation Approaches](#implementation-approaches)
3. [Method 1: Asset-Based HTML](#method-1-asset-based-html)
4. [Method 2: URL-Based WebView](#method-2-url-based-webview)
5. [Localization Support](#localization-support)
6. [Navigation Integration](#navigation-integration)
7. [Complete Code Examples](#complete-code-examples)

---

## Overview

### Why These Pages Are Important
- **Privacy Policy**: Legal requirement for app stores and GDPR compliance
- **Contact Us**: Provides user support channels
- **About Us**: Introduces your company and services

### Key Features
- ✅ Multi-language support (English/Arabic RTL)
- ✅ Offline-capable with asset-based approach
- ✅ Dynamic content with URL-based approach
- ✅ SVG support for modern graphics
- ✅ Responsive design
- ✅ Clean, professional UI

---

## Implementation Approaches

### Comparison Table

| Feature | Asset-Based HTML | URL-Based WebView |
|---------|------------------|-------------------|
| **Offline Support** | ✅ Yes | ❌ No |
| **Easy Updates** | ❌ Requires app update | ✅ Update server only |
| **Load Speed** | ⚡ Instant | 🐌 Network dependent |
| **File Size** | 📦 Adds to app | 📦 No impact |
| **Best For** | Static content | Dynamic/frequently updated |

---

## Method 1: Asset-Based HTML

### Step 1: Add Required Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_html: ^3.0.0-beta.2  # For rendering HTML
  flutter_inappwebview: ^6.0.0  # For SVG support
  get: ^4.6.5  # For navigation (optional)
```

### Step 2: Create HTML Files

Create directory structure:
```
assets/
  html/
    privacy-policy-en.html
    privacy-policy-ar.html
    contact-us-en.html
    contact-us-ar.html
    about-us-en.html
    about-us-ar.html
```

**Register assets in `pubspec.yaml`:**
```yaml
flutter:
  assets:
    - assets/html/
```

### Step 3: HTML File Templates

#### Privacy Policy Template (`privacy-policy-en.html`)

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Privacy Policy</title>
<style>
  body { 
    font-family: Arial, sans-serif; 
    line-height: 1.6; 
    direction: ltr; 
    padding: 20px; 
    color: #333;
  }
  h1, h2, h3 { color: #333; margin-top: 20px; }
  h1 { font-size: 24px; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
  h2 { font-size: 20px; color: #007bff; }
  ul { margin: 10px 0 10px 20px; }
  li { margin-bottom: 5px; }
  p { margin-bottom: 10px; }
  strong { color: #000; }
</style>
</head>
<body>

<h1>Privacy Policy</h1>

<p>Last Updated: [Insert Date]</p>

<p>[Your App Name] is committed to protecting your personal data and privacy. This policy explains how we collect, use, and safeguard your information.</p>

<h2>1. Information We Collect</h2>
<ul>
  <li><strong>Account Data:</strong> Name, email address, phone number</li>
  <li><strong>Identity Data:</strong> ID verification documents (when required)</li>
  <li><strong>Usage Data:</strong> Pages viewed, features used, interaction patterns</li>
  <li><strong>Device Data:</strong> OS version, device type, IP address</li>
  <li><strong>Location Data:</strong> GPS location (with your permission)</li>
</ul>

<h2>2. How We Use Your Information</h2>
<ul>
  <li>To provide and maintain our services</li>
  <li>To process transactions and send notifications</li>
  <li>To improve user experience and app functionality</li>
  <li>To communicate important updates</li>
  <li>To comply with legal obligations</li>
</ul>

<h2>3. Data Sharing and Disclosure</h2>
<p>We do not sell your personal information. We may share data with:</p>
<ul>
  <li>Service providers (payment processors, cloud hosting)</li>
  <li>Legal authorities when required by law</li>
  <li>Business partners with your consent</li>
</ul>

<h2>4. Data Security</h2>
<p>We implement industry-standard security measures including encryption, secure servers, and regular security audits to protect your data.</p>

<h2>5. Your Rights</h2>
<ul>
  <li>Access your personal data</li>
  <li>Request data correction or deletion</li>
  <li>Opt-out of marketing communications</li>
  <li>Withdraw consent at any time</li>
</ul>

<h2>6. Cookies and Tracking</h2>
<p>We use cookies and similar technologies to enhance your experience, analyze usage patterns, and remember your preferences.</p>

<h2>7. Children's Privacy</h2>
<p>Our services are not intended for users under 18. We do not knowingly collect data from children.</p>

<h2>8. Changes to This Policy</h2>
<p>We may update this policy periodically. We will notify you of significant changes via email or app notification.</p>

<h2>9. Contact Us</h2>
<p>For privacy-related questions, contact us at:</p>
<ul>
  <li>Email: privacy@yourcompany.com</li>
  <li>Phone: +1-XXX-XXX-XXXX</li>
  <li>Address: [Your Company Address]</li>
</ul>

</body>
</html>
```

#### Contact Us Template (`contact-us-en.html`)

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Contact Us</title>

<style>
  body {
    font-family: "Inter", sans-serif;
    background: #f4f7ff;
    margin: 0;
    padding: 0;
  }
  .container {
     width: 90%;
     max-width: 900px;
     margin: 40px auto;
     background: white;
     border-radius: 22px;
     padding: 40px;
     box-shadow: 0 8px 35px rgba(0,0,0,0.06);
  }
  h1 { 
    text-align: center; 
    color: #333;
    margin-bottom: 10px;
  }
  p { 
    text-align: center; 
    margin-bottom: 35px; 
    color: #666;
  }
  .info-card {
    display: flex;
    align-items: center;
    gap: 18px;
    background: #f7f9ff;
    border-radius: 18px;
    padding: 18px;
    margin-bottom: 18px;
    border: 1px solid #e2e7ff;
    transition: transform 0.2s;
  }
  .info-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(51, 102, 255, 0.15);
  }
  .icon {
    width: 54px;
    height: 54px;
    min-width: 54px;
    background: #3366ff;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .icon svg {
    width: 28px;
    height: 28px;
    fill: white;
  }
  .info-content h3 {
    margin: 0 0 5px 0;
    color: #333;
    font-size: 16px;
  }
  .info-content p {
    margin: 0;
    text-align: left;
    color: #666;
  }
  a {
    color: #3366ff;
    text-decoration: none;
  }
  a:hover {
    text-decoration: underline;
  }
  footer {
    text-align: center;
    margin-top: 25px;
    color: #777;
    font-size: 14px;
  }
</style>
</head>

<body>
<div class="container">
  <h1>📞 Contact Us</h1>
  <p>We're here to help! Reach out to us through any of the channels below.</p>

  <!-- Phone -->
  <div class="info-card">
    <div class="icon">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M20.01 15.38c-1.23 0-2.42-.2-3.53-.56-.35-.12-.74-.03-1.01.24l-1.57 1.97c-2.83-1.35-5.48-3.9-6.89-6.83l1.95-1.66c.27-.28.35-.67.24-1.02-.37-1.11-.56-2.3-.56-3.53 0-.54-.45-.99-.99-.99H4.19C3.65 3 3 3.24 3 3.99 3 13.28 10.73 21 20.01 21c.71 0 .99-.63.99-1.18v-3.45c0-.54-.45-.99-.99-.99z"/>
      </svg>
    </div>
    <div class="info-content">
      <h3>Phone</h3>
      <p><a href="tel:+1234567890">+1 (234) 567-890</a></p>
    </div>
  </div>

  <!-- Email -->
  <div class="info-card">
    <div class="icon">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
      </svg>
    </div>
    <div class="info-content">
      <h3>Email</h3>
      <p><a href="mailto:support@yourcompany.com">support@yourcompany.com</a></p>
    </div>
  </div>

  <!-- WhatsApp -->
  <div class="info-card">
    <div class="icon">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M12.04 2c-5.46 0-9.91 4.45-9.91 9.91 0 1.75.46 3.45 1.32 4.95L2.05 22l5.25-1.38c1.45.79 3.08 1.21 4.74 1.21 5.46 0 9.91-4.45 9.91-9.91 0-2.65-1.03-5.14-2.9-7.01A9.816 9.816 0 0012.04 2m.01 1.67c2.2 0 4.26.86 5.82 2.42a8.225 8.225 0 012.41 5.83c0 4.54-3.7 8.23-8.24 8.23-1.48 0-2.93-.39-4.19-1.15l-.3-.17-3.12.82.83-3.04-.2-.32a8.188 8.188 0 01-1.26-4.38c.01-4.54 3.7-8.24 8.25-8.24M8.53 7.33c-.16 0-.43.06-.66.31-.22.25-.87.85-.87 2.07 0 1.22.89 2.39 1 2.56.14.17 1.76 2.67 4.25 3.73.59.27 1.05.42 1.41.53.59.19 1.13.16 1.56.1.48-.07 1.46-.6 1.67-1.18.21-.58.21-1.07.15-1.18-.07-.1-.23-.16-.48-.27-.25-.14-1.47-.74-1.69-.82-.23-.08-.37-.12-.56.12-.16.25-.64.81-.78.97-.15.17-.29.19-.53.07-.26-.13-1.06-.39-2-1.23-.74-.66-1.23-1.47-1.38-1.72-.12-.24-.01-.39.11-.5.11-.11.27-.29.37-.44.13-.14.17-.25.25-.41.08-.17.04-.31-.02-.43-.06-.11-.56-1.35-.76-1.84-.2-.48-.4-.42-.56-.43-.14 0-.3-.01-.47-.01z"/>
      </svg>
    </div>
    <div class="info-content">
      <h3>WhatsApp</h3>
      <p><a href="https://wa.me/1234567890">+1 (234) 567-890</a></p>
    </div>
  </div>

  <!-- Address -->
  <div class="info-card">
    <div class="icon">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/>
      </svg>
    </div>
    <div class="info-content">
      <h3>Address</h3>
      <p>123 Business St, Suite 456<br>City, State 12345</p>
    </div>
  </div>

  <!-- Working Hours -->
  <div class="info-card">
    <div class="icon">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
        <path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10 10-4.5 10-10S17.5 2 12 2zm4.2 14.2L11 13V7h1.5v5.2l4.5 2.7-.8 1.3z"/>
      </svg>
    </div>
    <div class="info-content">
      <h3>Working Hours</h3>
      <p>Monday - Friday: 9:00 AM - 6:00 PM<br>Saturday: 10:00 AM - 2:00 PM<br>Sunday: Closed</p>
    </div>
  </div>

  <footer>
    <p>We typically respond within 24 hours.</p>
  </footer>
</div>
</body>
</html>
```

#### About Us Template (`about-us-en.html`)

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>About Us</title>
  <style>
    body { 
      font-family: "Helvetica Neue", Arial, sans-serif; 
      direction: ltr; 
      text-align: left; 
      padding: 24px; 
      line-height: 1.6; 
      color: #222; 
      background:#fff; 
    }
    .container{
      max-width:900px;
      margin:0 auto;
    }
    header{
      border-bottom:2px solid #007bff;
      padding-bottom:12px;
      margin-bottom:18px;
    }
    h1{
      margin:0 0 6px;
      font-size:28px;
      color:#111;
    }
    p.lead{
      color:#444;
      margin-bottom:10px;
      font-size:16px;
    }
    .card{
      border:1px solid #eee;
      padding:20px;
      border-radius:8px;
      margin-bottom:16px;
      background:#fafafa;
    }
    .card h2 {
      color: #007bff;
      margin-top: 0;
      font-size: 20px;
    }
    ul{
      margin:8px 0 0 0;
      padding:0 16px;
    }
    li{
      margin-bottom:8px;
    }
    .footer{
      font-size:13px;
      color:#666;
      margin-top:18px;
      border-top:1px solid #eee;
      padding-top:12px;
      text-align: center;
    }
    .stats {
      display: flex;
      justify-content: space-around;
      margin: 20px 0;
      flex-wrap: wrap;
    }
    .stat-item {
      text-align: center;
      padding: 10px;
      min-width: 120px;
    }
    .stat-number {
      font-size: 32px;
      font-weight: bold;
      color: #007bff;
    }
    .stat-label {
      color: #666;
      font-size: 14px;
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>About [Your Company Name]</h1>
      <p class="lead">Building the future of [your industry] with innovation and excellence.</p>
    </header>

    <section class="card">
      <h2>🎯 Our Mission</h2>
      <p>Our mission is to [describe your mission]. We strive to deliver exceptional value to our customers through innovative solutions, outstanding service, and unwavering commitment to quality.</p>
    </section>

    <section class="card">
      <h2>🌟 Who We Are</h2>
      <p>Founded in [year], [Your Company Name] has grown from a small startup to a leading provider of [services/products]. We are a team of passionate professionals dedicated to [your core focus].</p>
    </section>

    <section class="card">
      <h2>💼 Our Services</h2>
      <ul>
        <li><strong>Service 1:</strong> Description of your first service</li>
        <li><strong>Service 2:</strong> Description of your second service</li>
        <li><strong>Service 3:</strong> Description of your third service</li>
        <li><strong>Service 4:</strong> Description of your fourth service</li>
        <li><strong>24/7 Support:</strong> Round-the-clock customer assistance</li>
      </ul>
    </section>

    <section class="card">
      <h2>📊 By The Numbers</h2>
      <div class="stats">
        <div class="stat-item">
          <div class="stat-number">10K+</div>
          <div class="stat-label">Happy Customers</div>
        </div>
        <div class="stat-item">
          <div class="stat-number">50+</div>
          <div class="stat-label">Team Members</div>
        </div>
        <div class="stat-item">
          <div class="stat-number">5+</div>
          <div class="stat-label">Years Experience</div>
        </div>
        <div class="stat-item">
          <div class="stat-number">99%</div>
          <div class="stat-label">Satisfaction Rate</div>
        </div>
      </div>
    </section>

    <section class="card">
      <h2>✨ Why Choose Us?</h2>
      <ul>
        <li>Industry-leading expertise and experience</li>
        <li>Customer-first approach in everything we do</li>
        <li>Innovative solutions tailored to your needs</li>
        <li>Transparent pricing with no hidden fees</li>
        <li>Proven track record of success</li>
        <li>Dedicated support team available 24/7</li>
      </ul>
    </section>

    <section class="card">
      <h2>🌍 Our Vision</h2>
      <p>We envision a future where [your vision statement]. Through continuous innovation and customer-centric solutions, we aim to set new standards in the industry and create lasting value for all stakeholders.</p>
    </section>

    <div class="footer">
      <p><strong>[Your Company Name]</strong> | Est. [Year]</p>
      <p>Committed to Excellence | Driven by Innovation</p>
    </div>
  </div>
</body>
</html>
```

### Step 4: Create HtmlScreen Widget

Create `lib/views/common/html_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

class HtmlScreen extends StatefulWidget {
  final String title;
  final String? asset;  // Path to asset file
  final String? url;    // URL to load from

  const HtmlScreen({
    Key? key,
    required this.title,
    this.asset,
    this.url,
  }) : super(key: key);

  @override
  State<HtmlScreen> createState() => _HtmlScreenState();
}

class _HtmlScreenState extends State<HtmlScreen> {
  String? _content;
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      if (widget.asset != null && widget.asset!.isNotEmpty) {
        // Load from asset
        _content = await rootBundle.loadString(widget.asset!);
      } else if (widget.url != null && widget.url!.isNotEmpty) {
        // Load from URL
        final res = await http.get(Uri.parse(widget.url!));
        if (res.statusCode == 200) {
          _content = res.body;
        }
      }
    } catch (_) {
      _content = null;
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: false,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, loading, _) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (_content == null || _content!.isEmpty) {
            return const Center(
              child: Text('No content available'),
            );
          }

          // If HTML contains SVG, use WebView for better rendering
          if (_content!.contains('<svg')) {
            return InAppWebView(
              initialData: InAppWebViewInitialData(data: _content!),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                ),
              ),
            );
          }

          // Otherwise use flutter_html for better performance
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Html(data: _content!),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _isLoading.dispose();
    super.dispose();
  }
}
```

### Step 5: Create Localization Strings

Add to `lib/languages/strings.dart`:

```dart
class Strings {
  static const String privacyPolicy = "appLPrivacyPolicy";
  static const String contactUs = "appLContactUs";
  static const String aboutUs = "appLAboutUs";
  static const String noContentAvailable = "appLNoContentAvailable";
}
```

Add to your localization files (e.g., `lib/l10n/app_en.arb`):

```json
{
  "appLPrivacyPolicy": "Privacy Policy",
  "appLContactUs": "Contact Us",
  "appLAboutUs": "About Us",
  "appLNoContentAvailable": "No content available"
}
```

### Step 6: Navigation Implementation

#### Option A: In Drawer Menu

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';  // Or use Navigator
import '../common/html_screen.dart';
import '../../languages/strings.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: Strings.privacyPolicy,
            onTap: () => _openPrivacyPolicy(),
          ),
          _buildMenuItem(
            icon: Icons.headphones,
            title: Strings.contactUs,
            onTap: () => _openContactUs(),
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: Strings.aboutUs,
            onTap: () => _openAboutUs(),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _openPrivacyPolicy() {
    final lang = Get.locale?.languageCode ?? 'en';  // Or use your i18n method
    final asset = lang.startsWith('en')
        ? 'assets/html/privacy-policy-en.html'
        : 'assets/html/privacy-policy-ar.html';
    
    Get.to(() => HtmlScreen(title: Strings.privacyPolicy, asset: asset));
  }

  void _openContactUs() {
    final lang = Get.locale?.languageCode ?? 'en';
    final asset = lang.startsWith('en')
        ? 'assets/html/contact-us-en.html'
        : 'assets/html/contact-us-ar.html';
    
    Get.to(() => HtmlScreen(title: Strings.contactUs, asset: asset));
  }

  void _openAboutUs() {
    final lang = Get.locale?.languageCode ?? 'en';
    final asset = lang.startsWith('en')
        ? 'assets/html/about-us-en.html'
        : 'assets/html/about-us-ar.html';
    
    Get.to(() => HtmlScreen(title: Strings.aboutUs, asset: asset));
  }
}
```

#### Option B: In Settings Screen

```dart
ListTile(
  leading: const Icon(Icons.privacy_tip_outlined),
  title: const Text('Privacy Policy'),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () {
    final lang = 'en';  // Get from your localization
    Get.to(() => HtmlScreen(
      title: 'Privacy Policy',
      asset: 'assets/html/privacy-policy-$lang.html',
    ));
  },
),
```

---

## Method 2: URL-Based WebView

### Step 1: Add Package

```yaml
dependencies:
  flutter_inappwebview: ^6.0.0
```

### Step 2: Create WebViewScreen Widget

Create `lib/views/common/webview_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const WebViewScreen({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late InAppWebViewController webViewController;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<double> progress = ValueNotifier<double>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              isLoading.value = true;
            },
            onLoadStop: (controller, url) {
              isLoading.value = false;
            },
            onProgressChanged: (controller, value) {
              progress.value = value / 100;
            },
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                useShouldOverrideUrlLoading: true,
              ),
            ),
          ),
          // Progress Indicator
          ValueListenableBuilder<double>(
            valueListenable: progress,
            builder: (context, value, _) {
              return value < 1.0
                  ? LinearProgressIndicator(value: value)
                  : const SizedBox.shrink();
            },
          ),
          // Loading Overlay
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, _) {
              return loading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    isLoading.dispose();
    progress.dispose();
    super.dispose();
  }
}
```

### Step 3: Define URLs in Configuration

Create `lib/config/app_urls.dart`:

```dart
class AppUrls {
  static const String baseUrl = 'https://yourcompany.com';
  
  // Static pages
  static const String privacyPolicyEn = '$baseUrl/privacy-policy?lang=en';
  static const String privacyPolicyAr = '$baseUrl/privacy-policy?lang=ar';
  static const String contactUsEn = '$baseUrl/contact-us?lang=en';
  static const String contactUsAr = '$baseUrl/contact-us?lang=ar';
  static const String aboutUsEn = '$baseUrl/about-us?lang=en';
  static const String aboutUsAr = '$baseUrl/about-us?lang=ar';
  
  // Helper method
  static String getPrivacyPolicyUrl(String language) {
    return language.startsWith('en') ? privacyPolicyEn : privacyPolicyAr;
  }
  
  static String getContactUsUrl(String language) {
    return language.startsWith('en') ? contactUsEn : contactUsAr;
  }
  
  static String getAboutUsUrl(String language) {
    return language.startsWith('en') ? aboutUsEn : aboutUsAr;
  }
}
```

### Step 4: Navigation Example

```dart
import 'package:get/get.dart';
import '../common/webview_screen.dart';
import '../../config/app_urls.dart';

void openPrivacyPolicy() {
  final lang = Get.locale?.languageCode ?? 'en';
  final url = AppUrls.getPrivacyPolicyUrl(lang);
  
  Get.to(() => WebViewScreen(
    title: 'Privacy Policy',
    url: url,
  ));
}
```

---

## Localization Support

### Complete Multi-Language Implementation

```dart
class LanguageHelper {
  /// Get current app language
  static String getCurrentLanguage() {
    // Using GetX
    return Get.locale?.languageCode ?? 'en';
    
    // OR using flutter_localizations
    // return Localizations.localeOf(context).languageCode;
  }
  
  /// Get HTML asset path based on page type and language
  static String getHtmlAsset(PageType type, [String? language]) {
    final lang = language ?? getCurrentLanguage();
    final suffix = lang.startsWith('en') ? 'en' : 'ar';
    
    switch (type) {
      case PageType.privacyPolicy:
        return 'assets/html/privacy-policy-$suffix.html';
      case PageType.contactUs:
        return 'assets/html/contact-us-$suffix.html';
      case PageType.aboutUs:
        return 'assets/html/about-us-$suffix.html';
      default:
        return 'assets/html/privacy-policy-$suffix.html';
    }
  }
  
  /// Get URL based on page type and language
  static String getPageUrl(PageType type, [String? language]) {
    final lang = language ?? getCurrentLanguage();
    
    switch (type) {
      case PageType.privacyPolicy:
        return AppUrls.getPrivacyPolicyUrl(lang);
      case PageType.contactUs:
        return AppUrls.getContactUsUrl(lang);
      case PageType.aboutUs:
        return AppUrls.getAboutUsUrl(lang);
      default:
        return AppUrls.getPrivacyPolicyUrl(lang);
    }
  }
}

enum PageType {
  privacyPolicy,
  contactUs,
  aboutUs,
}
```

### Arabic RTL Support Template

```html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>سياسة الخصوصية</title>
<style>
  body { 
    font-family: 'Cairo', 'Tajawal', sans-serif; 
    line-height: 1.8; 
    direction: rtl; 
    text-align: right;
    padding: 20px; 
    color: #333;
  }
  h1, h2, h3 { color: #333; margin-top: 20px; }
  h1 { font-size: 24px; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
  h2 { font-size: 20px; color: #007bff; }
  ul { margin: 10px 20px 10px 0; }
  li { margin-bottom: 5px; }
  p { margin-bottom: 10px; }
</style>
</head>
<body>

<h1>سياسة الخصوصية</h1>

<p>آخر تحديث: [أدخل التاريخ]</p>

<p>نحن ملتزمون بحماية بياناتك الشخصية وخصوصيتك...</p>

<!-- Add Arabic content here -->

</body>
</html>
```

---

## Navigation Integration

### Complete Drawer Example with All Pages

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
              ),
            ),
            accountName: const Text('User Name'),
            accountEmail: const Text('user@example.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
          ),
          
          // Main menu items
          _buildMenuItem(
            icon: Icons.home,
            title: 'Home',
            onTap: () => Get.back(),
          ),
          _buildMenuItem(
            icon: Icons.history,
            title: 'History',
            onTap: () => Get.toNamed('/history'),
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => Get.toNamed('/settings'),
          ),
          
          const Divider(),
          
          // Static pages section
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
            child: Text(
              'Information',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _openPrivacyPolicy(),
          ),
          _buildMenuItem(
            icon: Icons.headphones,
            title: 'Contact Us',
            onTap: () => _openContactUs(),
          ),
          _buildMenuItem(
            icon: Icons.info_outline,
            title: 'About Us',
            onTap: () => _openAboutUs(),
          ),
          
          const Divider(),
          
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () => _handleLogout(context),
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  void _openPrivacyPolicy() {
    final lang = LanguageHelper.getCurrentLanguage();
    final asset = LanguageHelper.getHtmlAsset(PageType.privacyPolicy, lang);
    Get.to(() => HtmlScreen(title: 'Privacy Policy', asset: asset));
  }

  void _openContactUs() {
    final lang = LanguageHelper.getCurrentLanguage();
    final asset = LanguageHelper.getHtmlAsset(PageType.contactUs, lang);
    Get.to(() => HtmlScreen(title: 'Contact Us', asset: asset));
  }

  void _openAboutUs() {
    final lang = LanguageHelper.getCurrentLanguage();
    final asset = LanguageHelper.getHtmlAsset(PageType.aboutUs, lang);
    Get.to(() => HtmlScreen(title: 'About Us', asset: asset));
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Perform logout
              Navigator.pop(context);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
```

---

## Complete Code Examples

### Full Project Structure

```
lib/
├── config/
│   └── app_urls.dart
├── languages/
│   └── strings.dart
├── helpers/
│   └── language_helper.dart
├── views/
│   ├── common/
│   │   ├── html_screen.dart
│   │   └── webview_screen.dart
│   └── drawer/
│       └── app_drawer.dart
└── main.dart

assets/
└── html/
    ├── privacy-policy-en.html
    ├── privacy-policy-ar.html
    ├── contact-us-en.html
    ├── contact-us-ar.html
    ├── about-us-en.html
    └── about-us-ar.html
```

### Complete pubspec.yaml

```yaml
name: your_app_name
description: A Flutter application with static pages

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management & Navigation
  get: ^4.6.5
  
  # HTML Rendering
  flutter_html: ^3.0.0-beta.2
  flutter_inappwebview: ^6.0.0
  
  # Network
  http: ^1.1.0
  
  # UI
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/html/
```

### main.dart Setup

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        child: Text('Welcome to Your App'),
      ),
    );
  }
}
```

---

## Best Practices

### 1. Security Considerations

```dart
// Restrict navigation in WebView
initialOptions: InAppWebViewGroupOptions(
  crossPlatform: InAppWebViewOptions(
    javaScriptEnabled: true,
    useShouldOverrideUrlLoading: true,  // Control navigation
    allowFileAccessFromFileURLs: false,  // Security
    allowUniversalAccessFromFileURLs: false,  // Security
  ),
),

// Handle URL navigation
shouldOverrideUrlLoading: (controller, navigationAction) async {
  final uri = navigationAction.request.url;
  
  // Only allow specific domains
  if (uri != null && !uri.toString().startsWith('https://yourcompany.com')) {
    // Open in external browser or block
    return NavigationActionPolicy.CANCEL;
  }
  
  return NavigationActionPolicy.ALLOW;
},
```

### 2. Error Handling

```dart
Future<void> _loadContent() async {
  try {
    if (widget.asset != null && widget.asset!.isNotEmpty) {
      _content = await rootBundle.loadString(widget.asset!);
    } else if (widget.url != null && widget.url!.isNotEmpty) {
      final res = await http.get(
        Uri.parse(widget.url!),
      ).timeout(const Duration(seconds: 30));
      
      if (res.statusCode == 200) {
        _content = res.body;
      } else {
        _content = '<h1>Error</h1><p>Failed to load content (${res.statusCode})</p>';
      }
    }
  } on TimeoutException {
    _content = '<h1>Timeout</h1><p>Connection timeout. Please try again.</p>';
  } catch (e) {
    _content = '<h1>Error</h1><p>An error occurred: ${e.toString()}</p>';
  } finally {
    _isLoading.value = false;
  }
}
```

### 3. Performance Optimization

```dart
// Use const constructors
const HtmlScreen(title: 'Privacy Policy', asset: 'path');

// Cache HTML content
class HtmlCache {
  static final Map<String, String> _cache = {};
  
  static Future<String?> get(String key) async {
    return _cache[key];
  }
  
  static void set(String key, String value) {
    _cache[key] = value;
  }
  
  static void clear() {
    _cache.clear();
  }
}

// Use in HtmlScreen
Future<void> _loadContent() async {
  // Check cache first
  final cached = await HtmlCache.get(widget.asset ?? widget.url ?? '');
  if (cached != null) {
    _content = cached;
    _isLoading.value = false;
    return;
  }
  
  // Load and cache
  // ... existing load code ...
  if (_content != null) {
    HtmlCache.set(widget.asset ?? widget.url ?? '', _content!);
  }
}
```

### 4. Testing

```dart
// test/html_screen_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HtmlScreen displays content', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HtmlScreen(
          title: 'Test',
          asset: 'assets/html/test.html',
        ),
      ),
    );
    
    await tester.pump();
    
    expect(find.text('Test'), findsOneWidget);
  });
}
```

---

## Checklist for Implementation

- [ ] Add required dependencies to `pubspec.yaml`
- [ ] Create `assets/html/` directory
- [ ] Create HTML files for all languages (en, ar, etc.)
- [ ] Register assets in `pubspec.yaml`
- [ ] Create `HtmlScreen` widget
- [ ] (Optional) Create `WebViewScreen` widget
- [ ] Add localization strings
- [ ] Implement navigation in drawer/settings
- [ ] Test on both iOS and Android
- [ ] Test RTL support for Arabic
- [ ] Verify offline functionality (asset-based)
- [ ] Check loading states and error handling
- [ ] Review privacy policy content with legal team
- [ ] Update contact information in Contact Us page
- [ ] Verify all links work correctly
- [ ] Test on different screen sizes

---

## Troubleshooting

### Common Issues

**Issue**: HTML not loading
- **Solution**: Ensure assets are registered in `pubspec.yaml` and run `flutter clean && flutter pub get`

**Issue**: SVG not rendering
- **Solution**: Use `InAppWebView` instead of `flutter_html` for SVG content

**Issue**: RTL not working
- **Solution**: Set `dir="rtl"` in HTML `<html>` tag and use appropriate fonts

**Issue**: WebView shows blank page
- **Solution**: Enable JavaScript and check console errors

**Issue**: App size too large
- **Solution**: Consider using URL-based approach instead of bundling HTML

---

## Conclusion

This guide provides two robust methods for implementing static pages in Flutter:

1. **Asset-Based**: Best for static, rarely-changing content that should work offline
2. **URL-Based**: Best for dynamic content that updates frequently

Choose the method that best fits your requirements, or use a hybrid approach where some pages are assets and others are loaded from URLs.

---

## Additional Resources

- [Flutter HTML Package](https://pub.dev/packages/flutter_html)
- [Flutter InAppWebView](https://pub.dev/packages/flutter_inappwebview)
- [GDPR Compliance Guide](https://gdpr.eu/)
- [App Store Privacy Policy Requirements](https://developer.apple.com/app-store/review/guidelines/#privacy)
- [Google Play Privacy Policy Requirements](https://support.google.com/googleplay/android-developer/answer/9859455)

---

**Created**: February 2026  
**Version**: 1.0  
**License**: Free to use and modify for your projects
