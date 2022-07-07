// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../service/database.dart';
import 'package:path/path.dart';

class EditPage extends StatefulWidget {
  const EditPage({Key? key}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  // ignore: non_constant_identifier_names
  String? user_uid = FirebaseAuth.instance.currentUser?.uid;
  File? image;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print("Failed :  $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Edit Page"),
      ),
      body: FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('Users').doc(user_uid!).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData)
            return Column(
              children: [
                Center(
                  child: SizedBox(
                    height: 30,
                  ),
                ),
                // Center(
                //   child: ClipOval(
                //     child: Image.network(
                //       snapshot.data!['imageurl'],
                //       fit: BoxFit.fill,
                //       width: 150,
                //       height: 150,
                //     ),
                //   ),
                // ),
                image == null
                    ? Container(
                        padding: EdgeInsets.only(left: 40, right: 40),
                        child: MaterialButton(
                          onPressed: () {
                            pickImage();
                          },
                          child: Text(
                            "Pick an avatar",
                            style: TextStyle(color: Colors.red),
                          ),
                          color: Colors.blue,
                        ),
                      )
                    : ClipOval(
                        child: Image.file(
                          image!,
                          fit: BoxFit.fill,
                          width: 150,
                          height: 150,
                        ),
                      ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  snapshot.data!['username'],
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  snapshot.data!['email'],
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                    onPressed: () async {
                      String? imageurl;
                      String filename = basename(image!.path);
                      final FirebaseStorage storage = FirebaseStorage.instance;
                      try {
                        var ref = storage.ref().child('avt/$filename');
                        TaskSnapshot uploadTask = await ref.putFile(image!);
                        if (uploadTask.state == TaskState.success) {
                          imageurl = await ref.getDownloadURL();
                        }
                      } on FirebaseException catch (e) {
                        print(e);
                      }
                      await FirebaseFirestore.instance
                          .collection('Users')
                          .doc(user_uid)
                          .update({'imageurl': imageurl}).then((value) {
                        Navigator.pop(context);
                      });
                    },
                    child: Text("Save")),
              ],
            );
          return Text("Profile");
        },
      ),
    );
  }
}
