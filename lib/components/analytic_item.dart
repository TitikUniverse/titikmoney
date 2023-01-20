import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titikmoney/models/day_analytic_money_model.dart';
import 'package:titikmoney/screens/view_analytic_screen.dart';

class AnalyticItem extends StatelessWidget {
  AnalyticItem({super.key, required this.analyticMoneyModel});

  final DayAnalyticMoneyModel analyticMoneyModel;
  final DateFormat _analyticDateFormat = DateFormat('dd MMM');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder:(context) => ViewAnalyticScreen(analyticMoneyModel: analyticMoneyModel)));
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 1
            )
          ],
          borderRadius: BorderRadius.circular(20)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _analyticDateFormat.format(DateTime.now()) == analyticMoneyModel.date 
                ? 'Сегодня' 
                : _analyticDateFormat.format(DateTime.now().add(const Duration(days: -1))) == analyticMoneyModel.date 
                  ? 'Вчера' 
                  : analyticMoneyModel.date,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16
              )
            ),
            const SizedBox(height: 6),
            Text(
              'Всего операций: ${analyticMoneyModel.items.length}'
            ),
            Row(
              children: [
                Text(
                  '-${analyticMoneyModel.totalExpenses.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  )
                ),
                const SizedBox(width: 6),
                Text(
                  '+${analyticMoneyModel.totalRevenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}