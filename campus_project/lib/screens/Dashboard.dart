import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/dashboard_controller.dart';
import '../states/dashboard_state.dart';
import 'SignInScreen.dart';
import 'ViewUsersScreen.dart';
import 'ViewQuestionsScreen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String authToken;
  final String userFullName;
  final String? userProfession;

  const DashboardScreen({
    super.key,
    required this.authToken,
    required this.userFullName,
    this.userProfession,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    ref
        .read(dashboardControllerProvider.notifier)
        .setAuthToken(widget.authToken);
    ref.read(dashboardControllerProvider.notifier).fetchDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DashboardScreen: build method called.');
    final dashboardState = ref.watch(dashboardControllerProvider);

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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo or App Name
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInScreen(),
                        ),
                      );
                    },
                  ),
                  // User's full name and profession
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.userFullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.userProfession ?? 'Admin',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 25),
                      ),
                    ],
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
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Welcome to your Dashboard\n'
                'Here, you can view and manage all users, browse questions and answers, '
                'and easily monitor activity across the platform',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              dashboardState.when(
                initial: () => _buildLoadingPlaceholder(),
                loading: () => _buildLoadingPlaceholder(),
                success: (totalUsers, totalQuestions, totalAnswers) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: StatCircle(
                            label: 'QUESTIONS',
                            value: totalQuestions,
                            progress: totalQuestions > 0
                                ? (totalQuestions /
                                    (totalQuestions + totalAnswers))
                                : 0.0,
                            color: const Color(0xFFD49C60),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: StatCircle(
                            label: 'SOLUTIONS',
                            value: totalAnswers,
                            progress: totalAnswers > 0
                                ? (totalAnswers /
                                    (totalQuestions + totalAnswers))
                                : 0.0,
                            color: const Color(0xFFD49C60),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: StatCircle(
                        label: 'USERS',
                        value: totalUsers,
                        progress: totalUsers > 0 ? (totalUsers / 1000.0) : 0.0,
                        color: const Color(0xFFD49C60),
                      ),
                    ),
                  ],
                ),
                error: (message) => Center(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewQuestionsScreen(
                            authToken: widget.authToken,
                            userFullName: widget.userFullName,
                            userProfession: widget.userProfession,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8500),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'View Questions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UsersScreen(
                            authToken: widget.authToken,
                            userFullName: widget.userFullName,
                            userProfession: widget.userProfession,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8500),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'View Users',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildLoadingPlaceholder() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildShimmerCircle(label: 'QUESTIONS'),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildShimmerCircle(label: 'SOLUTIONS'),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Center(
          child: _buildShimmerCircle(label: 'USERS'),
        ),
      ],
    );
  }

  Widget _buildShimmerCircle({required String label}) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Color(0xFFD49C60),
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCircle extends StatelessWidget {
  final String label;
  final int value;
  final double progress;
  final Color color;

  const StatCircle({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: CustomPaint(
              size: const Size(150, 150),
              painter: CircularProgressPainter(
                progress: progress,
                color: color,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 5;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
