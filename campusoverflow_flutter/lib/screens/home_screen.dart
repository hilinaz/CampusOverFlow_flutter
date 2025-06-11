import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _userData;
  List<dynamic> _questions = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchQuestions();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      setState(() {
        _userData = jsonDecode(userJson);
      });
    }
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/api/questions'));
      if (response.statusCode == 200) {
        setState(() {
          _questions = jsonDecode(response.body);
        });
      } else {
        // Handle error fetching questions
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to fetch questions: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching questions: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () {
    // TODO: Implement back navigation if needed
    },
    ),
    titleSpacing: 0.0,
    title: Row(
    children: [
    Expanded(
    flex: 3,
    child: Container(
    height: 40, // Adjust height as needed
    decoration: BoxDecoration(
    color: Colors.grey[800], // Dark grey for search background
    borderRadius: BorderRadius.circular(8.0),
    ),
    child: TextField(
    controller: _searchController,
    decoration: InputDecoration(
    hintText: 'Q Search',
    hintStyle: TextStyle(color: Colors.grey[400]),
    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
    border: InputBorder.none,
    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
    ),
    style: TextStyle(color: Colors.white),
    ),
    ),
    ),
    const SizedBox(width: 16),
    Expanded(
    flex: 2,
    child: _userData != null
    ? Text(
    'Welcome: ${_userData!['name']}',
    style: const TextStyle(color: Colors.white, fontSize: 16),
    overflow: TextOverflow.ellipsis,
    )
        : const SizedBox.shrink(),
    ),
    ],
    ),
    actions: [
    TextButton(
    onPressed: () {
    Navigator.pushNamed(context, '/askQuestion');
    },
    child: const Text('Ask', style: TextStyle(color: Colors.white, fontSize: 16)),

      style: TextButton.styleFrom(backgroundColor: Colors.deepOrange), // Orange background
    ),
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.white),
        onPressed: _logout,
      ),
    ],
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Questions',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  return QuestionCard(question: question);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Placeholder for the Question Card widget
class QuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;

  const QuestionCard({Key? key, required this.question}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900], // Dark card background
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  // TODO: Add user avatar image
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question['author']['name'] ?? 'Anonymous',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      question['author']['status'] ?? '',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question['content'] ?? 'No content',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  // Assuming question object has an '_id' field
                  Navigator.pushNamed(context, '/answer', arguments: question['_id']);
                },
                child: const Text('See Answers', style: TextStyle(color: Colors.deepOrangeAccent)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
