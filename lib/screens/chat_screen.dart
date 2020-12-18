import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letstalk/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_Screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController  = TextEditingController();
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedUser;
  String  messageText;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }
  void getCurrentUser() async{
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedUser = user;
        //print(loggedUser.email);
      }
    }catch(e){
      print(e);
    }

  }
  void messageStream()async {
    await for (var snapshot in _firestore.collection('message').snapshots()) {
      for (var message in snapshot.documents) {

      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('message').snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                final messages = snapshot.data.documents;
                List<MessageBubble> messageWidgets = [];
                for(var message in messages){
                  final messageText = message.data['text'];
                  final messageSender = message.data['sender'];
                  final currentUser = loggedUser.email;
                  final messageTime = message.data['time'];
                  final messageWidget = MessageBubble(sender: messageSender,text: messageText, time: messageTime, isMe: currentUser == messageSender,);
                  messageWidgets.add(messageWidget);
                  messageWidgets.sort((a , b ) => b.time.compareTo(a.time));
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    children: messageWidgets,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      //Implement send functionality.
                      messageTextController.clear();
                      _firestore.collection('message').add({
                        'text' : messageText,
                        'sender' : loggedUser.email,
                        'time': DateTime.now(),
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
    );
  }
}
class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender,this.text,this.isMe, this.time});
  final String sender;
  final String text;
  final bool isMe;
  final Timestamp time;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ?  CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(sender,style: TextStyle(
            fontSize: 10.0,
            color: Colors.black54,
          ),),
          Padding(
            padding:  EdgeInsets.all(4.0),
            child: Material(
              borderRadius:  isMe ? BorderRadius.only(topLeft: Radius.circular(30.0), bottomLeft:  Radius.circular(30.0),bottomRight: Radius.circular(30.0))
                  :BorderRadius.only(topRight: Radius.circular(30.0), bottomLeft:  Radius.circular(30.0),bottomRight: Radius.circular(30.0)),
              elevation: 5.0,
              color: isMe ?  Colors.lightBlueAccent : Colors.white,
              child: Padding(
                padding:  EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
                child: Text(
                  '$text',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: isMe ?  Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
