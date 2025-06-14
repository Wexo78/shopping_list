// Refactored ItemsScreen using external widgets for clarity
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/models/list_item.dart';
import 'package:shopping_list/notifiers/item_notifier.dart';
import 'package:shopping_list/utils/categorize_items.dart';
import 'package:shopping_list/utils/get_suggestions.dart';
import 'package:shopping_list/widgets/about_content.dart';
import 'package:shopping_list/widgets/item_tile.dart';
import 'package:shopping_list/widgets/item_dialog.dart';
import 'package:shopping_list/widgets/bottom_bar_button.dart';

class ItemsScreen extends ConsumerStatefulWidget {
  final void Function() toHomeScreen;
  const ItemsScreen({required this.toHomeScreen, super.key});
  @override
  ConsumerState<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends ConsumerState<ItemsScreen> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final GlobalKey<FormState> _itemFormKey = GlobalKey<FormState>();
  bool isCategorizing = false;

  @override
  Widget build(BuildContext context) {
    final listItems = ref.watch(itemProvider);
    final groupedContent = groupItems(listItems);

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Was there everything?'))),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add item',
        onPressed: () => showItemDialog(
          context: context,
          ref: ref,
          itemController: itemController,
          amountController: amountController,
          formKey: _itemFormKey,
          listItems: listItems,
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: listItems.isEmpty
            ? const Center(child: Text('No items in list'))
            : isCategorizing
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: buildItemList(groupedContent),
                    ),
                  ),
      ),
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget buildItemList(Map<String, List<ListItem>> groupedContent) {
    return ListView(
      padding: EdgeInsets.zero,
      children: groupedContent.entries.expand((entry) {
        final category = entry.key;
        final items = entry.value;

        return [
          Text(
            category,
            style: TextStyle(
              color: Colors.purple,
              fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
            ),
          ),
          ...items.map((item) => ItemTile(
                item: item,
                onEdit: () => showItemDialog(
                  context: context,
                  ref: ref,
                  itemController: itemController,
                  amountController: amountController,
                  formKey: _itemFormKey,
                  listItems: groupedContent.values.expand((e) => e).toList(),
                  item: item,
                ),
              )),
        ];
      }).toList(),
    );
  }

  Widget buildBottomBar() {
    return BottomAppBar(
      color: Colors.white,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BottomBarButton(
            icon: Icons.delete,
            label: 'Delete…',
            color: Colors.red,
            onPressed: _showDeleteOptions,
          ),
          BottomBarButton(
            icon: Icons.category,
            label: 'AI-Categorize',
            color: Colors.green,
            onPressed: categorizeItemsWithAI,
          ),
          BottomBarButton(
            icon: Icons.info,
            label: 'About',
            color: Colors.blue,
            onPressed: showAboutDialog,
          ),
          BottomBarButton(
            icon: Icons.exit_to_app,
            label: 'Logout',
            color: Colors.brown,
            onPressed: logout,
          ),
        ],
      ),
    );
  }

  Future<void> showAboutDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About'),
        content: const AboutContent(),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'))
        ],
      ),
    );
  }

  Future<void> _showDeleteAllDialog() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete all?'),
        content: const Text(
            'If you continue, all items from the list will disappear.'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(itemProvider.notifier).deleteAll();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete All'),
              onTap: () async {
                await _showDeleteAllDialog();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep, color: Colors.orange),
              title: const Text('Delete Collected'),
              onTap: () {
                ref.read(itemProvider.notifier).deleteCollected();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> categorizeItemsWithAI() async {
    setState(() => isCategorizing = true);
    try {
      final content = ref.read(itemProvider);
      if (content.isNotEmpty) {
        final result = await categorizeItems(content);
        await parseAndGroupItems(content, result, ref);
        ref.invalidate(itemProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => isCategorizing = false);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    ref.read(itemProvider.notifier).reset();
    widget.toHomeScreen();
  }

  @override
  void dispose() {
    itemController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
