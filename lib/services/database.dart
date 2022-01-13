import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseMethods{

  //agregar usuarios a una coleccion
  Future addUserInfoToDB(String userId,Map<String,dynamic>  userInfoMap) async
  {
    return FirebaseFirestore.instance.collection('users').doc(userId).set(userInfoMap);
  }

  //encontrar un usuario
  Future<Stream<QuerySnapshot>> getUserByUserName(String username) async {
    return FirebaseFirestore.instance.collection("users").where("username",isEqualTo: username).snapshots();
  }

  Future addMessage(String chatRoomid,String messageId,Map<String,dynamic> messageInfoMap) async {
    return FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomid).collection("chats").doc(messageId).set(messageInfoMap);
  }

  updateLastMessageSend(String chatRoomId,Map<String,dynamic> messageInfoMap) async
  {
    return FirebaseFirestore.instance.collection('chatrooms').doc(chatRoomId).update(messageInfoMap);
  }

  createChatRoom(String chatRoomId,Map<String,dynamic> chatRoomInfoMap) async {
    final snapShot = await FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).get();

    if(snapShot.exists){
      //chatroom already exist
      return true;
    }
    else{
      //chatroom does not existe
      return FirebaseFirestore.instance.collection("chatrooms").doc(chatRoomId).set(chatRoomInfoMap);
    }
  }

}