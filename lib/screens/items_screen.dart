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
          return const Center(child: Text("Waiting for data."));
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData) {
          return const Center(child: Text("No data yet."));
        } else {
          final content = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: [
                  //      Center(child: const Text('Item List')),
                  Expanded(
                    child: ListView(
                      children: content.map((item) {
                        return ListTile(
                            key: ValueKey(item.id),
                            leading: Text(
                              item.amount.toString(),
                              style: TextStyle(
                                fontSize: 15,
                                decoration: item.acquired
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      //  deleteItem(item.id);
                                      showaddItemDialog(item: item);
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () async {
                                      await deleteItem(item.id);
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.delete_rounded)),
                              ],
                            ),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton.filled(
                          onPressed: () => showaddItemDialog(),
                          icon: const Icon(Icons.add)),
                      const SizedBox(
                        width: 36,
                      ),
                      ElevatedButton.icon(
                          onPressed: () async {
                            await deleteAll();
                            setState(() {});
                          },
                          label: const Text('Delete all!')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                      icon: const Icon(Icons.home),
                      onPressed: widget.toHomeScreen,
                      label: const Text('Back to home'))
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future showaddItemDialog({ListItem? item}) {
    final newItem = item == null;
    if (item != null) {
      itemController.text = item.itemName;
      amountController.text = item.amount.toString();
    }
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Form(
              key: _keyDialogForm,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    // initialValue: editItem ? item.itemName : '',
                    controller: itemController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.food_bank),
                    ),
                    maxLength: 50,
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
                    //  initialValue: editItem ? item.amount.toString() : '',
                    controller: amountController,
                    //   initialValue: '1',
                    decoration: const InputDecoration(),
                    maxLength: 20,
                    // keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    //      onSaved: (val) {
                    //        titleController.text = val;
                    //        setState(() {});
                    //      },
                    autovalidateMode: AutovalidateMode.always,
                    validator: (value) {
                      //       if (value!.isEmpty) {
                      //         return 'You must give at least 1 number';
                      //       }

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
                    newItem
                        ? addItem(itemController.text, amountController.text)
                        : editItem(item.id, itemController.text,
                            amountController.text);
                    itemController.clear();
                    amountController.clear();
                    setState(() {});
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(33, 150, 243, 1)),
                child: const Text('Save'),
              ),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
            ],
          );
        });
  }

  @override
  void dispose() {
    itemController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
