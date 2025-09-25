import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../models/review.dart';
import '../../theme/app_theme.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  String _filter = 'all'; // all, pending, approved, rejected

  @override
  void initState() {
    super.initState();
    context.read<ReviewProvider>().loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Management'),
        centerTitle: true,
        backgroundColor: AppTheme.ceruleanBlue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Reviews'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('Pending Approval'),
              ),
              const PopupMenuItem(
                value: 'approved',
                child: Text('Approved'),
              ),
              const PopupMenuItem(
                value: 'rejected',
                child: Text('Rejected'),
              ),
            ],
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, reviewProvider, _) {
          final filteredReviews = _getFilteredReviews(reviewProvider.reviews);

          return Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: filteredReviews.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredReviews.length,
                        itemBuilder: (context, index) {
                          final review = filteredReviews[index];
                          return _buildReviewCard(review, reviewProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Approved', 'approved'),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected', 'rejected'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => setState(() => _filter = value),
      selectedColor: AppTheme.ceruleanBlue.withOpacity(0.2),
      checkmarkColor: AppTheme.ceruleanBlue,
      side: BorderSide(
        color: isSelected ? AppTheme.ceruleanBlue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.reviews_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reviews will appear here once students start rating courses',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review, ReviewProvider reviewProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(review.approved).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.ceruleanBlue.withOpacity(0.1),
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.ceruleanBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final starIndex = index + 1;
                          final isFilled = starIndex <= review.rating;
                          return Icon(
                            isFilled ? Icons.star : Icons.star_border,
                            color: Colors.amber.shade600,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          'Course ID: ${review.courseId}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusChip(review.approved),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _formatDate(review.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              if (!review.approved) ...[
                TextButton.icon(
                  onPressed: () => _approveReview(review.id, reviewProvider),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Approve'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _rejectReview(review.id, reviewProvider),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reject'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ] else ...[
                TextButton.icon(
                  onPressed: () => _rejectReview(review.id, reviewProvider),
                  icon: const Icon(Icons.undo, size: 16),
                  label: const Text('Undo'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool approved) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(approved).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(approved).withOpacity(0.3),
        ),
      ),
      child: Text(
        approved ? 'Approved' : 'Pending',
        style: TextStyle(
          color: _getStatusColor(approved),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(bool approved) {
    return approved ? Colors.green : AppTheme.amberOrange;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  List<Review> _getFilteredReviews(List<Review> reviews) {
    switch (_filter) {
      case 'pending':
        return reviews.where((r) => !r.approved).toList();
      case 'approved':
        return reviews.where((r) => r.approved).toList();
      case 'rejected':
        return reviews
            .where((r) => !r.approved)
            .toList(); // For demo, treating pending as rejected
      default:
        return reviews;
    }
  }

  void _approveReview(String reviewId, ReviewProvider reviewProvider) {
    reviewProvider.approveReview(reviewId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review approved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectReview(String reviewId, ReviewProvider reviewProvider) {
    reviewProvider.rejectReview(reviewId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review rejected'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
