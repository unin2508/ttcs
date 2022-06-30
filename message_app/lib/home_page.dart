// ignore_for_file: unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables, curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/service/auth.dart';
import 'package:message_app/service/database.dart';
import 'package:message_app/signinsignup_page/login_page.dart';
import 'mainchat_page.dart';
import 'search_page.dart';

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
              child: Text("sign Out"))
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
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.search))],
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

class ChatPage extends StatelessWidget {
  const ChatPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => InkWell(
                      // onTap: () => Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => MainChatPage())),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  AssetImage('assets/images/goku.jpg'),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nguyen Linh',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  'Cau Dang lam gi do',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                )
                              ],
                            )),
                            Text(
                              "12:12",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w300),
                            )
                          ],
                        ),
                      ),
                    )))

        // Text("${user.email}"),
        // ElevatedButton(
        //     onPressed: () async {
        //       AuthMethods()
        //           .signOut()
        //           .then((value) => Navigator.pushReplacement(
        //               context,
        //               MaterialPageRoute(
        //                 builder: (context) => const LoginPage(),
        //               )));
        //     },
        //     child: Text("sign Out"))
      ],
    );
  }
}

class PeoplePage extends StatelessWidget {
  const PeoplePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/images/goku.jpg'),
                              radius: 25,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                "Nguyen Linh",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                    )))
      ],
    );
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
