import 'package:custom_scroll_indicator/scroll_indicator.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Custom Scroll Indicator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ScrollController _scrollController;

  final colors = [
    Colors.amber,
    Colors.blue,
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.brown,
  ];
  double offsetPercent = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(scrollListener);
  }

  void scrollListener() {
    if (_scrollController.hasClients) {
      _updateIndicator(scrollPosition: _scrollController.position.pixels);
    }
  }

  void _updateIndicator({double scrollPosition = 0}) {
    // print('scrollPosition: $scrollPosition');
    // print('scrollMax: ${_scrollController.position.maxScrollExtent}');

    final scroll100Percent = _scrollController.position.maxScrollExtent;
    setState(() {
      offsetPercent = scrollPosition * 100 / scroll100Percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: colors.length,
                itemBuilder: ((context, index) {
                  // return Text('data');
                  return Container(
                    width: 300.0,
                    color: colors[index],
                  );
                })),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: ScrollIndicator(
              height: 16.0,
              width: 150,
              offsetPercent: offsetPercent,
              color: Colors.white,
              diamondColor: Colors.lightGreen,
            ),
          ),
        ],
      ),
    );
  }
}
