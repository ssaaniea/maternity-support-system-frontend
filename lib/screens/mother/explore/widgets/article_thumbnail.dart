import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ArticleThumbnail extends StatelessWidget {
  final String? imageUrl;
  final Color color;
  final IconData icon;
  final double? height;
  final BorderRadius? borderRadius;

  const ArticleThumbnail({
    required this.imageUrl,
    required this.color,
    required this.icon,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final actualHeight = height ?? 80;
    final actualWidth = height == null ? 80.0 : null;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      child: SizedBox(
        width: actualWidth,
        height: actualHeight,
        child: hasImage
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width: actualWidth,
                height: actualHeight,
                fit: BoxFit.cover,
                memCacheHeight: (actualHeight * 2).toInt(), // 2x for quality
                memCacheWidth: actualWidth != null
                    ? (actualWidth * 2).toInt()
                    : null,
                maxHeightDiskCache: (actualHeight * 2).toInt(),
                maxWidthDiskCache: actualWidth != null
                    ? (actualWidth * 2).toInt()
                    : null,
                placeholder: (context, url) => Container(
                  color: color.withOpacity(0.2),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: actualWidth != null ? 32 : 48,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: color.withOpacity(0.2),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: actualWidth != null ? 32 : 48,
                    ),
                  ),
                ),
              )
            : Container(
                color: color.withOpacity(0.2),
                child: Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: actualWidth != null ? 32 : 48,
                  ),
                ),
              ),
      ),
    );
  }
}
