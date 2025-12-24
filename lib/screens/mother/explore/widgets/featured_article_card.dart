import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/screens/mother/explore/article_details_screem.dart';

class FeaturedArticleCard extends StatelessWidget {
  final Map<String, dynamic> article;
  final Map<String, IconData> categoryIcons;
  final Map<String, Color> categoryColors;

  const FeaturedArticleCard({
    required this.article,
    required this.categoryIcons,
    required this.categoryColors,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColors[article['category']] ?? Colors.grey;
    final icon = categoryIcons[article['category']] ?? Iconsax.document;
    final hasImage =
        article['image_url'] != null &&
        article['image_url'].toString().isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailsScreen(articleId: article['_id']),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image - FIXED
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: SizedBox(
                width: 280, // Match card width
                height: 120,
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: article['image_url'],
                        width: 280,
                        height: 120,
                        fit: BoxFit.cover,
                        memCacheHeight: 240, // Cache at 2x for quality
                        memCacheWidth: 560,
                        maxHeightDiskCache: 240,
                        maxWidthDiskCache: 560,
                        placeholder: (context, url) => Container(
                          color: color.withOpacity(0.2),
                          child: Center(
                            child: Icon(icon, color: color, size: 48),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: color.withOpacity(0.2),
                          child: Center(
                            child: Icon(icon, color: color, size: 48),
                          ),
                        ),
                      )
                    : Container(
                        color: color.withOpacity(0.2),
                        child: Center(
                          child: Icon(icon, color: color, size: 48),
                        ),
                      ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      article['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${article['read_time_minutes'] ?? 5} min read",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
