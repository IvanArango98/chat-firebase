import 'package:chat_firebase/helperfunctions/shared_helper.dart';
import 'package:chat_firebase/services/database.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class ChatScreen extends StatefulWidget {

  final String chatWithUsername,name;
  ChatScreen(this.chatWithUsername,this.name);
  @override
  ChatScreen_ createState() => ChatScreen_();  
}

class ChatScreen_ extends State<ChatScreen>{

  String chatRoomId = "",messageId = "";
  String myName = "",myProfilePic = "", myUserName = "", myEmail = "";
  TextEditingController messageTextEditingController = TextEditingController();

  getMyInfoFromSharedPreference() async{
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;

    chatRoomId = getChatRoomIdByUsernames(widget.chatWithUsername,myUserName);
  }

  getChatRoomIdByUsernames(String a,String b){
    if(a.substring(0,1).codeUnitAt(0) >  b.substring(0,1).codeUnitAt(0)){
      return "$b\_$a";
    }
    else{
      return "$a\_$b";
    }
  }

  getAndSetMessages() async {

  }

  addMessage(bool sendClicked)
  {
    if(messageTextEditingController.text != ""){
      String message = messageTextEditingController.text;  
      var lastMessageTs = DateTime.now();
      Map<String,dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic
      };

      //messageId
      if(messageId == ""){
        messageId = randomAlpha(12);
      }

      DatabaseMethods().addMessage(chatRoomId,messageId,messageInfoMap).then((value) {
        Map<String,dynamic> lastMessageInfoMap = {
            "lastMessage" : message,
            "lastMessageSendTs": lastMessageTs,
            "lastMessageSendBy": myUserName
        };  

      DatabaseMethods().updateLastMessageSend(chatRoomId, messageInfoMap);

      if(sendClicked){
        //remove the text in the message input field
        messageTextEditingController.text = "";

        //make message id blank to get regenerated on next message send
        messageId = "";

        

      }
      });
    }
  }

  doThisOnLaunch() async {
    await  getMyInfoFromSharedPreference();
  }

  @override
  void initState(){
    doThisOnLaunch();
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: 
      AppBar(title: Text(widget.name),      
      ),
      body: Container(child: 
      Stack(children: [
        Container(
          alignment: Alignment.bottomCenter,          
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            color: Colors.black.withOpacity(0.8),
            child: Row(children: [
              Expanded(child: TextField(
                style: TextStyle(color: Colors.white)
                ,decoration: InputDecoration(border: InputBorder.none,hintText: "Escribe un mensaje",hintStyle: TextStyle(color: Colors.white.withOpacity(0.6))),)),
              Icon(Icons.send,color: Colors.white,)
            ],),
          ),
        )
      ],
        ),
          ),
    );
  }

}