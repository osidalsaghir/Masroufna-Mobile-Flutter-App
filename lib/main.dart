import 'package:firebase_database/firebase_database.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:masroufna/backend/firebaseController.dart';
import 'package:masroufna/signupScreen.dart';
import 'dashboardScreen.dart';
import 'theme/colorsMasroufna.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() => runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      primaryColor: MasroufnaColors.orang,
      accentColor: Colors.cyan[600],
      textTheme: TextTheme(
        headline1: TextStyle(color: Colors.white),
        headline6: TextStyle(color: Colors.white),
        bodyText2: TextStyle(color: Colors.white),
      ),
    ),
    home: MainMasroufna()));

class MainMasroufna extends StatefulWidget {
  @override
  _MainMasroufnaState createState() {
    return _MainMasroufnaState();
  }
}

final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();

String _email;
String _password;
bool wait = true;

class _MainMasroufnaState extends State<MainMasroufna> {
  Future<void> signIn(contextC) async {
    final formState = _loginFormKey.currentState;
    if (formState.validate()) {
      formState.save();

      FireBase login = new FireBase(email: _email, password: _password);

      String done = await login.signIn();
      if (done != "") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return Dashboard(
              userName: _email,
              desplayname: done,
            );
          }),
        );
      } else {
        showDialog(
            context: context,
            builder: (_) {
              return EroorDialog(
                  error: "\nCheck Email and Password\nand then try again");
            });
      }
    } else {
      setState(() {
        wait = false;
      });
    }
    setState(() {
      wait = false;
    });
  }

  String textValue = 'Hello World !';
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    checkAuth();
    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);
    flutterLocalNotificationsPlugin.initialize(platform);

    firebaseMessaging.configure(
      onLaunch: (Map<String, dynamic> msg) {
        showNotification(msg);
        print(" onLaunch called ${(msg)}");
      },
      onResume: (Map<String, dynamic> msg) {
        showNotification(msg);
        print(" onResume called ${(msg)}");
      },
      onMessage: (Map<String, dynamic> msg) {
        showNotification(msg);
        print(" onMessage called ${(msg)}");
      },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, alert: true, badge: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings setting) {
      print('IOS Setting Registed');
    });
    firebaseMessaging.getToken().then((token) {
      update(token);
    });
  }

  Future<void> checkAuth() async {
    FireBase check = new FireBase();
    var ls = await check.isthereCurrentUser();
    if (ls.first != "" && ls.last != "") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return Dashboard(
            userName: ls.first,
            desplayname: ls.last,
          );
        }),
      );
    } else {
      setState(() {
        wait = false;
      });
    }
  }

  showNotification(Map<String, dynamic> msg) async {
    var android = new AndroidNotificationDetails(
      'sdffds dsffds',
      "CHANNLE NAME",
      "channelDescription",
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, msg["notification"]["title"], msg["notification"]["body"], platform);
  }

  update(String token) {
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    databaseReference.child('fcm-token/${token}').set({"token": token});
    textValue = token;
    setState(() {});
  }

  Widget build(BuildContext context) {
    var deviceQ = MediaQuery.of(context);
    return wait
        ? Scaffold(
            body: SafeArea(
              child: Container(
                child: Center(
                  child: SpinKitWave(
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: index.isEven
                              ? MasroufnaColors.orang
                              : MasroufnaColors.blackgrey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        : Builder(
            builder: (context) => Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: MasroufnaColors.blackgrey,
              body: SafeArea(
                top: true,
                child: Container(
                  width: deviceQ.size.width,
                  height: deviceQ.size.height,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: MasroufnaColors.blackgrey,
                            ),
                            height: deviceQ.size.height / 4,
                            width: deviceQ.size.height / 4,
                            child: Center(
                                child: Image(
                              image: AssetImage('assets/logoWhite.png'),
                            )),
                          ),
                          Container(
                              decoration: BoxDecoration(
                                color: MasroufnaColors.blackgrey,
                              ),
                              height: deviceQ.size.height / 12,
                              width: deviceQ.size.height / 3,
                              child: Center(
                                  child: TextButton(
                                child: Text(
                                  "Masroufna Finance Managment",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: MasroufnaColors.orang,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
                              ))),
                          Padding(
                            padding: EdgeInsets.all(15),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: MasroufnaColors.blackgrey,
                              boxShadow: [
                                new BoxShadow(
                                  color: MasroufnaColors.blackgrey,
                                  offset: Offset(0.0, 0.0),
                                )
                              ],
                            ),
                            height: deviceQ.size.height / 4,
                            width: deviceQ.size.width - 60,
                            child: Center(
                                child: Form(
                              key: _loginFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    style: TextStyle(color: Colors.white),
                                    onSaved: (input) => _email = input,
                                    decoration: InputDecoration(
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1)),
                                      fillColor: Colors.transparent,
                                      prefixIcon: Icon(
                                        Icons.mail_outline,
                                        color: Colors.white,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MasroufnaColors.orang,
                                              width: 1)),
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                          color: MasroufnaColors.orang),
                                      disabledBorder: InputBorder.none,
                                      prefixStyle:
                                          TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    obscureText: true,
                                    style: TextStyle(color: Colors.white),
                                    onSaved: (input) => _password = input,
                                    decoration: InputDecoration(
                                      border: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 1)),
                                      fillColor: Colors.transparent,
                                      prefixIcon: Icon(
                                        Icons.lock_open_outlined,
                                        color: Colors.white,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: MasroufnaColors.orang,
                                              width: 1)),
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                          color: MasroufnaColors.orang),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: MasroufnaColors.blackgrey,
                              boxShadow: [
                                BoxShadow(
                                  color: MasroufnaColors.blackgrey,
                                  offset: Offset(0.0, 0.0),
                                )
                              ],
                            ),
                            height: deviceQ.size.height / 8,
                            width: deviceQ.size.width - 10,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                ButtonTheme(
                                  minWidth: 110.0,
                                  height: 45.0,
                                  child: RaisedButton(
                                    child: Text("LOGIN"),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    onPressed: () {
                                      setState(() {
                                        wait = true;
                                      });
                                      signIn(context);
                                    },
                                    color: MasroufnaColors.orang,
                                    textColor: Colors.black87,
                                    padding: EdgeInsets.fromLTRB(10, 5, 10, 10),
                                    splashColor: MasroufnaColors.grey,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      "If you don't have an account please",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    ButtonTheme(
                                      child: TextButton(
                                        child: Text(
                                          "Sign Up",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: MasroufnaColors.orang),
                                        ),
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SignUp()),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}

class EroorDialog extends StatefulWidget {
  final String error;
  EroorDialog({this.error});
  @override
  _EroorDialogState createState() => new _EroorDialogState(error: this.error);
}

class _EroorDialogState extends State<EroorDialog> {
  final String error;
  _EroorDialogState({this.error});
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK", style: TextStyle(color: Colors.black)))
      ],
      title: null,
      backgroundColor: MasroufnaColors.orang,
      contentPadding: EdgeInsets.all(0),
      content: Container(
        color: Colors.transparent,
        width: 100,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Icon(
                  Icons.error,
                  color: Colors.black,
                  size: 40,
                )),
              ],
            )),
            SizedBox(
              height: 15,
            ),
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Text(this.error,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center)),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
