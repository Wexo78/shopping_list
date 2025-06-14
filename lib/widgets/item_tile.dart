import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/list_item.dart';
import '../notifiers/item_notifier.dart';

class ItemTile extends ConsumerWidget {
  final ListItem item;
  final VoidCallback onEdit;

  const ItemTile({super.key, required this.item, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      minVerticalPadding: 0,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      key: ValueKey(item.id),
      leading: Text(
        item.amount.toString(),
        style: TextStyle(
          fontSize: 12,
          decoration: item.acquired ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () =>
                ref.read(itemProvider.notifier).deleteItem(item.id),
            icon: const Icon(Icons.delete_rounded),
          ),
        ],
      ),
      title: GestureDetector(
        onTap: () =>
            ref.read(itemProvider.notifier).toggleAcquiredProvider(item),
        child: Text(
          item.itemName,
          style: TextStyle(
            decoration: item.acquired ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
