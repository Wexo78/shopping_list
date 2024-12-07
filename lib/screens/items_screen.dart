import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list/models/list_item.dart';
import 'package:shopping_list/providers/item_provider.dart';
import 'package:shopping_list/utils/categorize_items.dart';

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

    List<String> testItems = ['omena', 'maito', 'porkkana', 'juusto'];

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
          final Map<String, List<ListItem>> groupedContent =
              groupItems(content);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                children: [
                  //      Center(child: const Text('Item List')),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: groupedContent.entries.expand((entry) {
                        final category = entry.key;
                        final items = entry.value;

                        return [
                          // Add category header
                          Text(
                            category,
                            style: TextStyle(
                                color: Colors.purple,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.fontSize),
                          ),
                          // Add items under the category
                          ...items.map(
                            (item) => ListTile(
                              dense: true,
                              minVerticalPadding: 0,
                              visualDensity: VisualDensity.compact,
                              contentPadding: EdgeInsets.zero,
                              key: ValueKey(item.id),
                              leading: Text(
                                item.amount.toString(),
                                style: TextStyle(
                                  fontSize: 12,
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
                                      icon: Icon(Icons.delete_rounded)),
                                ],
                              ),
                              title: GestureDetector(
                                onTap: () async {
                                  await toggleAcquiredProvider(item);

                                  setState(() {});
                                },
                                child: Text(
                                  item.itemName,
                                  style: TextStyle(
                                    decoration: item.acquired
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ];
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
                      const SizedBox(
                        width: 36,
                      ),
                      /*
                      ElevatedButton(
                          onPressed: () async {
                            final testResult = await categorizeItems(content);
                            print('******** testResult *******');
                            print(testResult);
                            final categorizedItems =
                                await parseAndGroupItems(content, testResult);

                            print(categorizedItems[0]);
                            setState(() {});
                          },
                          child: const Text('Reorder'))
                          */
                    ],
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                      icon: const Icon(Icons.exit_to_app),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        widget.toHomeScreen();
                      },
                      label: const Text('Logout')),
                  const SizedBox(
                    height: 16,
                  ),
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
                            amountController.text, item.category);
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
