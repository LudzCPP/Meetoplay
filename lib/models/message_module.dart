import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meetoplay/global_variables.dart';
import 'package:meetoplay/models/message_bubble.dart';

class GroupChatPage extends StatefulWidget {
  final String meetingId;

  const GroupChatPage({super.key, required this.meetingId});

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final _messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore? _firestore;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat grupowy',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        backgroundColor: darkBlue,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black54,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: MessagesStream(firestore: _firestore, meetingId: widget.meetingId),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        cursorColor: Colors.lightGreen,
                        style: const TextStyle(color: Colors.white),
                        controller: _messageController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          hintText: 'Napisz wiadomość...',
                          hintStyle: const TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.black38,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: white, size: 30),
                      onPressed: () {
                        _sendMessage();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _firestore?.collection('meetingchat_${widget.meetingId}').add({
        'text': _messageController.text,
        'sender': _auth.currentUser!.email,
        'timestamp': Timestamp.now(),
      });
      _messageController.clear();
    }
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


