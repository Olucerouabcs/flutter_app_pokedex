import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: generations.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(primary: Colors.green[300]),
              onPressed: () {},
              child: Text(generations[index].toUpperCase()),
            ),
          );
        },
      ),
    );
  }
}
