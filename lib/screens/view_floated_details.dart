import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ViewFloatedDetails extends StatefulWidget {
  final String id;
  const ViewFloatedDetails({
    Key? key,
    required this.id,
  }) : super(key: key);
  @override
  State<ViewFloatedDetails> createState() => _ViewFloatedDetailsState();
}

class _ViewFloatedDetailsState extends State<ViewFloatedDetails> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference tenders =
      FirebaseFirestore.instance.collection('tenders');

  Future showFullText(context, data) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Item Name'),
            content: Text(data),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              )
            ],
          );
        });
  }

  Widget getData(data) {
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
                    Text.rich(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      TextSpan(
                        text: '',
                        children: [
                          TextSpan(
                            text: itemsData[i].split("*")[0],
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18.0),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                showFullText(
                                    context, itemsData[i].split("*")[0]);
                              },
                          ),
                        ],
                      ),
                    ),
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
    return Scaffold(
        appBar: AppBar(title: const Text("Tender Details")),
        body: FutureBuilder<DocumentSnapshot>(
          future: tenders.doc(widget.id).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Something went wrong");
            }

            if (snapshot.hasData && !snapshot.data!.exists) {
              return const Text("Document does not exist");
            }

            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshot.data!.data() as Map<String, dynamic>;
              return getData(data);
            }

            return const Text("loading");
          },
        ));
  }
}
