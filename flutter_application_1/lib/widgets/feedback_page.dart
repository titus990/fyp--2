import 'package:flutter/material.dart';
import '../services/feedback_service.dart';
import '../models/feedback_model.dart';
import 'package:intl/intl.dart';

class FeedbackPage extends StatefulWidget {
  final String moduleType;
  final String moduleName;

  const FeedbackPage({
    super.key,
    required this.moduleType,
    required this.moduleName,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final FeedbackService _feedbackService = FeedbackService();
  String _sortBy = 'newest'; // newest, highest, lowest

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text('${widget.moduleName} Reviews'),
        backgroundColor: const Color(0xFF1A1F38),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Text('Newest First'),
              ),
              const PopupMenuItem(
                value: 'highest',
                child: Text('Highest Rated'),
              ),
              const PopupMenuItem(
                value: 'lowest',
                child: Text('Lowest Rated'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Section
            FutureBuilder<double>(
              future: _feedbackService.getAverageRating(
                moduleType: widget.moduleType,
                moduleName: widget.moduleName,
              ),
              builder: (context, avgSnapshot) {
                final avgRating = avgSnapshot.data ?? 0.0;
                return FutureBuilder<int>(
                  future: _feedbackService.getFeedbackCount(
                    moduleType: widget.moduleType,
                    moduleName: widget.moduleName,
                  ),
                  builder: (context, countSnapshot) {
                    final count = countSnapshot.data ?? 0;
                    return FutureBuilder<Map<int, int>>(
                      future: _feedbackService.getRatingDistribution(
                        moduleType: widget.moduleType,
                        moduleName: widget.moduleName,
                      ),
                      builder: (context, distSnapshot) {
                        final distribution = distSnapshot.data ?? {};
                        return _buildStatisticsCard(
                          avgRating,
                          count,
                          distribution,
                        );
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Reviews List
            const Text(
              'All Reviews',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            StreamBuilder<List<FeedbackModel>>(
              stream: _feedbackService.getFeedbackForModule(
                moduleType: widget.moduleType,
                moduleName: widget.moduleName,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F38),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 64,
                            color: Colors.white30,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                var feedbackList = snapshot.data!;

                // Sort feedback
                if (_sortBy == 'highest') {
                  feedbackList.sort((a, b) => b.rating.compareTo(a.rating));
                } else if (_sortBy == 'lowest') {
                  feedbackList.sort((a, b) => a.rating.compareTo(b.rating));
                }
                // 'newest' is already sorted by timestamp descending

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: feedbackList.length,
                  itemBuilder: (context, index) {
                    return _buildFeedbackCard(feedbackList[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(
    double avgRating,
    int count,
    Map<int, int> distribution,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F38), Color(0xFF0A0E21)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Average Rating
              Expanded(
                child: Column(
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < avgRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 24,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$count ${count == 1 ? 'review' : 'reviews'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Rating Distribution
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    final starCount = distribution[star] ?? 0;
                    final percentage = count > 0 ? (starCount / count) : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$star',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 8),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.amber,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$starCount',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(FeedbackModel feedback) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Text(
                      feedback.userName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(feedback.timestamp),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      feedback.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback.comment,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (feedback.isEdited)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '(edited)',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
