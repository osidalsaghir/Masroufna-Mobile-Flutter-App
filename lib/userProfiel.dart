import 'package:firebase_database/firebase_database.dart';
import "package:flutter/material.dart";
import 'package:masroufna/backend/firebaseController.dart';
import 'package:masroufna/theme/colorsMasroufna.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:masroufna/transtionsScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool wait = true;
  double amount = 0.0;

  var amountController = new TextEditingController();

  @override
  void initState() {
    getImage();
    super.initState();
  }

  var _image;
  File newfile;
  final picker = ImagePicker();
  Future<void> setImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      newfile = File(pickedFile.path);
      wait = true;
    });
    if (pickedFile != null) {
      try {
        var user;
        await FirebaseAuth.instance.currentUser().then((value) => user = value);

        await firebase_storage.FirebaseStorage.instance
            .ref()
            .child(user.email.toString())
            .putFile(newfile)
            .onComplete;

        final databaseReference = FirebaseDatabase.instance.reference();
        await databaseReference
            .child("Users")
            .child(user.uid)
            .child("picture")
            .set(1);
      } catch (e) {} finally {
        await getImage();
      }
    } else {
      print('No image selected.');
    }
  }

  Future<void> getImage() async {
    setState(() {
      _image = null;
      getMonryBalance();
      wait = true;
    });
    Directory appDocDir = await getApplicationDocumentsDirectory();

    try {
      var user;
      var pic = 0;
      await FirebaseAuth.instance.currentUser().then((value) => user = value);
      try {
        final databaseReference = FirebaseDatabase.instance.reference();
        await databaseReference
            .child("Users")
            .child(user.uid)
            .child("picture")
            .once()
            .then((value) {
          pic = value.value;
        });
      } catch (e) {
        print(e);
      }
      if (pic == 1) {
        var url = null;
        await firebase_storage.FirebaseStorage.instance
            .ref()
            .child(user.email.toString())
            .getDownloadURL()
            .then((value) {
          url = value.toString();
        });
        setState(() {
          _image = url;
          wait = false;
        });
      } else {
        setState(() {
          _image = null;
          wait = false;
        });
      }
    } catch (e) {
      print("catch");

      setState(() {
        wait = false;
      });
    }
  }

  getMonryBalance() async {
    FireBase fb = new FireBase();
    amount = await fb.currentUserAmount();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var device = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: device.width,
          height: device.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.only(top: 15)),
                  wait
                      ? Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1000)),
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
                          ))
                      : Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  alignment: Alignment.center,
                                  fit: BoxFit.fill,
                                  image: _image != null
                                      ? NetworkImage(_image)
                                      : AssetImage("assets/avatar.png")),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(1000)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: MasroufnaColors.orang,
                                        borderRadius:
                                            BorderRadius.circular(1000)),
                                    width: 50,
                                    height: 50,
                                    child: IconButton(
                                        icon: Icon(
                                          Icons.photo_camera,
                                          color: Colors.white,
                                        ),
                                        onPressed: () async {
                                          await setImage();
                                        }),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                  Text("Account Balance : " + amount.toString() + " TL",
                      style: TextStyle(
                          color: MasroufnaColors.orang, fontSize: 24)),
                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                  Column(
                    children: [
                      TextButton(
                        onPressed: () {
                          _showMyDialog(context)
                              .then((value) => getMonryBalance());
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.add,
                              color: MasroufnaColors.orang,
                              size: 30,
                            ),
                            Padding(padding: EdgeInsets.only(right: 5)),
                            Text(
                              "Add Balance",
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => Transitions()),
                          );
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.compare_arrows_rounded,
                              color: MasroufnaColors.orang,
                              size: 30,
                            ),
                            Padding(padding: EdgeInsets.only(right: 5)),
                            Text(
                              "Transtions",
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton(
                        onPressed: () {
                          print("Withdraw");
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_money_rounded,
                              color: MasroufnaColors.orang,
                              size: 30,
                            ),
                            Padding(padding: EdgeInsets.only(right: 5)),
                            Text(
                              "Withdraw",
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                  TextButton(
                      style: ButtonStyle(),
                      onPressed: () => print("new"),
                      child: Row(
                        children: [
                          Icon(
                            Icons.exit_to_app,
                            color: MasroufnaColors.orang,
                            size: 30,
                          ),
                          Padding(padding: EdgeInsets.only(right: 5)),
                          Text(
                            "Sign Out",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        ],
                      )),
                  Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showMyDialog(context) async {
  var amountController = new TextEditingController();
  double newAmount = 0.0;
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          width: 70,
          height: 250,
          color: Colors.transparent,
          child: Column(
            children: [
              Center(
                child: Icon(
                  Icons.add_box_rounded,
                  size: 60,
                  color: MasroufnaColors.orang,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text("Enter a balance to add to your account",
                  textAlign: TextAlign.center),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  newAmount = double.parse(value);
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 0)),
                  border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 0)),
                  fillColor: Colors.black,
                  prefixIcon: Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.transparent, width: 0)),
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: MasroufnaColors.orang),
                  disabledBorder: InputBorder.none,
                  prefixStyle: TextStyle(color: Colors.transparent),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(color: MasroufnaColors.orang, fontSize: 20),
              ),
              onPressed: () async {
                FireBase fb = new FireBase();
                await fb.addBalance(newAmount);
                amountController.clear();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}
