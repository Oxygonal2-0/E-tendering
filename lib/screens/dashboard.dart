import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pritam_app/authentication/login.dart';
import 'package:flutter_pritam_app/screens/bidded_tender.dart';
import 'package:flutter_pritam_app/screens/bidding_on_tender.dart';
import 'package:flutter_pritam_app/screens/float_new_tender.dart';
import 'package:flutter_pritam_app/screens/floated_tender.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future choiceAction(context, choice) async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green, content: Text('Logout Successfully')));

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "E-Tendering App",
          style: TextStyle(fontSize: 23),
        ),
        actions: [
          PopupMenuButton(
            enabled: true,
            padding: const EdgeInsets.all(0),
            onSelected: (String choice) {
              choiceAction(context, choice);
            },
            itemBuilder: (BuildContext context) {
              return Contraints.choices.map((String choices) {
                return PopupMenuItem(
                    value: choices, child: Center(child: Text(choices)));
              }).toList();
            },
          )
        ],
      ),
      body: Column(children: [
        Container(
            height: 70,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ElevatedButton(
              child: const Text(
                'Float a Tender',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FloatNewTender()));
              },
            )),
        Container(
            height: 70,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ElevatedButton(
              child: const Text(
                'Bidding on Tender',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BidOnTender()));
              },
            )),
        Container(
            width: double.infinity,
            height: 70,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ElevatedButton(
              child: const Text(
                'Floated Tender',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FlotedTender()));
              },
            )),
        Container(
            width: double.infinity,
            height: 70,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: ElevatedButton(
              child: const Text(
                'Bidded Tender',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BiddedTender()));
              },
            )),
      ]),
    );
  }
}

class Contraints {
  static const List<String> choices = <String>['Logout'];
}
