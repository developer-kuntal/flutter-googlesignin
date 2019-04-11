import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_firebaseauth/new_page.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: new ThemeData(
        primarySwatch: Colors.amber,
        primaryColor: defaultTargetPlatform == TargetPlatform.iOS ? Colors.grey[50]:null
    ),
    home: MyMainPage(),
  ));
}

class MyMainPage extends StatefulWidget {
  @override
  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _gSignIn = new GoogleSignIn( );
  bool isLogged = false;
  double myOpacity = 1.0;
  FirebaseUser myUser;

  Future<FirebaseUser> _loginWithGoogle() async {
    GoogleSignInAccount googleSignInAccount = await _gSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);
    print("signed in " + user.displayName);
    return user;
  }

  void _logOut() async {
    await _auth.signOut().then((response) {
      isLogged = false;
      setState(() { });
    });
    await _gSignIn.signOut();
  }

  void _logIn() {
     _loginWithGoogle().then((response) {
      if(response != null) {
        myUser = response;
        isLogged = true;
        setState(() { });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text(isLogged ? "Drawer App" : "Sign In Page"),
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.power_settings_new),
            onPressed: _logOut,
          )
        ],
      ),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text(isLogged ? myUser.displayName: "<Name>" ),
              accountEmail: new Text(isLogged ?  myUser.email: "<example@gmail.com>"),
              currentAccountPicture: new CircleAvatar(
                backgroundColor: Theme.of(context).platform == TargetPlatform.iOS?Colors.amber:Colors.white,
                child: isLogged ? Image.network( myUser.photoUrl ) : new Text("<>"), //,
              ),
              // otherAccountsPictures: <Widget>[
              //   new CircleAvatar(
              //     backgroundColor: Colors.brown,
              //     child: new Text("P"),
              //   )
              // ],
            ),
            new ListTile(
              title: new Text("Page One"),
              trailing: new Icon(Icons.arrow_downward),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new NewPage("Page One")));
              }
            ),
            new ListTile(
              title: new Text("Page Two"),
              trailing: new Icon(Icons.arrow_downward),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context)=>new NewPage("Page Two")));
              }
            ),
            new Divider(),
            new ListTile(
              title: new Text("Close"),
              trailing: new Icon(Icons.close),
              onTap: () => Navigator.of(context).pop(),
            )
          ],
        ),
      ),
      body: Center(
        child: isLogged ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text("Name: "+ myUser.displayName),
            // CircleAvatar( 
            //   child:Image.network(myUser.photoUrl)
            // ),
            AnimatedOpacity(
              child: FlutterLogo(size: 100.0,),
              opacity: myOpacity,
              duration: Duration(seconds: 1),
            ),    
            RaisedButton(
              child: new Text("Click Here to Change The Opacity",
                style: TextStyle(color: Colors.blue,fontSize: 10.0),
              ),
              onPressed: () {
                myOpacity = 0.1;
                setState(() {});
              },
            )
          ],
        ) : GoogleSignInButton(onPressed: _logIn),
      ),
    );
  }
}