import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:masked_text/masked_text.dart';
import 'package:intl/intl.dart';
import 'package:titikmoney/database.dart';
import 'package:titikmoney/models/money_info_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

GlobalKey<_MyAppState> myApp = GlobalKey();

Future<void> main() async {
  Intl.defaultLocale = 'ru_RU';
  WidgetsFlutterBinding.ensureInitialized();

  final database = await $FloorAppDatabase
      .databaseBuilder('titik_money.db')
      .build();

  runApp(MyApp(key: myApp, database: database));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.database});

  final AppDatabase database;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   primarySwatch: Colors.cyan
      // ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, // This is required
      ],
      supportedLocales: const [
        // Locale('en', 'US'),
        Locale('ru', 'RU'),
      ],
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.cyan,
        primaryContrastingColor: Colors.white,
        textTheme: CupertinoTextThemeData(
          primaryColor: CupertinoColors.black,
          textStyle: TextStyle(color: CupertinoColors.black),
          // ... here I actually utilised all possible parameters in the constructor
          // as you can see in the link underneath
        ),
      ),
      home: MyHomePage(database: widget.database)
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.database});

  final AppDatabase database;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _descriptionController;
  late TextEditingController _moneyController;
  String operationType = 'spend';
  bool _isLoading = true;

  final List<MoneyInfoModel> _moneyInfoModel = [];

  @override
  void initState() {
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _descriptionController = TextEditingController();
    _moneyController = TextEditingController();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await loadMoneyInfo();
    });
  }

  Future loadMoneyInfo() async {
    List<MoneyInfoModel> queryResult = await widget.database.moneyInfoDao.getAllMoneyInfo();
    _moneyInfoModel.clear();
    _moneyInfoModel.addAll(queryResult.reversed.toList());
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _moneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardDismisser(
        gestures: const [GestureType.onTap, GestureType.onPanUpdateDownDirection],
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(20), right: Radius.circular(20)),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 2
                      )
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: _isLoading 
                      ? const Center(
                        child: CircularProgressIndicator.adaptive(),
                      ) 
                      : _moneyInfoModel.isNotEmpty 
                        ? ListView.builder(
                            itemCount: _moneyInfoModel.length,
                            itemBuilder: (context, index) => MoneyInfoItem(moneyInfoModel: _moneyInfoModel[index], onDelete: loadMoneyInfo)
                          )
                        : const Center(
                          child: Text(
                            'Операций пока что нет.\nДобавьте свою первую денежную операцию ниже',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16
                            ),
                          ),
                        )
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 50,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (operationType == 'spend') {
                                                  operationType = 'income';
                                                } else if (operationType == 'income') {
                                                  operationType = 'spend';
                                                }
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(20),
                                            child: Container(
                                              height: double.infinity,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: operationType == 'spend' 
                                                  ? const Color.fromARGB(255, 255, 202, 202) 
                                                  : operationType == 'income' 
                                                    ? const Color.fromARGB(255, 205, 255, 202)
                                                    : Colors.white,
                                                borderRadius: BorderRadius.circular(20)
                                              ),
                                              child: Icon(
                                                operationType == 'spend' 
                                                ? CupertinoIcons.minus 
                                                : operationType == 'income' 
                                                  ? CupertinoIcons.plus
                                                  : CupertinoIcons.question,
                                                color: Colors.black,
                                              )
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          flex: 2,
                                          child: TextField(
                                            controller: _moneyController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                                              filled: true,
                                              fillColor: const Color(0xFFf3f4f9),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                                borderRadius: BorderRadius.circular(20)
                                              ),
                                              hintText: '0',
                                              hintStyle: const TextStyle(
                                                color: Colors.black26
                                              ),
                                              // labelText: 'Сумма',
                                              suffixIconConstraints: const BoxConstraints(
                                                
                                              ),
                                              suffixIcon: const Padding(
                                                padding: EdgeInsets.only(right: 5),
                                                child: Icon(
                                                  CupertinoIcons.money_rubl
                                                ),
                                              )
                                            ),
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  MaskedTextField(
                                    controller: _dateController,
                                    mask: "##.##.####",
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      filled: true,
                                      fillColor: const Color(0xFFf3f4f9),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(20)
                                      ),
                                      hintText: 'Дата',
                                      hintStyle: const TextStyle(
                                        color: Colors.black26
                                      ),
                                      labelText: 'Дата',
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          DateTime now = DateTime.now();
                                          String day = now.day.toString().length == 1 ? '0${now.day.toString()}' : now.day.toString();
                                          String month = now.month.toString().length == 1 ? '0${now.month.toString()}' : now.month.toString();
                                          String date = '$day.$month.${now.year}';
                                          _dateController.text = date;
                                        },
                                        borderRadius: BorderRadius.circular(50),
                                        child: const Icon(
                                          Icons.date_range
                                        ),
                                      )
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  MaskedTextField(
                                    controller: _timeController,
                                    mask: "##:##",
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                      filled: true,
                                      fillColor: const Color(0xFFf3f4f9),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(20)
                                      ),
                                      hintText: 'Время',
                                      hintStyle: const TextStyle(
                                        color: Colors.black26
                                      ),
                                      labelText: 'Время',
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          DateTime now = DateTime.now();
                                          String hour = now.hour.toString().length == 1 ? '0${now.hour.toString()}' : now.hour.toString();
                                          String minute = now.minute.toString().length == 1 ? '0${now.minute.toString()}' : now.minute.toString();
                                          String time = '$hour:$minute';
                                          _timeController.text = time;
                                        },
                                        borderRadius: BorderRadius.circular(50),
                                        child: const Icon(
                                          Icons.date_range
                                        ),
                                      )
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      if (_dateController.text.isEmpty || _timeController.text.isEmpty || _moneyController.text.isEmpty) {
                                        Vibrate.feedback(FeedbackType.warning);
                                        showTopSnackBar(
                                          Overlay.of(context)!,
                                          const CustomSnackBar.info(message: "Заполните необходимые поля"),
                                          dismissType: DismissType.onSwipe,
                                        );
                                        return;
                                      }
                                      DateFormat format = DateFormat("dd.MM.yyyy HH:mm");
                                      DateTime dateTime;
                                      try {
                                        dateTime = format.parse('${_dateController.text} ${_timeController.text}');
                                      }
                                      on FormatException {
                                        Vibrate.feedback(FeedbackType.error);
                                        showTopSnackBar(
                                          Overlay.of(context)!,
                                          const CustomSnackBar.error(message: "Какое-то поле заполнено неверно"),
                                          dismissType: DismissType.onSwipe,
                                        );
                                        return;
                                      }
      
                                      MoneyInfoModel moneyInfoModel = MoneyInfoModel(
                                        operationType: operationType,
                                        amountOfMoney: double.parse(_moneyController.text),
                                        dateTimeStamp: dateTime,
                                        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : ''
                                      );
      
                                      await widget.database.moneyInfoDao.insertMoneyInfo(moneyInfoModel);
      
                                      _dateController.clear();
                                      _timeController.clear();
                                      _descriptionController.clear();
                                      _moneyController.clear();
      
                                      await loadMoneyInfo();

                                      Vibrate.feedback(FeedbackType.success);

                                      showTopSnackBar(
                                        Overlay.of(context)!,
                                        const CustomSnackBar.success(message: "Добавлено"),
                                        dismissType: DismissType.onSwipe,
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                      )
                                    ),
                                    icon: const Icon(CupertinoIcons.add_circled),
                                    label: const Text('Добавить')
                                  )
                                ],
                              )
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: TextField(
                                controller: _descriptionController,
                                maxLines: 9,
                                decoration: InputDecoration(
                                  // contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: ),
                                  filled: true,
                                  fillColor: const Color(0xFFf3f4f9),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  hintText: 'Описание',
                                  hintStyle: const TextStyle(
                                    color: Colors.black26
                                  ),
                                  labelText: 'Описание'
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        width: double.infinity,
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
                            fontSize: 14,
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
                      '350',
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
              child: Text(
                widget.moneyInfoModel.description ?? ''
              ),
            )
          ],
        ),
      ),
    );
  }
}