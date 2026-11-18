import 'dart:convert';
import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:dentify_flutter/inventory/data/model/item_response.dart';
import 'package:dentify_flutter/inventory/data/remote/dto/item_request.dart';
import 'package:http/http.dart' as http;

class ItemService {
  final String baseUrl;

  ItemService(this.baseUrl);

  Future<List<ItemResponse>> getAllItems() async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      ApiConstants.endpoint(baseUrl, 'v1/items'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print("BODY: ${response.body}");
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((item) => ItemResponse.fromJson(item)).toList();
    } else {
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      throw Exception('Failed to load items');
    }
  }

  Future<void> deleteItem(int id) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      ApiConstants.endpoint(baseUrl, 'v1/items/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete item');
    }
  }

  Future<ItemResponse> createItem(ItemRequest request) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      ApiConstants.endpoint(baseUrl, 'v1/items'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to create item');
    }

    final data = json.decode(response.body);
    return ItemResponse.fromJson(data);
  }

  Future<void> updateItem(int id, ItemRequest request) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.put(
      ApiConstants.endpoint(baseUrl, 'v1/items/$id'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: json.encode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item');
    }
  }
}
