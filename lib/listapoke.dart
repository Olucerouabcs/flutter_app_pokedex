import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokedetalles.dart';

class ListaPoke extends StatefulWidget {
  @override
  _ListaPokeState createState() => _ListaPokeState();
}

class _ListaPokeState extends State<ListaPoke> {
  String searchText = '';
  List<Map<String, dynamic>> searchResults =
      []; // Lista de pares de nombre y número de Pokédex

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscar Pokémon'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  searchText = text;
                  buscarPokemonesPorNombre(text);
                });
              },
              decoration:
                  InputDecoration(labelText: 'Buscar Pokémon por nombre'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final pokemon = searchResults[index];
                return GestureDetector(
                  onTap: () {
                    final pokedexNumber = pokemon[
                        'pokedexNumber']; // Obtener el número de la Pokédex
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokedetallesPage(
                          pokedexNumber: pokedexNumber,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title:
                        Text(pokemon['name']), // Mostrar el nombre del Pokémon
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> buscarPokemonesPorNombre(String query) async {
    final response = await http.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon?limit=1017')); // Obtener datos de los primeros 1000 Pokémon

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];

      List<Map<String, dynamic>> resultados = [];

      for (var result in results) {
        final pokemonName = result['name'];
        if (pokemonName.toLowerCase().contains(query.toLowerCase())) {
          final pokedexNumber =
              results.indexOf(result) + 1; // Calcular el número de Pokédex
          resultados.add({
            'name': pokemonName,
            'pokedexNumber': pokedexNumber,
          });
        }
      }

      setState(() {
        searchResults = resultados;
      });
    }
  }
}
