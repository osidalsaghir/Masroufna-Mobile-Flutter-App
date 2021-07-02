import "package:flutter/material.dart";
import 'package:masroufna/theme/colorsMasroufna.dart';
import 'package:masroufna/backend/firebaseController.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();

  String _email;
  String _password;
  String _firstName;
  String _lastName;

  Future signUp(BuildContext context) async {
    final formState = _signUpFormKey.currentState;
    if (formState.validate()) {
      formState.save();
      FireBase signUp = FireBase(
          email: _email,
          password: _password,
          name: _firstName,
          surname: _lastName,
          context: context);
      signUp.signUp();
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData deviceQ = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: MasroufnaColors.blackgrey,
      body: SafeArea(
        top: true,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: MasroufnaColors.blackgrey,
                  ),
                  height: deviceQ.size.height / 6,
                  width: deviceQ.size.height / 6,
                  child: Center(
                      child: Image(
                    image: AssetImage('assets/logo1.png'),
                  )),
                ),
                Padding(
                  padding: EdgeInsets.all(30),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: MasroufnaColors.blackgrey,
                  ),
                  height: deviceQ.size.height / 3,
                  width: deviceQ.size.width - 20,
                  child: Center(
                      child: Form(
                    key: _signUpFormKey,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Flexible(
                                child: new TextFormField(
                              style: TextStyle(color: Colors.white),
                              onSaved: (input) => _firstName = input,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderSide: BorderSide(
                                      color: Colors.orange, width: 1.0),
                                ),
                                labelText: 'First Name',
                                labelStyle:
                                    TextStyle(color: MasroufnaColors.orang),
                              ),
                            )),
                            SizedBox(
                              width: 10.0,
                            ),
                            new Flexible(
                                child: new TextFormField(
                              style: TextStyle(color: Colors.white),
                              onSaved: (input) => _lastName = input,
                              decoration: InputDecoration(
                                border: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderSide: BorderSide(
                                      color: Colors.grey, width: 0.0),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  // width: 0.0 produces a thin "hairline" border
                                  borderSide: BorderSide(
                                      color: Colors.orange, width: 1.0),
                                ),
                                labelText: 'Last Name',
                                labelStyle:
                                    TextStyle(color: MasroufnaColors.orang),
                              ),
                            )),
                            SizedBox(
                              width: 0.0,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          onSaved: (input) => _email = input,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.mail,
                              color: Colors.white,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 0.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.orange, width: 1.0),
                            ),
                            labelText: 'USERNAME',
                            labelStyle: TextStyle(color: MasroufnaColors.orang),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          onSaved: (input) => _password = input,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(
                              Icons.dialpad,
                              color: Colors.white,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 0.0),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              // width: 0.0 produces a thin "hairline" border
                              borderSide:
                                  BorderSide(color: Colors.orange, width: 1.0),
                            ),
                            labelText: 'PASSWORD',
                            labelStyle: TextStyle(color: MasroufnaColors.orang),
                          ),
                        ),
                      ],
                    ),
                  )),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: MasroufnaColors.blackgrey,
                  ),
                  height: deviceQ.size.height / 4,
                  width: deviceQ.size.width - 10,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ButtonTheme(
                          minWidth: 110.0,
                          height: 45.0,
                          child: RaisedButton(
                            child: Text("SingUp"),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            onPressed: () => signUp(context),
                            color: MasroufnaColors.orang,
                            textColor: Colors.black87,
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            splashColor: MasroufnaColors.blackgrey,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
