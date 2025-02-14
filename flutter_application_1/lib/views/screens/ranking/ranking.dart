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

  Future<void> searchFriend() async {
    final response = await supabase
        .from('Account')
        .select('user_name')
        .eq('user_name', searchController.text.trim())
        .single()
        ;

    if (response != null || response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not found")),
      );
      return;
    }

    final friendId = response['id'];
    sendFriendRequest(friendId);
  }

  Future<void> sendFriendRequest(String friendId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final userResponse = await supabase
        .from('Account')
        .select('id')
        .eq('user_id', user.id)
        .single()
        ;

    if (userResponse != null || userResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching your account ID")),
      );
      return;
    }

    final userId = userResponse['id'];
    final response = await supabase.from('friends').insert({
      'user_id': userId,
      'friend_id': friendId,
      'status': 'pending',
    });

    if (response.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Friend request sent!")),
      );
    }
  }

  Future<void> fetchFriends() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final userResponse = await supabase
        .from('Account')
        .select('id')
        .eq('user_id', user.id)
        .single()
        ;

    if (userResponse != null || userResponse == null) {
      return;
    }

    final userId = userResponse['id'];
    final response = await supabase
        .from('friends')
        .select('friend_id, status')
        .or('user_id.eq.$userId,friend_id.eq.$userId')
        .eq('status', 'accepted')
        ;

    if (response == null) {
      setState(() {
        friends = response ?? [];
      });
    }
  }

  Future<void> fetchFriendRequests() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final userResponse = await supabase
        .from('Account')
        .select('id')
        .eq('user_id', user.id)
        .single()
        ;

    if (userResponse != null || userResponse == null) {
      return;
    }

    final userId = userResponse['id'];
    final response = await supabase
        .from('friends')
        .select('id, user_id')
        .eq('friend_id', userId)
        .eq('status', 'pending')
        ;

    if (response == null) {
      setState(() {
        friendRequests = response ?? [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: main_black,
      appBar: AppBar(
        backgroundColor: main_black,
        title: Text("Friends", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: main_green),
                hintText: "Username",
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.black54,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: Icon(Icons.person_add, color: main_green),
              onPressed: searchFriend,
            ),
            Divider(color: Colors.white24),
            Text("Friend Requests", style: TextStyle(color: Colors.white)),
            friendRequests.isEmpty
                ? Text("No pending requests", style: TextStyle(color: Colors.white70))
                : Column(
                    children: friendRequests.map((request) {
                      return ListTile(
                        title: Text(request['user_id'], style: TextStyle(color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
            Divider(color: Colors.white24),
            Text("Your Friends", style: TextStyle(color: Colors.white)),
            Expanded(
              child: friends.isEmpty
                  ? Center(child: Text("No friends yet", style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return FriendTile(name: friend['friend_id'], status: "Online");
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
