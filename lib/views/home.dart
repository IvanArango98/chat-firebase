import 'package:chat_firebase/services/auth.dart';
import 'package:chat_firebase/services/database.dart';
import 'package:chat_firebase/views/chatscreen.dart';
import 'package:chat_firebase/views/signin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSearching = false;
  bool isIntializate = false;
  bool isGetting = false;
  bool hasData_ = false;
  String myName = "", myProfilePic = "", myUserName = "", myEmail = "";
  static String userIdKey = "USERIDKEY";
  static String userNameKey = "USERNAMEKEY";
  static String displayNameKey = "USERDISPLAYNAME";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfilePicKey = "USERPROFILEKEY";

  late AsyncSnapshot snapshot_;
  late Stream usersStream, chatRoomsStream;

  TextEditingController searchUsernameEditingController =
      TextEditingController();

  _HomeState()  {
     GetUserName().then((value) => setState(() {
      myUserName = value;
    }));

    GetmyEmail().then((value) => setState(() {
      myEmail = value;
    }) );

     GetName().then((value) => setState(() {
      myName = value;
    }));
    
     GetmyProfilePic().then((value) => setState(() {
      myProfilePic = value;
       isGetting = true;
    }));

  }

  Future<String> GetmyEmail() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String myEmail_ = prefs.getString(userEmailKey).toString();   
   return myEmail_;
  }

  Future<String> GetUserName() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String myUserName_ = prefs.getString(userNameKey).toString();   
    return myUserName_;
  }

  Future<String> GetmyProfilePic() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String myProfilePic = prefs.getString(userProfilePicKey).toString();   
    return myProfilePic;
  }

  Future<String> GetName() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String myName_ = prefs.getString(displayNameKey).toString();   
    return myName_;
  }

  String getChatRoomIdByUsernames(String a, String b) {    
    String res = a + "\_" + b;
     return res;
  }


  onSearchBtnClick() async {
    isSearching = true;
    setState(() {});
    usersStream = await DatabaseMethods()
        .getUserByUserName(searchUsernameEditingController.text);

    setState(() {});
  }

  ValidateSnapShot(AsyncSnapshot snapshot) async
  {
     if(snapshot.hasData) {
          hasData_ = true;
          snapshot_ = snapshot;
        setState(() {});
        }
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {

        ValidateSnapShot(snapshot);              
        bool _hasData = (snapshot.hasData &&  hasData_) ? true : 
        (!snapshot.hasData &&  hasData_) ? true : (snapshot.hasData &&  !hasData_) ? true : false;       

        return _hasData
            ?  ListView.builder            
            (
                itemCount: snapshot_.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot_.data.docs[index];
                  print('AQUI $ds');
                  return ChatRoomListTile(ds["lastMessage"], ds.id, myUserName);
                })
            : Center(child: Text("Sin mensajes aún."));
      },
    );
  }

  Widget searchListUserTile({required String profileUrl, name, username, email}) {
    return GestureDetector(
      onTap: () {
        String chatRoomId = getChatRoomIdByUsernames(myUserName, username);
        print('ID 1: $chatRoomId');
        Map<String, dynamic> chatRoomInfoMap = {
          "users": [myUserName, username,'Envía $myUserName']
        };
        
        String chatRoomId2 = getChatRoomIdByUsernames(username,myUserName);
        print('ID 2: $chatRoomId2');
        Map<String, dynamic> chatRoomInfoMap2 = {
          "users": [username,myUserName,'Envía $username']
        };

        DatabaseMethods().createChatRoom(chatRoomId, chatRoomInfoMap);
        DatabaseMethods().createChatRoom(chatRoomId2, chatRoomInfoMap2);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name,profileUrl)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.network(
                profileUrl,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 12),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(name), Text(email)])
          ],
        ),
      ),
    );
  }

  Widget searchUsersList() {
    return StreamBuilder(
      stream: usersStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return searchListUserTile(
                      profileUrl: ds["imgUrl"],
                      name: ds["name"],
                      email: ds["email"],
                      username: ds["username"]);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  getChatRooms() async {
    chatRoomsStream = await DatabaseMethods().getChatRooms(this.myUserName);
    setState(() {});

    isIntializate = true;
    setState(() {});    
  }

  onScreenLoaded() async {
    if(isGetting)
    {    
    if(!isIntializate) {getChatRooms();}
    }
  }

  @override
  void initState() {
    _HomeState();
    onScreenLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido $myUserName'),
        actions: [
          InkWell(
            onTap: () {
              AuthMethods().signOut().then((s) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => SignIn()));
              });
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)),
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Row(
              children: [
                isSearching
                    ? GestureDetector(
                        onTap: () {
                          isSearching = false;
                          searchUsernameEditingController.text = "";
                          setState(() {});
                        },
                        child: Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.arrow_back)),
                      )
                    : Container(),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey,
                            width: 1,
                            style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                          controller: searchUsernameEditingController,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: "username"),
                        )),
                        GestureDetector(
                            onTap: () {
                              if (searchUsernameEditingController.text != "") {
                                onSearchBtnClick();
                              }
                            },
                            child: Icon(Icons.search))
                      ],
                    ),
                  ),
                ),
              ],
            ),
            isSearching ? searchUsersList() : 
            isIntializate ?
            chatRoomsList() : Container() 
          ],
        ),
      ),
    );
  }
}

class ChatRoomListTile extends StatefulWidget {
  final String lastMessage, chatRoomId, myUsername;
  ChatRoomListTile(this.lastMessage, this.chatRoomId, this.myUsername);

  @override
  _ChatRoomListTileState createState() => _ChatRoomListTileState();
}

class _ChatRoomListTileState extends State<ChatRoomListTile> {
  String profilePicUrl = "", name = "", username = "";

  getThisUserInfo() async {
    username =
        widget.chatRoomId.replaceAll(widget.myUsername, "").replaceAll("_", "");
    QuerySnapshot querySnapshot = await DatabaseMethods().getUserInfo(username);
    name = "${querySnapshot.docs[0]["name"]}";
    profilePicUrl = "${querySnapshot.docs[0]["imgUrl"]}";
    setState(() {});
  }

  @override
  void initState() {
    getThisUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(username, name,profilePicUrl)));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: 
              profilePicUrl.length > 0 ?
              Image.network(
                profilePicUrl,
                height: 40,
                width: 40,
              ) : CircularProgressIndicator(),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 3),
                Text(widget.lastMessage)
              ],
            )
          ],
        ),
      ),
    );
  }
}