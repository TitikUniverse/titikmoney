import 'package:flutter/material.dart';
import 'package:titikmoney/components/analytic_item.dart';
import 'package:titikmoney/components/money_info_item.dart';
import 'package:titikmoney/models/day_analytic_money_model.dart';

class ViewAnalyticScreen extends StatefulWidget {
  const ViewAnalyticScreen({super.key, required this.analyticMoneyModel});

  final DayAnalyticMoneyModel analyticMoneyModel;

  @override
  State<ViewAnalyticScreen> createState() => _ViewAnalyticScreenState();
}

class _ViewAnalyticScreenState extends State<ViewAnalyticScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Аналитика за ${widget.analyticMoneyModel.date}'
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'date_${widget.analyticMoneyModel.date}',
                child: AnalyticItem(analyticMoneyModel: widget.analyticMoneyModel),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8, top: 16, left: 16),
                child: Text(
                  'Список операций',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: widget.analyticMoneyModel.items.length,
                itemBuilder: (context, index) => MoneyInfoItem(moneyInfoModel: widget.analyticMoneyModel.items[index]),
              )
            ],
          ),
        ),
      ),
    );
  }
}