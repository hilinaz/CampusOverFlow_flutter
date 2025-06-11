import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Overall black background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Height for the app bar
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context); // Navigate back to dashboard
                        },
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color:
                                Colors.grey[800], // Darker grey for search bar
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: const TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Q Search',
                              hintStyle: TextStyle(color: Colors.white54),
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.white54),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 8.0),
                            ),
                          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Users',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 5,
              itemBuilder: (context, index) {
                return UserCard(
                  userName: 'Abebe Mola',
                  userProfession: 'Developer',
                  onDelete: () {
                    debugPrint(
                        'Delete button pressed for Abebe Mola (User ${index + 1})');
                    // TODO: Implement delete user logic
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final String userName;
  final String userProfession;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.userName,
    required this.userProfession,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFF1EBEB),
      margin: const EdgeInsets.only(bottom: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: Color(0xFF7F7E7E), // Thin border with the specified color
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[700],
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userProfession,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: Image.asset(
                'assets/delete.png',
                width: 28,
                height: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
