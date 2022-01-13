import 'package:chat_firebase/helperfunctions/shared_helper.dart';
import 'package:chat_firebase/services/auth.dart';
import 'package:chat_firebase/services/database.dart';
import 'package:chat_firebase/views/chatscreen.dart';
import 'package:chat_firebase/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isSearching = false;
  TextEditingController searchUsernameEditingController = TextEditingController();  
  String myName = "",myProfilePic = "", myUserName = "", myEmail = "";

  @override
  void initState(){
    getMyInfoFromSharedPreference();
    super.initState();
  }
  

   getMyInfoFromSharedPreference() async{
    myName = (await SharedPreferenceHelper().getDisplayName())!;
    myProfilePic = (await SharedPreferenceHelper().getUserProfileUrl())!;
    myUserName = (await SharedPreferenceHelper().getUserName())!;
    myEmail = (await SharedPreferenceHelper().getUserEmail())!;    
    setState(() {});
  }  

    onSearchBtnClick() async {
    isSearching = true;
    setState(() {});  
  }

   getChatRoomIdByUsernames(String a,String b){
    if(a.substring(0,1).codeUnitAt(0) >  b.substring(0,1).codeUnitAt(0)){
      return "$b\_$a";
    }
    else{
      return "$a\_$b";
    }
  }

  Widget searchListUserTitle({required String profileUrl,name,username,email}){
    return GestureDetector(
      onTap: (){
        print('this is the value we have haha $myUserName || $username');
        var chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        Map<String,dynamic> chatRoomInfoMap = {
          "users": [myUserName,username]
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(username,name)));
      },
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(40),child: Image.network(profileUrl,width: 40,height: 40,)),
        SizedBox(width: 12,),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(name),
          Text(email)
        ],)
      ],),
    );
  }

   Widget searchUsersList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("users").where("username",isEqualTo: searchUsernameEditingController.text).snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {                              
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTitle(                    
                    profileUrl : ds["imgUrl"].toString(),name : ds["name"].toString(),username: ds["username"].toString(),email : ds["email"].toString());
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
  

  Widget chatRoomsList(){
    return Container();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: 
      Text("Messagle clone"),
      actions: [InkWell(
        onTap: (){AuthMethods().signOut().then((s) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn() ));
        } ); }
        ,
        child: Container(
          child: Icon(Icons.exit_to_app),
          padding: EdgeInsets.symmetric(horizontal: 16),
          
          ),
      )],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),        
        child: Column(children: [        
        Row(
          children: [
            isSearching ?
            GestureDetector(
              onTap: () {setState(() {
                isSearching = false;
                searchUsernameEditingController.text = "";
              });},
              child: Padding(
                padding: EdgeInsets.only(right: 12)
                ,child: Icon(Icons.arrow_back)),
            ) : Container(),            
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 16),
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(border: Border.all(color: Colors.black87,width: 1.0,style: BorderStyle.solid,),
                borderRadius: BorderRadius.circular(20)          
                ),
                child: Row(children: [
                Expanded(child: TextField(controller: searchUsernameEditingController,decoration: InputDecoration(border: InputBorder.none,hintText: "username"),)), 
                GestureDetector(                  
                  onTap: (){                    
                    if(searchUsernameEditingController.text != ""){
                      onSearchBtnClick();                   
                    }                                        
                  }
                  ,child: Icon(Icons.search))],),
              ),
            ),
          ],
        ),
        isSearching ? searchUsersList() : chatRoomsList()
        ],),),
    );
  }

}