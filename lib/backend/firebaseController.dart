import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masroufna/data/roomDataList.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../data/InvoicesData.dart';
import '../data/UserListData.dart';
import '../dashboardScreen.dart';
import '../main.dart';

class FireBase {
  final String email;
  final String roomName;
  final String password;
  final BuildContext context;
  final List<dynamic> roomMembers;
  final List<dynamic> usersInfo = [];
  final List<dynamic> room = [];
  final List<dynamic> invoices = [];
  final String roomId;
  final double amount;
  final String description;
  final String invoiceId;
  final String name;
  final String pictureName;
  final String surname;
  FirebaseUser user;
  FireBase(
      {this.surname,
      this.name,
      this.email,
      this.password,
      this.context,
      this.user,
      this.roomName,
      this.roomMembers,
      this.roomId,
      this.amount,
      this.description,
      this.pictureName,
      this.invoiceId});

  Future<String> signIn() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) => user = value.user);
      String nameval = "";
      final databaseReference = FirebaseDatabase.instance.reference();
      await databaseReference
          .child("Users")
          .child(user.uid)
          .child("name")
          .once()
          .then((value) => {nameval = value.value.toString()});
      return nameval;
    } catch (e) {
      return "";
    }
  }

/**************************************************************************************************/
  Future signUp() async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                user = value.user,
                print(value),
              })
          .whenComplete(() async => await uploadUserDataToDataBase());

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          print("go to the second page");
          return Dashboard(
            userName: email,
            desplayname: name,
          );
        }),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.currentUser().then((value) async {
      final databaseReference = FirebaseDatabase.instance.reference();
      await databaseReference
          .child("fcm-token")
          .child(value.uid)
          .child("token")
          .set("");
    });

    await FirebaseAuth.instance.signOut();
  }

  Future uploadInvoicToDataBase() async {
    final databaseReferenceuploadToDataBase =
        FirebaseDatabase.instance.reference();
    try {
      databaseReferenceuploadToDataBase
          .child("Rooms")
          .child(roomId)
          .child("Invoices")
          .push()
          .set({
        "user": email,
        "amount": amount,
        "description": description,
        "picture": pictureName
      });
    } catch (e) {
      print(e);
    }
  }

  Future makeRoomDataBase() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    try {
      databaseReference.child("Rooms").push().set({
        "roomName": roomName,
        "roomMembers": roomMembers,
      });
    } catch (e) {
      print(e);
    }
  }

  Future userid() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    try {
      await databaseReference
          .child("Users")
          .once()
          .then((DataSnapshot snapshot) {
        var KEYS = snapshot.value.keys;
        var Data = snapshot.value;
        for (var individualKey in KEYS) {
          UsersData usersData = new UsersData(
            Data[individualKey]["email"],
          );
          usersInfo
              .add({"individualKey": individualKey, "name": usersData.email});
        }
      });
    } catch (e) {
      print(e);
    }

    return user;
  }

  Future getRoomsFroomDatabase() async {
    bool addthisRoom = false;
    final databaseReference = FirebaseDatabase.instance.reference();
    try {
      await databaseReference
          .child("Rooms")
          .once()
          .then((DataSnapshot snapshot) {
        var KEYS = snapshot.value.keys;
        var Data = snapshot.value;
        for (var individualKey in KEYS) {
          RoomData roomData = new RoomData(Data[individualKey]["roomMembers"],
              Data[individualKey]["roomName"]);

          for (var i in roomData.members) {
            if (i["name"] == email) {
              addthisRoom = true;
            }
          }
          if (addthisRoom) {
            room.add({
              "name": roomData.roomName,
              "roomId": individualKey,
              "roomMembers": roomData.members
            });
            addthisRoom = false;
          }
        }
      });
    } catch (e) {
      print(e);
    }

    return room;
  }

  Future getTheInvocesfromDataBase() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    String pic = "";
    String invPic = "";
    try {
      await databaseReference
          .child("Rooms")
          .child(roomId)
          .child("Invoices")
          .once()
          .then((DataSnapshot snapshot) async {
        var KEYS = snapshot.value.keys;
        var Data = snapshot.value;
        for (var individualKey in KEYS) {
          Invoice invoice = new Invoice(
            Data[individualKey]["amount"],
            Data[individualKey]["description"],
            Data[individualKey]["user"],
            individualKey,
            Data[individualKey]["picture"],
          );
          var picture;
          try {
            await databaseReference.child("Users").once().then((value) {
              Map<dynamic, dynamic>.from(value.value).forEach((key, value) {
                if (value["email"].toString().compareTo(invoice.user) == 0) {
                  picture = value["picture"];
                }
              });
            });
            picture == 1 ? pic = await getImage(invoice.user) : pic = "";
          } catch (e) {
            picture = 0;
          }

          invPic = invoice.picture.toString().length == 1
              ? "0"
              : await getImage(invoice.picture);
          invoices.add({
            "amount": invoice.amount,
            "description": invoice.description,
            "user": invoice.user,
            "invoiceId": invoice.invoiceId,
            "pictur": pic,
            "invPic": invPic
          });
        }
      });
    } catch (e) {
      print(e);
    }

    return user;
  }

  Future deleteInvoicesFromdataBase() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    try {
      await databaseReference
          .child("Rooms")
          .child(roomId)
          .child("Invoices")
          .child(invoiceId)
          .remove()
          .then((_) {});
    } catch (e) {}
  }

  Future deleteRoomsFromdataBase() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    try {
      await databaseReference
          .child("Rooms")
          .child(roomId)
          .remove()
          .then((_) {});
    } catch (e) {}
  }

  Future<String> getImage(userEmailpic) async {
    var url = "";
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref()
          .child(userEmailpic.toString())
          .getDownloadURL()
          .then((value) {
        url = value.toString();
      }).onError((error, stackTrace) {
        url = "";
      });
    } catch (e) {
      print(e);
    }
    return url;
  }

  Future uploadUserDataToDataBase() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    try {
      await databaseReference.child("Users").child(user.uid).set({
        "email": user.email,
        "name": name,
        "surname": surname,
        "UserId": user.uid,
        "picture": 0
      });
    } catch (e) {
      print(e);
    }
    try {
      await databaseReference.child("UsersAmount").child(user.uid).set({
        "Amount": 0,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> sendMoneyTo(
      String sentToEmail, String sentFromEmail, double amount) async {
    var uid = "";
    double newAm = amount;
    final databaseReference = FirebaseDatabase.instance.reference();
    String currentuid =
        await FirebaseAuth.instance.currentUser().then((value) => value.uid);
    double currentAmount = await currentUserAmount();
    currentAmount = currentAmount - amount;
    if (currentAmount < 0) {
      return false;
    }
    try {
      await databaseReference
          .child("UsersAmount")
          .child(currentuid)
          .child("Amount")
          .set(currentAmount);
    } catch (e) {
      print(e);
    }
    try {
      await databaseReference.child("Users").once().then((value) {
        Map<dynamic, dynamic>.from(value.value).forEach((key, value) {
          if (value["email"].toString().compareTo(sentToEmail) == 0) {
            uid = value["UserId"];
          }
        });
      });
    } catch (e) {
      print(e);
    }
    try {
      await databaseReference
          .child("UsersAmount")
          .child(uid)
          .child("Amount")
          .once()
          .then(
            (value) => amount = amount + value.value,
          );
    } catch (e) {
      print(e);
    }
    try {
      await databaseReference.child("UsersAmount").child(uid).update({
        "Amount": amount,
      });
    } catch (e) {
      print(e);
    }

    try {
      DateTime now = new DateTime.now();
      databaseReference.child("transitions").child(uid);
      await databaseReference.child("transitions").child(uid).push().set({
        "from": sentFromEmail,
        "Amount": newAm,
        "Date": now.toString().substring(0, 16),
        "then": amount
      });
    } catch (e) {
      print(e);
    }
    try {
      DateTime now = new DateTime.now();
      await databaseReference
          .child("transitions")
          .child(currentuid)
          .push()
          .set({
        "to": sentToEmail,
        "Amount": newAm,
        "Date": now.toString().substring(0, 16),
        "then": currentAmount
      });
    } catch (e) {
      print(e);
    }
    try {
      await databaseReference
          .child("fcm-token")
          .child(uid)
          .child("token")
          .once()
          .then((value) {
        print("notifi :  " + value.value.toString());
        databaseReference.child("notifi").push().set({
          "noty": value.value.toString(),
          "from": sentFromEmail,
          "amount": newAm
        });
      });
    } catch (e) {
      print(e);
    }
    return true;
  }

  Future<bool> addBalance(double amount) async {
    final databaseReference = FirebaseDatabase.instance.reference();
    String currentuid =
        await FirebaseAuth.instance.currentUser().then((value) => value.uid);
    double currentAmount = await currentUserAmount();
    currentAmount = currentAmount + amount;

    try {
      await databaseReference
          .child("UsersAmount")
          .child(currentuid)
          .child("Amount")
          .set(currentAmount);
    } catch (e) {
      print(e);
    }

    return true;
  }

  getTransitions() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    var vals;
    String currentuid =
        await FirebaseAuth.instance.currentUser().then((value) => value.uid);
    try {
      await databaseReference
          .child("transitions")
          .child(currentuid)
          .orderByChild("Date")
          .once()
          .then((value) => vals = value.value);
    } catch (e) {
      print(e);
    }

    return vals;
  }

  Future<double> currentUserAmount() async {
    String uid =
        await FirebaseAuth.instance.currentUser().then((value) => value.uid);

    final databaseReference = FirebaseDatabase.instance.reference();

    try {
      return await databaseReference
          .child("UsersAmount")
          .child(uid)
          .child("Amount")
          .once()
          .then((value) => double.parse(value.value.toString()));
    } catch (e) {
      print("exception : " + e.toString());
      return 0.0;
    }
  }

  Future<List<String>> isthereCurrentUser() async {
    final databaseReference = FirebaseDatabase.instance.reference();
    var userEmail = "";
    var userName = "";

    await FirebaseAuth.instance.currentUser().then((value) async {
      userEmail = value.email.toString();
      await databaseReference
          .child("Users")
          .child(value.uid.toString())
          .child("name")
          .once()
          .then((value) => {
                userName = value.value.toString(),
              });
    }).onError((error, stackTrace) {});
    return [userEmail, userName];
  }

  List<dynamic> getrooms() => room;
  List<dynamic> getInvoices() => invoices;
  List<dynamic> getList() => usersInfo;
  String getUserEmail() => user.email;
  String getUserUid() => user.uid;
}
