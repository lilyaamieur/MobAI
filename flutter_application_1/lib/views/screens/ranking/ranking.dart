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

  Future<void> fetchFriends() async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  final accountResponse = await supabase
      .from('Account')
      .select('id')
      .eq('email', user.email!)
      .maybeSingle();

  if (accountResponse == null) return;

  final String accountId = accountResponse['id'].toString();

  final friendIdsResponse = await supabase
      .from('friends')
      .select('friend_id')
      .eq('user_id', accountId)
      .eq('status', 'accepted');

  List<Map<String, dynamic>> friendList = [];
  for (var friend in friendIdsResponse) {
    final accountData = await supabase
        .from('Account')
        .select('id, user_name, status') // ✅ Fetch status
        .eq('id', friend['friend_id'])
        .maybeSingle();
    if (accountData != null) {
      friendList.add(accountData);
    }
  }

  if (mounted) {
    setState(() {
      friends = friendList;
    });
  }
}

  Future<void> fetchFriendRequests() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final accountResponse = await supabase
        .from('Account')
        .select('id')
        .eq('email', user.email!)
        .maybeSingle();

    if (accountResponse == null) return;
    final String accountId = accountResponse['id'].toString();

    final receivedResponse = await supabase
        .from('friends')
        .select('user_id')
        .eq('friend_id', accountId)
        .eq('status', 'pending');

    List<Map<String, dynamic>> receivedRequests = [];
    for (var request in receivedResponse) {
      final accountData = await supabase
          .from('Account')
          .select('id, user_name')
          .eq('id', request['user_id'])
          .maybeSingle();
      if (accountData != null) {
        receivedRequests.add(accountData);
      }
    }

    if (mounted) {
      setState(() {
        friendRequests = receivedRequests;
      });
    }
  }

  Future<void> updateRequestStatus(String userId, String status) async {
    await supabase.from('friends').update({'status': status}).match({'user_id': userId});
    fetchFriends();
    fetchFriendRequests();
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
            const Divider(color: Colors.white24),
            const Text("Friend Requests", style: TextStyle(color: Colors.white)),
            friendRequests.isEmpty
                ? const Text("No pending requests",
                    style: TextStyle(color: Colors.white70))
                : Column(
                    children: friendRequests.map((request) {
                      return ListTile(
                        title: Text(request['user_name'],
                            style: const TextStyle(color: Colors.white)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => updateRequestStatus(request['id'], 'accepted'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => updateRequestStatus(request['id'], 'rejected'),
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
                  ? const Center(
                      child: Text("No friends yet",
                          style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        return FriendTile(
                            name: friends[index]['user_name'], status: friends[index]['status']);
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
