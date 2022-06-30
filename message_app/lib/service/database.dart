import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  Future createUserData(
      String uid, String username, String email, String imageurl) async {
    final CollectionReference userCollection =
        FirebaseFirestore.instance.collection("Users");
    return await userCollection
        .doc(uid)
        .set({'username': username, 'email': email, 'imageurl': imageurl});
  }

  searchUserByname(String name) async {
    return FirebaseFirestore.instance
        .collection('Users')
        .where('username', isEqualTo: name)
        .get();
  }

  getInfoUser(String uid) async {
    return FirebaseFirestore.instance.collection('Users').doc(uid).get();
  }

  findChat(String uid1, String uid2) async {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('users', isEqualTo: {uid1: null, uid2: null})
        .limit(1)
        .get();
  }

  createNewChat(String uid1, String uid2) async {
    return FirebaseFirestore.instance.collection('chats').add({
      'users': {uid1: null, uid2: null}
    }).then((value) => value.id);
  }
}
