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

    final response = await http
        .get(
          ApiConstants.endpoint(baseUrl, 'v1/items'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse =
          json.decode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((item) => ItemResponse.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error al cargar los insumos (${response.statusCode})');
    }
  }

  Future<void> deleteItem(int id) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http
        .delete(
          ApiConstants.endpoint(baseUrl, 'v1/items/$id'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el insumo');
    }
  }

  Future<ItemResponse> createItem(ItemRequest request) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http
        .post(
          ApiConstants.endpoint(baseUrl, 'v1/items'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      throw Exception('Error al registrar el insumo');
    }

    final data = json.decode(utf8.decode(response.bodyBytes));
    return ItemResponse.fromJson(data);
  }

  Future<void> updateItem(int id, ItemRequest request) async {
    final token = await TokenStorage.getAccessToken();

    final response = await http
        .put(
          ApiConstants.endpoint(baseUrl, 'v1/items/$id'),
          headers: {
            'Content-Type': 'application/json',
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
          body: json.encode(request.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el insumo');
    }
  }
}
