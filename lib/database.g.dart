// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  MoneyInfoDao? _moneyInfoDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `MoneyInfoModel` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `operationType` TEXT NOT NULL, `amountOfMoney` REAL NOT NULL, `dateTimeStamp` TEXT NOT NULL, `description` TEXT, `tags` TEXT)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  MoneyInfoDao get moneyInfoDao {
    return _moneyInfoDaoInstance ??= _$MoneyInfoDao(database, changeListener);
  }
}

class _$MoneyInfoDao extends MoneyInfoDao {
  _$MoneyInfoDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _moneyInfoModelInsertionAdapter = InsertionAdapter(
            database,
            'MoneyInfoModel',
            (MoneyInfoModel item) => <String, Object?>{
                  'id': item.id,
                  'operationType': item.operationType,
                  'amountOfMoney': item.amountOfMoney,
                  'dateTimeStamp':
                      _dateTimeConverter.encode(item.dateTimeStamp),
                  'description': item.description,
                  'tags': item.tags
                },
            changeListener),
        _moneyInfoModelDeletionAdapter = DeletionAdapter(
            database,
            'MoneyInfoModel',
            ['id'],
            (MoneyInfoModel item) => <String, Object?>{
                  'id': item.id,
                  'operationType': item.operationType,
                  'amountOfMoney': item.amountOfMoney,
                  'dateTimeStamp':
                      _dateTimeConverter.encode(item.dateTimeStamp),
                  'description': item.description,
                  'tags': item.tags
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MoneyInfoModel> _moneyInfoModelInsertionAdapter;

  final DeletionAdapter<MoneyInfoModel> _moneyInfoModelDeletionAdapter;

  @override
  Future<List<MoneyInfoModel>> getAllMoneyInfo() async {
    return _queryAdapter.queryList('SELECT * FROM MoneyInfoModel',
        mapper: (Map<String, Object?> row) => MoneyInfoModel(
            id: row['id'] as int?,
            operationType: row['operationType'] as String,
            amountOfMoney: row['amountOfMoney'] as double,
            dateTimeStamp:
                _dateTimeConverter.decode(row['dateTimeStamp'] as String),
            description: row['description'] as String?,
            tags: row['tags'] as String?));
  }

  @override
  Stream<MoneyInfoModel?> findMoneyInfoById(int id) {
    return _queryAdapter.queryStream(
        'SELECT * FROM MoneyInfoModel WHERE id = ?1',
        mapper: (Map<String, Object?> row) => MoneyInfoModel(
            id: row['id'] as int?,
            operationType: row['operationType'] as String,
            amountOfMoney: row['amountOfMoney'] as double,
            dateTimeStamp:
                _dateTimeConverter.decode(row['dateTimeStamp'] as String),
            description: row['description'] as String?,
            tags: row['tags'] as String?),
        arguments: [id],
        queryableName: 'MoneyInfoModel',
        isView: false);
  }

  @override
  Future<void> insertMoneyInfo(MoneyInfoModel moneyInfoModel) async {
    await _moneyInfoModelInsertionAdapter.insert(
        moneyInfoModel, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletemoneyInfo(MoneyInfoModel moneyInfoModel) async {
    await _moneyInfoModelDeletionAdapter.delete(moneyInfoModel);
  }

  @override
  Future<void> deletemoneyInfos(List<MoneyInfoModel> moneyInfoModel) async {
    await _moneyInfoModelDeletionAdapter.deleteList(moneyInfoModel);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
