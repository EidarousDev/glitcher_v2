import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glitcher/utils/functions.dart';

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

  factory Game.fromMap(Map game) {
    try {
      List platforms = [];
      if (game['platforms'] != null) {
        (game['platforms'] as List).forEach((platform) {
          platforms.add(platform['platform']['name']);
        });
      }

      List stores = [];
      if (game['stores'] != null) {
        (game['stores'] as List).forEach((store) {
          stores.add(store['store']['name']);
        });
      }

      List publishers = [];
      (game['publishers'] as List)?.forEach((publisher) {
        publishers.add(publisher['name']);
      });

      List developers = [];
      (game['developers'] as List)?.forEach((developer) {
        developers.add(developer['name']);
      });

      List search = searchList(game['name']);
      List genres = [];
      (game['genres'] as List)?.forEach((genre) {
        genres.add(genre['name']);
      });
      return Game(
        id: game['id'].toString(),
        fullName: _fixString(game['name']),
        tba: game['tba'],
        releaseDate: game['released'],
        description: _fixString(game['description_raw'].toString()),
        website: game['website'],
        image: game['background_image'],
        platforms: platforms,
        stores: stores,
        search: search,
        developers: developers,
        frequency: 0,
        genres: genres,
        metacritic: game['metacritic_url'],
        esrbRating:
            game['esrb_rating'] == null ? null : game['esrb_rating']['name'],
      );
    } catch (ex) {
      print('game error: $ex');
      return null;
    }
  }

  addGamesToFirestore() async {
    await FirebaseFirestore.instance
        .collection('games')
        .doc(this.id.toString())
        .set({
      'fullName': this.fullName,
      'tba': this.tba,
      'release_date': this.releaseDate,
      'description': this.description,
      'website': this.website,
      'platforms': this.platforms,
      'stores': this.stores,
      'metacritic': this.metacritic,
      'esrb_rating': this.esrbRating,
      'metacritic_url': this.metacritic,
      'genres': genres,
      'image': this.image,
      'developers': this.developers,
      'timestamp': FieldValue.serverTimestamp(),
      'search': this.search,
      'frequency': 0
    });
  }

  static _fixString(String s) {
    try {
      return utf8.decode(s.runes.toList());
    } catch (ex) {
      return s;
    }
  }
}
