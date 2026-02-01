import 'package:flutter/material.dart';

/// Skeleton loading widget for the home screen
/// Shows placeholder animations while data is loading
class HomeSkeleton extends StatelessWidget {
  final bool isPregnant;

  const HomeSkeleton({super.key, this.isPregnant = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPregnant
              ? [
                  const Color.fromARGB(255, 158, 204, 200),
                  const Color.fromARGB(255, 226, 223, 222),
                  const Color(0xffeecde6),
                ]
              : [
                  const Color(0xFFFCE4EC),
                  const Color(0xFFE1BEE7),
                  const Color(0xFFE8EAF6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56), // AppBar space
                // Greeting skeleton
                const _SkeletonBox(width: 200, height: 20),
                const SizedBox(height: 8),
                // Subtitle skeleton
                const _SkeletonBox(width: 280, height: 16),
                const SizedBox(height: 16),
                // Week progress skeleton
                if (isPregnant) ...[
                  _buildWeekProgressSkeleton(),
                  const SizedBox(height: 16),
                ],
                // Main visual skeleton
                _buildMainVisualSkeleton(),
                const SizedBox(height: 16),
                // Tracker skeleton
                _buildTrackerSkeleton(),
                const SizedBox(height: 16),
                // SOS skeleton
                _buildSOSSkeleton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekProgressSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          _SkeletonBox(width: 50, height: 50, isCircle: true),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: 120, height: 14),
                SizedBox(height: 8),
                _SkeletonBox(width: double.infinity, height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainVisualSkeleton() {
    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: _SkeletonBox(width: 200, height: 200, isCircle: true),
      ),
    );
  }

  Widget _buildTrackerSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBox(width: 150, height: 18),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (index) => const Column(
                children: [
                  _SkeletonBox(width: 48, height: 48, isCircle: true),
                  SizedBox(height: 8),
                  _SkeletonBox(width: 40, height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          _SkeletonBox(width: 40, height: 40, isCircle: true),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: 100, height: 14),
                SizedBox(height: 4),
                _SkeletonBox(width: 180, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated skeleton box with shimmer effect
class _SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final bool isCircle;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.isCircle = false,
  });

  @override
  State<_SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<_SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: _animation.value),
            borderRadius: widget.isCircle ? null : BorderRadius.circular(8),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
          ),
        );
      },
    );
  }
}
