import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/models/list_item.dart';
import 'package:shopping_list/providers/item_provider.dart';

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
    groupedItems[item.category]!.add(item);
  }

  return groupedItems;
}

Future<List<ListItem>> parseAndGroupItems(
    List<ListItem> items, Map<String, List<String>> responseText) async {
  Map<String, List<String>> categorizedItems = {};

  for (var item in items) {
    item.category = 'Uncategorized'; // Default category

    responseText.forEach((categoryName, keywords) {
      print(categoryName);
      if (keywords.any((keyword) =>
          item.itemName.toLowerCase().contains(keyword.toLowerCase()))) {
        print(categoryName);
        editItem(item.id, item.itemName, item.amount!, categoryName);

        //  item.category = categoryName;
      }
    });
  }

  return items;
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
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are a helpful assistant that categorizes items into categories such as Vegetables, Dairy Products, etc.'
          },
          {
            'role': 'user',
            'content':
                """Categorize in english the following items: $itemList and return them in the format:
{
  "Fruit": ["Apple"],
  "Dairy Products": ["Milk", "Cheese"],
  "Vegetables": ["Carrot", "Lettuce"]
}"""
          }
        ],
        'max_tokens': 100,
      }),
    );

    // Log the response status code and body for debugging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Check if the 'choices' array exists and is not empty
      if (data['choices'] != null && data['choices'].isNotEmpty) {
        final content = data['choices'][0]['message']['content'];

        // Check if the content is not null before trimming
        if (content != null) {
          // Decode the response if necessary (if there's an encoding issue)
          String decodedText = decodeResponse(content).trim();
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
      throw Exception(
          'Failed to categorize. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // Log the error for debugging
    print('Error: $e');
    rethrow;
  }
}
