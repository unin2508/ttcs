// ignore_for_file: prefer_const_constructors, unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/mainchat_page.dart';
import 'package:message_app/service/database.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var userid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController searchController = TextEditingController();
  var searched = false;
  var chatid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  searched = true;
                });
              },
              icon: Icon(Icons.search),
              color: Colors.black,
            )
          ],
          title: TextField(
            decoration: InputDecoration(
              hintText: 'Search User',
            ),
            controller: searchController,
          ),
        ),
        body: searched
            ? FutureBuilder(
                future:
                    DatabaseService().searchUserByname(searchController.text),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData) {
                    if (snapshot.data.size == 0) {
                      return Center(
                        child: Text("No data"),
                      );
                    } else {
                      // print(snapshot.data.docs[0].id);

                      return InkWell(
                        onTap: () {
                          // FirebaseFirestore.instance
                          //     .collection('chats')
                          //     .where('users', isEqualTo: {
                          //       snapshot.data.docs[0].id: null,
                          //       userid: null
                          //     })
                          //     .limit(1)
                          //     .get()
                          //     .then((value) {
                          //       if (value.docs.isNotEmpty) {
                          //         chatid = value.docs.single.id;
                          //       } else {
                          //         DatabaseService().createNewChat(
                          //             snapshot.data.docs[0].id, userid);
                          //       }
                          //     });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainChatPage(
                                        uid_receiver: snapshot.data.docs[0].id,
                                        name_receiver: snapshot.data.docs[0]
                                            ['username'],
                                      )));
                        },
                        child: Container(
                          constraints: BoxConstraints(maxHeight: 100),
                          padding: EdgeInsets.only(left: 10, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipOval(
                                child: Image.network(
                                  snapshot.data.docs[0]['imageurl'],
                                  fit: BoxFit.fill,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data.docs[0]['username'],
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(snapshot.data.docs[0]['email']),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }
                  }
                  return Center(
                    child: Text("No data"),
                  );
                },
              )
            : Center(child: Text("Search something")));
  }
}
