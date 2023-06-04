import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FloatNewTender extends StatefulWidget {
  const FloatNewTender({super.key});

  @override
  State<FloatNewTender> createState() => _FloatNewTenderState();
}

class _FloatNewTenderState extends State<FloatNewTender> {
  List<String> names = [];
  List<String> quantities = [];
  List<String> price = [];
  String _desc = "";
  String _name = "";
  String _range = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final currentuser = FirebaseAuth.instance.currentUser;
  CollectionReference tenders =
      FirebaseFirestore.instance.collection('tenders');

  Future showAddItemFunction(context) async {
    // ignore: prefer_typing_uninitialized_variables
    var itemName;
    // ignore: prefer_typing_uninitialized_variables
    var itemQuantity;
    // ignore: prefer_typing_uninitialized_variables
    var itemPrice;
    return await showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: Material(
            type: MaterialType.transparency,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.grey[100],
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                height: 320,
                child: Column(
                  children: [
                    Expanded(
                      child: Form(
                          key: _formKey,
                          child: ListView(
                            physics: const ScrollPhysics(),
                            padding: const EdgeInsets.all(20),
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Item Name',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Item Name is Required';
                                  }
                                  // if (value.length >= 30) {
                                  //   return 'Item Name should be less than 30';
                                  // }
                                  return null;
                                },
                                onSaved: (String? value) {
                                  itemName = value;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Item Quantity'),
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Item Quantity is Required';
                                  }
                                  return null;
                                },
                                onSaved: (String? value) {
                                  itemQuantity = value;
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Item Price Per Unit'),
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Item Price is Required';
                                  }
                                  return null;
                                },
                                onSaved: (String? value) {
                                  itemPrice = value;
                                },
                              ),
                            ],
                          )),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          _formKey.currentState!.save();
                          names.add(itemName);
                          quantities.add(itemQuantity);
                          price.add(itemPrice);
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child:
                              Text('Add Item', style: TextStyle(fontSize: 18)),
                        )),
                    const SizedBox(height: 10)
                  ],
                )),
          ));
        });
  }

  Future<void> postTender(context) async {
    final DateTime now = DateTime.now();
    var data = [];

    for (var i = 0; i < names.length; i++) {
      String tempData = [names[i], quantities[i], price[i]].join("*");
      data.add(tempData);
    }

    await tenders.add({
      'tender_holder_id': currentuser!.uid,
      'tender_name': _name,
      'tender_desc': _desc,
      'tender_range_accp': _range,
      'tender_holder_name': currentuser!.displayName,
      'tender_holder_phone': currentuser!.photoURL,
      'tender_holder_data': data,
      'tender_post_date': now
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Tender Posted Successfully')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red, content: Text('Failed to Post tender')));
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Float New Tender")),
        body: ListView(children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Form(
                key: _formKey1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        decoration:
                            const InputDecoration(labelText: 'Tender Name'),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Tender Name ';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          _name = value!;
                        }),
                    TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Description ';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          _desc = value!;
                        }),
                    TextFormField(

                        // textCapitalization: TextCapitalization.,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Range of Acceptance'),
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return 'Please Enter Range of Acceptance (in %)';
                          }
                          int range = int.parse(value);
                          if (range > 100 || range <= 0) {
                            return 'Range of Acceptance should be between 0-100%';
                          }
                          return null;
                        },
                        onSaved: (String? value) {
                          _range = value!;
                        }),
                  ],
                )),
          ),
          (names.isNotEmpty)
              ? Container(
                  margin: const EdgeInsets.all(20),
                  child: Table(
                    border: TableBorder.all(
                        color: Colors.black,
                        style: BorderStyle.solid,
                        width: 2),
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
                      for (var i = 0; i < names.length; i++)
                        TableRow(children: [
                          Column(children: [
                            Text(names[i],
                                style: const TextStyle(fontSize: 18.0))
                          ]),
                          Column(children: [
                            Text(quantities[i],
                                style: const TextStyle(fontSize: 18.0))
                          ]),
                          Column(children: [
                            Text(price[i],
                                style: const TextStyle(fontSize: 18.0))
                          ]),
                        ]),
                    ],
                  ),
                )
              : Container(),
          (names.isNotEmpty)
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  child: ElevatedButton(
                    child: const Text(
                      'Post',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    onPressed: () {
                      if (!_formKey1.currentState!.validate()) {
                        return;
                      }
                      _formKey1.currentState!.save();
                      postTender(context);
                    },
                  ),
                )
              : Container()
        ]),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.blue[600],
          onPressed: () async {
            await showAddItemFunction(context);
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Item'),
        ));
  }
}
