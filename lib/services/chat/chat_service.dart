import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:global_chat_app/models/message.dart';

class ChatService extends ChangeNotifier{

  // get instance of firestore and auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /*
  List<Map<String, dynamic>> =
  [
  {
    "email": test@email.com
    "id": ..
  },
  {
    "email": miller@email.com
    "id": ..
  }
  ]
  */
  // GET ALL USERS STREAM
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();

        // return user
        return user;
      }).toList();
    });
  }

  // GET ALL USERS STREAM EXCEPT BLOCKED USERS
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;
    
    return _firestore
      .collection('Users')
      .doc(currentUser!.uid)
      .collection('BlockedUsers')
      .snapshots()
      .asyncMap((snapshot) async {
        // get blocked user ids
        final blockedUserIDs = snapshot.docs.map((doc) => doc.id).toList();

        // get all users
        final usersSnapshot = await _firestore.collection('Users').get();

        // return as stream list, excluding current user and blocked users
        return usersSnapshot.docs
        .where((doc) =>
          doc.data()['email'] != currentUser.email &&
          !blockedUserIDs.contains(doc.id))
        .map((doc) => doc.data())
        .toList();
    });
  }

  // SEND MESSAGE
  Future<void> sendMessage(String receiverID, message) async {
    // get current user info
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    // construct a chat room ID for the two users (sorted to unsure uniqueness) DMS
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join("_");

    // add new message to database
    await _firestore
    .collection("chat_rooms")
    .doc(chatRoomID)
    .collection("messages")
    .add(newMessage.toMap());
  }

  // GET MESSAGE
  // TODO - translate when getting messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    // construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
    .collection("chat_rooms")
    .doc(chatRoomID)
    .collection("messages")
    .orderBy("timestamp", descending: false)
    .snapshots();
  }

  // REPORT USER
  Future<void> reportUser(String messageID, String userID) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy':currentUser!.uid,
      'messageID': messageID,
      'messageOwnerID': userID,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Reports').add(report);
  }

  // BLOCK USER
  Future<void> blockUser(String userID) async {
    final currentUser = _auth.currentUser;
    await _firestore
      .collection('Users')
      .doc(currentUser!.uid)
      .collection('BlockedUsers')
      .doc(userID)
      .set({});
    notifyListeners();
  }

  // UNBLOCK USER
  Future<void> unblockUser(String blockedUserID) async {
    final currentUser = _auth.currentUser;
    await _firestore
      .collection('Users')
      .doc(currentUser!.uid)
      .collection('BlockedUsers')
      .doc(blockedUserID)
      .delete();
  }
  // GET BLOCK USERS STREAM

  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userID) {
    return _firestore
      .collection('Users')
      .doc(userID)
      .collection('BlockedUsers')
      .snapshots()
      .asyncMap((snapshot) async {
        // get list of block user ids
        final blockedUserIDs = snapshot.docs.map((doc) => doc.id).toList();

        final userDocs = await Future.wait(
          blockedUserIDs
            .map((id) => _firestore.collection('Users').doc(id).get()),
        );
      // return as a list
      return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  // GET FOLLOWED USERS STREAM
  
}