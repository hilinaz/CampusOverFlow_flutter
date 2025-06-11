import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/question_controller.dart';
import '../states/question_state.dart';
import '../models/question_model.dart'; // Make sure this path is correct
import 'AskQuestionScreen.dart'; // Make sure this path is correct
import 'AnswerScreen.dart'; // Make sure this path is correct
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'SignInScreen.dart'; // Make sure this path is correct

class QuestionsScreen extends ConsumerStatefulWidget {
  final String authToken;
  final String userFullName;

  const QuestionsScreen({
    super.key,
    required this.authToken,
    required this.userFullName,
  });

  @override
  ConsumerState<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends ConsumerState<QuestionsScreen> {
  String? _currentUserId;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _decodeAuthToken();
    ref
        .read(questionControllerProvider.notifier)
        .setAuthToken(widget.authToken);
    ref.read(questionActionProvider.notifier).setAuthToken(widget.authToken);
    ref.read(questionControllerProvider.notifier).fetchQuestions();
  }

  void _decodeAuthToken() {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.authToken);
      _currentUserId = decodedToken['userid'].toString();
      if (kDebugMode) {
        print('Decoded User ID for QuestionsScreen: $_currentUserId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding JWT token in QuestionsScreen: $e');
      }
      _currentUserId = null;
    }
  }

  void _showEditQuestionDialog(Question question) {
    final titleController = TextEditingController(text: question.title);
    final descriptionController =
        TextEditingController(text: question.description);
    String selectedTag = question.tag ?? 'general';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Question'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                value: selectedTag,
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('General')),
                  DropdownMenuItem(
                      value: 'technical', child: Text('Technical')),
                  DropdownMenuItem(value: 'academic', child: Text('Academic')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedTag = value; // Update the variable directly
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();

              if (title.isEmpty || description.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                  ),
                );
                return;
              }

              await ref.read(questionActionProvider.notifier).updateQuestion(
                    questionId: question.questionId,
                    title: title,
                    description: description,
                    tag: selectedTag,
                  );

              if (!mounted) return;

              final actionState = ref.read(questionActionProvider);
              actionState.when(
                initial: () {},
                loading: () {
                  // Show loading indicator if needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Updating question...')),
                  );
                },
                success: () {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Question updated successfully!')),
                  );
                  ref
                      .read(questionControllerProvider.notifier)
                      .fetchQuestions(); // Refresh questions
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $message')),
                  );
                },
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Question question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(questionActionProvider.notifier)
                  .deleteQuestion(question.questionId);

              if (!mounted) return;

              final actionState = ref.read(questionActionProvider);
              actionState.when(
                initial: () {},
                loading: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deleting question...')),
                  );
                },
                success: () {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Question deleted successfully!')),
                  );
                  ref
                      .read(questionControllerProvider.notifier)
                      .fetchQuestions(); // Refresh questions
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $message')),
                  );
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questionState = ref.watch(questionControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Background of the screen
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(130.0), // Increased height for more elements
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF212121), // Darker grey at top
                Color(0xFF1A1A1A), // Slightly lighter grey at bottom
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8), // Adjusted vertical padding
              child: Column(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Center content vertically in app bar
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          // Navigate back to SignInScreen (or previous screen)
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SignInScreen(), // Use const with SignInScreen
                            ),
                          );
                        },
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[
                                800], // Darker grey for search bar background
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Search questions...',
                              hintStyle: TextStyle(color: Colors.white54),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.white54),
                              border: InputBorder.none, // Remove default border
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 15.0),
                            ),
                            onChanged: (value) {
                              ref
                                  .read(questionControllerProvider.notifier)
                                  .setSearchQuery(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height:
                          10), // Spacer between search bar and buttons/welcome
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        // Changed from ElevatedButton to GestureDetector for custom button style
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AskQuestionScreen(
                                authToken: widget.authToken,
                                onQuestionCreated: () {
                                  ref
                                      .read(questionControllerProvider.notifier)
                                      .fetchQuestions(); // Refresh questions on creation
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8500), // Orange background
                            borderRadius:
                                BorderRadius.circular(20), // Rounded corners
                          ),
                          child: const Text(
                            'Ask',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      Text(
                        'Welcome: ${widget.userFullName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: questionState.when(
              initial: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF8500),
                ),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF8500),
                ),
              ),
              success: (questions, searchQuery) {
                if (questions.isEmpty) {
                  return const Center(
                    child: Text(
                      'No questions found.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final String fullName = (question.firstName != null &&
                            question.lastName != null)
                        ? '${question.firstName} ${question.lastName}'
                        : question.username ?? 'Unknown User';

                    return QuestionCard(
                      userName: fullName,
                      questionText: question.description ?? '',
                      profession: question.profession,
                      onSeeAnswersPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnswersScreen(
                              questionId: question.questionId,
                              questionTitle: question.title ?? 'No Title',
                              authToken: widget.authToken,
                            ),
                          ),
                        );
                      },
                      currentUserId: _currentUserId,
                      questionUserId: question.userId,
                      onEdit: () => _showEditQuestionDialog(question),
                      onDelete: () => _showDeleteConfirmationDialog(question),
                    );
                  },
                );
              },
              error: (message) => Center(
                child: Text(
                  'Error loading questions: $message',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final String userName;
  final String questionText;
  final String? profession;
  final VoidCallback onSeeAnswersPressed;
  final String? currentUserId;
  final String questionUserId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const QuestionCard({
    super.key,
    required this.userName,
    required this.questionText,
    this.profession,
    required this.onSeeAnswersPressed,
    required this.currentUserId,
    required this.questionUserId,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser =
        currentUserId != null && currentUserId == questionUserId;

    return GestureDetector(
      onTap: isCurrentUser
          ? () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Question Options'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading:
                            const Icon(Icons.edit, color: Color(0xFFFF8500)),
                        title: const Text('Edit Question'),
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
        color: const Color(0xFFF1EBEB),
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: isCurrentUser
              ? const BorderSide(color: Color(0xFFFF8500), width: 1)
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey[700],
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        if (profession != null && profession!.isNotEmpty)
                          Text(
                            profession!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                questionText,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: onSeeAnswersPressed,
                  child: const Text(
                    'See Answers',
                    style: TextStyle(
                      color: Color(0xFFFF8500),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
