
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/messages_screens/messages_screen_2.dart';
import 'package:delivery_service_riders/models/chat.dart';
import 'package:delivery_service_riders/services/providers/badge_provider.dart';
import 'package:delivery_service_riders/widgets/partner_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeBadge = context.watch<StoreMessageCount>().count ?? 0;
    final userBadge = context.watch<UserMessageCount>().count ?? 0;

    String currentUserId = sharedPreferences!.getString('uid') ?? '';
    String selectedRole = _selectedIndex == 0 ? 'store' : 'user';



    // Compute the query stream.
    final Stream<QuerySnapshot> chatStream = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .where('partnerRoleFor.$currentUserId', isEqualTo: selectedRole)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: chatStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      // Convert Firestore data to a Chat model.
                      Chat chat = Chat.fromJson(data);

                      return PartnerListTile(
                        context: context,
                        chat: chat,
                        currentUserId: currentUserId,
                        onTap: () {
                          final partnerId = chat.participants!.firstWhere((id) => id != currentUserId);
                          final partnerName = chat.participantNames?[partnerId] ?? 'Unknown';
                          final partnerImageURL = chat.participantImageURLs?[partnerId] ?? '';
                          final partnerRole = chat.roles?[partnerId] ?? 'user';

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => MessagesScreen2(
                                partnerName: partnerName,
                                partnerID: partnerId,
                                imageURL: partnerImageURL,
                                partnerRole: partnerRole,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                _selectedIndex == 0
                    ? Icon(PhosphorIcons.storefront(PhosphorIconsStyle.fill), size: 24)
                    : Icon(PhosphorIcons.storefront(PhosphorIconsStyle.regular), size: 24),

                if (storeBadge > 0)
                  Positioned(
                    left: 16,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        storeBadge < 99 ? '$storeBadge' : '99',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                _selectedIndex == 1
                    ? Icon(PhosphorIcons.user(PhosphorIconsStyle.fill), size: 24)
                    : Icon(PhosphorIcons.user(PhosphorIconsStyle.regular), size: 24),

                if (userBadge > 0)
                  Positioned(
                    left: 16,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        userBadge < 99 ? '$userBadge' : '99',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'User',
          ),
        ],
      ),
    );
  }
}
