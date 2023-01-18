import 'package:titikmoney/models/money_info_model.dart';

class DayAnalyticMoneyModel {
  final String date;
  final List<MoneyInfoModel> items;
  double totalRevenue;
  double totalExpenses;

  DayAnalyticMoneyModel({
    required this.date,
    required this.items,
    required this.totalExpenses,
    required this.totalRevenue,
  });
}