import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/mainScreens/messages_screens/messages_screen_2.dart';
import 'package:delivery_service_riders/models/chat.dart';
import 'package:delivery_service_riders/widgets/partner_list_tile.dart';
import 'package:flutter/material.dart';

class MessageUserScreen extends StatefulWidget {
  const MessageUserScreen({super.key});

  @override
  State<MessageUserScreen> createState() => _MessageUserScreenState();
}

class _MessageUserScreenState extends State<MessageUserScreen> {
  String currentUserId = sharedPreferences!.getString('uid') ?? '';

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> storeStream = firebaseFirestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: storeStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              // Convert snapshot data to a list of Chat objects
              final docs = snapshot.data!.docs.map((doc) {
                return Chat.fromJson(doc.data() as Map<String, dynamic>);
              }).toList();

              // ✅ Filter chats where current user’s role is 'store'
              final filteredChats = docs.where((chat) {
                return chat.partnerRoleFor?[currentUserId] == 'user';
              }).toList();

              if (filteredChats.isEmpty) {
                return const Center(child: Text('No messages yet'));
              }

              return ListView.builder(
                itemCount: filteredChats.length,
                itemBuilder: (context, index) {
                  final chat = filteredChats[index];

                  return PartnerListTile(
                    context: context,
                    chat: chat,
                    currentUserId: currentUserId,
                    onTap: () {
                      final partnerId = chat.participants!
                          .firstWhere((id) => id != currentUserId);
                      final partnerName =
                          chat.participantNames?[partnerId] ?? 'Unknown';
                      final partnerImageURL =
                          chat.participantImageURLs?[partnerId] ?? '';
                      final partnerRole = chat.roles?[partnerId] ?? 'user';

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => MessagesScreen2(
                                    partnerName: partnerName,
                                    partnerID: partnerId,
                                    imageURL: partnerImageURL,
                                    partnerRole: partnerRole,
                                  )));
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
