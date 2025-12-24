import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticleDetailsScreen extends StatefulWidget {
  final String articleId;

  const ArticleDetailsScreen({
    super.key,
    required this.articleId,
  });

  @override
  State<ArticleDetailsScreen> createState() => _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends State<ArticleDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _article;
  bool _isSaved = false;

  final Map<String, IconData> _categoryIcons = {
    'meal_plan': Iconsax.cake,
    'tips': Iconsax.lamp_on,
    'exercise': Iconsax.heart,
    'mental_health': Iconsax.emoji_happy,
    'baby_care': Iconsax.activity,
    'nutrition': Iconsax.fatrows,
    'pregnancy': Iconsax.flash_slash,
    'postpartum': Iconsax.hospital,
  };

  final Map<String, Color> _categoryColors = {
    'meal_plan': Colors.orange,
    'tips': Colors.amber,
    'exercise': Colors.red,
    'mental_health': Colors.purple,
    'baby_care': Colors.pink,
    'nutrition': Colors.green,
    'pregnancy': Colors.blue,
    'postpartum': Colors.teal,
  };

  final Map<String, String> _categoryNames = {
    'meal_plan': 'Meal Plans',
    'tips': 'Tips & Tricks',
    'exercise': 'Exercise',
    'mental_health': 'Mental Health',
    'baby_care': 'Baby Care',
    'nutrition': 'Nutrition',
    'pregnancy': 'Pregnancy',
    'postpartum': 'After Delivery',
  };

  @override
  void initState() {
    super.initState();
    _fetchArticle();
  }

  Future<void> _fetchArticle() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await http.get(
        Uri.parse('$kBaseRoute/article/${widget.articleId}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          _article = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Article not found")),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Error fetching article: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to load article")),
        );
      }
    }
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isSaved ? Iconsax.heart5 : Iconsax.heart,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(_isSaved ? "Article saved" : "Article unsaved"),
          ],
        ),
        backgroundColor: _isSaved ? Colors.red : Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_article == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text("Article not found"),
        ),
      );
    }

    final color = _categoryColors[_article!['category']] ?? Colors.grey;
    final icon = _categoryIcons[_article!['category']] ?? Iconsax.document;
    final categoryName =
        _categoryNames[_article!['category']] ?? _article!['category'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isSaved ? Iconsax.heart5 : Iconsax.heart,
                    color: _isSaved ? Colors.red : Colors.black87,
                  ),
                  onPressed: _toggleSave,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  image:
                      _article!['image_url'] != null &&
                          _article!['image_url'].toString().isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(_article!['image_url']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child:
                    _article!['image_url'] == null ||
                        _article!['image_url'].toString().isEmpty
                    ? Center(
                        child: Icon(
                          icon,
                          size: 80,
                          color: color.withOpacity(0.6),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16, color: color),
                        const SizedBox(width: 6),
                        Text(
                          categoryName,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    _article!['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Meta Info
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${_article!['read_time_minutes'] ?? 5} min read",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_article!['for_stage'] != 'both') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _article!['for_stage'] == 'pregnancy'
                                ? 'Pregnancy'
                                : 'Postpartum',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 24),

                  // Summary (if available)
                  if (_article!['summary'] != null &&
                      _article!['summary'].toString().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            color: color,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _article!['summary'],
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.6,
                                color: Colors.grey[800],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Content
                  Text(
                    _article!['content'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tags
                  if (_article!['tags'] != null &&
                      (_article!['tags'] as List).isNotEmpty) ...[
                    const Text(
                      "Tags",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (_article!['tags'] as List).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "#$tag",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Published Date
                  if (_article!['createdAt'] != null) ...[
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Iconsax.calendar,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Published ${_formatDate(_article!['createdAt'])}",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return "today";
      } else if (difference.inDays == 1) {
        return "yesterday";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} days ago";
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return "$weeks ${weeks == 1 ? 'week' : 'weeks'} ago";
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return "$months ${months == 1 ? 'month' : 'months'} ago";
      } else {
        final years = (difference.inDays / 365).floor();
        return "$years ${years == 1 ? 'year' : 'years'} ago";
      }
    } catch (e) {
      return "";
    }
  }
}
