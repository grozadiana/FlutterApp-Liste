import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class Movie {
  final String title;
  final int year;
  final double rating;
  final List<String> genres;

  Movie({
    required this.title,
    required this.year,
    required this.rating,
    required this.genres,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Movie List'),
        ),
        body: FutureBuilder<List<Movie>>(
          future: fetchMovies(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Movie> movies = snapshot.data!;
              return ListView.builder(
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(movies[index].title),
                    subtitle: Text('Year: ${movies[index].year}, Rating: ${movies[index].rating}'),
                    trailing: Text('Genres: ${movies[index].genres.join(', ')}'),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Future<List<Movie>> fetchMovies() async {
    final Uri url = Uri.parse('https://yts.mx/api/v2/list_movies.json');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> moviesData = data['data']['movies'];

      return moviesData.map((movieData) {
        return Movie(
          title: movieData['title_long'],
          year: movieData['year'],
          rating: movieData['rating'].toDouble(),
          genres: List<String>.from(movieData['genres']),
        );
      }).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
