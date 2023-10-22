import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokedetalles.dart';

class ListagenPage extends StatelessWidget {
  final int numGen;

  ListagenPage(this.numGen);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokemon'),
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: fetchPokemonList(numGen),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data?.isEmpty == true) {
            return Text(
                'No se encontraron Pokémon para esta generación. $numGen');
          } else {
            final pokemonList = snapshot.data!;
            pokemonList
                .sort((a, b) => a.pokedexNumber.compareTo(b.pokedexNumber));

            return ListView.builder(
              itemCount: pokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = pokemonList[index];
                return FutureBuilder<PokemonDetails>(
                  future: fetchPokemonDetails(pokemon.pokedexNumber),
                  builder: (context, detailsSnapshot) {
                    if (detailsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (detailsSnapshot.hasError) {
                      return Text('Error: ${detailsSnapshot.error}');
                    } else if (!detailsSnapshot.hasData) {
                      return Text('Cargando detalles...');
                    } else {
                      final details = detailsSnapshot.data!;
                      return PokemonCard(pokemon: pokemon, details: details);
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Pokemon {
  final int pokedexNumber;
  final String name;

  Pokemon(this.pokedexNumber, this.name);
}

class PokemonDetails {
  final List<String> types;
  final String spriteUrl;

  PokemonDetails(this.types, this.spriteUrl);
}

Future<List<Pokemon>> fetchPokemonList(int numGen) async {
  try {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/generation/$numGen/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Pokemon> pokemonList = [];

      for (final pokemonData in data['pokemon_species']) {
        final pokedexNumber =
            int.parse(pokemonData['url'].split('/').elementAt(6));
        final name = pokemonData['name'];
        final pokemon = Pokemon(pokedexNumber, name);
        pokemonList.add(pokemon);
      }

      return pokemonList;
    } else {
      throw Exception(
          'Solicitud fallida con el estado: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Error al cargar los Pokémon');
  }
}

Future<PokemonDetails> fetchPokemonDetails(int pokedexNumber) async {
  try {
    final response = await http
        .get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokedexNumber/'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Verificar si 'types' y 'sprites' son nulos o no contienen datos válidos
      final types = (data['types'] as List<dynamic>?)?.map((typeData) {
            final typeName = typeData['type']['name'];
            return typeName != null ? typeName.toString() : '';
          })?.toList() ??
          [];

      // Verificar si 'sprites' contiene una URL válida
      final spriteUrl = data['sprites']['front_default'] != null
          ? data['sprites']['front_default'].toString()
          : ''; // Puedes asignar una URL por defecto o un valor vacío en caso de no existir

      return PokemonDetails(types, spriteUrl);
    } else {
      throw Exception(
          'Solicitud fallida con el estado: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Error al cargar los detalles del Pokémon');
  }
}

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final PokemonDetails details;

  PokemonCard({required this.pokemon, required this.details});

  @override
  Widget build(BuildContext context) {
    Map<String, Color> typeColors = {
      'normal': Color.fromRGBO(191, 185, 127, 1.0),
      'fighting': Color.fromRGBO(211, 47, 46, 1.0),
      'flying': Color.fromRGBO(158, 135, 225, 1.0),
      'poison': Color.fromRGBO(170, 71, 188, 1.0),
      'ground': Color(0xFFDFB352),
      'rock': Color(0xFFBDA537),
      'bug': Color(0xFF98B92E),
      'ghost': Color(0xFF7556A4),
      'steel': Color(0xFFB4B4CC),
      'fire': Color(0xFFE86513),
      'water': Color(0xFF2196F3),
      'grass': Color(0xFF4CB050),
      'electric': Color(0xFFFECD07),
      'psychic': Color(0xFFEC407A),
      'ice': Color(0xFF80DEEA),
      'dragon': Color(0xFF673BB7),
      'dark': Color(0xFF5D4038),
      'fairy': Color(0xFFF483BB),
    };

    return Card(
      child: GestureDetector(
        onTap: () {
          int pokedexNumber = pokemon.pokedexNumber;
          print('Número de Pokedex seleccionado: $pokedexNumber');
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return PokedetallesPage(pokedexNumber: pokedexNumber);
          }));
        },
        child: ListTile(
          title: Text(
            '${pokemon.pokedexNumber}. ${pokemon.name}',
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: details.types.map((type) {
                  return Container(
                    margin:
                        EdgeInsets.only(right: 4.0), // Espacio entre los óvalos
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: typeColors[type.toLowerCase()] ??
                          Colors.grey, // Obtén el color del mapa
                      borderRadius:
                          BorderRadius.circular(20.0), // Hacer un óvalo
                    ),
                    child: Text(
                      type,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
              // Verificar si details.spriteUrl es vacío o nulo
              details.spriteUrl.isEmpty
                  ? Text('No hay sprite disponible')
                  : Image.network(details.spriteUrl),
            ],
          ),
        ),
      ),
    );
  }
}
