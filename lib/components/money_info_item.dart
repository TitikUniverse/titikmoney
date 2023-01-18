
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:titikmoney/main.dart';
import 'package:titikmoney/models/money_info_model.dart';

class MoneyInfoItem extends StatefulWidget {
  const MoneyInfoItem({Key? key, required this.moneyInfoModel, this.onDelete}) : super(key: key);

  final MoneyInfoModel moneyInfoModel;
  final void Function()? onDelete;

  @override
  State<MoneyInfoItem> createState() => _MoneyInfoItemState();
}

class _MoneyInfoItemState extends State<MoneyInfoItem> {
  DateFormat dateFormat = DateFormat("dd MMM");
  DateFormat timeFormat = DateFormat("HH:mm");

  final List<String> _tags = [];

  @override
  void initState() {
    if (widget.moneyInfoModel.tags! != '') {
      List<String> words = widget.moneyInfoModel.tags!.split(',');
      for (var element in words) {
        _tags.add(element.trim());
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoContextMenu(
      actions: [
        CupertinoContextMenuAction(
          onPressed: () {
            myApp.currentState!.widget.database.moneyInfoDao.deletemoneyInfo(widget.moneyInfoModel);
            if (widget.onDelete != null) widget.onDelete!();
            Navigator.pop(context);
          },
          trailingIcon: CupertinoIcons.delete,
          isDestructiveAction: true,
          child: const Text('Удалить'),
        )
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 40,
          maxHeight: 110
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 2
            )
          ],
          borderRadius: BorderRadius.circular(20)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.date_range
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateFormat.format(widget.moneyInfoModel.dateTimeStamp),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        Text(
                          timeFormat.format(widget.moneyInfoModel.dateTimeStamp),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.money_rubl
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      widget.moneyInfoModel.operationType == 'spend' 
                        ? CupertinoIcons.minus
                        : widget.moneyInfoModel.operationType == 'income'
                          ? CupertinoIcons.plus
                          : CupertinoIcons.question,
                      size: 15,
                      color: widget.moneyInfoModel.operationType == 'spend' 
                        ? Colors.red
                        : widget.moneyInfoModel.operationType == 'income' 
                          ? Colors.green
                          : Colors.black,
                    ),
                    Text(
                      widget.moneyInfoModel.amountOfMoney.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.moneyInfoModel.operationType == 'spend' 
                        ? Colors.red
                        : widget.moneyInfoModel.operationType == 'income' 
                          ? Colors.green
                          : Colors.black,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.moneyInfoModel.description != null && widget.moneyInfoModel.description!.isNotEmpty) Text(
                    widget.moneyInfoModel.description!
                  ),
                  if (_tags.isNotEmpty) const SizedBox(height: 6),
                  if (_tags.isNotEmpty) Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent.withOpacity(.3),
                              borderRadius: BorderRadius.circular(6)
                            ),
                            child: Text(
                              _tags[index],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                        ],
                      ),
                      separatorBuilder:(context, index) => const SizedBox(width: 10),
                      itemCount: _tags.length
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}