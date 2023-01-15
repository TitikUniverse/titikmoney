import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.cyan
      ),
      title: 'T.Money',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _dateController;

  @override
  void initState() {
    _dateController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                clipBehavior: Clip.hardEdge,
                height: double.infinity,
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
                  child: ListView.builder(
                    itemCount: 30,
                    itemBuilder: (context, index) => Container(
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
                                children: const [
                                  Icon(
                                    Icons.date_range
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '02.02.2000',
                                    style: TextStyle(
                                      fontSize: 14
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    CupertinoIcons.money_rubl
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    CupertinoIcons.minus,
                                    size: 15,
                                    color: Colors.red,
                                  ),
                                  Text(
                                    '350',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          const Flexible(
                            flex: 3,
                            child: Text(
                              'На рождение меня sdfsdfsdfsdfsdfsdfsdsf hgfmhgmjhgjhgkjhgkjhgkjhg'
                            ),
                          )
                        ],
                      ),
                    )
                  ),
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
                                          child: Container(
                                            height: double.infinity,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 255, 202, 202),
                                              borderRadius: BorderRadius.circular(20)
                                            ),
                                            child: const Icon(
                                              CupertinoIcons.minus
                                            )
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
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
                                OutlinedButton.icon(
                                  onPressed: () {},
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
                              maxLines: 6,
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
    );
  }
}