import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:carbo/base/themes/token.dart';

class PaymentWebView extends StatefulWidget {
  final String url;
  final String title;

  const PaymentWebView({
    super.key,
    required this.url,
    this.title = 'Payment',
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  double progress = 0;
  bool isLoading = true;
  bool _hasClosedWithResult = false;

  @override
  void initState() {
    super.initState();
    print('=== PaymentWebView INITIALIZED ===');
    print('Initial URL: ${widget.url}');
    print('Title: ${widget.title}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: CustomColor.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white, size: 24.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 24.sp),
            onPressed: () => webViewController?.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              javaScriptEnabled: true,
              domStorageEnabled: true,
              supportZoom: false,
              clearCache: false,
              javaScriptCanOpenWindowsAutomatically: true,
              useOnDownloadStart: true,
              useOnLoadResource: true,
            ),
            onWebViewCreated: (controller) {
              print('=== WebView CREATED ===');
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              print('=== LOAD START ===');
              print('URL: $url');
              setState(() {
                isLoading = true;
              });
            },
            onLoadStop: (controller, url) async {
              print('=== LOAD STOP ===');
              print('Final URL: $url');
              setState(() {
                isLoading = false;
              });
              
              // Get page title
              final title = await controller.getTitle();
              print('Page Title: $title');
              
              // Check for payment success and auto-close after 5 seconds
              if (url != null && !_hasClosedWithResult) {
                final urlString = url.toString().toLowerCase();
                final pageTitle = title?.toLowerCase() ?? '';
                
                print('Checking URL for payment status: $urlString');
                print('Page title (lowercase): $pageTitle');
                
                // Only detect success on the backend callback URL with all success parameters
                final isCallbackUrl = urlString.contains('/invoices/callback');
                final hasStatusPaid = urlString.contains('status=paid');
                final hasSuccess1 = urlString.contains('success=1');
                final titleHasSuccess = pageTitle.contains('payment successful');
                
                print('Detection results:');
                print('  - isCallbackUrl: $isCallbackUrl');
                print('  - hasStatusPaid: $hasStatusPaid');
                print('  - hasSuccess1: $hasSuccess1');
                print('  - titleHasSuccess: $titleHasSuccess');
                
                // Only trigger on the final backend callback page with all success indicators
                if (isCallbackUrl && hasStatusPaid && hasSuccess1 && titleHasSuccess) {
                  print('✅ Payment SUCCESS detected on callback page!');
                  print('Showing success page for 5 seconds before closing...');
                  _hasClosedWithResult = true;
                  
                  await Future.delayed(const Duration(seconds: 5));
                  
                  if (mounted) {
                    print('🔚 Closing WebView with success result');
                    Navigator.of(context).pop('success');
                  }
                }
              }
            },
            onProgressChanged: (controller, progress) {
              print('Progress: $progress%');
              setState(() {
                this.progress = progress / 100;
              });
            },
            onLoadResource: (controller, resource) {
              print('Loading Resource: ${resource.url}');
            },
            onConsoleMessage: (controller, consoleMessage) {
              print('=== CONSOLE [${consoleMessage.messageLevel}] ===');
              print('Message: ${consoleMessage.message}');
            },
            onReceivedError: (controller, request, error) {
              print('=== RECEIVED ERROR ===');
              print('Error Type: ${error.type}');
              print('Error Description: ${error.description}');
              print('Error URL: ${request.url}');
              Get.snackbar(
                'Error',
                'Failed to load payment page: ${error.description}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade900,
              );
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              print('=== HTTP ERROR ===');
              print('Status Code: ${errorResponse.statusCode}');
              print('URL: ${request.url}');
              print('Reason: ${errorResponse.reasonPhrase}');
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url;
              print('=== SHOULD OVERRIDE URL ===');
              print('Navigation Type: ${navigationAction.navigationType}');
              print('URL: $url');
              print('Is Main Frame: ${navigationAction.isForMainFrame}');
              
              if (url != null) {
                final urlString = url.toString().toLowerCase();
                print('Lowercase URL: $urlString');
                
                // Log all URL patterns for debugging
                print('Checking for patterns:');
                print('  - Contains "success": ${urlString.contains('success')}');
                print('  - Contains "paid": ${urlString.contains('paid')}');
                print('  - Contains "status=paid": ${urlString.contains('status=paid')}');
                print('  - Contains "callback": ${urlString.contains('callback')}');
                print('  - Contains "webhook": ${urlString.contains('webhook')}');
                print('  - Contains "complete": ${urlString.contains('complete')}');
              }
              
              print('Allowing navigation to continue');
              return NavigationActionPolicy.ALLOW;
            },
            onDownloadStartRequest: (controller, downloadStartRequest) {
              print('=== DOWNLOAD START ===');
              print('URL: ${downloadStartRequest.url}');
              print('Filename: ${downloadStartRequest.suggestedFilename}');
            },
            onUpdateVisitedHistory: (controller, url, androidIsReload) {
              print('=== VISITED HISTORY UPDATE ===');
              print('URL: $url');
              print('Is Reload: $androidIsReload');
            },
          ),
          if (isLoading || progress < 1.0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(CustomColor.primary),
              ),
            ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: CustomColor.primary,
              ),
            ),
        ],
      ),
    );
  }
}
