import 'package:flutter/material.dart';

class AskQuestionScreen extends StatelessWidget {
  const AskQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Overall black background
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(80.0), // Height of the custom AppBar
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF212121), // Darker grey for the top bar
                Color(0xFF1A1A1A), // Slightly darker for subtle depth
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
                      Navigator.pop(
                          context); // Navigate back to QuestionsScreen
                    },
                  ),
                  // You can add a title here if needed, like 'Ask Question'
                  // const Text(
                  //   'Ask Question',
                  //   style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  // ),
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
              const Divider(
                  color: Colors.white30,
                  height: 40,
                  thickness: 1), // Divider line
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
              // Title Input Field
              TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800], // Dark background for input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Slightly less rounded corners
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              // Description Input Field
              TextField(
                style: const TextStyle(color: Colors.white),
                maxLines: 8, // Allow multiple lines for description
                minLines: 5,
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[800], // Dark background for input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Slightly less rounded corners
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 50),
              // Post Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement question posting logic
                    debugPrint('Post button pressed!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF8500), // Orange button color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          30.0), // Rounded corners for the button
                    ),
                    minimumSize:
                        const Size(200, 50), // Fixed size for the button
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'Post',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }
}
