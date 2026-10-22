import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MoyasarWebViewPage extends StatefulWidget {
  final String paymentUrl;
  final String transactionId;
  final String bookingToken;

  const MoyasarWebViewPage({
    Key? key,
    required this.paymentUrl,
    required this.transactionId,
    required this.bookingToken,
  }) : super(key: key);

  @override
  State<MoyasarWebViewPage> createState() => _MoyasarWebViewPageState();
}

class _MoyasarWebViewPageState extends State<MoyasarWebViewPage> {
  late InAppWebViewController webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  void _checkUrlForCompletion(String url) {
    // Only detect callback URL - status must be verified via backend
    if (url.contains('/api/moyasar/callback') ||
        url.contains('/moyasar/callback') ||
        url.contains('payment/callback')) {
      // Return callback detected - handler must verify payment status via backend API
      Navigator.pop(context, 'callback_detected');
      return;
    }

    // Check for explicit cancellation
    if (url.contains('cancelled=true')) {
      Navigator.pop(context, 'cancelled');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Cancel Payment?'),
                content: const Text(
                  'Are you sure you want to cancel this payment?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context, 'cancelled'); // Close WebView
                    },
                    child: const Text('Yes, Cancel'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
            onWebViewCreated: (InAppWebViewController controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() => isLoading = true);
              if (url != null) {
                _checkUrlForCompletion(url.toString());
              }
            },
            onLoadStop: (controller, url) {
              setState(() => isLoading = false);
              if (url != null) {
                _checkUrlForCompletion(url.toString());
              }
            },
            onLoadError: (controller, url, code, message) {
              debugPrint('WebView error: $message');
            },
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
