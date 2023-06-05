import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Details extends StatefulWidget {
  final String id;
  const Details({Key? key, required this.id}) : super(key: key);

  @override
  State<Details> createState() => _DetailsState();
}

class Group<T1, T2, T3, T4, T5> {
  final T1 itemName;
  final T2 quantity;
  final T3 amount;
  final T4 responseAmount;
  final T5 status;
  Group(this.itemName, this.quantity, this.amount, this.responseAmount,
      this.status);
}

class _DetailsState extends State<Details> {
  Color checkFeasibility(amount, responseAmount) {
    double minPrice = int.parse(amount) * 0.8;
    double maxPrice = int.parse(amount) * 1.2;
    int resAmount = int.parse(responseAmount);
    if (resAmount < minPrice || resAmount > maxPrice) {
      return Colors.red;
    }
    return Colors.green;
  }

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

  TableRow getTableRow(data) {
    return TableRow(decoration: BoxDecoration(color: data.status), children: [
      Column(children: [
        Text.rich(
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          TextSpan(
            text: '',
            children: [
              TextSpan(
                text: data.itemName,
                style: const TextStyle(color: Colors.black, fontSize: 18.0),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    showFullText(context, data.itemName);
                  },
              ),
            ],
          ),
        ),
      ]),
      Column(children: [
        Text(data.quantity, style: const TextStyle(fontSize: 18.0))
      ]),
      Column(children: [
        Text(data.amount, style: const TextStyle(fontSize: 18.0))
      ]),
      Column(children: [
        Text(data.responseAmount, style: const TextStyle(fontSize: 18.0))
      ]),
    ]);
  }

  FutureBuilder getData(id) {
    CollectionReference responses =
        FirebaseFirestore.instance.collection('tender_responses');
    return FutureBuilder<DocumentSnapshot>(
      future: responses.doc(id).get(),
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
          List resData = data['response_holder_data'];
          List compareData = data['response_holder_compare_data'];
          List<Group<String, String, String, String, Color>> output = [];
          for (var i = 0; i < resData.length; i++) {
            String itemName = resData[i].split("*")[0];
            String quantity = resData[i].split("*")[1];
            String responseAmount = resData[i].split("*")[2];
            String amount = compareData[i].split("*")[2];
            Color status = checkFeasibility(amount, responseAmount);
            output
                .add(Group(itemName, quantity, amount, responseAmount, status));
          }

          return ListView(
            children: [
              Table(
                border: TableBorder.all(
                    color: Colors.black, style: BorderStyle.solid, width: 2),
                children: [
                  TableRow(children: [
                    Column(children: const [
                      Text('Item Name', style: TextStyle(fontSize: 22.0))
                    ]),
                    Column(children: const [
                      Text('Quantity', style: TextStyle(fontSize: 22.0))
                    ]),
                    Column(children: const [
                      Text('Estimated Price', style: TextStyle(fontSize: 22.0))
                    ]),
                    Column(children: const [
                      Text('Actual Price', style: TextStyle(fontSize: 22.0))
                    ]),
                  ]),
                  for (var i = 0; i < output.length; i++) getTableRow(output[i])
                ],
              ),
            ],
          );
        }

        return const Text("loading");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: getData(widget.id),
      ),
    );
  }
}
