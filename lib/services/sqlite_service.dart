import 'package:glitcher/data/models/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class UserSqlite {
  static Database db;
  static String tableName = 'users';

  static Future open() async {
    String initPath = await getDatabasesPath();
    String path = join(initPath, 'glitcher.db');

    ///Uncomment this line if you want to recreate table
    //await deleteDatabase(path);

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          create table $tableName( 
            id text primary key, 
            name text,
            username text not null,
            profile_url text,
            cover_url text,
            description text,
            following integer,
            followers integer,
            friends integer,
            followed_games integer,
            is_following integer,
            is_friend integer,
            is_verified integer,
            is_follower integer)
          ''');
      },
    );
  }

  static Future<int> insert(User user) async {
    if (db == null || !db.isOpen) {
      await open();
    }
    Map userMap = user.toMap();
    try {
      return await db.insert(tableName, userMap);
    } catch (ex) {
      String initPath = await getDatabasesPath();
      String path = join(initPath, 'glitcher.db');
      await deleteDatabase(path);
    }
    return null;
  }

  static Future<User> getUserWithId(String id) async {
    if (db == null || !db.isOpen) {
      await open();
    }
    try {
      List<Map> maps = await db.query(tableName,
          columns: [
            'id',
            'name',
            'username',
            'profile_url',
            'cover_url',
            'description',
            'following',
            'followers',
            'friends',
            'followed_games',
            'is_following',
            'is_friend',
            'is_verified',
            'is_follower'
          ],
          where: 'id = ?',
          whereArgs: [id]);
      if (maps.length > 0) {
        return User.fromMap(maps.first);
      }
    } catch (ex) {
      String initPath = await getDatabasesPath();
      String path = join(initPath, 'glitcher.db');
      await deleteDatabase(path);
    }

    return null;
  }

  static Future<List<User>> getByCategory(String category) async {
    if (db == null || !db.isOpen) {
      await open();
    }

    String where = '';

    switch (category) {
      case 'friends':
        where = 'is_friend = ?';
        break;
      case 'following':
        where = 'is_following = ?';
        break;
      case 'followers':
        where = 'is_follower = ?';
        break;
    }

    try {
      List<Map> maps = await db.query(tableName,
          columns: [
            'id',
            'name',
            'username',
            'profile_url',
            'cover_url',
            'description',
            'following',
            'followers',
            'friends',
            'followed_games',
            'is_following',
            'is_friend',
            'is_verified',
            'is_follower'
          ],
          where: where,
          whereArgs: [1]);

      if (maps.length > 0) {
        List<User> friends = maps.map((map) => User.fromMap(map)).toList();
        return friends;
      }
    } catch (ex) {
      String initPath = await getDatabasesPath();
      String path = join(initPath, 'glitcher.db');
      await deleteDatabase(path);
    }

    await close();

    return null;
  }

  static Future<int> delete(String id) async {
    if (db == null || !db.isOpen) {
      await open();
    }
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(User user) async {
    if (db == null || !db.isOpen) {
      await open();
    }
    try {
      return await db.update(tableName, user.toMap(),
          where: 'id = ?', whereArgs: [user.id]);
    } catch (ex) {
      String initPath = await getDatabasesPath();
      String path = join(initPath, 'glitcher.db');
      await deleteDatabase(path);
    }
    return null;
  }

  static Future close() async => db.close();
}
