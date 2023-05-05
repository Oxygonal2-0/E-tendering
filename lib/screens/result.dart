import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pritam_app/screens/details.dart';

class BidResult extends StatefulWidget {
  final String id;
  const BidResult({Key? key, required this.id}) : super(key: key);

  @override
  State<BidResult> createState() => _BidResultState();
}

class Pair<T1, T2, T3, T4> {
  final T1 amount;
  final T2 name;
  final T3 status;
  final T4 id;
  Pair(this.amount, this.name, this.status, this.id);
}

class _BidResultState extends State<BidResult> {
  int getTotalAmount(data) {
    int totalAmount = 0;
    for (var i = 0; i < data.length; i++) {
      totalAmount +=
          int.parse(data[i].split("*")[1]) * int.parse(data[i].split("*")[2]);
    }
    return totalAmount;
  }

  Color getColor(color) {
    if (color == 'accepted') {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  TableRow getTableRow(data) {
    return TableRow(
        decoration: BoxDecoration(color: getColor(data.status)),
        children: [
          Column(children: [
            Text.rich(
              TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: data.name,
                    style: const TextStyle(color: Colors.black, fontSize: 18.0),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Details(id: data.id)));
                      },
                  ),
                ],
              ),
            ),
          ]),
          Column(children: [
            Text("${data.amount}", style: const TextStyle(fontSize: 18.0))
          ]),
          Column(children: [
            Text(data.status, style: const TextStyle(fontSize: 18.0))
          ]),
        ]);
  }

  StreamBuilder getResultData(id) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tender_responses')
          .where('response_tender_id', isEqualTo: id)
          // .where('response_status', isEqualTo: "accepted")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        List<Pair<int, String, String, String>> output = [];
        List<Pair<int, String, String, String>> notOutput = [];
        List<Pair<int, String, String, String>> list =
            snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          int finalAmount = getTotalAmount(data['response_holder_data']);
          Pair<int, String, String, String> pair = Pair(
              finalAmount,
              data['response_holder_name'],
              data['response_status'],
              document.id);
          return pair;
        }).toList();

        for (var element in list) {
          if (element.status == 'accepted') {
            output.add(element);
          } else {
            notOutput.add(element);
          }
        }

        output.sort((a, b) => a.amount.compareTo(b.amount));
        notOutput.sort((a, b) => a.amount.compareTo(b.amount));

        return Table(
          border: TableBorder.all(
              color: Colors.black, style: BorderStyle.solid, width: 2),
          children: [
            TableRow(children: [
              Column(children: const [
                Text('Name', style: TextStyle(fontSize: 22.0))
              ]),
              Column(children: const [
                Text('Amount', style: TextStyle(fontSize: 22.0))
              ]),
              Column(children: const [
                Text('See Details', style: TextStyle(fontSize: 22.0))
              ]),
            ]),
            for (var i = 0; i < output.length; i++) getTableRow(output[i]),
            for (var i = 0; i < notOutput.length; i++) getTableRow(notOutput[i])
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: getResultData(widget.id),
      ),
    );
  }
}
