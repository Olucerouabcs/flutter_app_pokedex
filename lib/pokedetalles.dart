import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PokedetallesPage extends StatelessWidget {
  final int pokedexNumber;

  PokedetallesPage({required this.pokedexNumber});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PokemonDetails>(
      future: fetchPokemonDetails(pokedexNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(''),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Detalles del Pokémon'),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(''),
            ),
            body: Center(child: Text('Cargando detalles...')),
          );
        } else {
          final details = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('${details.name}'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Verificar si details.spriteUrl es vacío o nulo
                    details.spriteUrl.isEmpty
                        ? Text('No hay sprite disponible')
                        : Image.network(details.spriteUrl, height: 200),
                    Text(
                      'Nombre: ${details.name}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Número de Pokedex: #$pokedexNumber',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Tipos: ${details.types.join(", ")}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Altura: ${details.height.toStringAsFixed(1)} M',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Peso: ${details.weight.toStringAsFixed(1)} KG',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Habilidades: ${details.abilities.join(", ")}',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Estadísticas Base:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    for (var stat in details.baseStats.keys)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$stat:',
                            style: TextStyle(fontSize: 18),
                          ),
                          Text(
                            '${details.baseStats[stat]}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class PokemonDetails {
  final String name;
  final List<String> types;
  final String spriteUrl;
  final double height;
  final double weight;
  final List<String> abilities;
  final Map<String, int> baseStats;

  PokemonDetails({
    required this.name,
    required this.types,
    required this.spriteUrl,
    required this.height,
    required this.weight,
    required this.abilities,
    required this.baseStats,
  });
}

Future<PokemonDetails> fetchPokemonDetails(int pokedexNumber) async {
  // Haz una solicitud a la API de PokeAPI para obtener detalles del Pokémon
  final response = await http
      .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokedexNumber/'));
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // Extrae los datos necesarios y crea un objeto PokemonDetails
    final name = data['name'];
    final types = (data['types'] as List)
        .map((type) => type['type']['name'].toString())
        .toList();
// Verificar si 'sprites' contiene una URL válida
    final spriteUrl = data['sprites']['front_default'] != null
        ? data['sprites']['front_default'].toString()
        : ''; // Puedes asignar una URL por defecto o un valor vacío en caso de no existir
    final height = data['height'] / 10.0;
    final weight = data['weight'] / 10.0;
    final abilities = (data['abilities'] as List)
        .map((ability) => ability['ability']['name'].toString())
        .toList();
    final baseStats = {
      'HP': data['stats'][0]['base_stat'] as int,
      'Ataque': data['stats'][1]['base_stat'] as int,
      'Defensa': data['stats'][2]['base_stat'] as int,
      'Ataque especial': data['stats'][3]['base_stat'] as int,
      'Defensa especial': data['stats'][4]['base_stat'] as int,
      'Velocidad': data['stats'][5]['base_stat'] as int,
    };
    return PokemonDetails(
      name: name,
      types: types,
      spriteUrl: spriteUrl,
      height: height,
      weight: weight,
      abilities: abilities,
      baseStats: baseStats,
    );
  } else {
    throw Exception('Solicitud fallida con el estado: ${response.statusCode}');
  }
}

void main() {
  runApp(MaterialApp(
    home: PokedetallesPage(
        pokedexNumber:
            1), // Cambia el número de Pokedex según el Pokémon que desees mostrar
  ));
}
