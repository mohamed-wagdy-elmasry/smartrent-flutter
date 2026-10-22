import 'package:flutter/material.dart';
import '../../../base/utils/basic_import.dart';

class ProfileLoadingSkeleton extends StatefulWidget {
  const ProfileLoadingSkeleton({super.key});

  @override
  State<ProfileLoadingSkeleton> createState() => _ProfileLoadingSkeletonState();
}

class _ProfileLoadingSkeletonState extends State<ProfileLoadingSkeleton>
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
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
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
    return CustomScrollView(
      slivers: [
        // Header skeleton
        SliverToBoxAdapter(child: _buildHeaderSkeleton()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildCardSkeleton(fieldCount: 2, isRow: true),
                const SizedBox(height: 16),
                _buildCardSkeleton(fieldCount: 2),
                const SizedBox(height: 16),
                _buildCardSkeleton(fieldCount: 4, isRow: true),
                const SizedBox(height: 16),
                _buildCardSkeleton(fieldCount: 2),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSkeleton() {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              CustomColor.disableColor.withOpacity(0.2),
              CustomColor.disableColor.withOpacity(0.12),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CustomColor.disableColor.withOpacity(0.25),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: CustomColor.disableColor.withOpacity(0.2),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 160,
                height: 11,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: CustomColor.disableColor.withOpacity(0.15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardSkeleton({int fieldCount = 2, bool isRow = false}) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: CustomColor.disableColor.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header skeleton
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: CustomColor.disableColor.withOpacity(0.15),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: CustomColor.disableColor.withOpacity(0.18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: CustomColor.disableColor.withOpacity(0.08),
            ),
            const SizedBox(height: 16),
            // Fields skeleton
            if (isRow && fieldCount == 2)
              Row(
                children: [
                  Expanded(child: _fieldSkeleton()),
                  const SizedBox(width: 12),
                  Expanded(child: _fieldSkeleton()),
                ],
              )
            else if (isRow && fieldCount == 4) ...[
              Row(
                children: [
                  Expanded(child: _fieldSkeleton()),
                  const SizedBox(width: 12),
                  Expanded(child: _fieldSkeleton()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _fieldSkeleton()),
                  const SizedBox(width: 12),
                  Expanded(child: _fieldSkeleton()),
                ],
              ),
            ] else
              ...List.generate(
                fieldCount,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: i < fieldCount - 1 ? 16 : 0),
                  child: _fieldSkeleton(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _fieldSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70,
          height: 11,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: CustomColor.disableColor.withOpacity(0.15),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 44,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: CustomColor.disableColor.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
