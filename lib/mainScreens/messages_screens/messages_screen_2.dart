import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_service_riders/global/global.dart';
import 'package:delivery_service_riders/models/chat.dart';
import 'package:delivery_service_riders/widgets/image_confirm.dart';
import 'package:delivery_service_riders/widgets/image_upload_option.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shimmer/shimmer.dart';

class MessagesScreen2 extends StatefulWidget {
  String partnerName, partnerID, imageURL, partnerRole;

  MessagesScreen2({required this.partnerName, required this.partnerID, required this.imageURL, required this.partnerRole, Key? key}) : super(key: key);

  @override
  _MessagesScreen2State createState() => _MessagesScreen2State();
}

class _MessagesScreen2State extends State<MessagesScreen2> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // Dummy messages list to simulate a chat
  final List<String> _messages = [];

  void _markMessagesAsRead() async {
    // Retrieve current user id from sharedPreferences.
    String currentUserId = sharedPreferences!.getString('uid') ?? '';
    // Generate a unique chatId by sorting the current user and partner IDs.
    List<String> ids = [currentUserId, widget.partnerID];
    ids.sort();
    String chatId = ids.join('_');

    // Reference the chat document.
    DocumentReference chatDocRef =
    FirebaseFirestore.instance.collection('chats').doc(chatId);
    // Check if the document exists.
    DocumentSnapshot chatSnapshot = await chatDocRef.get();
    if (!chatSnapshot.exists) {
      // If it doesn't exist, exit the method.
      return;
    }
    // Update the document to set the unread count for the current user to 0.
    await chatDocRef.update({
      'unreadCount.$currentUserId': 0,
    });
  }

  Future<void> _sendMessage() async {
    // Get the text to send.
    String messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    // Clear the input field.
    _messageController.clear();

    // Retrieve current user details from sharedPreferences.
    String currentUserId = sharedPreferences!.getString('uid') ?? '';
    String currentUserName = sharedPreferences!.getString('name') ?? '';
    String currentUserImageURL = sharedPreferences!.getString('imageURL') ?? '';

    // Create a chat ID. Here, we sort the two IDs to create a unique ID.
    List<String> ids = [currentUserId, widget.partnerID];
    ids.sort();
    String chatId = ids.join('_');

    // Create a Chat model instance with all necessary fields.
    Chat chat = Chat(
      chatId: chatId,
      participants: [currentUserId, widget.partnerID],
      roles: {currentUserId: 'rider', widget.partnerID: widget.partnerRole},
      partnerRoleFor: {currentUserId: widget.partnerRole, widget.partnerID: 'rider'},
      participantNames: {
        currentUserId: currentUserName,
        widget.partnerID: widget.partnerName
      },
      participantImageURLs: {
        currentUserId: currentUserImageURL,
        widget.partnerID: widget.imageURL
      },
      lastMessage: messageText,
      lastSender: currentUserId,
      timestamp: DateTime.now(),
      unreadCount: {currentUserId: 0, widget.partnerID: 1},
    );

    // Reference the chat document in Firestore.
    DocumentReference chatDocRef =
    FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Check if the chat already exists.
    DocumentSnapshot chatSnapshot = await chatDocRef.get();
    if (!chatSnapshot.exists) {
      // Create a new chat document using the Chat model.
      await chatDocRef.set(chat.toJson());
    } else {
      // Update the existing chat document (update the lastMessage, timestamp, and unread count).
      await chatDocRef.update({
        'lastMessage': messageText,
        'lastSender': currentUserId,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        // Increase unread count for the partner.
        'unreadCount.${widget.partnerID}': FieldValue.increment(1),
      });
    }

    // Add the message to the 'messages' subcollection.
    await chatDocRef.collection('messages').add({
      'senderID': currentUserId,
      'content': messageText,
      'timestamp': Timestamp.now(),
      'read': false,
      'type': 'text',
    });

    // Optionally scroll to the bottom.
    // Future.delayed(const Duration(milliseconds: 100), () {
    //   if (_scrollController.hasClients) {
    //     _scrollController.animateTo(
    //       _scrollController.position.maxScrollExtent,
    //       duration: const Duration(milliseconds: 300),
    //       curve: Curves.easeOut,
    //     );
    //   }
    // });

    _scrollToBottom();
  }

  /// Upload and send image message using the given image file.
  Future<void> _uploadAndSendImage(File imageFile) async {
    // Retrieve current user data from sharedPreferences.
    String currentUserId = sharedPreferences!.getString('uid') ?? '';
    String currentUserName = sharedPreferences!.getString('name') ?? '';
    String currentUserImageURL = sharedPreferences!.getString('imageURL') ?? '';

    // Generate a unique chatId by sorting the IDs.
    List<String> ids = [currentUserId, widget.partnerID];
    ids.sort();
    String chatId = ids.join('_');

    // Create a unique file name using timestamp and partnerID.
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${widget.partnerID}';
    Reference storageRef =
    FirebaseStorage.instance.ref().child('chat_images/$chatId').child(fileName);

    // Upload the file to Firebase Storage.
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
    String imageUrl = await snapshot.ref.getDownloadURL();

    DocumentReference chatDocRef =
    FirebaseFirestore.instance.collection('chats').doc(chatId);

    // Check if the chat document exists.
    DocumentSnapshot chatSnapshot = await chatDocRef.get();
    if (!chatSnapshot.exists) {
      // Create a new chat document with the necessary fields.
      await chatDocRef.set({
        'chatId': chatId,
        'participants': [currentUserId, widget.partnerID],
        'roles': {currentUserId: 'rider', widget.partnerID: widget.partnerRole},
        'partnerRoleFor': {currentUserId: widget.partnerRole, widget.partnerID: 'rider'},
        'participantNames': {
          currentUserId: currentUserName,
          widget.partnerID: widget.partnerName,
        },
        'participantImageURLs': {
          currentUserId: currentUserImageURL,
          widget.partnerID: widget.imageURL,
        },
        'lastMessage': 'Sent an image',
        'lastSender': currentUserId,
        'timestamp': Timestamp.now(),
        'unreadCount': {currentUserId: 0, widget.partnerID: 1},
      });
    } else {
      // Update the existing chat document.
      await chatDocRef.update({
        'lastMessage': 'Sent an image',
        'lastSender': currentUserId,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'unreadCount.${widget.partnerID}': FieldValue.increment(1),
      });
    }

    // Add the image message to the 'messages' subcollection.
    await chatDocRef.collection('messages').add({
      'senderID': currentUserId,
      'content': imageUrl,
      'timestamp': Timestamp.now(),
      'read': false,
      'type': 'image',
    });

    // Optionally scroll to the bottom.
    // Future.delayed(const Duration(milliseconds: 100), () {
    //   if (_scrollController.hasClients) {
    //     _scrollController.animateTo(
    //       _scrollController.position.maxScrollExtent,
    //       duration: const Duration(milliseconds: 300),
    //       curve: Curves.easeOut,
    //     );
    //   }
    // });
    _scrollToBottom();
  }

  /// This function picks the image based on the source, then shows a confirmation dialog.
  Future<void> _pickAndConfirmImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    // Show confirmation dialog with image preview.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ImageConfirm(
        imageFile: imageFile,
        onCancel: () => Navigator.pop(context),
        onSend: () {
          Navigator.pop(context);
          _uploadAndSendImage(imageFile);
        },
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToBottom();
    // });
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(Map<String, dynamic> messageData, bool isSentByUser) {
    // Format the timestamp; if it doesn't exist, show an empty string.
    String formattedTime = '';
    if (messageData['timestamp'] != null) {
      // Convert Firestore Timestamp to DateTime
      DateTime time = (messageData['timestamp'] as Timestamp).toDate();
      // Format time, for example "2:30 PM"
      formattedTime = DateFormat.jm().format(time);
    }

    // For image messages:
    if ((messageData['type'] ?? 'text') == 'image') {
      return Align(
        alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: Column(
            crossAxisAlignment: isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  // Show full image in a dialog when tapped.
                  showDialog(
                    context: context,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        insetPadding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Image.network(
                            messageData['content'],
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: 150,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: messageData['content'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.grey,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white.withOpacity(0.8),
                        child: Icon(
                          PhosphorIcons.imageBroken(PhosphorIconsStyle.fill),
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedTime,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    } else {
      // For text messages:
      return Align(
        alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: isSentByUser ? Colors.blue[200] : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(messageData['content']),
              const SizedBox(height: 4),
              Text(
                formattedTime,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }
  }

  InputDecoration _messageInputDecoration() {
    return InputDecoration(
      hintText: 'Type your message...',
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        // fontSize: 12,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      isDense: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user id from sharedPreferences.
    String currentUserId = sharedPreferences!.getString('uid') ?? '';

    // Compute a unique chat ID by sorting the current user and partner IDs.
    List<String> ids = [currentUserId, widget.partnerID];
    ids.sort();
    String chatId = ids.join('_');

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child: widget.imageURL.isNotEmpty
                  ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.imageURL,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              )
                  : const Icon(Icons.person),
            ),
            const SizedBox(width: 8,),
            Flexible(child: Text(widget.partnerName, maxLines: 1, overflow: TextOverflow.ellipsis,)),
          ],
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Expanded widget to display the list of chat messages.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(8.0),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final bool isSentByUser = data['senderID'] == currentUserId;
                    return _buildMessageBubble(data, isSentByUser);
                  },
                );
              },
            ),
          ),
          // Input area with a camera button and a send button.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: PhosphorIcon(
                    PhosphorIcons.camera(PhosphorIconsStyle.regular),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => ImageUploadOption(
                        onImageSelected: (ImageSource source) {
                          _pickAndConfirmImage(source);
                        },
                      ),
                    );
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: _messageInputDecoration(),
                  ),
                ),
                IconButton(
                  icon: PhosphorIcon(
                    PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill),
                    color: Colors.blue,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
