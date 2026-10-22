import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Configure global HTTP client settings for better image loading
void configureHttpClient() {
  HttpOverrides.global = _CustomHttpOverrides();
}

class _CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(seconds: 60)
      ..idleTimeout = const Duration(seconds: 60);
  }
}

/// Widget for loading images with retry logic
class RetryableNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;
  final Widget Function(BuildContext) loadingBuilder;
  final Widget Function(BuildContext) errorBuilder;
  final int maxRetries;

  const RetryableNetworkImage({
    required this.imageUrl,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
    required this.loadingBuilder,
    required this.errorBuilder,
    this.maxRetries = 3,
  });

  @override
  State<RetryableNetworkImage> createState() => _RetryableNetworkImageState();
}

class _RetryableNetworkImageState extends State<RetryableNetworkImage> {
  late int _retryCount;
  late Key _key;

  @override
  void initState() {
    super.initState();
    _retryCount = 0;
    _key = UniqueKey();
  }

  void _retry() {
    if (_retryCount < widget.maxRetries) {
      _retryCount++;
      setState(() {
        _key = UniqueKey();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      key: _key,
      imageUrl: widget.imageUrl,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      placeholder: (context, url) => widget.loadingBuilder(context),
      errorWidget: (context, url, error) {
        debugPrint('Image load error (attempt ${_retryCount + 1}/${widget.maxRetries + 1}): $error');
        
        // Auto-retry if retries remain
        if (_retryCount < widget.maxRetries) {
          Future.delayed(const Duration(milliseconds: 500), _retry);
          return widget.loadingBuilder(context);
        }
        
        return widget.errorBuilder(context);
      },
    );
  }
}

