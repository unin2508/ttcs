// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:message_app/service/database.dart';

class MainChatPage extends StatefulWidget {
  final String uid_receiver;
  final String name_receiver;

  const MainChatPage(
      {Key? key, required this.uid_receiver, required this.name_receiver})
      : super(key: key);

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
    // FirebaseFirestore.instance
    //     .collection('chats')
    //     .where('users', isEqualTo: {userid: null, widget.uid_receiver: null})
    //     .limit(1)
    //     .get()
    //     .then((value) async {
    //       chatid = value.docs.single.id;
    //       print('idchat:' + value.docs.single.id);
    //     });
    FirebaseFirestore.instance
        .collection('chats')
        .where('users', isEqualTo: {widget.uid_receiver: null, userid: null})
        .limit(1)
        .get()
        .then((value) {
          if (value.docs.isNotEmpty) {
            chatid = value.docs.single.id;
          } else {
            FirebaseFirestore.instance.collection('chats').add({
              'users': {widget.uid_receiver: null, userid: null}
            }).then((value) {
              chatid = value.id;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    // FirebaseFirestore.instance
    //     .collection('chats')
    //     .where('users', isEqualTo: {userid: null, widget.uid_receiver: null})
    //     .limit(1)
    //     .get()
    //     .then((value) {
    //       setState(() => this.chatid = value.docs.single.id);
    //     });
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
          if (snapshot.hasError) {
            return Text("Has error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData) {
            var data;
            return Column(
              children: [
                Expanded(
                  //     child: ListView(
                  //   reverse: true,
                  //   children:
                  //       snapshot.data!.docs.map((DocumentSnapshot document) {
                  //     data = document.data()!;
                  //     return Text("data");
                  //   }),
                  // )
                  child: ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: ((context, index) => Row(
                            children: [
                              Text(snapshot.data.docs[index]['msg']),
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
      // body: Row(
      //   children: [
      //     CircleAvatar(
      //       backgroundImage: AssetImage('assets/images/goku.jpg'),
      //     ),
      //     Container(
      //         padding: EdgeInsets.all(10),
      //         margin: EdgeInsets.symmetric(vertical: 10),
      //         constraints: BoxConstraints(
      //           maxWidth: MediaQuery.of(context).size.width * 0.8,
      //         ),
      //         decoration: BoxDecoration(
      //             color: Colors.blue, borderRadius: BorderRadius.circular(15)),
      //         child: Text(
      //             "djaanjncajncanskcn ajsndjna nsjcnajnjsnjancjnajsndjnajnata")),
      //     Text("hello")
      //   ],
      // ),
    );
  }

  send_message(String text) {
    if (text == '') return;
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatid)
        .collection('messages')
        .add({
      'createdOn': FieldValue.serverTimestamp(),
      'uid': userid,
      'msg': text
    }).then((value) {
      _message.text = '';
    });
  }
}
