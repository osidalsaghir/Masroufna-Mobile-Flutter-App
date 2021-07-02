import "package:flutter/material.dart";
import 'package:masroufna/backend/firebaseController.dart';
import 'package:masroufna/theme/colorsMasroufna.dart';

class Transitions extends StatefulWidget {
  @override
  _TransitionsState createState() => _TransitionsState();
}

class _TransitionsState extends State<Transitions> {
  FireBase fb = new FireBase();
  var list;
  List<dynamic> tlist = [];
  @override
  void initState() {
    tlist.clear();
    getTransitions();
    super.initState();
  }

  getTransitions() async {
    list = await fb.getTransitions();
    Map<dynamic, dynamic>.from(list).forEach((key, value) {
      tlist.add([
        value["Amount"],
        value["to"] == null
            ? "From : " + value["from"].toString()
            : "To : " + value["to"].toString(),
        value["Date"],
        value["then"]
      ]);
    });
    tlist.sort((a, b) {
      return b[2].compareTo(a[2]);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var deviceQ = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: deviceQ.width,
        height: deviceQ.height,
        color: MasroufnaColors.grey,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 120.0,
              backgroundColor: MasroufnaColors.blackgrey,
              floating: true,
              flexibleSpace: ListView(
                children: <Widget>[
                  SizedBox(
                    height: 60.0,
                  ),
                  Text("Transitions",
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
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Container(
                    height: 150,
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      shape: BoxShape.rectangle,
                      color: MasroufnaColors.blackgrey,
                      boxShadow: [
                        BoxShadow(
                            color: MasroufnaColors.orang,
                            offset: Offset(3, 0),
                            blurRadius: 2),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(tlist[index][1][0] == "F"
                                ? "Type : Receive"
                                : "Type : Send"),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              tlist[index][1][0] == "F"
                                  ? "Amount " +
                                      "+ " +
                                      tlist[index][0].toString() +
                                      " TL"
                                  : "Amount " +
                                      "- " +
                                      tlist[index][0].toString() +
                                      " TL",
                              style: TextStyle(
                                  color: tlist[index][1][0] == "F"
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 17),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            tlist[index][1][0] == "F"
                                ? Icon(
                                    Icons.arrow_drop_up_outlined,
                                    color: Colors.green,
                                  )
                                : Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.red,
                                  ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Balance : " + tlist[index][3].toString() + " TL",
                              style: TextStyle(
                                  color: tlist[index][1][0] == "F"
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 17),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(tlist[index][1]),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text("Date and Time: "),
                            SizedBox(
                              width: 10,
                            ),
                            Text(tlist[index][2]),
                            SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                childCount: tlist.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
