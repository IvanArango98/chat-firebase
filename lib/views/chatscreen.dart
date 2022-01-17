import 'package:chat_firebase/helperfunctions/shared_helper.dart';
import 'package:chat_firebase/services/database.dart';
import 'package:chat_firebase/views/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {

  final String chatWithUsername,name,ProfilePicture;
  ChatScreen(this.chatWithUsername,this.name,this.ProfilePicture);
  @override
  ChatScreen_ createState() => ChatScreen_();  
}

class ChatScreen_ extends State<ChatScreen>{

  String chatRoomId = "",messageId = "";
  String myName = "",myProfilePic = "", myUserName = "", myEmail = "";
  bool isInitialized = false;
  TextEditingController messageTextEdittingController = TextEditingController();
  late Stream messageStream;

  getMyInfoFromSharedPreference() async{
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;
    chatRoomId = getChatRoomIdByUsernames(widget.chatWithUsername,myUserName);
  }

 String getChatRoomIdByUsernames(String a, String b) {
    String res = a + "\_" + b;
     return res;
  }

  getAndSetMessages() async {
    isInitialized = true;
    setState(() {      
    });  
    messageStream = await DatabaseMethods().getChatRoomMessages(chatRoomId);
    setState(() {      
    });    
  }


  addMessage(bool sendClicked)  {
    if (messageTextEdittingController.text != "") {
      String message = messageTextEdittingController.text;

      var lastMessageTs = DateTime.now();

      Map<String, dynamic> messageInfoMap = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic
      };

      //messageId
      if (messageId == "") {
        messageId = randomAlphaNumeric(12);
      }

      DatabaseMethods()
          .addMessage(chatRoomId, messageId, messageInfoMap)
          .then((value)  {
        Map<String, dynamic> lastMessageInfoMap = {
          "users": [myUserName,widget.chatWithUsername,'Envía ${myUserName}'],
          "lastMessage": message.toString(),
          "lastMessageSendTs": lastMessageTs.toString(),
          "lastMessageSendBy": myUserName.toString()
        };
        
        DatabaseMethods().updateLastMessageSend(getChatRoomIdByUsernames(myUserName,widget.chatWithUsername), lastMessageInfoMap).then((_) => print('Updated xd')).catchError((error) => print('Update xd failed: $error'));;        

        if (sendClicked) {
          addAnotherMessage(message);
          // remove the text in the message input field
          messageTextEdittingController.text = "";
          // make message id blank to get regenerated on next message send
          messageId = "";
        }
      });      
    }
  }

  doThisOnLaunch() async {
    await  getMyInfoFromSharedPreference();
    getAndSetMessages();
  }

  addAnotherMessage(String message)
  {
    String IdRoom = getChatRoomIdByUsernames(myUserName,widget.chatWithUsername);
     var lastMessageTs = DateTime.now();
     String messageId_ = randomAlphaNumeric(12);

    Map<String, dynamic> messageInfoMap_ = {
        "message": message,
        "sendBy": myUserName,
        "ts": lastMessageTs,
        "imgUrl": myProfilePic
      };

      DatabaseMethods()
          .addMessage(IdRoom, messageId_, messageInfoMap_)
          .then((value)  {
        Map<String, dynamic> lastMessageInfoMap = {
          "users": [widget.chatWithUsername,myUserName,'Envía ${widget.chatWithUsername}'],
          "lastMessage": message.toString(),
          "lastMessageSendTs": lastMessageTs.toString(),
          "lastMessageSendBy": myUserName.toString()
        };
        
        DatabaseMethods().updateLastMessageSend(getChatRoomIdByUsernames(widget.chatWithUsername,myUserName), lastMessageInfoMap).then((_) => print('Updated xd')).catchError((error) => print('Update xd failed: $error'));;
      });  

  }

  @override
  void initState(){
    doThisOnLaunch();
    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(   
          leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.white),
    onPressed: () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home())),
        ),      
        title: Row(
           mainAxisAlignment: MainAxisAlignment.start,           
          children: [                    
          ClipRRect(
          borderRadius: BorderRadius.circular(20),child: Image.network(widget.ProfilePicture,width: 30,height: 30)),
          SizedBox(width: 5,),
          Text(widget.name,style: TextStyle(fontSize: 17),),
        ],),          
      ),
      body: Container(
        child: Stack(
          children: [ 
            isInitialized ?
            chatMessages() : Container(),           
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black.withOpacity(0.8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageTextEdittingController,
                      onChanged: (value) {
                        addMessage(false);
                      },
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Escribe tu mensaje",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.6))),
                    )),
                    GestureDetector(
                      onTap: () {
                        addMessage(true);
                      },
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget chatMessages()
  {
    return StreamBuilder(
      stream: messageStream,
      builder: (BuildContext context, AsyncSnapshot snapshot){
        return snapshot.hasData ? ListView.builder(
          padding: EdgeInsets.only(bottom: 70),
          itemCount: snapshot.data.docs.length,
          reverse: true,
          //physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context,index){
            DocumentSnapshot ds = snapshot.data.docs[index];
            return chatMessageTitle(ds["message"],myUserName == ds["sendBy"] ? true : false,ds["ts"]);
          },
        ) : Center(child:CircularProgressIndicator());
      }
    );
  }

  Widget chatMessageTitle(String message,bool sendByMe,Timestamp hora){    
      DateTime enviado = DateTime.parse(hora.toDate().toString());
    String formattedTime = DateFormat.jm().format(enviado);
    return Row(
      mainAxisAlignment: sendByMe ? MainAxisAlignment.end : MainAxisAlignment.start,      
      children: [
        Container( 
          constraints: BoxConstraints(minWidth: 0, maxWidth: 300),                         
          margin: EdgeInsets.symmetric(horizontal: 16,vertical: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: sendByMe ? Radius.circular(0) : Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: sendByMe ? Radius.circular(20) : Radius.circular(0)           
            ),color: sendByMe ? Colors.blue : Colors.blueGrey),      
          padding: EdgeInsets.all(16),
          child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.end
            ,children: [
            Text(message,style: TextStyle(color: Colors.white),),
            Text(formattedTime,style: TextStyle(color: Colors.white,fontSize:9),)                               
          ],)          
        ),
      ],
    );
  }  

}