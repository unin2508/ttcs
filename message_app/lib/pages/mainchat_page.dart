// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:message_app/service/database.dart';

class MainChatPage extends StatefulWidget {
  final String uid_receiver;
  // final String name_receiver;

  // const MainChatPage(
  //     {Key? key, required this.uid_receiver, required this.name_receiver})
  //     : super(key: key);

  const MainChatPage({Key? key, required this.uid_receiver}) : super(key: key);
  @override
  State<MainChatPage> createState() => _MainChatPageState();
}

class _MainChatPageState extends State<MainChatPage> {
  var _message = TextEditingController();
  var userid = FirebaseAuth.instance.currentUser!.uid;
  var chatid;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    checkuser();
  }

  void checkuser() async {
    await FirebaseFirestore.instance
        .collection('chats')
        .where('users', isEqualTo: {widget.uid_receiver: null, userid: null})
        .limit(1)
        .get()
        .then((value) {
          if (value.docs.isNotEmpty)
            setState(() {
              chatid = value.docs.single.id;
            });
          else {
            FirebaseFirestore.instance.collection('chats').add({
              'users': {widget.uid_receiver: null, userid: null},
              'lastmsg': null
            }).then((value) {
              chatid = value.id;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: FutureBuilder(
          future: DatabaseService().getInfoUser(widget.uid_receiver),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Row(
                children: [
                  BackButton(),
                  ClipOval(
                    child: Image.network(snapshot.data['imageurl'],
                        fit: BoxFit.fill, width: 50, height: 50),
                  ),
                  SizedBox(width: 20),
                  Text(snapshot.data['username'])
                ],
              );
            } else
              return Text('has error');
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc(chatid)
            .collection('messages')
            .orderBy('createdOn', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // if (snapshot.hasError) {
          //   return Text("Has error");
          // }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            var data;

            // if (snapshot.data!.docs.length >= 1)
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: ((context, index) => Column(
                            crossAxisAlignment: snapshot.data!.docs[index]
                                        ['uid'] ==
                                    widget.uid_receiver
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              Container(
                                  margin: EdgeInsets.only(top: 10, right: 10),
                                  padding: EdgeInsets.only(right: 10, left: 10),
                                  decoration: BoxDecoration(
                                      color: (Colors.blue),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                    snapshot.data!.docs[index]['msg'],
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  )),
                              if (snapshot.data!.docs[index]['createdOn'] !=
                                  null)
                                Text(DateFormat('hh:mm a').format(snapshot
                                    .data!.docs[index]['createdOn']!
                                    .toDate()))
                            ],
                          ))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          controller: _message,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20)))),
                    )),
                    CupertinoButton(
                      onPressed: () => send_message(_message.text),
                      child: Icon(Icons.send_sharp),
                    )
                  ],
                ),
              ],
            );
          }
          return Text("Chat Page");
        },
      ),
    );
  }

  send_message(String text) async {
    if (text == '') return;
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatid)
        .collection('messages')
        .add({
      'createdOn': FieldValue.serverTimestamp(),
      'uid': userid,
      'msg': text
    }).then((value) {
      // FirebaseFirestore.instance
      //     .collection('chats')
      //     .doc(chatid)
      //     .update({'lastmsg': value.id});
      _message.text = '';
    });
  }
}
