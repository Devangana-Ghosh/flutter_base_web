import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants.dart';


class ApiService {
  static Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse('${Constants.apiUrl}${Constants.productsEndpoint}'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load products');
    }
  }
}

