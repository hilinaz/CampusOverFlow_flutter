import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/answer_controller.dart'; // Ensure this path is correct
import '../states/answer_state.dart'; // Ensure this path is correct
import '../models/answer_model.dart'; // Ensure this path is correct
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter/foundation.dart'; // For debugPrint

class AnswersScreen extends ConsumerStatefulWidget {
  final String questionId;
  final String questionTitle;
  final String authToken;

  const AnswersScreen({
    super.key,
    required this.questionId,
    required this.questionTitle,
    required this.authToken,
  });

  @override
  ConsumerState<AnswersScreen> createState() => _AnswersScreenState();
}

class _AnswersScreenState extends ConsumerState<AnswersScreen> {
  final TextEditingController _answerController = TextEditingController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    debugPrint('AnswersScreen: initState called.');
    _decodeAuthToken();
    ref.read(answerControllerProvider.notifier).setAuthToken(widget.authToken);
    ref.read(answerActionProvider.notifier).setAuthToken(widget.authToken);

    // Initial fetch of answers
    debugPrint('AnswersScreen: Calling fetchAnswers from initState.');
    ref.read(answerControllerProvider.notifier).fetchAnswers(widget.questionId);
  }

  void _decodeAuthToken() {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.authToken);
      _currentUserId = decodedToken['userid'].toString();
      if (kDebugMode) {
        debugPrint('AnswersScreen: Decoded User ID: \$_currentUserId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AnswersScreen: Error decoding JWT token: \$e');
      }
      _currentUserId = null;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    debugPrint(
        'AnswerController raw text: \${_answerController.text}'); // Debug print
    debugPrint(
        'AnswerController trimmed text: \${_answerController.text.trim()}'); // Debug print
    debugPrint(
        'AnswerController isEmpty check: \${_answerController.text.trim().isEmpty}'); // Debug print
    if (_answerController.text.trim().isEmpty) {
      debugPrint(
          'Entering isEmpty error block - answer is considered empty.'); // New debug print
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an answer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Indicate loading state (optional, can be part of Riverpod state management)
    // ref.read(answerActionProvider.notifier).setLoading(); // If you have such a method

    await ref.read(answerActionProvider.notifier).submitAnswer(
          questionId: widget.questionId,
          content: _answerController.text.trim(),
        );

    if (!mounted) return;

    final actionState = ref.read(answerActionProvider);
    actionState.when(
      initial: () {
        debugPrint('AnswerActionState: initial');
      },
      loading: () {
        debugPrint('AnswerActionState: loading');
      },
      success: () {
        debugPrint('Answer submission successful!'); // Debug print
        _answerController.clear();
        debugPrint(
            'AnswersScreen: Calling fetchAnswers after successful submission.');
        ref
            .read(answerControllerProvider.notifier)
            .fetchAnswers(widget.questionId); // Refresh answers
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Answer submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
      error: (message) {
        debugPrint('Answer submission failed: \$message'); // Debug print
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _showEditAnswerDialog(Answer answer) {
    final TextEditingController editController =
        TextEditingController(text: answer.content);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        title: const Text('Edit Answer'),
        content: TextField(
          controller: editController,
          autofocus: true,
          maxLines: 5,
          minLines: 3,
          decoration: const InputDecoration(
            hintText: 'Edit your answer',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (editController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Answer cannot be empty')),
                );
                return;
              }

              await ref.read(answerActionProvider.notifier).editAnswer(
                    answerId: answer.answerId,
                    content: editController.text.trim(),
                  );

              if (!mounted) return;

              final actionState = ref.read(answerActionProvider);
              actionState.when(
                initial: () {},
                loading: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Updating answer...')),
                  );
                },
                success: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Answer updated successfully')),
                  ); // Show snackbar BEFORE popping
                  debugPrint(
                      'AnswersScreen: Calling invalidateCache after successful edit.');
                  ref
                      .read(answerControllerProvider.notifier)
                      .invalidateCache(widget.questionId); // Invalidate cache
                  debugPrint(
                      'AnswersScreen: Calling fetchAnswers after successful edit.');
                  ref
                      .read(answerControllerProvider.notifier)
                      .fetchAnswers(widget.questionId); // Refresh answers
                  Navigator.pop(
                      dialogContext); // Pop dialog AFTER snackbar and fetch
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: \$message')),
                  ); // Show snackbar BEFORE popping
                  Navigator.pop(dialogContext); // Pop dialog AFTER snackbar
                },
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Answer answer) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete Answer'),
        content: const Text('Are you sure you want to delete this answer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(answerActionProvider.notifier).deleteAnswer(
                    answerId: answer.answerId,
                  );

              if (!mounted) return;

              final actionState = ref.read(answerActionProvider);
              actionState.when(
                initial: () {},
                loading: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deleting answer...')),
                  );
                },
                success: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Answer deleted successfully')),
                  ); // Show snackbar BEFORE popping
                  debugPrint(
                      'AnswersScreen: Calling invalidateCache after successful delete.');
                  ref
                      .read(answerControllerProvider.notifier)
                      .invalidateCache(widget.questionId); // Invalidate cache
                  debugPrint(
                      'AnswersScreen: Calling fetchAnswers after successful delete.');
                  ref
                      .read(answerControllerProvider.notifier)
                      .fetchAnswers(widget.questionId); // Refresh answers
                  Navigator.pop(
                      dialogContext); // Pop dialog AFTER snackbar and fetch
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: \$message')),
                  ); // Show snackbar BEFORE popping
                  Navigator.pop(dialogContext); // Pop dialog AFTER snackbar
                },
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('AnswersScreen: build method called.');
    final answerState = ref.watch(answerControllerProvider);
    final actionState = ref.watch(answerActionProvider);
    debugPrint('AnswersScreen: Current answerState: $answerState');

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tips',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align children to start
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: 200.0 +
                      MediaQuery.of(context)
                          .viewInsets
                          .bottom, // Account for input section and keyboard
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Guidelines section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Read the question carefully before answering.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Stay on topic — make sure your answer directly addresses the question.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• Be clear and concise — explain your solution step-by-step.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // View Answers section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'View Answers',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Answers list
                    answerState.when(
                      initial: () => _buildLoadingPlaceholder(),
                      loading: () => _buildLoadingPlaceholder(),
                      success: (answers) {
                        if (answers.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'No answers yet. Be the first to answer!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: answers.map((answer) {
                            final String fullName = (answer.firstName != null &&
                                    answer.lastName != null)
                                ? '${answer.firstName} ${answer.lastName}'
                                : answer.username ?? 'Unknown User';

                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 16.0), // Add padding for each card
                              child: AnswerCard(
                                userName: fullName,
                                answerText: answer.content,
                                profession: answer.profession,
                                createdAt: answer.createdAt,
                                currentUserId: _currentUserId,
                                answerUserId: answer.userId,
                                onEdit: () => _showEditAnswerDialog(answer),
                                onDelete: () =>
                                    _showDeleteConfirmationDialog(answer),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      error: (message) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            message,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Submit an Answer section (fixed at bottom and adapts to keyboard)
            Container(
              width: double.infinity,
              color: Colors.black, // Background color for the input section
              padding: const EdgeInsets.only(
                // Fixed bottom padding
                left: 24.0,
                right: 24.0,
                top: 16.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Submit an answer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _answerController,
                    maxLines: 4,
                    minLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Type your answer here',
                      filled: true,
                      fillColor:
                          const Color(0xFFF1EBEB), // Light cream background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.orange, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: actionState.maybeWhen(
                        loading: () => null,
                        orElse: () => _submitAnswer,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8500),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 15),
                      ),
                      child: actionState.maybeWhen(
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                        orElse: () => const Text(
                          'Post',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding:
              const EdgeInsets.only(bottom: 16.0), // Add padding for each card
          child: Card(
            color: Colors.grey[
                200], // Changed to a slightly darker grey for shimmer effect
            margin: EdgeInsets.zero, // Remove margin as padding is added
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            Colors.grey[700], // Slightly lighter for avatar
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 15,
                            color: Colors.grey[700], // Placeholder for name
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 60,
                            height: 10,
                            color:
                                Colors.grey[700], // Placeholder for profession
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 40,
                    color: Colors.grey[700], // Placeholder for answer content
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class AnswerCard extends StatelessWidget {
  final String userName;
  final String answerText;
  final String? profession;
  final DateTime? createdAt;
  final String? currentUserId;
  final String answerUserId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnswerCard({
    super.key,
    required this.userName,
    required this.answerText,
    this.profession,
    required this.createdAt,
    required this.currentUserId,
    required this.answerUserId,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser =
        currentUserId != null && currentUserId == answerUserId;

    return GestureDetector(
      onTap: isCurrentUser
          ? () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Answer Options'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.edit, color: Color(0xFFFF8500)),
                        title: const Text('Edit Answer'),
                        onTap: () {
                          Navigator.pop(context);
                          onEdit();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          : null,
      child: Card(
        color: const Color(0xFFF1EBEB), // Changed to match TextField fillColor
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: isCurrentUser
              ? const BorderSide(
                  color: Color(0xFFFF8500),
                  width: 1.5) // Orange border for current user
              : BorderSide.none, // No border for others
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize:
                MainAxisSize.min, // To make column take minimum height
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align to top
                children: [
                  CircleAvatar(
                    radius: 20, // Slightly smaller avatar for answers
                    backgroundColor: Colors.grey[700],
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12), // Space between avatar and text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        if (profession != null && profession!.isNotEmpty)
                          Text(
                            profession!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Timestamp on the right
                  if (createdAt != null)
                    Text(
                      _formatDateTime(createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12), // Space below user info
              Text(
                answerText,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
