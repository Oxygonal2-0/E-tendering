import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Bid extends StatefulWidget {
  final String id;
  // ignore: non_constant_identifier_names
  final String tender_name;
  // ignore: non_constant_identifier_names
  final String tender_desc;
  // ignore: non_constant_identifier_names
  const Bid(
      {Key? key,
      required this.id,
      // ignore: non_constant_identifier_names
      required this.tender_name,
      // ignore: non_constant_identifier_names
      required this.tender_desc})
      : super(key: key);

  @override
  State<Bid> createState() => _BidState();
}

class _BidState extends State<Bid> {
  final List<Map<String, dynamic>> _tableData = [];
  final List<Map<String, dynamic>> _compareData = [];
  double range = 100;

  Map<String, dynamic> _editingData = {};

  final _formKey = GlobalKey<FormState>();

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Price'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _editingData['Price'].toString(),
                  decoration:
                      const InputDecoration(labelText: 'Price per unit'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _editingData['Price'] = int.parse(value!),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Price Should be there';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Price must be a number';
                    }
                    return null;
                  },
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  setState(() {
                    _tableData[_tableData.indexOf(_editingData)] = _editingData;
                    _editingData = {};
                  });

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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

  void fillData(data) {
    List tenderData = data['tender_holder_data'];
    range = double.parse(data['tender_range_accp']) / 100;
    for (var i = 0; i < tenderData.length; i++) {
      Map<String, dynamic> tempData = {
        'Item': tenderData[i].split("*")[0],
        'Quantity': tenderData[i].split("*")[1],
        'Price': 0
      };
      _tableData.add(tempData);
    }
    for (var i = 0; i < tenderData.length; i++) {
      Map<String, dynamic> tempData = {
        'Item': tenderData[i].split("*")[0],
        'Quantity': tenderData[i].split("*")[1],
        'Price': tenderData[i].split("*")[2]
      };
      _compareData.add(tempData);
    }
  }

  CollectionReference tenders =
      FirebaseFirestore.instance.collection('tenders');

  CollectionReference responses =
      FirebaseFirestore.instance.collection('tender_responses');

  final currentuser = FirebaseAuth.instance.currentUser;

  // ignore: non_constant_identifier_names
  bool check_feasibility(double range) {
    for (var i = 0; i < _tableData.length; i++) {
      var minPrice = int.parse(_compareData[i]['Price']) * (1 - range);
      var maxPrice = int.parse(_compareData[i]['Price']) * (1 + range);
      if (_tableData[i]['Price'] < minPrice ||
          _tableData[i]['Price'] > maxPrice) {
        return false;
      }
    }
    return true;
  }

  Future<void> applyTender(context) async {
    final DateTime now = DateTime.now();
    List<String> data = [];
    List<String> compareData = [];
    String status = check_feasibility(range) ? "accepted" : "not accepted";

    for (var i = 0; i < _tableData.length; i++) {
      String tempData = [
        _tableData[i]['Item'],
        _tableData[i]['Quantity'],
        _tableData[i]['Price']
      ].join("*");
      data.add(tempData);
    }

    for (var i = 0; i < _compareData.length; i++) {
      String tempData = [
        _compareData[i]['Item'],
        _compareData[i]['Quantity'],
        _compareData[i]['Price']
      ].join("*");
      compareData.add(tempData);
    }

    await responses.add({
      'response_holder_id': currentuser!.uid,
      'response_holder_name': currentuser!.displayName,
      'response_holder_phone': currentuser!.photoURL,
      'response_holder_data': data,
      'response_holder_compare_data': compareData,
      'response_post_date': now,
      'response_tender_name': widget.tender_name,
      'response_tender_desc': widget.tender_desc,
      'response_tender_id': widget.id,
      'response_status': status
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Tender Applied Successfully')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to Apply for tender')));
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Bid the Tender")),
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
              if (_tableData.isEmpty) {
                fillData(data);
              }

              return ListView(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(
                            label:
                                Text('Item', style: TextStyle(fontSize: 18))),
                        DataColumn(
                            label: Text('Quantity',
                                style: TextStyle(fontSize: 18))),
                        DataColumn(
                            label:
                                Text('Price', style: TextStyle(fontSize: 18))),
                        DataColumn(
                            label:
                                Text('Edit', style: TextStyle(fontSize: 18))),
                      ],
                      rows: _tableData
                          .map(
                            (data) => DataRow(cells: [
                              DataCell(
                                Text.rich(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  TextSpan(
                                    text: '',
                                    children: [
                                      TextSpan(
                                        text: data['Item'].length > 15
                                            ? data['Item'].substring(0, 10) +
                                                '...'
                                            : data['Item'],
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            showFullText(context, data['Item']);
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(Text(data['Quantity'].toString(),
                                  style: const TextStyle(fontSize: 16))),
                              DataCell(Text('${data['Price']}',
                                  style: const TextStyle(fontSize: 16))),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      _editingData = data;
                                    });
                                    _showEditDialog(context);
                                  },
                                ),
                              ),
                            ]),
                          )
                          .toList(),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      onPressed: () {
                        applyTender(
                          context,
                        );
                      },
                    ),
                  ),
                ],
              );
            }

            return const Text("loading");
          },
        ));
  }
}
