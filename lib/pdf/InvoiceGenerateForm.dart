import "package:flutter/material.dart";
import 'package:masroufna/theme/colorsMasroufna.dart';
import 'package:steps/steps.dart';

class InvoiceGenerator extends StatefulWidget {
  @override
  _InvoiceGeneratorState createState() => _InvoiceGeneratorState();
}

class _InvoiceGeneratorState extends State<InvoiceGenerator> {
  @override
  Widget build(BuildContext context) {
    var deviceQ = MediaQuery.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: deviceQ.size.width,
              height: deviceQ.size.height / 2,
              padding: EdgeInsets.only(top: 20),
              child: Steps(
                path: {'color': MasroufnaColors.red, 'width': 3.0},
                steps: [
                  {
                    'color': Colors.white,
                    'background': MasroufnaColors.orang,
                    'label': '1',
                    'content': Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Type The Invoice Information',
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ],
                    ),
                  },
                  {
                    'color': Colors.white,
                    'background': MasroufnaColors.orang,
                    'label': '2',
                    'content': Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Fill all the blanks',
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ],
                    ),
                  },
                  {
                    'color': Colors.white,
                    'background': MasroufnaColors.orang,
                    'label': '3',
                    'content': Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Generate The PDF',
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ],
                    ),
                  },
                  {
                    'color': Colors.white,
                    'background': MasroufnaColors.orang,
                    'label': '4',
                    'content': Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Save The PDF in The Local Storge',
                          style: TextStyle(fontSize: 22.0),
                        ),
                      ],
                    ),
                  },
                ],
              ),
            ),
            Container(
              height: deviceQ.size.height / 3,
              width: deviceQ.size.width,
              child: Center(
                child: TextButton(
                  style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.scatter_plot_outlined,
                        color: MasroufnaColors.red,
                        size: 45,
                      ),
                      Padding(padding: EdgeInsets.only(right: 10)),
                      Text(
                        "Start Generating",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ],
                  ),
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => FormsInvoice())),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormsInvoice extends StatefulWidget {
  @override
  _FormsInvoiceState createState() => _FormsInvoiceState();
}

class _FormsInvoiceState extends State<FormsInvoice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.mail_outline,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Email',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                    disabledBorder: InputBorder.none,
                    prefixStyle: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(
                      Icons.lock_open_outlined,
                      color: Colors.white,
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: MasroufnaColors.orang, width: 1)),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: MasroufnaColors.orang),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
