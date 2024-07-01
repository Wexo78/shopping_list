import 'package:flutter/material.dart';
import 'package:shopping_list/models/list_item.dart';
import 'package:shopping_list/providers/item_provider.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({required this.toHomeScreen, super.key});

  final void Function() toHomeScreen;

  @override
  State<ItemsScreen> createState() {
    return _ItemsScreenState();
  }
}

class _ItemsScreenState extends State<ItemsScreen> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final GlobalKey<FormState> _keyDialogForm = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final Future<List<ListItem>> _listItems = fetchItems();

    return FutureBuilder<List<ListItem>>(
      future: _listItems,
      builder: (BuildContext context, AsyncSnapshot<List<ListItem>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Waiting for data.");
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (!snapshot.hasData) {
          return Text("No data yet.");
        } else {
          final content = snapshot.data!;
          return Center(
            child: Column(
              children: [
                //      Center(child: const Text('Item List')),
                Expanded(
                  child: ListView(
                    children: content.map((item) {
                      return ListTile(
                          leading: Text(
                            item.amount.toString(),
                            style: TextStyle(
                              fontSize: 15,
                              decoration: item.acquired
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                          trailing: IconButton(
                              onPressed: () {
                                deleteItem(item.id);
                                setState(() {});
                              },
                              icon: const Icon(Icons.delete_rounded)),
                          title: GestureDetector(
                            onTap: () async {
                              //  print('****Tultiin Gestureen, item: $item');
                              await toggleAcquiredProvider(item);
                              //   print('****** mentiin togglen ohi *****');
                              setState(() {
                                //     print('**** Tultiin stateen ******');
                              });
                            },
                            child: Text(
                              item.itemName,
                              style: TextStyle(
                                decoration: item.acquired
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ));
                    }).toList(),
                  ),
                ),
                //...content.map((item) => Text(item.itemName)),
                IconButton.filled(
                    onPressed: () => showaddItemDialog(),
                    icon: const Icon(Icons.add)),
                ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    onPressed: widget.toHomeScreen,
                    label: const Text('Back to home'))
              ],
            ),
          );
        }
      },
    );
  }

  Future showaddItemDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Form(
              key: _keyDialogForm,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: itemController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.food_bank),
                    ),
                    maxLength: 20,
                    textAlign: TextAlign.center,
                    //      onSaved: (val) {
                    //        titleController.text = val;
                    //        setState(() {});
                    //      },
                    autovalidateMode: AutovalidateMode.always,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'You must type something';
                      }

                      return null;
                    },
                  ),
                  TextFormField(
                    controller: amountController,
                    //   initialValue: '1',
                    decoration: const InputDecoration(),
                    maxLength: 5,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    //      onSaved: (val) {
                    //        titleController.text = val;
                    //        setState(() {});
                    //      },
                    autovalidateMode: AutovalidateMode.always,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'You must give at least 1 number';
                      }

                      return null;
                    },
                  )
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  if (_keyDialogForm.currentState!.validate()) {
                    addItem(
                        itemController.text, int.parse(amountController.text));
                    itemController.clear();
                    amountController.clear();
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(33, 150, 243, 1)),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
            ],
          );
        });
  }

  void dispose() {
    itemController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
