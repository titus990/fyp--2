import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/feedback_model.dart';
import '../services/feedback_service.dart';
import 'package:intl/intl.dart';

class FeedbackWidget extends StatefulWidget {
  final String moduleType;
  final String moduleName;

  const FeedbackWidget({
    super.key,
    required this.moduleType,
    required this.moduleName,
  });

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  final FeedbackService _feedbackService = FeedbackService();
  final TextEditingController _commentController = TextEditingController();
  double _currentRating = 0;
  bool _isSubmitting = false;
  FeedbackModel? _userFeedback;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserFeedback();
  }

  Future<void> _loadUserFeedback() async {
    final feedback = await _feedbackService.getUserFeedbackForModule(
      moduleType: widget.moduleType,
      moduleName: widget.moduleName,
    );

    if (feedback != null && mounted) {
      setState(() {
        _userFeedback = feedback;
        _currentRating = feedback.rating;
        _commentController.text = feedback.comment;
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_userFeedback != null) {
        // Update existing feedback
        await _feedbackService.updateFeedback(
          feedbackId: _userFeedback!.id,
          rating: _currentRating,
          comment: _commentController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feedback updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Submit new feedback
        await _feedbackService.submitFeedback(
          moduleType: widget.moduleType,
          moduleName: widget.moduleName,
          rating: _currentRating,
          comment: _commentController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feedback submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      // Reload user feedback
      await _loadUserFeedback();
      setState(() => _isEditing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteFeedback() async {
    if (_userFeedback == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Feedback',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete your feedback?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _feedbackService.deleteFeedback(_userFeedback!.id);
        setState(() {
          _userFeedback = null;
          _currentRating = 0;
          _commentController.clear();
          _isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feedback deleted'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting feedback: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with average rating
        FutureBuilder<double>(
          future: _feedbackService.getAverageRating(
            moduleType: widget.moduleType,
            moduleName: widget.moduleName,
          ),
          builder: (context, snapshot) {
            final avgRating = snapshot.data ?? 0.0;
            return FutureBuilder<int>(
              future: _feedbackService.getFeedbackCount(
                moduleType: widget.moduleType,
                moduleName: widget.moduleName,
              ),
              builder: (context, countSnapshot) {
                final count = countSnapshot.data ?? 0;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A1F38), Color(0xFF0A0E21)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$count ${count == 1 ? 'review' : 'reviews'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),

        const SizedBox(height: 24),

        // User's feedback input section
        if (_userFeedback == null || _isEditing) ...[
          const Text(
            'Rate this workout',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStarRating(),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Share your experience...',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF1A1F38),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _userFeedback != null ? 'Update' : 'Submit',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _currentRating = _userFeedback!.rating;
                      _commentController.text = _userFeedback!.comment;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ] else ...[
          // Display user's existing feedback
          _buildUserFeedbackCard(),
        ],

        const SizedBox(height: 32),

        // All feedback section
        const Text(
          'User Reviews',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
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
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1F38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No reviews yet. Be the first to review!',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final feedback = snapshot.data![index];
                final currentUser = FirebaseAuth.instance.currentUser;
                final isOwnFeedback = currentUser?.uid == feedback.userId;

                // Don't show user's own feedback in the list if already shown above
                if (isOwnFeedback && !_isEditing) return const SizedBox.shrink();

                return _buildFeedbackCard(feedback);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = starValue.toDouble();
            });
          },
          child: Icon(
            _currentRating >= starValue ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 40,
          ),
        );
      }),
    );
  }

  Widget _buildUserFeedbackCard() {
    if (_userFeedback == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2193B0).withOpacity(0.3),
            const Color(0xFF6DD5ED).withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2193B0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Review',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                    onPressed: () {
                      setState(() => _isEditing = true);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: _deleteFeedback,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < _userFeedback!.rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _userFeedback!.comment,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM dd, yyyy').format(_userFeedback!.timestamp),
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (_userFeedback!.isEdited)
            const Text(
              '(edited)',
              style: TextStyle(color: Colors.white54, fontSize: 12),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < feedback.rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 18,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            feedback.comment,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          if (feedback.isEdited)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '(edited)',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
