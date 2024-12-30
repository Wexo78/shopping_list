import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/models/list_item.dart';
import 'package:shopping_list/notifiers/item_notifier.dart';

class SuggestionDialogContent extends ConsumerWidget {
  // Get suggested itemes and show them on a list
  // Save picked items and pass them to
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    final Future<List<ListItem>> suggestedItems =
        ref.read(itemProvider.notifier).suggestItems();
  }
}
