import 'package:flutter/material.dart';

class UserScoreCard extends StatelessWidget {
  final String avatarUrl;
  final String username;
  final int score;
  final int rank;

  const UserScoreCard({
    Key? key,
    required this.avatarUrl,
    required this.username,
    required this.score,
    required this.rank,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: rank <= 3 ? Colors.greenAccent.withOpacity(0.6) : Colors.grey.withOpacity(0.3),
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
              color: rank == 1 ? Colors.yellow : rank == 2 ? Colors.grey : rank == 3 ? Colors.brown : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "#$rank",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),

          // Username and Score
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "$score pts",
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
