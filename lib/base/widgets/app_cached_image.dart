import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';

/// A centralized, reusable widget for loading network images with caching, placeholders, error handling,
/// memory optimization, and consistent styling across the app.
///
/// Features:
/// - Automatic memCache sizing based on devicePixelRatio to reduce memory usage
/// - Shimmer placeholder by default (can be customized)
/// - Fallback asset on error
/// - Support for rounded corners and circle shapes
/// - Fade-in animation
/// - Stable cache keys
/// - Optional custom cache manager for fine-tuned cache policies
class AppCachedImage extends StatelessWidget {
  /// The URL of the image to load. If null or empty, shows error/placeholder.
  final String? imageUrl;

  /// Width of the image container
  final double? width;

  /// Height of the image container
  final double? height;

  /// How the image should fit within its container
  final BoxFit fit;

  /// Border radius for rounded corners (ignored if shape is BoxShape.circle)
  final BorderRadius? borderRadius;

  /// Shape of the image container (rectangle or circle)
  final BoxShape shape;

  /// Custom placeholder widget to show while loading (overrides shimmer)
  final Widget? placeholderWidget;

  /// Custom error widget to show on failure
  final Widget? errorWidget;

  /// Whether to show shimmer effect while loading (default: true)
  final bool useShimmer;

  /// Optional explicit cache key (defaults to imageUrl)
  final String? cacheKey;

  /// Optional explicit memCacheWidth (computed from width if not provided)
  final int? memCacheWidth;

  /// Optional explicit memCacheHeight (computed from height if not provided)
  final int? memCacheHeight;

  /// Whether to fade in the image when loaded (default: true)
  final bool fadeIn;

  /// Duration of the fade-in animation
  final Duration fadeInDuration;

  /// Whether to use the old image while loading a new URL (reduces flicker)
  final bool useOldImageOnUrlChange;

  /// Optional custom cache manager (defaults to DefaultCacheManager)
  final BaseCacheManager? cacheManager;

  /// Asset path for fallback image on error
  final String fallbackAsset;

  const AppCachedImage({
    Key? key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.placeholderWidget,
    this.errorWidget,
    this.useShimmer = true,
    this.cacheKey,
    this.memCacheWidth,
    this.memCacheHeight,
    this.fadeIn = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.useOldImageOnUrlChange = true,
    this.cacheManager,
    this.fallbackAsset = 'assets/background/smartrent.jpg',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Normalize the URL: treat null, empty, or 'null' strings as invalid
    final normalizedUrl = _normalizeUrl(imageUrl);

    // If URL is invalid, show error widget immediately
    if (normalizedUrl == null) {
      return _buildErrorWidget(context);
    }

    // Compute memory cache dimensions for optimal memory usage
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final computedMemCacheWidth = memCacheWidth ?? 
        (width != null && width!.isFinite ? (width! * devicePixelRatio).round() : null);
    final computedMemCacheHeight = memCacheHeight ?? 
        (height != null && height!.isFinite ? (height! * devicePixelRatio).round() : null);

    return CachedNetworkImage(
      imageUrl: normalizedUrl,
      cacheKey: cacheKey ?? normalizedUrl,
      cacheManager: cacheManager,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: computedMemCacheWidth,
      memCacheHeight: computedMemCacheHeight,
      useOldImageOnUrlChange: useOldImageOnUrlChange,
      fadeInDuration: fadeIn ? fadeInDuration : Duration.zero,
      placeholder: (context, url) => _buildPlaceholder(context),
      errorWidget: (context, url, error) => _buildErrorWidget(context),
      imageBuilder: (context, imageProvider) => _buildImageWithDecoration(imageProvider),
    );
  }

  /// Normalize URL: return null if invalid, trimmed URL otherwise
  String? _normalizeUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final trimmed = url.trim();
    if (trimmed.isEmpty || 
        trimmed.toLowerCase() == 'null' || 
        trimmed.contains('/null')) {
      return null;
    }
    return trimmed;
  }

  /// Build the placeholder widget (shimmer or custom)
  Widget _buildPlaceholder(BuildContext context) {
    // If custom placeholder provided, use it
    if (placeholderWidget != null) {
      return _wrapInContainer(placeholderWidget!);
    }

    // If shimmer enabled, show shimmer effect
    if (useShimmer) {
      return _wrapInContainer(
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: shape,
              borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
            ),
          ),
        ),
      );
    }

    // Default: simple loading indicator
    return _wrapInContainer(
      Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  /// Build the error widget (custom or fallback asset)
  Widget _buildErrorWidget(BuildContext context) {
    // If custom error widget provided, use it
    if (errorWidget != null) {
      return _wrapInContainer(errorWidget!);
    }

    // Default: show fallback asset image
    return _wrapInContainer(
      Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          // If even the fallback asset fails, show icon
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.grey[400],
              size: 40,
            ),
          );
        },
      ),
    );
  }

  /// Build image with proper decoration (shape and border radius)
  Widget _buildImageWithDecoration(ImageProvider imageProvider) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        image: DecorationImage(
          image: imageProvider,
          fit: fit,
        ),
      ),
    );
  }

  /// Wrap widget in a container with proper sizing and decoration
  Widget _wrapInContainer(Widget child) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        color: Colors.grey[100],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
