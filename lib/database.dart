// ignore_for_file: unused_import
// flutter packages pub run build_runner build
// https://pinchbv.github.io/floor/migrations/

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:titikmoney/models/money_info_model.dart';
import 'package:titikmoney/dao/money_info_dao.dart';
import 'package:titikmoney/type_converter.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 2, entities: [MoneyInfoModel])
@TypeConverters([DateTimeConverter])
abstract class AppDatabase extends FloorDatabase {
  MoneyInfoDao get moneyInfoDao;
}