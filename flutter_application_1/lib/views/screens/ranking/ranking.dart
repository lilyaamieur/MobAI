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
    fetchFriendRequests();
  }

  // Fetch the list of friends using account_id
  Future<void> fetchFriends() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print("Null user");
      return;
    }

    final userEmail = user.email!;
    print("email: " + userEmail);

    final accountResponse = await supabase
        .from('Account')
        .select('id')
        .eq('email', userEmail.toString());

    print(accountResponse);

    if (accountResponse!.isEmpty || accountResponse[0]['id'] == null) return;

    final String accountId = accountResponse[0]['id'].toString();

    final List<Map<String, dynamic>> response = await supabase
        .from('friends')
        .select('friend_id')
        .eq('user_id', accountId);

    if (mounted) {
      setState(() {
        friends = response;
      });
    }
  }

  // Fetch pending friend requests using account_id
  Future<void> fetchFriendRequests() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final accountResponse = await supabase
        .from('Account')
        .select('id')
        .eq('user_name', searchController.text);

    if (accountResponse.isEmpty || accountResponse[0]['id'] == null) return;

    final String accountId = accountResponse[0]['id'].toString();

    final List<Map<String, dynamic>> response = await supabase
        .from('friends')
        .select('user_id')
        .eq('friend_id', accountId)
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a username")));
      return;
    }

    final user = supabase.auth.currentUser;
    if (user == null) return;

    // Fetch friend's account_id from username
    final friendResponse = await supabase
        .from('Account')
        .select('id, user_name')
        .eq('user_name', friendUsername);

    print("Friend response " + friendResponse.toString());

    if (friendResponse.isEmpty || friendResponse[0]['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found")),
      );
      return;
    }

    final String friendId = friendResponse[0]['id'].toString();
    print(friendId);

    // Fetch current user's account_id
    final userResponse = await supabase
        .from('Account')
        .select('id')
        .eq('email', user.email!);

    if (userResponse.isEmpty || userResponse[0]['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your account was not found")),
      );
      return;
    }

    final String currentUserId = userResponse[0]['id'].toString();
    print("current userid" + currentUserId);

    await sendFriendRequest(currentUserId, friendId);
  }

  // Send a friend request using account IDs
  Future<void> sendFriendRequest(
    String currentUserAccountId, String friendAccountId) async {
    if (currentUserAccountId == friendAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You cannot add yourself as a friend")));
      return;
    }

    // Check if a request already exists
    final existingRequest = await supabase
        .from('friends')
        .select('id')
        .or('user_id.eq.$currentUserAccountId,friend_id.eq.$friendAccountId')
        .or('user_id.eq.$friendAccountId,friend_id.eq.$currentUserAccountId');

    if (existingRequest.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Friend request already sent!")));
      return;
    }
    try {
      await supabase.from('friends').insert({
        'user_id': currentUserAccountId,
        'friend_id': friendAccountId,
        'status': 'pending',
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Friend request sent!")));

      fetchFriendRequests(); // Refresh pending requests
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to send request: $e")));
    }
  }

  Future<List<String>> getFriends() async {
      final user = supabase.auth.currentUser;
      if (user == null) {
        print("Null user");
        return [];
      }

      final userEmail = user.email!;
      print("email: $userEmail");

      // Fetch the current user's account ID
      final accountResponse = await supabase
          .from('Account')
          .select('id')
          .eq('email', userEmail)
          .single();

      if (accountResponse == null || accountResponse['id'] == null) return [];

      final String accountId = accountResponse['id'].toString();

      // Fetch friends' IDs
      final List<Map<String, dynamic>> friendIdsResponse = await supabase
          .from('friends')
          .select('friend_id')
          .eq('user_id', accountId);

      if (friendIdsResponse.isEmpty) return [];

      List<String> friendNames = [];

      for (var friend in friendIdsResponse) {
        final friendId = friend['friend_id'];

        final accountData = await supabase
            .from('Account')
            .select('user_name')
            .eq('id', friendId)
            .single();

        if (accountData != null && accountData['user_name'] != null) {
          friendNames.add(accountData['user_name']);
        }
      }

      return friendNames;
    }

    Future<void> fetchFriendss() async {
      List<String> friendNames = await getFriends();
      if (mounted) {
        setState(() {
          friends = friendNames.map((name) => {'user_name': name}).toList();
        });
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
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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
            const Text("Friend Requests",
                style: TextStyle(color: Colors.white)),
            friendRequests.isEmpty
                ? const Text("No pending requests",
                    style: TextStyle(color: Colors.white70))
                : Column(
                    children: friendRequests.map((request) {
                      return ListTile(
                        title: FutureBuilder<List<Map<String, dynamic>>>(
                          future: supabase
                              .from('Account')
                              .select('user_name')
                              .eq('id', searchController),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Text("Loading...",
                                  style: TextStyle(color: Colors.white70));
                            }
                            final userName = snapshot.data!.isNotEmpty
                                ? snapshot.data![0]['user_name']
                                : 'Unknown';
                            return Text(userName,
                                style: const TextStyle(color: Colors.white));
                          },
                        ),
                      );
                    }).toList(),
                  ),
            const Divider(color: Colors.white24),
            const Text("Your Friends", style: TextStyle(color: Colors.white)),
            Expanded(
              child: friends.isEmpty
                  ? const Center(
                      child: Text("No friends yet",
                          style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return FriendTile(
                            name: friends[index]['user_name'],
                            status: "Online");
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
