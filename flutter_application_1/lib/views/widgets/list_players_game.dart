import 'package:flutter/material.dart';

class ProfileAvatarList extends StatelessWidget {
  final List<String> avatarUrls;

  const ProfileAvatarList({Key? key, required this.avatarUrls})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: avatarUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(avatarUrls[index]),
            ),
          );
        },
      ),
    );
  }
}
