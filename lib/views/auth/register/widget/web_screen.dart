import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../base/api/services/basic_services.dart';
import '../../../../base/utils/basic_import.dart';

class WebViewScreen extends StatefulWidget {
  final String title;

  WebViewScreen({super.key, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late InAppWebViewController webViewController;

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(widget.title, centerTitle: false),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    String getUrl(title) {
      var url = '';
      switch (title) {
        case Strings.privacyPolicy:
          url = BasicServices.privacyPolicy.value;
          break;
        case Strings.aboutUs:
          url = BasicServices.aboutUs.value;
        case Strings.helpCenter:
          url = BasicServices.contactUs.value;
      }
      print(url);
      return url;
    }

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(getUrl(widget.title))),
          onWebViewCreated: (controller) {
            webViewController = controller;
            controller.addJavaScriptHandler(
              handlerName: 'jsHandler',
              callback: (args) {},
            );
          },
          onLoadStart: (controller, url) {
            isLoading.value = true;
          },
          onLoadStop: (controller, url) {
            isLoading.value = false;
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (context, isLoading, _) {
            return isLoading
                ? Center(child: Loader())
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
