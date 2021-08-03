import 'package:cloud_firestore/cloud_firestore.dart';

class Game {
  final String id;
  final String fullName;
  final String shortName;
  final String description;
  final String image;
  final String releaseDate;
  final String esrbRating;
  final String website;
  final int metacritic;
  final bool tba;
  final List genres;
  final List platforms;
  final List stores;
  final List developers;
  final List<dynamic> search;
  final int frequency;
  final dynamic timestamp;

  Game({
    this.id,
    this.fullName,
    this.shortName,
    this.description,
    this.image,
    this.releaseDate,
    this.esrbRating,
    this.website,
    this.metacritic,
    this.tba,
    this.genres,
    this.platforms,
    this.stores,
    this.developers,
    this.search,
    this.frequency,
    this.timestamp,
  });

  factory Game.fromDoc(DocumentSnapshot doc) {
    Map data = doc.data();

    return Game(
      id: doc.id,
      fullName: data['fullName'],
      shortName: data['shortName'],
      description: data['description'],
      image: data['image'],
      releaseDate: data['release_date'],
      esrbRating: data['esrb_rating'],
      website: data['website'],
      metacritic: data['metacritic'],
      tba: data['tba'],
      genres: data['genres'],
      platforms: data['platforms'],
      stores: data['stores'],
      developers: data['developers'],
      search: data['search'],
      frequency: data['frequency'],
      timestamp: data['timestamp'],
    );
  }
}
