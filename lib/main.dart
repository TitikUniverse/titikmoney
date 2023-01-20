import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:masked_text/masked_text.dart';
import 'package:intl/intl.dart';
import 'package:titikmoney/components/analytic_item.dart';
import 'package:titikmoney/components/money_info_item.dart';
import 'package:titikmoney/database.dart';
import 'package:titikmoney/extensions/first_where-or_null.dart';
import 'package:titikmoney/models/day_analytic_money_model.dart';
import 'package:titikmoney/models/money_info_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

GlobalKey<_MyAppState> myApp = GlobalKey();
bool isBeginnigSession = true;

Future<void> main() async {
  Intl.defaultLocale = 'ru_RU';
  WidgetsFlutterBinding.ensureInitialized();

  final database = await $FloorAppDatabase
      .databaseBuilder('titik_money_2.db')
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

class CustomPageRoute<T> extends MaterialPageRoute { // PageRouteBuilder
  @override
  Duration get transitionDuration => const Duration(milliseconds: 0);

  CustomPageRoute({builder}) : super(builder: builder);
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
  late TextEditingController _tagController;
  late  FocusNode _moneyFocusNode;
  late FocusNode _tagFocusNode;
  String operationType = 'spend';
  bool _isLoading = true;
  final DateFormat _analyticDateFormat = DateFormat('dd MMM');

  final List<MoneyInfoModel> _moneyInfoModel = [];
  final List<DayAnalyticMoneyModel> _dayAnalyticMoneyModel = [];
  final List<String> _availableTags = [];

  @override
  void initState() {
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _descriptionController = TextEditingController();
    _moneyController = TextEditingController();
    _tagController = TextEditingController();
    _moneyFocusNode = FocusNode();
    _tagFocusNode = FocusNode();
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (isBeginnigSession) {
        _moneyFocusNode.requestFocus();
        isBeginnigSession = false;
      }
      await loadMoneyInfo();
    });
  }

  /// Выборка всех доступных тегов в один список
  void updateAvailableTags() {
    for (MoneyInfoModel item in _moneyInfoModel) {
      List<String> tags = item.tags!.isNotEmpty ? item.tags!.split(',') : [];
      for (int i = 0; i < tags.length; i++) {
        String? findedTag = _availableTags.firstWhereOrNull((element) => element.toLowerCase() == tags[i].trim().toLowerCase());
        if (findedTag == null) _availableTags.add(tags[i].trim());
      }
    }
  }

  Future loadMoneyInfo() async {
    setState(() {
      _isLoading = true;
    });
    List<MoneyInfoModel> queryResult = await widget.database.moneyInfoDao.getAllMoneyInfo();
    _moneyInfoModel.clear();
    _moneyInfoModel.addAll(queryResult.reversed.toList());
    _moneyInfoModel.sort((a,b) {
      return b.dateTimeStamp.compareTo(a.dateTimeStamp);
    });

    updateAvailableTags();

    // Расчеты для экрана аналитики
    for (MoneyInfoModel element in _moneyInfoModel) {
      String elementDate = _analyticDateFormat.format(element.dateTimeStamp);
      DayAnalyticMoneyModel? dayAnalyticModel = _dayAnalyticMoneyModel.firstWhereOrNull((element) => element.date == elementDate);
      if (dayAnalyticModel != null) {
        // Такой день уже существет и его надо обновить
        int index = _dayAnalyticMoneyModel.indexWhere((element) => element.date == elementDate);
        _dayAnalyticMoneyModel[index].items.add(element);
        double totalExpenses = element.operationType == 'spend' ? element.amountOfMoney : 0;
        double totalRevenue = element.operationType == 'income' ? element.amountOfMoney : 0;
        _dayAnalyticMoneyModel[index].totalExpenses += totalExpenses;
        _dayAnalyticMoneyModel[index].totalRevenue += totalRevenue;
      }
      else {
        // Такой день не существует и его надо создать
        double totalExpenses = element.operationType == 'spend' ? element.amountOfMoney : 0;
        double totalRevenue = element.operationType == 'income' ? element.amountOfMoney : 0;

        final value = DayAnalyticMoneyModel(
          date: elementDate,
          items: [element],
          totalExpenses: totalExpenses,
          totalRevenue: totalRevenue
        );

        _dayAnalyticMoneyModel.add(value);
      }
    }
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
    _tagController.dispose();
    _moneyFocusNode.dispose();
    _tagFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> recomendedTags = createRecomendedTags();
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
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(20), right: Radius.circular(20)),
                    // color: Theme.of(context).colorScheme.secondary,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.cyan, Colors.blue]
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 2
                      )
                    ],
                  ),
                  // clipBehavior: Clip.hardEdge,
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    children: [
                      SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: _isLoading 
                          ? const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ) 
                          : _moneyInfoModel.isEmpty 
                            ? const Center(
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
                            : ListView.builder(
                              itemCount: _moneyInfoModel.length,
                              itemBuilder: (context, index) => MoneyInfoItem(moneyInfoModel: _moneyInfoModel[index], onDelete: loadMoneyInfo)
                            ),
                      ),
                      SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: _dayAnalyticMoneyModel.isEmpty
                        ? const Center(
                          child: Text(
                            'Тут будет аналитика по дням'
                          ),
                        )
                        : ListView.builder(
                          itemCount: _dayAnalyticMoneyModel.length,
                          itemBuilder: (context, index) => Hero(
                            tag: 'date_${_dayAnalyticMoneyModel[index].date}',
                            child: AnalyticItem(analyticMoneyModel: _dayAnalyticMoneyModel[index])
                          )
                        ),
                      )
                    ],
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
                                            focusNode: _moneyFocusNode,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 20),
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
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
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
                                          _dateController.selection = TextSelection.fromPosition(
                                            TextPosition(offset: _dateController.text.length),
                                          );
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
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
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
                                          _timeController.selection = TextSelection.fromPosition(
                                            TextPosition(offset: _timeController.text.length),
                                          );
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

                                      String tags = _tagController.text.trim();

                                      MoneyInfoModel moneyInfoModel = MoneyInfoModel(
                                        operationType: operationType,
                                        amountOfMoney: double.parse(_moneyController.text),
                                        dateTimeStamp: dateTime,
                                        description: _descriptionController.text.isNotEmpty ? _descriptionController.text.trim() : '',
                                        tags: tags
                                      );
      
                                      await widget.database.moneyInfoDao.insertMoneyInfo(moneyInfoModel);
      
                                      _dateController.clear();
                                      _timeController.clear();
                                      _descriptionController.clear();
                                      _moneyController.clear();
                                      _tagController.clear();

                                      Vibrate.feedback(FeedbackType.success);

                                      showTopSnackBar(
                                        Overlay.of(context)!,
                                        const CustomSnackBar.success(message: "Добавлено"),
                                        dismissType: DismissType.onSwipe,
                                      );

                                      Navigator.pushReplacement(context, CustomPageRoute(builder:(context) => MyHomePage(database: widget.database))); // Почему-то только так можно увидеть обновленные жанные в списе. Если реал обновить через loadMoneyInfo(), то ничего не обновляется, пока список не покрутишь
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
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _descriptionController,
                                    maxLines: 4,
                                    textCapitalization: TextCapitalization.sentences,
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
                                  const SizedBox(height: 10),
                                  Focus(
                                    onFocusChange: (hasFocus) {
                                      setState(() {
                                        // Нужно чтобы перерисовался bottomNavBar, он зависит от фокуса
                                      });
                                    },
                                    child: TextField(
                                      controller: _tagController,
                                      focusNode: _tagFocusNode,
                                      minLines: 1,
                                      maxLines: 3,
                                      textCapitalization: TextCapitalization.sentences,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                                        filled: true,
                                        fillColor: const Color(0xFFf3f4f9),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(20)
                                        ),
                                        hintText: 'Теги',
                                        hintStyle: const TextStyle(
                                          color: Colors.black26
                                        ),
                                        labelText: 'Теги',
                                        prefixIcon: const Icon(
                                          CupertinoIcons.tag
                                        )
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          // Обновляет фильтр ввода и перезагружает список слов
                                        });
                                      },
                                    ),
                                  ),
                                  const Text(
                                    'Вводите через запятую',
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontSize: 12
                                    ),
                                  )
                                ],
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
      bottomNavigationBar: _tagFocusNode.hasFocus ? Container(
        width: double.infinity,
        height: 50,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: Colors.cyan.withOpacity(.1)
        ),
        child: recomendedTags.isEmpty 
        ? const Center(
          child: Text(
            'Добавьте хотя бы один тег, чтобы сормировались подсказки'
          ),
        )
        : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: recomendedTags
          ),
        )
      ) : null
    );
  }

  List<Widget> createRecomendedTags() {
    List<Widget> value = [];

    for (int i = 0; i < _availableTags.length; i++) {
      List<String> enteredTags = _tagController.text.split(',');
      String lastTag = enteredTags.last.trim();

      if (_availableTags[i].toLowerCase().contains(lastTag.toLowerCase()) == false) continue;
      Widget widget = InkWell(
        onTap: () {
          setState(() {
            _tagController.text = _tagController.text + _availableTags[i];
            _tagController.selection = TextSelection.fromPosition(
              TextPosition(offset: _tagController.text.length),
            );
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.cyanAccent.withOpacity(.3),
            borderRadius: BorderRadius.circular(6)
          ),
          child: Text(
            _availableTags[i],
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w600
            ),
          ),
        ),
      );

      value.add(widget);

      if (i < _availableTags.length) value.add(const SizedBox(width: 10));
    }

    return value;
  }
}
