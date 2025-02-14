import 'package:flutter/material.dart';
import 'package:flutter_application_1/colors.dart';
import 'package:flutter_application_1/views/widgets/navBar.dart';
import 'package:flutter_application_1/views/widgets/friend_tile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> friendRequests = [];

  @override
  void initState() {
    super.initState();
    fetchFriends();
    fetchFriendRequests();
  }

  // Fetch the list of friends
  Future<void> fetchFriends() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final List<Map<String, dynamic>> response = await supabase
        .from('friends')
        .select('friend_id')
        .eq('user_id', user.userMetadata?['id']);

    if (mounted) {
      setState(() {
        friends = response;
      });
    }
  }

  // Fetch pending friend requests
  Future<void> fetchFriendRequests() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final List<Map<String, dynamic>> response = await supabase
        .from('friends')
        .select('user_id')
        .eq('friend_id', user.userMetadata?['id'])
        .eq('status', 'pending');

    if (mounted) {
      setState(() {
        friendRequests = response;
      });
    }
  }

  // Search for a friend by username and send a friend request
  Future<void> searchFriend() async {
    final String friendUsername = searchController.text.trim();
    if (friendUsername.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please enter a username")));
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Fetch the friend's account ID
    final List<Map<String, dynamic>> friendResponse = await supabase
        .from('Account')
        .select('id, user_name')
        .eq('user_name', friendUsername);

    if (friendResponse.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User not found")));
      return;
    }

    final String friendId = friendResponse[0]['id'];

    // Fetch the current user's account ID
    final List<Map<String, dynamic>> userResponse = await supabase
        .from('Account')
        .select('id')
        .eq('user_name', user.userMetadata?['user_name']);

    if (userResponse.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Your account not found")));
      return;
    }

    final String currentUserId = userResponse[0]['id'];

    sendFriendRequest(currentUserId, friendId);
  }

  // Send a friend request using account IDs
  Future<void> sendFriendRequest(String currentUserId, String friendId) async {
    if (currentUserId == friendId) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("You cannot add yourself as a friend")));
      return;
    }

    try {
      await supabase.from('friends').insert({
        'user_id': currentUserId,
        'friend_id': friendId,
        'status': 'pending',
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Friend request sent!")));

      fetchFriendRequests(); // Refresh pending requests
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to send request")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_black,
      appBar: AppBar(
        backgroundColor: main_black,
        title: const Text(
          "Friends",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: main_green),
                hintText: "Username",
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black54,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.person_add, color: main_green),
              onPressed: searchFriend,
            ),
            const Divider(color: Colors.white24),
            const Text("Friend Requests", style: TextStyle(color: Colors.white)),
            friendRequests.isEmpty
                ? const Text("No pending requests", style: TextStyle(color: Colors.white70))
                : Column(
                    children: friendRequests.map((request) {
                      return ListTile(
                        title: FutureBuilder<List<Map<String, dynamic>>>(
                          future: supabase
                              .from('Account')
                              .select('user_name')
                              .eq('id', request['user_id']),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text("Loading...", style: TextStyle(color: Colors.white70));
                            }
                            final userName = snapshot.data!.isNotEmpty ? snapshot.data![0]['user_name'] : 'Unknown';
                            return Text(userName, style: const TextStyle(color: Colors.white));
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {}, // Accept friend request logic needed
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {}, // Decline friend request logic needed
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
            const Divider(color: Colors.white24),
            const Text("Your Friends", style: TextStyle(color: Colors.white)),
            Expanded(
              child: friends.isEmpty
                  ? const Center(child: Text("No friends yet", style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<List<Map<String, dynamic>>>(
                          future: supabase.from('Account').select('user_name').eq('id', friends[index]['friend_id']),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const ListTile(
                                title: Text("Loading...", style: TextStyle(color: Colors.white70)),
                              );
                            }
                            final friendName = snapshot.data!.isNotEmpty ? snapshot.data![0]['user_name'] : 'Unknown';
                            return FriendTile(name: friendName, status: "Online");
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
