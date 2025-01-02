import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/product.dart';

class ProductsRepository {
  final String baseUrl = 'https://dummyjson.com/products';

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        print('API Response: ${response.body}');

        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> productsList = data['products'] as List<dynamic>;

        return productsList.map((productJson) {
          try {
            return Product.fromJson(productJson as Map<String, dynamic>);
          } catch (e) {
            print('Error parsing product: $productJson');
            print('Error details: $e');
            throw e;
          }
        }).toList();
      }

      throw Exception(
          'Failed to load products. Status code: ${response.statusCode}');
    } catch (e) {
      print('Error in getProducts: $e');
      throw Exception('Failed to load products: $e');
    }
  }

  Future<Product> getProductById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data);
      }

      throw Exception(
          'Failed to load product details. Status code: ${response.statusCode}');
    } catch (e) {
      print('Error in getProductById: $e');
      throw Exception('Failed to load product details: $e');
    }
  }
}
