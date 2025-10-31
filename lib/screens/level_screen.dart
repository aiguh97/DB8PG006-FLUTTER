import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pandai/auth/signin_screen.dart';
import 'package:pandai/constant/theme.dart';
import 'package:pandai/screens/screen_one.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  int _currentIndex = 0;
  final List<String> _languages = [
    'German',
    'Spanish',
    'French',
    'Italian',
    'Korean',
  ];

  Future<void> _changeLanguage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    final userId = user.uid;

    // Show dialog to select language
    String? selectedLanguage = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("Select language"),
          children: _languages.map((lang) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, lang);
              },
              child: Text(lang),
            );
          }).toList(),
        );
      },
    );

    if (selectedLanguage != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'Language': selectedLanguage,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Language changed to $selectedLanguage")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final levelQuery = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('levels')
        .orderBy('levelNumber');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Language Tutor',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greenPrimary,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.settings,
                        color: AppColors.greenPrimary,
                      ),
                      onSelected: (value) async {
                        if (value == 'language') {
                          await _changeLanguage();
                        } else if (value == 'logout') {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SigninScreen(),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'language',
                          child: ListTile(
                            leading: Icon(
                              Icons.language,
                              color: AppColors.greenPrimary,
                            ),
                            title: Text('Change language'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: ListTile(
                            leading: Icon(
                              Icons.logout,
                              color: Colors.redAccent,
                            ),
                            title: Text("Logout"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // User streak card with language
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // final userData = snapshot.data!;
                  // final email = userData['email'] ?? 'User';
                  // final name = email.split('@')[0];
                  // final streak = userData['streak'] ?? 0;
                  // final language = userData['Language'] ?? 'German';

                  final userData = snapshot.data!;
                  final data = userData.data() as Map<String, dynamic>? ?? {};

                  final email = data['email'] ?? 'User';
                  final name = email.split('@')[0];
                  final streak = data['streak'] ?? 0;
                  final language = data.containsKey('Language')
                      ? data['Language']
                      : 'German';

                  // Gunakan `email` sesuai kebutuhan
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black12, // bisa diganti sesuai kebutuhan
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage('assets/images/cool.png'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, $name!",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Learning: $language",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8A65), Color(0XFFFF7043)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '🔥 $streak',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "days",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StreamBuilder(
                    stream: levelQuery.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final levels = snapshot.data!.docs;

                      return SingleChildScrollView(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: levels.asMap().entries.map((entry) {
                            final index = entry.key;
                            final doc = entry.value;

                            final levelNumber = doc['levelNumber'] ?? index + 1;
                            final title = doc['title'] ?? 'Level';
                            final bool isUnlocked =
                                doc['isUnlocked'] ?? (levelNumber == 1);
                            final bool isLeft = index % 2 == 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: isLeft
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                                children: [
                                  if (!isLeft)
                                    Lottie.asset(
                                      'assets/animation/animation.json',
                                      height: 80,
                                      width: 80,
                                    ),
                                  Column(
                                    children: [
                                      GestureDetector(
                                        onTap: isUnlocked
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ScreenOne(
                                                      levelNumber: levelNumber,
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: isUnlocked
                                                ? const LinearGradient(
                                                    colors: [
                                                      AppColors.greenPrimary,
                                                      AppColors.greenAccent,
                                                    ],
                                                  )
                                                : LinearGradient(
                                                    colors: [
                                                      Colors.grey.shade400,
                                                      Colors.grey.shade500,
                                                    ],
                                                  ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 15,
                                                ),
                                                blurRadius: 12,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          width: 80,
                                          height: 80,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  isUnlocked
                                                      ? Icons.star
                                                      : Icons.lock,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '$levelNumber',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isLeft)
                                    Lottie.asset(
                                      'assets/animation/animation3.json',
                                      height: 80,
                                      width: 80,
                                    ),
                                ],
                              ),
                              // Tambahkan widget child di sini
                            );
                          }).toList(),
                        ),

                        // di sini Anda bisa tambahkan child misalnya Column dengan daftar levels
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 12,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            // Navigator.push(context, MaterialPageRoute(builder: (_)=>const LeaderboardScreen))
          } else if (index == 2) {
            // Navigator.push(context,MaterialPageRoute(builder: (_)=>const ProfileScreen());
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/avatars/home.png'),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/avatars/rank.png'),
            ),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Image.asset('assets/avatars/avatar.png'),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
