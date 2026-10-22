import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
 
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../base/utils/basic_import.dart';

class HtmlScreen extends StatefulWidget {
  final String title;
  final String? asset;
  final String? url;

  const HtmlScreen({Key? key, required this.title, this.asset, this.url}) : super(key: key);

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
        _content = await rootBundle.loadString(widget.asset!);
      } else if (widget.url != null && widget.url!.isNotEmpty) {
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
      appBar: CustomAppBar(widget.title, centerTitle: false),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, loading, _) {
          if (loading) return Center(child: Loader());
          if (_content == null || _content!.isEmpty) {
            return Center(child: TextWidget(Strings.noContentAvailable));
          }
          // If HTML contains inline <svg> tags, the flutter_html widget
          // does not reliably render them across versions. Fall back to
          // a WebView loaded from a data URI which renders SVG correctly.
          if (_content!.contains('<svg')) {
            return InAppWebView(
              initialData: InAppWebViewInitialData(data: _content!),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
              ),
            );
          }

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
}
