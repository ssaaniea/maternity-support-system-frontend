import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:project_frontend/constants.dart';
import 'package:project_frontend/screens/mother/explore/article_details_screem.dart';
import 'package:project_frontend/screens/mother/explore/widgets/article_list_card.dart';
import 'package:project_frontend/screens/mother/explore/widgets/article_thumbnail.dart';
import 'package:project_frontend/screens/mother/explore/widgets/empty_state_widget.dart';
import 'package:project_frontend/screens/mother/explore/widgets/featured_article_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _featuredArticles = [];
  List<Map<String, dynamic>> _allArticles = [];
  List<Map<String, dynamic>> _categories = [];

  // Category lookup cache for performance
  late Map<String, String> _categoryNameCache;

  String? _selectedCategory;
  String? _selectedStage;
  final TextEditingController _searchController = TextEditingController();

  // Debounce timer for search
  Timer? _debounce;

  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  static const Map<String, IconData> _categoryIcons = {
    'meal_plan': Iconsax.cake,
    'tips': Iconsax.lamp_on,
    'exercise': Iconsax.heart,
    'mental_health': Iconsax.emoji_happy,
    'baby_care': Iconsax.fatrows,
    'nutrition': Iconsax.refresh,
    'pregnancy': Iconsax.gallery,
    'postpartum': Iconsax.hospital,
  };

  static const Map<String, Color> _categoryColors = {
    'meal_plan': Colors.orange,
    'tips': Colors.amber,
    'exercise': Colors.red,
    'mental_health': Colors.purple,
    'baby_care': Colors.pink,
    'nutrition': Colors.green,
    'pregnancy': Colors.blue,
    'postpartum': Colors.teal,
  };

  @override
  void initState() {
    super.initState();
    _categoryNameCache = {};
    _fetchData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Implement pagination if needed
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more logic here
    }
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      // Fetch all data in parallel for better performance
      final results = await Future.wait([
        http.get(Uri.parse('$kBaseRoute/article/categories'), headers: headers),
        http.get(Uri.parse('$kBaseRoute/article/featured'), headers: headers),
        _fetchArticlesRequest(headers),
      ]);

      // Process categories
      if (results[0].statusCode == 200) {
        final data = jsonDecode(results[0].body) as List;
        _categories = List<Map<String, dynamic>>.from(data);

        // Build category name cache
        _categoryNameCache = {
          for (var cat in _categories)
            cat['id'] as String: cat['name'] as String,
        };
      }

      // Process featured
      if (results[1].statusCode == 200) {
        final data = jsonDecode(results[1].body) as List;
        _featuredArticles = List<Map<String, dynamic>>.from(data);
      }

      // Process articles
      if (results[2].statusCode == 200) {
        final data = jsonDecode(results[2].body) as List;
        _allArticles = List<Map<String, dynamic>>.from(data);
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching explore data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<http.Response> _fetchArticlesRequest(
    Map<String, String> headers,
  ) async {
    final queryParams = <String, String>{};
    if (_selectedCategory != null) {
      queryParams['category'] = _selectedCategory!;
    }
    if (_selectedStage != null) {
      queryParams['stage'] = _selectedStage!;
    }
    if (_searchController.text.isNotEmpty) {
      queryParams['search'] = _searchController.text;
    }

    final uri = Uri.parse('$kBaseRoute/article').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    return http.get(uri, headers: headers);
  }

  Future<void> _fetchArticles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("jwt_token");

      final headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      final response = await _fetchArticlesRequest(headers);

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _allArticles = List<Map<String, dynamic>>.from(data);
        });
      }
    } catch (e) {
      print("Error fetching articles: $e");
    }
  }

  void _onSearchChanged(String value) {
    // Debounce search to avoid too many API calls
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchArticles();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedStage = null;
      _searchController.clear();
    });
    _fetchArticles();
  }

  String _getCategoryName(String categoryId) {
    return _categoryNameCache[categoryId] ?? categoryId;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Explore",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Bar
            SliverToBoxAdapter(child: _buildSearchSection()),

            // Stage Filter
            SliverToBoxAdapter(child: _buildStageFilter()),

            // Categories
            SliverToBoxAdapter(child: _buildCategoriesSection()),

            // Active Filters
            if (_selectedCategory != null || _selectedStage != null)
              SliverToBoxAdapter(child: _buildActiveFilters()),

            // Featured Articles
            if (_selectedCategory == null &&
                _selectedStage == null &&
                _searchController.text.isEmpty &&
                _featuredArticles.isNotEmpty)
              SliverToBoxAdapter(child: _buildFeaturedSection()),

            // All Articles Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text(
                  _selectedCategory != null || _selectedStage != null
                      ? "Articles"
                      : "All Articles",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // All Articles List - OPTIMIZED
            if (_allArticles.isEmpty)
              SliverToBoxAdapter(child: EmptyStateWidget())
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildArticleCard(_allArticles[index]),
                    childCount: _allArticles.length,
                  ),
                ),
              ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: "Search articles...",
          prefixIcon: const Icon(Iconsax.search_normal_1),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: () {
                    _searchController.clear();
                    _fetchArticles();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: _onSearchChanged,
        onSubmitted: (_) => _fetchArticles(),
      ),
    );
  }

  Widget _buildStageFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            "For:",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStageChip("All", null),
                  _buildStageChip("Pregnancy", "pregnancy"),
                  _buildStageChip("Postpartum", "postpartum"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageChip(String label, String? value) {
    final isSelected = _selectedStage == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedStage = selected ? value : null;
          });
          _fetchArticles();
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.red.withOpacity(0.15),
        labelStyle: TextStyle(
          color: isSelected ? Colors.red : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Categories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_categories.isEmpty)
            _buildEmptyCategoriesState()
          else
            SizedBox(
              height: 105, // Fixed compact height
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryCard(_categories[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final categoryId = category['id'] as String;
    final isSelected = _selectedCategory == categoryId;
    final color = _categoryColors[categoryId] ?? Colors.grey;
    final icon = _categoryIcons[categoryId] ?? Iconsax.document;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? null : categoryId;
        });
        _fetchArticles();
      },
      child: Container(
        width: 110,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              category['name'] ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: isSelected ? color : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              "${category['count']}",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCategoriesState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.category,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "No categories available",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Categories will appear here when articles are added",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            "Active filters:",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_selectedCategory != null)
                    _buildFilterTag(
                      _getCategoryName(_selectedCategory!),
                      () {
                        setState(() => _selectedCategory = null);
                        _fetchArticles();
                      },
                    ),
                  if (_selectedStage != null)
                    _buildFilterTag(
                      _selectedStage == 'pregnancy'
                          ? 'Pregnancy'
                          : 'Postpartum',
                      () {
                        setState(() => _selectedStage = null);
                        _fetchArticles();
                      },
                    ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              "Clear all",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTag(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Iconsax.close_circle,
              size: 16,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Featured Articles",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredArticles.length,
              itemBuilder: (context, index) {
                return FeaturedArticleCard(
                  article: _featuredArticles[index],
                  categoryIcons: _categoryIcons,
                  categoryColors: _categoryColors,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
    final color = _categoryColors[article['category']] ?? Colors.grey;
    final icon = _categoryIcons[article['category']] ?? Iconsax.document;
    final categoryName = _getCategoryName(article['category']);

    return ArticleListCard(
      color: color,
      icon: icon,
      categoryName: categoryName,
      article: article,
    );
  }
}
