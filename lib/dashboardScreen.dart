import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:masroufna/backend/firebaseController.dart';
import 'package:masroufna/transtionsScreen.dart';
import 'package:masroufna/userProfiel.dart';
import 'theme/colorsMasroufna.dart';
import 'roomScreen.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'main.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';

bool errorRoom = false;
bool errorList = false;

class Dashboard extends StatefulWidget {
  final String userName;
  final String desplayname;
  Dashboard({this.userName, this.desplayname});
  _DashboardState createState() =>
      _DashboardState(userName: userName, desplayname: desplayname);
}

class _DashboardState extends State<Dashboard> {
  final String userName;
  final String desplayname;
  static const _indicatorSize = 150.0;
  final roomController = TextEditingController();
  final List<dynamic> list = [];
  final List<dynamic> shareWithMembers = [];
  static List<dynamic> rooms = [];
  static bool wait = true;
  static bool _renderCompleteState = false;
  _DashboardState({this.userName, this.desplayname});
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  @override
  void initState() {
    getUsers();
    getRoom();
    firebaseMessaging.getToken().then((token) {
      update(token);
    });
    super.initState();
  }

  update(String token) async {
    print("here");
    DatabaseReference databaseReference = new FirebaseDatabase().reference();
    var c = await FirebaseAuth.instance
        .currentUser()
        .then((value) => [value.email, value.uid]);
    databaseReference
        .child('fcm-token/${c[1].toString()}')
        .set({"token": token, "email": c[0].toString(), "id": c[1].toString()});
    setState(() {});
  }

  Future<List> getSuggestions(String query) async {
    await Future.delayed(Duration(milliseconds: 400), null);
    await getUsers();
    List<dynamic> filteredTagList = <dynamic>[];
    List<dynamic> sharewith = <dynamic>[];
    bool found;
    for (var tag in list) {
      found = false;
      for (var members in shareWithMembers) {
        if (tag["name"].contains(members["name"])) {
          found = true;
        } else {}
      }
      if (!found) {
        sharewith.add(tag);
      }
    }
    for (var tag in sharewith) {
      if (tag["name"].toLowerCase().contains(query)) {
        filteredTagList.add(tag);

        if (filteredTagList.length == 3) {
          break;
        }
      }
    }
    return filteredTagList;
  }

  getUsers() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    FireBase userdata = FireBase(user: user);
    await userdata.userid();
    list.clear();
    list.addAll(userdata.getList());
  }

  Future<void> getRoom() async {
    setState(() {
      wait = true;
    });
    FireBase membersroom = FireBase(email: userName);
    rooms = await membersroom.getRoomsFroomDatabase();
    setState(() {
      wait = false;
    });
  }

  void addRoom(String roomName) async {
    FireBase membersroom = FireBase(
        roomName: roomName, roomMembers: shareWithMembers, email: userName);
    await membersroom.makeRoomDataBase();
    await membersroom.getRoomsFroomDatabase();
    rooms = membersroom.getrooms();
    shareWithMembers.clear();
  }

  Future<void> _getMemberList(
      List<dynamic> members, BuildContext context) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Members',
                  style: TextStyle(
                    color: MasroufnaColors.orang,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.group,
                  color: MasroufnaColors.orang,
                ),
              ],
            ),
            backgroundColor: MasroufnaColors.blackgrey,
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  members.length > 0
                      ? Container(
                          width: 100,
                          height: 200,
                          child: ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  members[index]["name"].toString(),
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          width: 100,
                          height: 100,
                        ),
                  TextButton(
                    child: Text(
                      'Ok',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void deleteRoom(int index, String roomId) async {
    setState(() {
      wait = true;
    });
    FireBase deleteRoom = new FireBase(roomId: roomId);
    await deleteRoom.deleteRoomsFromdataBase();
    setState(() {
      rooms.removeAt(index);
      wait = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MasroufnaColors.grey,
      body: wait
          ? Container(
              child: Center(
                child: SpinKitWave(
                  itemBuilder: (BuildContext context, int index) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color:
                            index.isEven ? MasroufnaColors.orang : Colors.white,
                      ),
                    );
                  },
                ),
              ),
            )
          : Stack(
              children: [
                CustomRefreshIndicator(
                  /// Scrollable widget
                  onRefresh: () async {
                    _renderCompleteState = true;
                    await getUsers();
                    await getRoom();
                    _renderCompleteState = false;
                  },
                  child: CustomScrollView(
                    slivers: <Widget>[
                      SliverAppBar(
                        actions: [
                          IconButton(
                              onPressed: () async {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => Transitions()),
                                );
                              },
                              icon: Icon(
                                Icons.compare_arrows_rounded,
                                color: Colors.white,
                              )),
                          IconButton(
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return UserProfile();
                                  }),
                                );
                              },
                              icon: Icon(
                                Icons.settings,
                                color: Colors.white,
                              )),
                          IconButton(
                              onPressed: () async {
                                FireBase userLogout = FireBase();
                                await userLogout.logout();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return MainMasroufna();
                                  }),
                                );
                              },
                              icon: Icon(
                                Icons.logout,
                                color: Colors.white,
                              )),
                        ],
                        expandedHeight: 120.0,
                        backgroundColor: MasroufnaColors.blackgrey,
                        floating: true,
                        flexibleSpace: ListView(
                          children: <Widget>[
                            SizedBox(
                              height: 60.0,
                            ),
                            Text("Hello " + this.desplayname,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0)),
                          ],
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 10.0,
                        ),
                      ),
                      rooms.length > 0
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return _list(context, index);
                                },
                                childCount: rooms.length,
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return _noList(context, index);
                                },
                                childCount: 1,
                              ),
                            )
                    ],
                  ),
                  builder: (
                    BuildContext context,
                    Widget child,
                    IndicatorController controller,
                  ) {
                    return Stack(
                      children: <Widget>[
                        AnimatedBuilder(
                          animation: controller,
                          builder: (BuildContext context, Widget _) {
                            /// set [_renderCompleteState] to true when controller.state become completed
                            if (controller.didStateChange(
                                to: IndicatorState.complete)) {
                              _renderCompleteState = true;

                              /// set [_renderCompleteState] to false when controller.state become idle
                            } else if (controller.didStateChange(
                                to: IndicatorState.idle)) {
                              _renderCompleteState = false;
                            }
                            final containerHeight =
                                controller.value * _indicatorSize;

                            return Container(
                              alignment: Alignment.center,
                              height: containerHeight,
                              child: OverflowBox(
                                maxHeight: 40,
                                minHeight: 40,
                                maxWidth: 40,
                                minWidth: 40,
                                alignment: Alignment.center,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  alignment: Alignment.center,
                                  child: _renderCompleteState
                                      ? const Icon(
                                          Icons.check,
                                          color: MasroufnaColors.blackgrey,
                                        )
                                      : SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                            value: controller.isDragging ||
                                                    controller.isArmed
                                                ? controller.value
                                                    .clamp(0.0, 1.0)
                                                : null,
                                          ),
                                        ),
                                  decoration: BoxDecoration(
                                    color: _renderCompleteState
                                        ? MasroufnaColors.orang
                                        : MasroufnaColors.orang,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          builder: (context, _) {
                            return Transform.translate(
                              offset: Offset(
                                  0.0, controller.value * _indicatorSize),
                              child: child,
                            );
                          },
                          animation: controller,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
              context: context,
              builder: (_) {
                return MyDialog(userName);
              }).whenComplete(() => getRoom()).then((value) => getRoom());
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black,
      ),
    );
  }

  _list(BuildContext context, int position) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        height: 100,
        padding: EdgeInsets.fromLTRB(0, 15, 0, 30),
        margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          shape: BoxShape.rectangle,
          color: MasroufnaColors.blackgrey,
          boxShadow: [
            BoxShadow(
                color: MasroufnaColors.orang,
                offset: Offset(3, 0),
                blurRadius: 5),
          ],
        ),
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RoomEnter(
                        roomName: rooms[position]["name"],
                        username: userName,
                        roomId: rooms[position]["roomId"].toString(),
                        members: rooms[position]["roomMembers"],
                      )),
            );
          },
          leading: CircleAvatar(
            backgroundColor: MasroufnaColors.orang,
            child: Text(
              rooms[position]["name"].toString()[0].toUpperCase(),
              style: TextStyle(fontSize: 30),
            ),
            foregroundColor: Colors.white,
          ),
          title: Text(
            rooms[position]["name"],
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
          subtitle: Text(
            rooms[position]["roomMembers"].length.toString() + " Members",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          onTap: () => _getMemberList(rooms[position]["roomMembers"], context),
          caption: 'Members',
          color: MasroufnaColors.grey,
          icon: Icons.group,
          closeOnTap: true,
          foregroundColor: Colors.white,
        ),
        IconSlideAction(
          caption: 'Delete',
          color: MasroufnaColors.grey,
          closeOnTap: true,
          icon: Icons.delete,
          foregroundColor: Colors.white,
          onTap: () => deleteRoom(position, rooms[position]["roomId"]),
        ),
      ],
    );
  }

  _noList(BuildContext context, int position) {
    MediaQueryData deviceQ = MediaQuery.of(context);
    return Center(
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Center(
          child: Container(
            height: deviceQ.size.height / 7,
            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
            margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              shape: BoxShape.rectangle,
              color: MasroufnaColors.blackgrey,
              boxShadow: [
                BoxShadow(
                    color: MasroufnaColors.orang,
                    offset: Offset(3, 0),
                    blurRadius: 5),
              ],
            ),
            child: Center(
              child: ListTile(
                title: Center(
                  child: Text(
                    "No groups found press + button to make a group",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyDialog extends StatefulWidget {
  final String username;
  MyDialog(this.username);
  @override
  _MyDialogState createState() => new _MyDialogState(this.username);
}

class _MyDialogState extends State<MyDialog> {
  final String username;
  _DashboardState ds;
  _MyDialogState(this.username) {
    this.ds = new _DashboardState(userName: this.username);
  }

  @override
  void initState() {
    ds.getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: MasroufnaColors.blackgrey,
      title: Text(
        'Create a Room',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextFormField(
              style: TextStyle(color: Colors.white),
              controller: ds.roomController,
              decoration: InputDecoration(
                errorText: errorRoom ? "enter room name" : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                enabledBorder: UnderlineInputBorder(
                  // width: 0.0 produces a thin "hairline" border
                  borderSide:
                      BorderSide(color: MasroufnaColors.orang, width: 0.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  // width: 0.0 produces a thin "hairline" border
                  borderSide:
                      BorderSide(color: MasroufnaColors.orang, width: 1.0),
                ),
                labelText: 'Room Name',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
            ),
            FlutterTagging(
              addButtonWidget: TextButton(
                child: Text("+"),
                onPressed: () => {},
              ),
              textFieldDecoration: InputDecoration(
                fillColor: MasroufnaColors.blackgrey,
                filled: true,
                errorText: errorList ? "Enter Members" : null,
                errorStyle: TextStyle(color: Colors.red),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(
                  Icons.group,
                  color: Colors.white,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: MasroufnaColors.orang, width: 0.0),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: MasroufnaColors.orang, width: 1.0),
                ),
                labelText: 'Members',
                labelStyle: TextStyle(color: Colors.white),
              ),
              chipsColor: MasroufnaColors.yellow,
              chipsFontColor: Colors.white,
              deleteIcon: Icon(Icons.cancel, color: Colors.white),
              chipsPadding: EdgeInsets.all(2.0),
              chipsFontSize: 14.0,
              chipsSpacing: 5.0,
              chipsFontFamily: 'helvetica_neue_light',
              suggestionsCallback: (pattern) async {
                if (pattern.length > 2) {
                  ds.shareWithMembers
                      .add({"name": ds.userName, "value": "null"});
                  return await ds.getSuggestions(pattern);
                }
              },
              onChanged: (result) {
                setState(() {});
                ds.shareWithMembers.clear();
                ds.shareWithMembers.addAll(result);
                ds.shareWithMembers.add({"name": ds.userName, "value": "null"});
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              errorRoom = false;
              errorList = false;
            });
            ds.roomController.text = "";
            ds.shareWithMembers.clear();

            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(
            'Add',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              errorRoom = false;
              errorList = false;
            });

            if (ds.shareWithMembers.length < 2) {
              setState(() {
                errorList = true;
              });
            }
            if (ds.roomController.text.length <= 0) {
              setState(() {
                errorRoom = true;
              });
            }
            if (ds.roomController.text.length <= 0 ||
                ds.shareWithMembers.length < 2) {
              setState(() {});
            } else if (ds.roomController.text.length > 0 ||
                ds.shareWithMembers.length > 2) {
              ds.addRoom(ds.roomController.text.toString());
              ds.roomController.text = "";
              Navigator.pop(context);
            } else {}
          },
        ),
      ],
    );
  }
}
