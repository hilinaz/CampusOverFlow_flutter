import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/question_controller.dart';
import '../states/question_state.dart';
import '../models/question_model.dart';
import 'Dashboard.dart';
import 'AnswerScreen.dart';
import 'AskQuestionScreen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/foundation.dart';
import 'SignInScreen.dart';

class ViewQuestionsScreen extends ConsumerStatefulWidget {
  final String authToken;
  final String userFullName;
  final String? userProfession;

  const ViewQuestionsScreen({
    super.key,
    required this.authToken,
    required this.userFullName,
    this.userProfession,
  });

  @override
  ConsumerState<ViewQuestionsScreen> createState() =>
      _ViewQuestionsScreenState();
}

class _ViewQuestionsScreenState extends ConsumerState<ViewQuestionsScreen> {
  String? _currentUserId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _decodeAuthToken();
    ref
        .read(questionControllerProvider.notifier)
        .setAuthToken(widget.authToken);
    ref.read(questionControllerProvider.notifier).fetchQuestions();
    _searchController.addListener(() {
      ref
          .read(questionControllerProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
  }

  void _decodeAuthToken() {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.authToken);
      _currentUserId = decodedToken['userid'].toString();
      if (kDebugMode) {
        print('Decoded User ID for ViewQuestionsScreen: $_currentUserId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error decoding JWT token in ViewQuestionsScreen: $e');
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
                    selectedTag = value;
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
                  const SnackBar(content: Text('Please fill in all fields')),
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
                loading: () {},
                success: () {
                  Navigator.pop(context);
                  ref
                      .read(questionControllerProvider.notifier)
                      .fetchQuestions();
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message)),
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

  @override
  Widget build(BuildContext context) {
    final questionState = ref.watch(questionControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF212121), Color(0xFF1A1A1A)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(
                            authToken: widget.authToken,
                            userFullName: widget.userFullName,
                            userProfession: widget.userProfession,
                          ),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Search...',
                          hintStyle:
                              TextStyle(color: Colors.white54, fontSize: 16),
                          prefixIcon: Icon(Icons.search,
                              color: Colors.white54, size: 22),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 15.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 12.0),
            child: Text(
              'Questions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: questionState.when(
              initial: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF8500))),
              loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF8500))),
              success: (questions, searchQuery) {
                if (questions.isEmpty) {
                  return const Center(
                    child: Text(
                      'No questions found',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final String fullName = (question.firstName != null &&
                            question.lastName != null)
                        ? '${question.firstName} ${question.lastName}'
                        : question.username ?? 'Unknown';
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
                      onDelete: () async {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete Question'),
                              content: const Text(
                                  'Are you sure you want to delete this question?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                        if (confirm == true && context.mounted) {
                          await ref
                              .read(questionControllerProvider.notifier)
                              .deleteQuestion(question.questionId);
                          ref
                              .read(questionControllerProvider.notifier)
                              .fetchQuestions();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Question deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                );
              },
              error: (message) => Center(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
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

    return Card(
      color: const Color(0xFFF1EBEB),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: isCurrentUser
            ? const BorderSide(color: Color(0xFFFF8500), width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
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
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton(
                    icon: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/minus.png',
                          width: 16,
                          height: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    onPressed: () {
                      onDelete();
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              questionText,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
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
            )
          ],
        ),
      ),
    );
  }
}
