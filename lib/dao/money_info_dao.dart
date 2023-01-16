import 'package:floor/floor.dart';
import 'package:titikmoney/models/money_info_model.dart';

@dao
abstract class MoneyInfoDao {
  @Query('SELECT * FROM MoneyInfoModel')
  Future<List<MoneyInfoModel>> getAllMoneyInfo();

  @Query('SELECT * FROM MoneyInfoModel WHERE id = :id')
  Stream<MoneyInfoModel?> findMoneyInfoById(int id);

  @delete
  Future<void> deletemoneyInfo(MoneyInfoModel moneyInfoModel);

  @delete
  Future<void> deletemoneyInfos(List<MoneyInfoModel> moneyInfoModel);

  @insert
  Future<void> insertMoneyInfo(MoneyInfoModel moneyInfoModel);
}