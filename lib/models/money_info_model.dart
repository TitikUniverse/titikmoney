import 'package:floor/floor.dart';

@entity
class MoneyInfoModel {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String operationType;
  final double amountOfMoney;
  final DateTime dateTimeStamp;
  final String? description;
  final String? tags;

  MoneyInfoModel({this.id, required this.operationType, required this.amountOfMoney, required this.dateTimeStamp, this.description, this.tags});
}