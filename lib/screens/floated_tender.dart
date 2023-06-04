import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pritam_app/screens/result.dart';
import 'package:flutter_pritam_app/screens/view_floated_details.dart';

class FlotedTender extends StatefulWidget {
  const FlotedTender({super.key});

  @override
  State<FlotedTender> createState() => _FlotedTenderState();
}

class _FlotedTenderState extends State<FlotedTender> {
  Future<void> deleteTender(id) {
    CollectionReference tenders =
        FirebaseFirestore.instance.collection('tenders');
    return tenders.doc(id).delete().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Tender Deleted Successfully')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to Delete tender')));
    });
  }

  Container getTenderData(data, id) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  data['tender_name'],
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  deleteTender(id);
                },
                color: Colors.blue,
                iconSize: 30,
                tooltip: 'Add',
              )
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              data['tender_desc'],
              style: const TextStyle(fontSize: 20),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              // ignore: prefer_interpolation_to_compose_strings
              "${"Range of Acceptance -> " + data['tender_range_accp']}%",
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    child: const Text(
                      'View Details',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewFloatedDetails(id: id),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    child: const Text(
                      'Result',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BidResult(id: id)));
                    },
                  ),
                ),
              ],
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
        .orderBy('tender_post_date', descending: true)
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
