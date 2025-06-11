import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/question_controller.dart'; // Ensure this path is correct
import 'package:jwt_decoder/jwt_decoder.dart';
import 'QuestionsScreen.dart'; // Ensure this path is correct

class AskQuestionScreen extends ConsumerStatefulWidget {
  final String authToken;
  final VoidCallback? onQuestionCreated;

  const AskQuestionScreen({
    super.key,
    required this.authToken,
    this.onQuestionCreated,
  });

  @override
  ConsumerState<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends ConsumerState<AskQuestionScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String? _selectedTag;
  String? _userFullName;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _decodeAuthToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // It's good to set the auth token here, but ensure your QuestionController
      // doesn't immediately try to fetch data upon setting it unless intended.
      ref
          .read(questionControllerProvider.notifier)
          .setAuthToken(widget.authToken);
    });
  }

  void _decodeAuthToken() {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(widget.authToken);
      debugPrint('AskQuestionScreen: Decoded JWT: $decodedToken');

      final firstName = decodedToken['firstname'] as String?;
      final lastName = decodedToken['lastname'] as String?;
      final username = decodedToken['username'] as String?;

      debugPrint('AskQuestionScreen: Extracted firstName: $firstName');
      debugPrint('AskQuestionScreen: Extracted lastName: $lastName');
      debugPrint('AskQuestionScreen: Extracted username: $username');

      String tempFullName = '';
      if (firstName != null && firstName.isNotEmpty) {
        tempFullName += firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        if (tempFullName.isNotEmpty) tempFullName += ' ';
        tempFullName += lastName;
      }

      if (tempFullName.isEmpty && username != null && username.isNotEmpty) {
        tempFullName = username;
      }

      _userFullName = tempFullName.isNotEmpty ? tempFullName : 'User';

      debugPrint(
          'AskQuestionScreen: Constructed _userFullName: $_userFullName');
    } catch (e) {
      _userFullName = 'User';
      debugPrint(
          'AskQuestionScreen: Error decoding JWT in AskQuestionScreen: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _postQuestion() async {
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();
    final String tag = _selectedTag ?? 'general';

    debugPrint('AskQuestionScreen: Attempting to post question.');
    debugPrint('AskQuestionScreen: Title: $title');
    debugPrint('AskQuestionScreen: Description: $description');
    debugPrint('AskQuestionScreen: Tag: $tag');

    if (title.isEmpty || description.isEmpty) {
      debugPrint(
          'AskQuestionScreen: Validation failed - title or description empty.');
      if (mounted) {
        // Check mounted before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please enter both title and description.')),
        );
      }
      return;
    }

    try {
      debugPrint(
          'AskQuestionScreen: Calling createQuestion in QuestionActionController.');
      await ref.read(questionActionProvider.notifier).createQuestion(
            title: title,
            description: description,
            tag: tag,
          );
      debugPrint('AskQuestionScreen: createQuestion completed successfully.');

      // Check the state of the action provider after the call
      final actionState = ref.read(questionActionProvider);
      actionState.when(
        initial: () {},
        loading: () {},
        success: () {
          debugPrint('AskQuestionScreen: QuestionActionState is SUCCESS.');
          widget.onQuestionCreated
              ?.call(); // Call the callback to refresh questions in parent

          // Redirect to QuestionsScreen after successful post
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Question posted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            // Using pushReplacement ensures the user can't go back to the AskQuestionScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionsScreen(
                  authToken: widget.authToken,
                  userFullName:
                      _userFullName ?? 'User', // Pass decoded user full name
                ),
              ),
            );
          }
        },
        error: (message) {
          debugPrint(
              'AskQuestionScreen: QuestionActionState is ERROR: $message');
          if (mounted) {
            // Check mounted before showing SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to post question: $message')),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('AskQuestionScreen: Caught unexpected error during post: $e');
      if (mounted) {
        // Check mounted before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post question: [${e.toString()}]')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF212121),
                Color(0xFF1A1A1A),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'STEPS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '• Sign in and go to the Q&A section\n'
                '• Click "Ask a Question" and write\n'
                '• Add relevant tags and submit your question',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const Divider(color: Colors.white30, height: 40, thickness: 1),
              const SizedBox(height: 20),
              const Text(
                'Ask your Question',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              // --- ADDED KEY HERE ---
              TextField(
                key: const ValueKey('title_field'),
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              // --- ADDED KEY HERE ---
              TextField(
                key: const ValueKey('description_field'),
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 8,
                minLines: 5,
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: ElevatedButton(
                  onPressed: _postQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8500),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    minimumSize: const Size(200, 50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'Post',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
