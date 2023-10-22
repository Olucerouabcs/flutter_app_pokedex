import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'listagen.dart';
import 'listaPoke.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeApidex',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: PokemonGenerationsPage(),
    );
  }
}

class PokemonGenerationsPage extends StatefulWidget {
  @override
  _PokemonGenerationsPageState createState() => _PokemonGenerationsPageState();
}

class _PokemonGenerationsPageState extends State<PokemonGenerationsPage> {
  List<String> generations = [];

  @override
  void initState() {
    super.initState();
    fetchPokemonGenerations();
  }

  Future<void> fetchPokemonGenerations() async {
    final response =
        await http.get(Uri.parse('https://pokeapi.co/api/v2/generation'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        generations = List<String>.from(
            data['results'].map((generation) => generation['name']));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PokeApidDex'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ListaPoke(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: generations.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.red[300],
                minimumSize:
                    Size(200, 60), // Establece el tamaño mínimo del botón
                padding: EdgeInsets.all(20), // Establece el relleno del botón
                textStyle:
                    TextStyle(fontSize: 20), // Establece el tamaño del texto
              ),
              onPressed: () {
                int numGen = 1;
                String nombreGen = "Kanto";
                switch (generations[index]) {
                  case "generation-i":
                    numGen = 1;
                    nombreGen = "Kanto";
                    break;
                  case "generation-ii":
                    numGen = 2;
                    nombreGen = "Johto";
                    break;
                  case "generation-iii":
                    numGen = 3;
                    nombreGen = "Hoenn";
                    break;
                  case "generation-iv":
                    numGen = 4;
                    nombreGen = "Sinnoh";
                    break;
                  case "generation-v":
                    numGen = 5;
                    nombreGen = "Unova";
                    break;
                  case "generation-vi":
                    numGen = 6;
                    nombreGen = "Kalos";
                    break;
                  case "generation-vii":
                    numGen = 7;
                    nombreGen = "Alola";
                    break;
                  case "generation-viii":
                    numGen = 8;
                    nombreGen = "Galar";
                    break;
                  case "generation-ix":
                    numGen = 9;
                    nombreGen = "Paldea";
                    break;
                  default:
                    numGen =
                        1; // Valor predeterminado si no se encuentra una coincidencia
                }
                print('numGen: $numGen'); // Imprimir el valor de numGen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListagenPage(numGen),
                  ),
                );
              },
              child: Text(generations[index].toUpperCase()),
            ),
          );
        },
      ),
    );
  }
}
