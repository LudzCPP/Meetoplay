import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meetoplay/models/message_bubble.dart';
import 'package:meetoplay/global_variables.dart';

class GroupChatPage extends StatefulWidget {
  final String meetingId;

  const GroupChatPage({Key? key, required this.meetingId}) : super(key: key);

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final _messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore? _firestore;
  String? _meetingId;

  @override
  void initState() {
    super.initState();
    // Retrieve meeting ID here or set it when navigating to this page
    _meetingId = widget.meetingId;
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat grupowy (beta 1.8.0)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.black12,
            border: Border(
              top: BorderSide(
                color: darkBlue,
                width: 3.0,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.grey, // Set your desired background color here
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(firestore: _firestore, meetingId: _meetingId),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,0,5), // Add your desired padding here
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          cursorColor: Colors.lightGreen,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w200, fontSize: 12),
                          controller: _messageController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
                            hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w200, fontSize: 12),
                            hintText: 'Napisz wiadomość...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_meetingId != null) {
                            _firestore?.collection('meetingchat_$_meetingId').add({
                              'text': _messageController.text,
                              'sender': _auth.currentUser!.email,
                              'timestamp': Timestamp.now(),
                            });
                            _messageController.clear();
                          } else {
                            // Handle case when meeting ID is not available
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                          child: const Icon(
                            Icons.send,
                            color: Colors.lightGreen,
                            size: 42.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({
    super.key,
    required this.firestore,
    required this.meetingId,
  });

  final FirebaseFirestore? firestore;
  final String? meetingId;

  @override
  Widget build(BuildContext context) {
    if (firestore == null || meetingId == null) {
      return const Text('Firestore or Meeting ID not available');
    }
    return StreamBuilder<QuerySnapshot>(
      stream: firestore?.collection('meetingchat_$meetingId').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 50,horizontal: 0),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.lightGreen),
              ),
            ),
          );
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final data = message.data() as Map<String, dynamic>?;
          final messageText = data != null ? data['text'] as String : '';
          final messageSender = data != null ? data['sender'] as String : '';
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
          );
          messageBubbles.add(messageBubble);
        }
        return SingleChildScrollView(  // Wrap with a SingleChildScrollView
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3, // Set a maximum height
            ),
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              children: messageBubbles,
            ),
          ),
        );
      },
    );
  }
}


