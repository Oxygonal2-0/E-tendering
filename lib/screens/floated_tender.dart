import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pritam_app/screens/result.dart';

class FlotedTender extends StatefulWidget {
  const FlotedTender({super.key});

  @override
  State<FlotedTender> createState() => _FlotedTenderState();
}

class _FlotedTenderState extends State<FlotedTender> {
  Container getTenderData(data, id) {
    // print(id);
    List itemsData = data['tender_holder_data'];
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              data['tender_name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              data['tender_desc'],
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 10),
          Table(
            // defaultColumnWidth: const FixedColumnWidth(120.0),
            border: TableBorder.all(
                color: Colors.black, style: BorderStyle.solid, width: 2),
            children: [
              TableRow(children: [
                Column(children: const [
                  Text('Item', style: TextStyle(fontSize: 22.0))
                ]),
                Column(children: const [
                  Text('Quantity', style: TextStyle(fontSize: 22.0))
                ]),
                Column(children: const [
                  Text('Price', style: TextStyle(fontSize: 22.0))
                ]),
              ]),
              for (var i = 0; i < itemsData.length; i++)
                TableRow(children: [
                  Column(children: [
                    Text(itemsData[i].split("*")[0],
                        style: const TextStyle(fontSize: 18.0))
                  ]),
                  Column(children: [
                    Text(itemsData[i].split("*")[1],
                        style: const TextStyle(fontSize: 18.0))
                  ]),
                  Column(children: [
                    Text(itemsData[i].split("*")[2],
                        style: const TextStyle(fontSize: 18.0))
                  ]),
                ]),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10),
            child: ElevatedButton(
              child: const Text(
                'Result',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BidResult(id: id)));
              },
            ),
          ),
        ],
      ),
    );
  }

  final currentuser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> tenders = FirebaseFirestore.instance
        .collection('tenders')
        .where('tender_holder_id', isEqualTo: currentuser!.uid)
        .snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text("Floated Tender")),
      body: StreamBuilder<QuerySnapshot>(
        stream: tenders,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Card(child: getTenderData(data, document.id));
            }).toList(),
          );
        },
      ),
    );
  }
}
