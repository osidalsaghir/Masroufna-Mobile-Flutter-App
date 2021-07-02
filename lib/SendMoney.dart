import "package:flutter/material.dart";
import 'package:masroufna/backend/firebaseController.dart';
import 'package:masroufna/theme/colorsMasroufna.dart';

class SendMony extends StatefulWidget {
  final List<dynamic> members;
  final String userName;
  SendMony({@required this.members, @required this.userName});
  @override
  _SendMonyState createState() =>
      _SendMonyState(members: members, userName: userName);
}

class _SendMonyState extends State<SendMony> {
  final List<dynamic> members;
  final String userName;
  var uAmount = 0.0;
  var amount = 0.0;
  bool transionStatuss = false;
  var dropdownValue;
  List<String> membersName = [];
  _SendMonyState({@required this.members, @required this.userName});
  FireBase fb = new FireBase();
  var amountController = new TextEditingController();
  @override
  void initState() {
    checkAmount();
    for (var names in members) {
      if (names["name"].toString().compareTo(userName) == 0) {
      } else {
        membersName.add(names["name"].toString());
      }
    }
    print(membersName);
  }

  checkAmount() async {
    uAmount = await fb.currentUserAmount();
    setState(() {});
  }

  s_monry() async {
    transionStatuss = await fb.sendMoneyTo(dropdownValue, userName, amount);
    uAmount = await fb.currentUserAmount();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var deviceQ = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Send Money"),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              Container(
                width: deviceQ.width,
                height: 150,
                color: Colors.transparent,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 60,
                        color: MasroufnaColors.yellow,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        uAmount.toString() + " TL",
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                width: double.infinity,
                height: 50,
                color: Colors.black,
                child: DropdownButton<String>(
                  underline: Container(
                    height: 1,
                    color: Colors.transparent,
                  ),
                  isExpanded: true,
                  hint: Text("To"),
                  value: dropdownValue,
                  icon: const Icon(Icons.person),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: MasroufnaColors.orang),
                  onChanged: (String newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items:
                      membersName.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Container(
                height: 50,
                margin: EdgeInsets.only(top: 10),
                width: deviceQ.width / 2,
                color: Colors.black,
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    amount = double.parse(value);
                  },
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0)),
                    border: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.transparent, width: 0)),
                    fillColor: Colors.transparent,
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
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
              Text(
                "To send money press OK and then the mony will be sent",
                style: TextStyle(color: MasroufnaColors.orang),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
              Container(
                height: 50,
                margin: EdgeInsets.only(top: 10),
                width: deviceQ.width / 5,
                color: Colors.black,
                child: TextButton(
                  child: Text(
                    "ok",
                    style: TextStyle(color: MasroufnaColors.orang),
                  ),
                  onPressed: () async => {
                    await s_monry(),
                    amountController.clear(),
                    _showMyDialog(context, transionStatuss),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showMyDialog(context, transionStatuss) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        content: Container(
          width: 70,
          height: 130,
          color: Colors.transparent,
          child: Column(
            children: [
              transionStatuss == true
                  ? Center(
                      child: Icon(
                        Icons.done,
                        size: 60,
                        color: Colors.green,
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.cancel,
                        size: 60,
                        color: Colors.red,
                      ),
                    ),
              transionStatuss == true
                  ? Text("Transition Completed")
                  : Text("Transition did not complete Try Again",
                      textAlign: TextAlign.center),
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
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}
