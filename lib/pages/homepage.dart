import 'package:chatting/pages/chatpage.dart';
import 'package:chatting/pages/loginpage.dart';
import 'package:chatting/service/authservice.dart';
import 'package:chatting/service/chatservice.dart';
import 'package:chatting/widgets/usertile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final Chatservice chatservice = Chatservice();
  final AuthService authService = AuthService();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Chats')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authService.signout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: chatservice.getUserScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No Users Found'));
          }
          return ListView(
            children: snapshot.data!
                .map<Widget>((userData) => userListitem(userData, context))
                .toList(),
          );
        },
      ),
    );
  }

  Widget userListitem(Map<String, dynamic> userData, BuildContext context) {
    if (userData["email"] != authService.getCurrentUser()!.email) {
      return Usertile(
        name: userData["name"],
        onTap: () {
          // Pass both name and receiverId to Chatpage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Chatpage(
                name: userData["name"], // Pass name
                receiverId: userData["uid"],
                receiverEmail: userData["email"], // Pass receiverId
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
