import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BiddedTender extends StatefulWidget {
  const BiddedTender({super.key});

  @override
  State<BiddedTender> createState() => _BiddedTenderState();
}

class _BiddedTenderState extends State<BiddedTender> {
  final currentuser = FirebaseAuth.instance.currentUser;

  Container getResponseData(data) {
    List itemsData = data['response_holder_data'];
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              data['response_tender_name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              data['response_tender_desc'],
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> responses = FirebaseFirestore.instance
        .collection('tender_responses')
        .where('response_holder_id', isEqualTo: currentuser!.uid)
        .snapshots();
    return Scaffold(
      appBar: AppBar(title: const Text("Bidded Tender")),
      body: StreamBuilder<QuerySnapshot>(
        stream: responses,
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
              return Card(child: getResponseData(data));
            }).toList(),
          );
        },
      ),
    );
  }
}
