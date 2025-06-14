import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/list_item.dart';
import '../notifiers/item_notifier.dart';
import '../utils/get_suggestions.dart';

Future<void> showItemDialog({
  required BuildContext context,
  required WidgetRef ref,
  required TextEditingController itemController,
  required TextEditingController amountController,
  required GlobalKey<FormState> formKey,
  List<ListItem>? listItems,
  ListItem? item,
}) async {
  final isNewItem = item == null;
  final suggestions = await getSuggestions();

  if (!isNewItem) {
    itemController.text = item!.itemName;
    amountController.text = item.amount.toString();
  }

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TypeAheadField(
              hideOnEmpty: true,
              controller: itemController,
              itemBuilder: (context, suggestion) =>
                  ListTile(title: Text(suggestion)),
              onSelected: (suggestion) => itemController.text = suggestion,
              suggestionsCallback: (pattern) => pattern.isEmpty
                  ? []
                  : suggestions
                      .where((i) =>
                          i.toLowerCase().contains(pattern.toLowerCase()))
                      .toList(),
              builder: (context, controller, focusNode) => TextFormField(
                controller: controller,
                focusNode: focusNode,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(label: Text('Grocery Item')),
                maxLength: 50,
                textAlign: TextAlign.center,
                autovalidateMode: AutovalidateMode.always,
                validator: (value) {
                  if (value!.isEmpty) return 'You must type something';
                  if (!isNewItem) return null;
                  final alreadyExists = listItems!
                      .map((i) => i.itemName.toLowerCase())
                      .contains(value.toLowerCase());
                  return alreadyExists ? 'Item already in list' : null;
                },
              ),
            ),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(label: Text('Amount')),
              maxLength: 20,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final provider = ref.read(itemProvider.notifier);
              if (isNewItem) {
                provider.addItem(itemController.text, amountController.text);
              } else {
                provider.editItem(item!.id, itemController.text,
                    amountController.text, item.category);
              }
              itemController.clear();
              amountController.clear();
              Navigator.pop(context);
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
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
