import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:glitcher/constants/constants.dart';
import 'package:glitcher/data/models/game_model.dart';
import 'package:http/http.dart' as http;

class GamesRepo {
  // This function is used to get the author info of each post
  static Future<Game> getGameWithId(String gameId) async {
    DocumentSnapshot gameDocSnapshot = await gamesRef.doc(gameId).get();
    if (gameDocSnapshot.exists) {
      return Game.fromDoc(gameDocSnapshot);
    }
    return Game();
  }

  static getGames() async {
    QuerySnapshot gameSnapshot = await gamesRef
        .where('frequency', isGreaterThan: 0)
        .orderBy(
          'frequency',
          descending: true,
        )
        .limit(20)
        .get();
    List<Game> games =
        gameSnapshot.docs.map((doc) => Game.fromDoc(doc)).toList();
    return games;
  }

//  static getGameNames() async {
//    Constants.games = [];
//    QuerySnapshot gameSnapshot =
//        await gamesRef.orderBy('fullName', descending: true).get();
//    List<Game> games =
//        gameSnapshot.docs.map((doc) => Game.fromDoc(doc)).toList();
//
//    for (var game in games) {
//      Constants.games.add(game.fullName);
//    }
//  }

  static Future<List<Game>> getNextGames(int lastVisibleGameSnapShot) async {
    QuerySnapshot gameSnapshot = await gamesRef
        .where('frequency', isGreaterThan: 0)
        .orderBy(
          'frequency',
          descending: true,
        )
        .startAfter([lastVisibleGameSnapShot])
        .limit(20)
        .get();
    List<Game> games =
        gameSnapshot.docs.map((doc) => Game.fromDoc(doc)).toList();
    return games;
  }

  static Future<List> searchGames(text) async {
    QuerySnapshot gameSnapshot = await gamesRef
        .where('search', arrayContains: text)
        .orderBy('fullName', descending: false)
        .limit(20)
        .get();
    List<Game> games =
        gameSnapshot.docs.map((doc) => Game.fromDoc(doc)).toList();
    if (games.length == 0) {
      String url =
          'https://api.rawg.io/api/games?search=$text&search_precise=1&key=$rawgAPIkey';
      try {
        var response = await http.get(
          Uri.parse(url),
        );
        var body = jsonDecode(response.body);
        (body['results'] as List).forEach((gameData) {
          games.add(Game.fromMap(gameData));
        });
      } catch (e) {
        //print('fetching games error $e');
      }
    }

    return games;
  }

  static Future<List> nextSearchGames(
      String lastVisibleGameSnapShot, String text) async {
    QuerySnapshot gameSnapshot = await gamesRef
        .where('search', arrayContains: text)
        .orderBy('fullName', descending: false)
        .startAfter([lastVisibleGameSnapShot])
        .limit(20)
        .get();
    List<Game> games =
        gameSnapshot.docs.map((doc) => Game.fromDoc(doc)).toList();
    return games;
  }

  static Future<List<Game>> getAllFollowedGames(String userId) async {
    QuerySnapshot followedGamesSnapshot =
        await usersRef.doc(userId).collection('followedGames').get();

    List<Game> followedGames = [];
    Constants.followedGamesNames = [];

    for (DocumentSnapshot doc in followedGamesSnapshot.docs) {
      Game game = await getGameWithId(doc.id);
      followedGames.add(game);
      if (userId == Constants.currentUserID) {
        Constants.followedGamesNames.add(game.fullName);
      }
    }

    return followedGames;
  }

  static followGame(String gameId) async {
    DocumentSnapshot gameDocSnapshot = await usersRef
        .doc(Constants.currentUserID)
        .collection('followedGames')
        .doc(gameId)
        .get();
    if (!gameDocSnapshot.exists) {
      await usersRef
          .doc(Constants.currentUserID)
          .collection('followedGames')
          .doc(gameId)
          .set({'followedAt': FieldValue.serverTimestamp()});
    }

    await usersRef
        .doc(Constants.currentUserID)
        .update({'followed_games': FieldValue.increment(1)});
  }

  static unFollowGame(String gameId) async {
    DocumentSnapshot gameDocSnapshot = await usersRef
        .doc(Constants.currentUserID)
        .collection('followedGames')
        .doc(gameId)
        .get();
    if (gameDocSnapshot.exists) {
      await usersRef
          .doc(Constants.currentUserID)
          .collection('followedGames')
          .doc(gameId)
          .delete();
    }

    await usersRef
        .doc(Constants.currentUserID)
        .update({'followed_games': FieldValue.increment(-1)});
  }

  static Future<Game> getGameWithGameName(String gameName) async {
    QuerySnapshot gameDocSnapshot =
        await gamesRef.where('fullName', isEqualTo: gameName).get();
    Game game =
        gameDocSnapshot.docs.map((doc) => Game.fromDoc(doc)).toList()[0];

    return game;
  }
}
