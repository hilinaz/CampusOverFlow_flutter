import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/user_controller.dart';
import '../states/user_state.dart';
import '../models/user_model.dart';

class UsersScreen extends ConsumerStatefulWidget {
  final String authToken;
  final String userFullName;
  final String? userProfession;

  const UsersScreen({
    super.key,
    required this.authToken,
    required this.userFullName,
    this.userProfession,
  });

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(userControllerProvider.notifier).setAuthToken(widget.authToken);
    ref.read(userControllerProvider.notifier).fetchUsers();
    _searchController.addListener(() {
      ref
          .read(userControllerProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
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
                          hintText: 'Search users...',
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
              'Users',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: userState.when(
              initial: () => _buildLoadingPlaceholder(),
              loading: () => _buildLoadingPlaceholder(),
              success: (users, searchQuery) {
                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 4.0),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return UserCard(
                      userName: user.fullName,
                      userProfession: user.profession ?? 'N/A',
                      onDelete: () async {
                        final bool confirmDelete = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: Text(
                                      'Are you sure you want to delete ${user.fullName}?'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;
                        if (confirmDelete) {
                          await ref
                              .read(userControllerProvider.notifier)
                              .deleteUser(user.id!);
                        }
                      },
                    );
                  },
                );
              },
              error: (message) => Center(
                child: Text(
                  'Error: $message',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      itemCount: 5, // Show 5 placeholder cards
      itemBuilder: (context, index) {
        return Card(
          color: Colors.grey[800], // Darker grey for shimmer effect
          margin: const EdgeInsets.only(bottom: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      Colors.grey[700], // Slightly lighter for avatar
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: Colors.grey[700], // Placeholder for name
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      color: Colors.grey[700], // Placeholder for profession
                    ),
                  ],
                ),
                const Spacer(), // Pushes the delete icon placeholder to the right
                Container(
                  width: 24,
                  height: 24,
                  color: Colors.grey[700], // Placeholder for delete icon
                ),
              ],
            ),
          ),
        );
      },
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
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[700],
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 12),
                Column(
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
                    Text(
                      userProfession,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: Image.asset('assets/delete.png', width: 24, height: 24),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
