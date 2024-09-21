import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageDisplay extends StatefulWidget {
  final String senderid;
  final String receiverid;
  const MessageDisplay({
    super.key,
    required this.senderid,
    required this.receiverid,
  });

  @override
  State<MessageDisplay> createState() => _MessageDisplayState();
}

class _MessageDisplayState extends State<MessageDisplay> {
  late final Stream<QuerySnapshot> messageStream;

  @override
  void initState() {
    super.initState();
    // Sorting senderId and receiverId to ensure consistency in chatRoomId
    List<String> ids = [widget.senderid, widget.receiverid];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Query messages for this specific chat room
    messageStream = FirebaseFirestore.instance
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy("time") // Order by time field
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: messageStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              QueryDocumentSnapshot queryDocumentSnapshot =
                  snapshot.data!.docs[index];
              Timestamp timestamp = queryDocumentSnapshot['time'];
              DateTime dateTime = timestamp.toDate();

              bool isCurrentUser =
                  widget.senderid == queryDocumentSnapshot["uid"];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Align(
                  alignment: isCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isCurrentUser ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isCurrentUser
                            ? const Radius.circular(20)
                            : const Radius.circular(0),
                        bottomRight: isCurrentUser
                            ? const Radius.circular(0)
                            : const Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: isCurrentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          queryDocumentSnapshot['email'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          queryDocumentSnapshot["message"],
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                          softWrap: true,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${dateTime.hour}:${dateTime.minute}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }
}
