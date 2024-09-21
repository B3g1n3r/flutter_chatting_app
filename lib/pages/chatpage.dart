import 'package:chatting/pages/loginpage.dart';
import 'package:chatting/service/authservice.dart';
import 'package:chatting/service/chatservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chatpage extends StatelessWidget {
  final String name;
  final String receiverId;
  final String receiverEmail;

  Chatpage({
    super.key,
    required this.name,
    required this.receiverId,
    required this.receiverEmail,
  });

  final TextEditingController messageController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final Chatservice chatService = Chatservice();

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      await chatService.sendMessage(receiverId, messageController.text);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(name)),
        actions: [
          IconButton(
            onPressed: () {
              AuthService().signout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [Expanded(child: _buildMessageList()), userInput()],
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildMessageList() {
    String senderId = firebaseAuth.currentUser!.uid;
    return StreamBuilder(
      stream: chatService.getMessages(senderId, receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading...");
        }
        return ListView(
          children: snapshot.data!.docs
              .map((e) => _buildMessageItem(e, context))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc, BuildContext context) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool currentUser = data["senderId"] == AuthService().getCurrentUser()!.uid;

    return GestureDetector(
      onDoubleTap: () {
        if (currentUser) {
          // Only allow actions if the current user is the sender
          _showEditDeleteDialog(context, data, doc.id);
        }
      },
      child: Container(
        child: Column(
          crossAxisAlignment:
              currentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: currentUser ? Colors.green : Colors.blue,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  data["message"],
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDeleteDialog(
      BuildContext context, Map<String, dynamic> data, String messageId) {
    TextEditingController editController =
        TextEditingController(text: data["message"]);
    String userId = firebaseAuth.currentUser!.uid;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit or Delete Message"),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: "Edit your message"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update the message
                chatService.updateMessage(
                    messageId, editController.text, userId, receiverId);
                editController.clear();
                Navigator.of(context).pop();
              },
              child: Text("Update"),
            ),
            TextButton(
              onPressed: () {
                // Delete the message
                chatService.deleteMessage(messageId, userId, receiverId);
                Navigator.of(context).pop();
              },
              child: Text("Delete"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("cancel"),
            ),
          ],
        );
      },
    );
  }

  Widget userInput() {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: messageController,
              decoration: InputDecoration(
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                hintText: 'Message',
                contentPadding:
                    const EdgeInsets.only(left: 15, bottom: 8, top: 8),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(40)),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.send_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
