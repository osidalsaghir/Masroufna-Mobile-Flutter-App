import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:masroufna/SendMoney.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:masroufna/theme/colorsMasroufna.dart';
import 'package:masroufna/backend/firebaseController.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:pdf/pdf.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:charts_common/src/common/color.dart' as sColors;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view.dart';

List<dynamic> invoices = [];
List<dynamic> totalAmountofUsers = [];
List<dynamic> pdfInvoiceDescription = [];
List<dynamic> pdfInvoiceTotalAmountSpendForEveryUser = [];

class RoomEnter extends StatefulWidget {
  final String roomName;
  final String username;
  final String roomId;
  final List<dynamic> members;

  RoomEnter({this.roomName, this.username, this.roomId, this.members});

  @override
  _RoomEnterState createState() => _RoomEnterState(
      roomName: roomName, username: username, roomId: roomId, members: members);
}

class _RoomEnterState extends State<RoomEnter> {
  final String roomName;
  final String username;
  final String roomId;
  final List<dynamic> members;
  static const _indicatorSize = 150.0;
  bool _renderCompleteState = false;
  double amoumt = 0;
  String description = "";
  double userTotalAmount = 0;
  double totalAmountOfUsers = 0.0;
  _RoomEnterState({this.roomName, this.username, this.roomId, this.members});
  bool errorAmount = false;
  bool errordes = false;
  bool wait = true;
  File newfile;
  var pickedFile;
  final desController = TextEditingController();
  final amountController = TextEditingController();
  @override
  void initState() {
    invoices.clear();
    pdfInvoiceDescription.clear();
    userTotalAmount = 0;
    getInvoices();

    super.initState();
  }

  Future<void> getInvoices() async {
    setState(() {
      wait = true;
    });
    FireBase getInvoices = new FireBase(roomId: roomId);
    await getInvoices.getTheInvocesfromDataBase();
    setState(() {
      invoices = getInvoices.getInvoices();
      getTheTotalAmountonTheInvoice();
    });
  }

  void deleteInvoice(int index, String invoiceId) async {
    setState(() {
      wait = true;
    });
    FireBase deleteInvoice = new FireBase(roomId: roomId, invoiceId: invoiceId);
    await deleteInvoice.deleteInvoicesFromdataBase();
    setState(() {
      invoices.removeAt(index);
      getTheTotalAmountonTheInvoice();
    });
    setState(() {
      wait = false;
    });
  }

  _deleteAll() {
    setState(() {
      invoices.clear();
      userTotalAmount = 0;
    });
  }

  Future<void> addAmount() async {
    setState(() {
      wait = true;
    });
    var pic = await uploadPictur();

    FireBase addamount = new FireBase(
        email: username,
        roomId: roomId,
        amount: amoumt,
        pictureName: pic,
        description: description);
    await addamount.uploadInvoicToDataBase();
    await getInvoices();
    setState(() {});
  }

  void getTheTotalAmountonTheInvoice() {
    userTotalAmount = 0;
    totalAmountOfUsers = 0;
    for (var invoice in invoices) {
      if (invoice["user"].toString().compareTo(username) == 0) {
        setState(() {
          userTotalAmount = userTotalAmount + invoice["amount"];
        });
      }
      totalAmountOfUsers = totalAmountOfUsers + invoice["amount"];
    }
    getTheOverAllInvoice();
  }

/**** The Calculater For The Users :) Here Is The Real Work ****/
  void getTheOverAllInvoice() {
    pdfInvoiceDescription.clear();
    double totalAmount = 0.0;
    double totalAmountforEveryOneToPay = 0.0;
    double total = 0;
    totalAmountofUsers.clear();
    for (var user in members) {
      totalAmount = 0;
      for (var invoice in invoices) {
        if (user["name"] == invoice["user"].toString()) {
          totalAmount = totalAmount + invoice["amount"];
        }
      }
      totalAmountforEveryOneToPay = totalAmount / members.length;
      totalAmountofUsers.add({
        "user": user["name"].toString(),
        "amount": totalAmount,
        "everyoneToPay": totalAmountforEveryOneToPay
      });

      pdfInvoiceDescription.clear();
      pdfInvoiceTotalAmountSpendForEveryUser.clear();
    }
    for (var paymnet in totalAmountofUsers) {
      for (var paymnetuser in totalAmountofUsers) {
        if (paymnet["everyoneToPay"] > paymnetuser["everyoneToPay"]) {
          total = paymnet["everyoneToPay"] - paymnetuser["everyoneToPay"];
          pdfInvoiceDescription.add({
            "theTaker": paymnetuser["user"].toString(),
            "theGiver": paymnet["user"].toString(),
            "theAmount": total,
          });
        } else if (paymnet["everyoneToPay"] < paymnetuser["everyoneToPay"]) {
          total = 0;
        } else if (paymnet["everyoneToPay"] == paymnetuser["everyoneToPay"]) {
          total = 0;
        }
      }
      pdfInvoiceTotalAmountSpendForEveryUser
          .add({"user": paymnet["user"], "amount": paymnet["amount"]});
    }
    setState(() {
      wait = false;
    });
  }

  final picker = ImagePicker();
  Future<void> setImage(context) async {
    pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      newfile = File(pickedFile.path);
    });
    Navigator.of(context).pop();
    _neverSatisfied();
  }

  Future<String> uploadPictur() async {
    var databaseReferenceuploadToDataBase = FirebaseDatabase.instance
        .reference()
        .child("Rooms")
        .child(roomId)
        .child("Invoices")
        .push()
        .key;

    if (pickedFile != null) {
      var fileUploadName = databaseReferenceuploadToDataBase.toString() +
          "_" +
          DateTime.now().toString() +
          "_" +
          username;
      try {
        await firebase_storage.FirebaseStorage.instance
            .ref()
            .child(fileUploadName)
            .putFile(newfile)
            .onComplete;
        return fileUploadName;
      } catch (e) {} finally {}
    } else {
      print('No image selected.');
      return "0";
    }
  }

  /**************************************************************************************************************/

  static final String path = "lib/src/pages/hotel/hhome.dart";

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
          : CustomRefreshIndicator(
              /// Scrollable widget
              onRefresh: () async {
                _renderCompleteState = true;
                invoices.clear();
                pdfInvoiceDescription.clear();
                userTotalAmount = 0;
                await getInvoices();
                _renderCompleteState = false;
              },
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
                        Text(roomName,
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
                  SliverToBoxAdapter(
                    child: _buildCategories(context),
                  ),
                  invoices.isEmpty == false || invoices == null
                      ? SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return _list(context, index);
                            },
                            childCount: invoices.length,
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
                                            ? controller.value.clamp(0.0, 1.0)
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
                          offset:
                              Offset(0.0, controller.value * _indicatorSize),
                          child: child,
                        );
                      },
                      animation: controller,
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _neverSatisfied();
        },
        child: Icon(
          Icons.add,
          color: MasroufnaColors.grey,
          size: 35,
        ),
        backgroundColor: MasroufnaColors.orang,
      ),
    );
  }

  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: MasroufnaColors.blackgrey,
          title: Text(
            'Enter invoice information',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        new RegExp(r'^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$'))
                  ],
                  decoration: InputDecoration(
                    errorText: errordes ? "invalid amount" : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      Icons.monetization_on_outlined,
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
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                ),
                TextFormField(
                  maxLines: 1,
                  maxLength: 20,
                  style: TextStyle(color: Colors.white),
                  controller: desController,
                  decoration: InputDecoration(
                    errorText: errordes ? "invalid description" : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(
                      Icons.description_outlined,
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
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
                Container(
                  height: 100,
                  child: pickedFile != null
                      ? Text(pickedFile.path.split("/").last.toString())
                      : IconButton(
                          icon: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Add picture"),
                              SizedBox(
                                height: 5,
                              ),
                              Icon(Icons.add),
                            ],
                          ),
                          onPressed: () => setImage(context)),
                )
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: MasroufnaColors.orang),
              ),
              onPressed: () {
                setState(() {
                  errorAmount = false;
                  errordes = false;
                });
                pickedFile = null;
                Navigator.of(context).pop();

                setState(() {
                  amountController.text = "";
                  desController.text = "";
                });
              },
            ),
            TextButton(
              child: Text(
                'Add',
                style: TextStyle(color: MasroufnaColors.orang),
              ),
              onPressed: () {
                description = desController.text;

                if (amountController.text.isEmpty || description.isEmpty) {
                  if (amountController.text.isEmpty) {
                    setState(() {
                      errorAmount = true;
                    });
                  }
                  if (description.length <= 0) {
                    setState(() {
                      errordes = true;
                    });
                  }

                  Navigator.of(context).pop();
                  _neverSatisfied();
                } else {
                  setState(() {
                    errorAmount = false;
                    errordes = false;
                  });
                  amoumt = double.parse(amountController.text);
                  addAmount();
                  amountController.text = "";
                  desController.text = "";
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
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
                    "No Invoices Found !",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, int position) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        height: 110,
        padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
        margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          shape: BoxShape.rectangle,
          color: MasroufnaColors.blackgrey,
          boxShadow: [
            BoxShadow(
                color:
                    invoices[position]["user"].toString().compareTo(username) ==
                            0
                        ? MasroufnaColors.blue
                        : MasroufnaColors.orang,
                offset: Offset(3, 0),
                blurRadius: 2),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: MasroufnaColors.orang,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                image: DecorationImage(
                    alignment: Alignment.center,
                    fit: BoxFit.fill,
                    image: invoices[position]["pictur"] != ""
                        ? NetworkImage(invoices[position]["pictur"])
                        : AssetImage("assets/avatar.png")),
              ),
            ),
            foregroundColor: Colors.white,
          ),
          title: Text(
            invoices[position]["user"] + "\n",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Description : " +
                    invoices[position]["description"] +
                    " \n" +
                    "Amount : " +
                    invoices[position]["amount"].toString() +
                    " TL",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              invoices[position]["invPic"].toString().length == 1
                  ? SizedBox()
                  : IconButton(
                      icon: Icon(Icons.inventory),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PicVewer(
                            picurl: invoices[position]["invPic"].toString(),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
      secondaryActions: invoices[position]["user"]
                  .toString()
                  .compareTo(username) ==
              0
          ? <Widget>[
              IconSlideAction(
                  caption: 'Delete',
                  color: MasroufnaColors.grey,
                  closeOnTap: true,
                  icon: Icons.delete,
                  foregroundColor: Colors.white,
                  onTap: () =>
                      deleteInvoice(position, invoices[position]["invoiceId"])),
            ]
          : <Widget>[],
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Container(
      color: MasroufnaColors.grey,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 10.0,
          ),
          Category(
            onPress: () => membersAlert(),
            backgroundColor: MasroufnaColors.orang,
            title: "Send Money",
            icon: Icons.people,
          ),
          SizedBox(
            width: 10.0,
          ),
          Category(
            onPress: () => alertDialog(),
            backgroundColor: MasroufnaColors.orang,
            title: "Spend : " + userTotalAmount.toString(),
            icon: Icons.person,
          ),
          SizedBox(
            width: 10.0,
          ),
          Category(
            onPress: () => _pdfmaker(context),
            backgroundColor: MasroufnaColors.yellow,
            title: "Generate PDF",
            icon: Icons.picture_as_pdf,
          ),
        ],
      ),
    );
  }

  _pdfmaker(context) async {
    var _logo = await rootBundle.loadString('assets/logosvg.svg');

    var glist = <List<String>>[];
    for (var i = 0; i < pdfInvoiceDescription.length; i++) {
      glist.add(<String>[
        pdfInvoiceDescription[i]["theTaker"].toString(),
        pdfInvoiceDescription[i]["theGiver"].toString(),
        pdfInvoiceDescription[i]["theAmount"].toString()
      ]);
    }
    var glist2 = <List<String>>[];
    for (var i = 0; i < pdfInvoiceTotalAmountSpendForEveryUser.length; i++) {
      glist2.add(<String>[
        pdfInvoiceTotalAmountSpendForEveryUser[i]["user"].toString(),
        pdfInvoiceTotalAmountSpendForEveryUser[i]["amount"].toString()
      ]);
    }
    getTheOverAllInvoice();
    var pdf = pdfLib.Document();

    pdf.addPage(pdfLib.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) {
          return pdfLib.Container(
              padding: pdfLib.EdgeInsets.only(bottom: 20),
              child: pdfLib.Center(
                child: pdfLib.Row(children: [
                  pdfLib.Container(
                    width: 100,
                    height: 100,
                    child: pdfLib.Center(
                      child: _logo != null
                          ? pdfLib.SvgImage(svg: _logo)
                          : pdfLib.PdfLogo(),
                    ),
                  ),
                  pdfLib.Text("Masroufna Invoice Document",
                      style: pdfLib.TextStyle(fontSize: 25)),
                ]),
              ));
        },
        footer: (context) {
          return pdfLib.Container(
              padding: pdfLib.EdgeInsets.only(bottom: 20),
              child: pdfLib.Center(
                child: pdfLib.Row(children: [
                  pdfLib.Container(
                    width: 25,
                    height: 25,
                    child: pdfLib.Center(
                      child: _logo != null
                          ? pdfLib.SvgImage(svg: _logo)
                          : pdfLib.PdfLogo(),
                    ),
                  ),
                  pdfLib.Text("powered by Masroufna",
                      style: pdfLib.TextStyle(fontSize: 10)),
                ]),
              ));
        },
        build: (context) => <pdfLib.Widget>[
              pdfLib.Table.fromTextArray(
                  context: context,
                  headers: <dynamic>["Giver", "Taker", "Amount"],
                  data: glist),
              pdfLib.Padding(padding: pdfLib.EdgeInsets.only(bottom: 50)),
              pdfLib.Divider(),
              pdfLib.Padding(padding: pdfLib.EdgeInsets.only(bottom: 50)),
              pdfLib.Table.fromTextArray(
                context: context,
                headers: <dynamic>["User", "Amount"],
                data: glist2,
              ),
            ]));
    final String dir = (await getApplicationDocumentsDirectory()).path;
    final String path = '$dir/ssm.pdf';
    final File file = File(path);
    final savedPdf = await pdf.save();
    await file.writeAsBytes(savedPdf);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfPreview(
          pdfFileName: roomName + ".pdf",
          build: (format) => savedPdf,
        ),
      ),
    );
  }

  Future<void> alertDialog() async {
    print("total : " + totalAmountOfUsers.toString());
    print("user : " + userTotalAmount.toString());
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        final List<charts.Series> seriesList = [];
        return AlertDialog(
          backgroundColor: MasroufnaColors.blackgrey,
          content: Container(
              width: 100,
              height: 150,
              child: charts.PieChart(
                _createSampleData((totalAmountOfUsers), userTotalAmount),
                animate: true,
              )),
          actions: <Widget>[
            TextButton(
              child: Text("ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> membersAlert() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return SendMony(
          userName: username,
          members: members,
        );
      }),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, int>> _createSampleData(total, user) {
    final data = [
      new LinearSales(0, user.floor(), sColors.Color.white),
      new LinearSales(1, total.floor() - user.floor(), sColors.Color.black),
    ];

    return [
      new charts.Series<LinearSales, int>(
        id: 'amount',
        labelAccessorFn: (LinearSales amount, _) => "dasdasd",
        colorFn: (LinearSales amount, _) => amount.color,
        domainFn: (LinearSales amount, _) => amount.user,
        measureFn: (LinearSales amount, _) => amount.total,
        data: data,
      )
    ];
  }
}

class LinearSales {
  final int user;
  final int total;
  final color;
  LinearSales(this.user, this.total, this.color);
}

class Category extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color backgroundColor;
  final Function onPress;

  const Category(
      {Key key,
      @required this.icon,
      @required this.title,
      this.backgroundColor,
      this.onPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData deviceQ = MediaQuery.of(context);
    return InkWell(
      onTap: () {
        onPress();
      },
      child: Container(
        decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        margin: EdgeInsets.symmetric(vertical: 10.0),
        padding: EdgeInsets.all(5.0),
        width: (deviceQ.size.width / 3) - 30,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
            ),
            SizedBox(
              height: 5.0,
            ),
            Center(child: Text(title, style: TextStyle(color: Colors.white)))
          ],
        ),
      ),
    );
  }
}

class PicVewer extends StatelessWidget {
  final picurl;
  const PicVewer({this.picurl});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: PhotoView(
      loadingBuilder: (context, event) => Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            value: event == null
                ? 0
                : event.cumulativeBytesLoaded / event.expectedTotalBytes,
          ),
        ),
      ),
      imageProvider: NetworkImage(picurl),
    ));
  }
}
