// data/poke_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class PokeApi {
  final String baseUrl = 'https://pokeapi.co/api/v2';

  Future<dynamic> fetchGenerations() async {
    final response = await http.get(Uri.parse('$baseUrl/generation'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['results'];
    } else {
      throw Exception('Failed to load generations');
    }
  }
}
