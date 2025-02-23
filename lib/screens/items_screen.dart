import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/models/list_item.dart';
import 'package:shopping_list/notifiers/item_notifier.dart';
import 'package:shopping_list/utils/categorize_items.dart';
import 'package:shopping_list/utils/get_suggestions.dart';
import 'package:shopping_list/widgets/about_content.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  const ItemsScreen({required this.toHomeScreen, super.key});

  final void Function() toHomeScreen;

  @override
  ConsumerState<ItemsScreen> createState() {
    return _ItemsScreenState();
  }
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final GlobalKey<FormState> _keyDialogForm = GlobalKey<FormState>();
  bool isCategorizing = false;

  @override
  void dispose() {
    itemController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> showDeleteAllDialog() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete all?'),
            content: const Text(
                'If you continue, all items from the list will disappear.'),
            actions: <Widget>[
              TextButton(
                  onPressed: () async {
                    // await deleteAll();
                    ref.read(itemProvider.notifier).deleteAll();
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'))
            ],
          );
        });
  }

  Future<void> showAbout() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('About'),
            content: const AboutContent(),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Back'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    //final Future<List<ListItem>> _listItems = fetchItems();

    final List<ListItem> listItems = ref.watch(itemProvider);

    // print('************ listItems on items_screen *********');
    // for (ListItem item in listItems) {
    //   print(item.itemName);
    //   print(item.category);
    // }

    // print('************ listItems on items_screen *********');

    final Map<String, List<ListItem>> groupedContent = groupItems(listItems);

    return Scaffold(
        appBar: AppBar(
            title: const Center(
                child: Text(
          'Was there everything?',
        ))),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Add item',
          onPressed: () {
            showaddItemDialog(listItems: listItems);
          },
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: listItems.isEmpty
              ? Center(
                  child: Text('No items in list'),
                )
              : isCategorizing
                  ? Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      child: Center(
                        child: Column(
                          children: [
                            //      Center(child: const Text('Item List')),
                            Expanded(
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: ListView(
                                  padding: EdgeInsets.zero,
                                  children:
                                      groupedContent.entries.expand((entry) {
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
                                                    showaddItemDialog(
                                                        item: item);
                                                    setState(() {});
                                                  },
                                                  icon: const Icon(Icons.edit)),
                                              IconButton(
                                                  onPressed: () async {
                                                    //await deleteItem(item.id);
                                                    await ref
                                                        .read(itemProvider
                                                            .notifier)
                                                        .deleteItem(item.id);
                                                  },
                                                  icon: Icon(
                                                      Icons.delete_rounded)),
                                            ],
                                          ),
                                          title: GestureDetector(
                                            onTap: () async {
                                              // await toggleAcquiredProvider(item);

                                              ref
                                                  .read(itemProvider.notifier)
                                                  .toggleAcquiredProvider(item);
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
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
        bottomNavigationBar: BottomAppBar(
          padding: EdgeInsets.all(0),
          child: Padding(
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await showDeleteAllDialog();
                        },
                        icon: Icon(Icons.delete),
                      ),
                      Text(
                        'Delete all',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.category),
                      onPressed: () async {
                        setState(() {
                          isCategorizing = true;
                        });

                        try {
                          final content =
                              ref.read(itemProvider); // Fetch items again

                          if (content.isEmpty) {
                            return;
                          }
                          final testResult = await categorizeItems(content);

                          await parseAndGroupItems(content, testResult, ref);
                          ref.invalidate(itemProvider);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())));
                        }

                        setState(() {
                          isCategorizing = false;
                        });
                      },
                    ),
                    Text(
                      'AI-Categorize',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info),
                      onPressed: showAbout,
                    ),
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.exit_to_app),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        ref.read(itemProvider.notifier).reset();

                        widget.toHomeScreen();
                      },
                    ),
                    Text(
                      'Logout',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Future showaddItemDialog({List<ListItem>? listItems, ListItem? item}) async {
    final newItem = item == null;
    bool editItem = false;
    final suggestions = await getSuggestions();
    if (item != null) {
      print('item in adhowAddItemDialog: $item');
      editItem = true;
      itemController.text = item.itemName;
      amountController.text = item.amount.toString();
      print(
          'item.Controller.text in adhowAddItemDialog: ${itemController.text}');
    }
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Form(
              key: _keyDialogForm,
              child: Column(
                children: <Widget>[
                  TypeAheadField(
                      hideOnEmpty: true,
                      controller: itemController,
                      itemBuilder: (context, suggestion) {
                        return ListTile(title: Text(suggestion));
                      },
                      onSelected: (suggestion) {
                        itemController.text = suggestion;
                      },
                      suggestionsCallback: (pattern) async {
                        if (pattern == '') {
                          return [];
                        }

                        return suggestions
                            .where((item) => item
                                .toLowerCase()
                                .contains(pattern.toLowerCase()))
                            .toList();
                      },
                      builder: (context, controller, focusNode) {
                        return TextFormField(
                          // initialValue: editItem ? item.itemName : '',
                          // initialValue: editItem ? item!.itemName : '',

                          controller: controller,
                          focusNode: focusNode,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            label: Text('Grocery Item'),
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
                            } else if (value.isNotEmpty && editItem) {
                              return null;
                            } else if (value.isNotEmpty &&
                                listItems!.isNotEmpty &&
                                item == null &&
                                listItems
                                    .map((ListItem item) => item.itemName)
                                    .contains(value)) {
                              // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                              return 'Item already in list';
                            }

                            return null;
                          },
                        );
                      }),
                  TextFormField(
                    //  initialValue: editItem ? item.amount.toString() : '',
                    controller: amountController,
                    //   initialValue: '1',
                    decoration: const InputDecoration(label: Text('Amount')),
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
                onPressed: () async {
                  if (_keyDialogForm.currentState!.validate()) {
                    newItem
                        ? ref
                            .read(itemProvider.notifier)
                            .addItem(itemController.text, amountController.text)

                        // ? await addItem(
                        //     itemController.text, amountController.text)

                        : ref.read(itemProvider.notifier).editItem(
                            item.id,
                            itemController.text,
                            amountController.text,
                            item.category);

                    // await editItem(item.id, itemController.text,
                    //     amountController.text, item.category);

                    itemController.clear();
                    amountController.clear();

                    // setState(() {});

                    // Delay the pop to ensure the widget has been disposed
                    if (mounted) {
                      await Future.delayed(Duration(milliseconds: 50));
                      Navigator.pop(context);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(33, 150, 243, 1)),
                child: const Text('Save'),
              ),
              ElevatedButton(
                  onPressed: () {
                    itemController.clear();
                    amountController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
            ],
          );
        });
  }
}
