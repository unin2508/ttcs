// ignore_for_file: unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/service/auth.dart';
import 'package:message_app/service/database.dart';
import 'package:message_app/signinsignup_page/login_page.dart';
import 'edit_page.dart';
import 'mainchat_page.dart';
import 'search_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _indexselect = 0;
  final user = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: getBody(),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _indexselect,
          onTap: (value) {
            setState(() {
              _indexselect = value;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chats'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ]),
    );
  }

  AppBar getAppBar() {
    if (_indexselect == 0)
      return AppBar(
        centerTitle: true,
        title: const Text("Chat"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: ((context) => SearchPage())));
              },
              icon: const Icon(Icons.search)),
        ],
      );
    else if (_indexselect == 1)
      return AppBar(
        centerTitle: true,
        title: const Text("People"),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
      );
    else
      return AppBar(
        centerTitle: true,
        title: const Text("Profile"),
        actions: [
          ElevatedButton(
              onPressed: () async {
                AuthMethods()
                    .signOut()
                    .then((value) => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        )));
              },
              child: Icon(Icons.logout)),
          ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPage(),
                    ));
                setState(() {});
              },
              child: Icon(Icons.edit))
        ],
      );
  }

  Widget getBody() {
    if (_indexselect == 0)
      return ChatPage();
    else if (_indexselect == 1)
      return PeoplePage();
    else
      return ProfilePage();
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var userid = FirebaseAuth.instance.currentUser!.uid;
  var chatdoc = [];
  var uid_receiver = [];
  var kq = [];
  var userdata = [];
  var chatdata = [];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    listChat();
  }

  void listChat() async {
    await FirebaseFirestore.instance
        .collection('chats')
        .where('users.$userid', isNull: true)
        .get()
        .then(
      (value) {
        setState(() {
          value.docs.map((e) {
            Map<String, dynamic> data = e.data() as Map<String, dynamic>;
          });
          chatdoc = value.docs.map((e) => e.id).toList();
        });
      },
    );
    for (var element in chatdoc) {
      FirebaseFirestore.instance
          .collection('chats')
          .doc(element)
          .snapshots()
          .listen((event) {
        Map<String, dynamic> data = event.data() as Map<String, dynamic>;
        Map<String, dynamic> uidchat = data['users'];

        uidchat.remove(userid);
        if (uidchat.length >= 1) {
          setState(() {
            uid_receiver.add({1: uidchat.keys.first, 2: element});
          });
        }
        //print(uidchat.toString() + 'demo');}
      });
    }
    // for (int i = 0; i < uid_receiver.length; i++) {
    //   FirebaseFirestore.instance
    //       .collection('Users')
    //       .doc(uid_receiver[i][1])
    //       .snapshots()
    //       .listen((event) {
    //     Map<String, dynamic> data = event.data() as Map<String, dynamic>;

    //     setState(() {
    //       print(data.toString() + 'data');
    //       userdata.add(
    //           {'username': data['username'], 'imageurl': data['imageurl']});
    //     });

    //     FirebaseFirestore.instance
    //         .collection('chats')
    //         .doc(uid_receiver[i][2])
    //         .collection('messages')
    //         .orderBy('createdOn', descending: true)
    //         .limit(1)
    //         .snapshots()
    //         .listen((event) {
    //       setState(() {
    //         chatdata.add({
    //           'msg': event.docs.first['msg'],
    //           'time': event.docs.first['createdOn']
    //         });
    //       });
    //     });
    //   });
    // }

    // var chatdoc2 = [];
    // for (int i = 0; i < chatdoc.length; i++) {
    //   FirebaseFirestore.instance
    //       .collection('chats')
    //       .doc(chatdoc[i])
    //       .get()
    //       .then((value) {
    //     if (value.data()?['lastmsg'] != null) chatdoc2.add(chatdoc[i]);
    //   });
    // }
    // print(chatdoc2.toString() + 'kq');
  }

  @override
  Widget build(BuildContext context) {
    print(uid_receiver);
    // print(chatdoc2.toString() + '2');
    return Row(
      children: [
        Expanded(
            child: ListView.builder(
                itemCount: uid_receiver.length,
                itemBuilder: (context, index) => InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainChatPage(
                                    uid_receiver: uid_receiver[index][1],
                                  ))),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            FutureBuilder(
                                future: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(uid_receiver[index][1])
                                    .get(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.hasData)
                                    return CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                          snapshot.data!['imageurl']),
                                    );
                                  return CircleAvatar(
                                    radius: 30,
                                  );
                                }),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<Object>(
                                    future: FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(uid_receiver[index][1])
                                        .get(),
                                    builder: (context, AsyncSnapshot snapshot) {
                                      if (snapshot.hasData)
                                        return Text(
                                          snapshot.data!['username'],
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        );
                                      else
                                        return Text(
                                          'No data',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        );
                                    }),
                                SizedBox(
                                  height: 8,
                                ),
                                StreamBuilder<Object>(
                                    stream: FirebaseFirestore.instance
                                        .collection('chats')
                                        .doc(uid_receiver[index][2])
                                        .collection('messages')
                                        .orderBy('createdOn', descending: true)
                                        .snapshots(),
                                    builder: (context, AsyncSnapshot snapshot) {
                                      if (snapshot.hasData)
                                        return Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                snapshot.data!.docs[0]['msg']!,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            ),
                                            Text(DateFormat('hh:mm a').format(
                                                snapshot
                                                    .data!.docs[0]['createdOn']!
                                                    .toDate()))
                                          ],
                                        );
                                      return Text(
                                        "no data",
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400),
                                      );
                                    })
                              ],
                            )),
                            // StreamBuilder(
                            //     stream: FirebaseFirestore.instance
                            //         .collection('chats')
                            //         .doc(uid_receiver[index][2])
                            //         .collection('messages')
                            //         .orderBy('createdOn', descending: true)
                            //         .snapshots(),
                            //     builder: (context, snapshot) {
                            //       // ignore: unused_local_variable

                            //       if (snapshot.hasData)
                            //         return Text(
                            //           DateFormat('hh:mm a').format(snapshot
                            //               .data!.docs[0]['createdOn']!
                            //               .toDate()),
                            //           style: TextStyle(
                            //               fontSize: 12,
                            //               fontWeight: FontWeight.w300),
                            //         );
                            //       else
                            //         return Text("no data");
                            //     })
                          ],
                        ),
                      ),
                    )))
      ],
    );
  }
}

class PeoplePage extends StatelessWidget {
  const PeoplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection("Users").limit(8).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return Row(
              children: [
                Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) => InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainChatPage(
                                              uid_receiver:
                                                  snapshot.data.docs[index].id,
                                              // name_receiver: snapshot
                                              //     .data.docs[index]['username'],
                                            )));
                              },
                              child: (snapshot.data.docs[index].id !=
                                      FirebaseAuth.instance.currentUser!.uid)
                                  ? Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                snapshot.data!.docs[index]
                                                    ['imageurl']),
                                            radius: 25,
                                          ),
                                          SizedBox(
                                            width: 15,
                                          ),
                                          Expanded(
                                            child: Text(
                                              snapshot.data!.docs[index]
                                                  ['username'],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : Container(),
                            )))
              ],
            );
          }
          return Text("People Page");
        });
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return FutureBuilder(
        future: DatabaseService().getInfoUser(user!.uid),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData)
            return Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Center(
                  child: ClipOval(
                    child: Image.network(
                      snapshot.data['imageurl'],
                      fit: BoxFit.fill,
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  snapshot.data['username'],
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  snapshot.data['email'],
                  style: TextStyle(fontSize: 20),
                )
              ],
            );
          return Text("Profile");
        });
  }
}
