// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, avoid_print, curly_braces_in_flow_control_structures

import 'dart:io';

import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/service/auth.dart';
import 'package:message_app/pages/home_page.dart';
import 'package:message_app/service/database.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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

  Future<bool> signup() async {
    String imageurl;
    AuthMethods()
        .signUp(emailController.text, passwordController.text)
        .then((value) async {
      if (value != null) {
        String filename = basename(image!.path);
        final FirebaseStorage storage = FirebaseStorage.instance;
        try {
          var ref = storage.ref().child('avt/$filename');
          UploadTask uploadTask = ref.putFile(image!);
          uploadTask.snapshot.ref.getDownloadURL().then((value) {
            imageurl = value;
          });
        } on FirebaseException catch (e) {
          print(e);
        }
        imageurl = storage.ref('avt/$image.name').getDownloadURL().toString();
        DatabaseService().createUserData(
            value.uid, usernameController.text, emailController.text, imageurl);
        return true;
      } else {
        print(value.toString());
        return false;
      }
    });
    return false;
  }

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "Sign Up",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              textAlign: TextAlign.center,
            ),
          ),
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
          Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(top: 10, left: 30),
              child: Text(
                "Username",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              )),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: usernameController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(top: 10, left: 30),
              child: Text(
                "Email",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              )),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(top: 10, left: 30),
              child: Text(
                "Password",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              )),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 1,
              width: 1,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an Account?",
                  style: TextStyle(fontSize: 13),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(fontSize: 13),
                    ))
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 10),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () async {
                    // ignore: unrelated_type_equality_checks
                    String? imageurl;
                    AuthMethods()
                        .signUp(emailController.text, passwordController.text)
                        .then((value) async {
                      if (value != null) {
                        String filename = basename(image!.path);
                        final FirebaseStorage storage =
                            FirebaseStorage.instance;
                        try {
                          var ref = storage.ref().child('avt/$filename');
                          TaskSnapshot uploadTask = await ref.putFile(image!);
                          if (uploadTask.state == TaskState.success) {
                            imageurl = await ref.getDownloadURL();
                          }
                        } on FirebaseException catch (e) {
                          print(e);
                        }
                        DatabaseService().createUserData(
                            value.uid,
                            usernameController.text,
                            emailController.text,
                            imageurl!);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                            (route) => false);
                      } else {
                        print(value.toString());
                      }
                    });
                  },
                  child: Text("Sign Up")))
        ],
      ),
    ));
  }
}
