// ignore_for_file: prefer_const_constructors, avoid_print, empty_statements

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/pages/home_page.dart';
import 'signinsignup_page/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: FirebaseAuth.instance.currentUser != null ? HomePage() : LoginPage(),
  ));
}
