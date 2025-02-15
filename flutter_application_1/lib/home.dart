import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/views/widgets/navBar.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  // Dummy leaderboard data
  final List<Map<String, dynamic>> leaderboard = const [
    {"avatar": "https://via.placeholder.com/150", "name": "Alice", "score": 1200, "rank": 1},
    {"avatar": "https://via.placeholder.com/150", "name": "Bob", "score": 1100, "rank": 2},
    {"avatar": "https://via.placeholder.com/150", "name": "Charlie", "score": 1000, "rank": 3},
    {"avatar": "https://via.placeholder.com/150", "name": "David", "score": 900, "rank": 4},
    {"avatar": "https://via.placeholder.com/150", "name": "Emma", "score": 850, "rank": 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_black,
      appBar: AppBar(
        title: const Text("🏆 Leaderboard", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: main_black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Leaderboard Title
            Text(
              "Top Players",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: main_green, offset: Offset(2, 2), blurRadius: 4),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Leaderboard List
            Expanded(
              child: ListView.builder(
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final user = leaderboard[index];
                  return _buildUserScoreCard(user);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  // 🏆 Leaderboard Row Item
  Widget _buildUserScoreCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: user["rank"] <= 3 ? Colors.greenAccent.withOpacity(0.6) : Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: _getRankColor(user["rank"]),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "#${user["rank"]}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(user["avatar"]),
          ),
          const SizedBox(width: 12),

          // Username and Score
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user["name"],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "${user["score"]} pts",
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🏅 Medal Colors for Top 3 Ranks
  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.yellow; // 🥇 Gold
    if (rank == 2) return Colors.grey; // 🥈 Silver
    if (rank == 3) return Colors.brown; // 🥉 Bronze
    return Colors.transparent;
  }
}
