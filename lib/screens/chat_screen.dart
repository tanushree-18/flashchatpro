import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashchat/screens/user_profile.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:flashchat/constants.dart';
import 'package:flashchat/screens/group_details.dart';

User? loggedInUser;
final _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Stream<QuerySnapshot<Object?>>? stream;
  String? userProfileImageUrl;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    stream = _firestore.collection('messages').snapshots();
  }

  final _auth = FirebaseAuth.instance;

  void getCurrentUser() async {
    final user = await _auth.currentUser;
    if (user != null) {
      loggedInUser = user;
      print(loggedInUser!.email);
      fetchUserProfileImageUrl();
    }
  }

  void fetchUserProfileImageUrl() async {
    try {
      final snapshot = await _firestore
          .collection('userDetails')
          .doc(loggedInUser!.uid)
          .get();
      final data = snapshot.data() as Map<String, dynamic>;
      setState(() {
        userProfileImageUrl = data['profileImageUrl'];
      });
    } catch (e) {
      print('Error fetching user profile image URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String? messagetext;
    final TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
          // Add user profile icon here
          IconButton(
            icon: CircleAvatar(
              backgroundImage: userProfileImageUrl != null
                  ? NetworkImage(userProfileImageUrl!)
                  : null,
              child: userProfileImageUrl == null
                  ? Icon(Icons.account_circle)
                  : null,
            ),
            onPressed: () {
              Navigator.pushNamed(context, UserProfile.id);
            },
          ),
        ],
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, GroupDetails.id);
          },
          child: Text('⚡️Chat'),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('reg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final messages = snapshot.data?.docs.reversed;
                    List<Messagebubble> messageBubbles = [];
                    for (var message in messages!) {
                      final messageText = (message.data() as Map)['text'];
                      final messageSender = (message.data() as Map)['sender'];
                      final currentUser = loggedInUser?.email;
                      if (messageText != null && messageSender != null) {
                        final messageBubble = Messagebubble(
                          messageText,
                          messageSender,
                          currentUser == messageSender,
                        );
                        messageBubbles.add(messageBubble);
                      }
                    }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        children: messageBubbles,
                      ),
                    );
                  } else
                    return Text('no messages');
                },
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          messagetext = value;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _controller.clear();
                        _firestore.collection('messages').add({
                          'sender': loggedInUser!.email,
                          'text': messagetext,
                        });
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
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
}

class Messagebubble extends StatelessWidget {
  Messagebubble(this.text, this.sender, this.isMe);
  final String text, sender;
  bool isMe;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          Material(
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            elevation: 5,
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: isMe ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
