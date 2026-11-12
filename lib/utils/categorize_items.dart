import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/list_item.dart';
import 'package:shopping_list/notifiers/item_notifier.dart';

var apiKey = dotenv.env['OPENAI_API_KEY'];
var baseUrl = dotenv.env['BASE_URL'];

String decodeResponse(String response) {
  // Decode any incorrectly encoded characters (like HedelmÃ¤t -> Hedelmät)
  return utf8.decode(response.runes.toList());
}

Map<String, List<ListItem>> groupItems(List<ListItem> items) {
  final Map<String, List<ListItem>> groupedItems = {};
  for (var item in items) {
    if (!groupedItems.containsKey(item.category)) {
      groupedItems[item.category] = [];
    }
    if (item.acquired == true) {
      groupedItems[item.category]!.add(item);
    } else {
      groupedItems[item.category]!.insert(0, item);
    }
  }

  return groupedItems;
}

Future<void> parseAndGroupItems(List<ListItem> items,
    Map<String, List<String>> responseText, WidgetRef ref) async {
  Map<String, List<String>> categorizedItems = {};

  for (var item in items) {
    item.category = 'Uncategorized'; // Default category

    for (var entry in responseText.entries) {
      String categoryName = entry.key;
      List<String> keywords = entry.value;

      if (keywords.any((keyword) =>
          item.itemName.toLowerCase().contains(keyword.toLowerCase()))) {
        await ref
            .read(itemProvider.notifier)
            .editItem(item.id, item.itemName, item.amount!, categoryName);
      }
    }
  }

  return;
}

Future<Map<String, List<String>>> categorizeItems(List<ListItem> items) async {
  final url = Uri.parse(baseUrl!);

  // Join the items into a single string, separated by commas or newlines

  List<String> itemNames = [];

  for (final item in items) {
    itemNames.add(item.itemName);
  }

  final itemList = itemNames.join(', ');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-6-luna',
        'messages': [
          {
            'role': 'system',
            'content': '''
              Group shopping items into categories.
              Create category names in English.
              Preserve item names EXACTLY as provided.
              Never translate, rename, correct, or shorten item names.
              Include each item exactly once.
              Return only a JSON object where keys are category names
              and values are arrays of the original item names.
              '''
          },
          {
            'role': 'user',
            'content': 'Group these items: ${jsonEncode(itemNames)}',
          }
        ],
        'max_completion_tokens': 1000,
        'reasoning_effort': 'none',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      // Check if the 'choices' array exists and is not empty
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        final content = data['choices'][0]['message']['content'];

        // Check if the content is not null before trimming
        if (content != null) {
          // Decode the response if necessary (if there's an encoding issue)
          //String decodedText = decodeResponse(content).trim();
          final decodedText = (content as String).trim();
          final Map<String, dynamic> tempMap = jsonDecode(decodedText);

          final Map<String, List<String>> categorizedItems = tempMap.map(
            (key, value) => MapEntry(key, List<String>.from(value)),
          );
          return categorizedItems;
        } else {
          throw Exception('No content in the response');
        }
      } else {
        throw Exception('No choices in the response');
      }
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes))['error'];

      throw Exception(
          'Error: ${error['message']}. Status code: ${response.statusCode}, ');
    }
  } catch (e) {
    // Log the error for debugging
    print('Error: $e');
    rethrow;
  }
}
