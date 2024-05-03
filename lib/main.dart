import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:math';

void main() async {
  await localhostServer.start();
  runApp(const MyApp());
}

InAppLocalhostServer localhostServer = InAppLocalhostServer();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;

  Timer? _timer;

  @override
  void dispose() {
    localhostServer.close();
    webViewController?.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _initData() {
    var newData = {
      "labels": ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
      "datasets": [
        {
          "label": 'Votes',
          "data": [12, 19, 3, 5, 2, 3],
          "backgroundColor": [
            'rgba(255, 99, 132, 0.2)',
            'rgba(54, 162, 235, 0.2)',
            'rgba(255, 206, 86, 0.2)',
            'rgba(75, 192, 192, 0.2)',
            'rgba(153, 102, 255, 0.2)',
            'rgba(255, 159, 64, 0.2)'
          ],
          "borderColor": [
            'rgba(255, 99, 132, 1)',
            'rgba(54, 162, 235, 1)',
            'rgba(255, 206, 86, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(153, 102, 255, 1)',
            'rgba(255, 159, 64, 1)'
          ],
          "borderWidth": 1
        }
      ]
    };

    webViewController?.evaluateJavascript(source: """
      createChart(${jsonEncode(newData)});
    """);

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateData();
    });
  }

  int _randomValue(int value) {
    final random = Random();
    return random.nextInt(value) + 10;
  }

  void _updateData() {
    var newData = {
      "labels": ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
      "datasets": [
        {
          "label": 'Votes',
          "data": [
            _randomValue(12),
            _randomValue(19),
            _randomValue(3),
            _randomValue(5),
            _randomValue(2),
            _randomValue(3)
          ],
          "backgroundColor": [
            'rgba(255, 99, 132, 0.2)',
            'rgba(54, 162, 235, 0.2)',
            'rgba(255, 206, 86, 0.2)',
            'rgba(75, 192, 192, 0.2)',
            'rgba(153, 102, 255, 0.2)',
            'rgba(255, 159, 64, 0.2)'
          ],
          "borderColor": [
            'rgba(255, 99, 132, 1)',
            'rgba(54, 162, 235, 1)',
            'rgba(255, 206, 86, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(153, 102, 255, 1)',
            'rgba(255, 159, 64, 1)'
          ],
          "borderWidth": 1
        }
      ]
    };

    webViewController?.evaluateJavascript(source: """
      updateChart(${jsonEncode(newData)});
    """);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("InAppWebview"),
          actions: [
            IconButton(
                onPressed: () async {
                  _updateData();
                },
                icon: const Icon(Icons.add)),
          ],
        ),
        body: Column(children: <Widget>[
          Expanded(
            child: InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(
                  url: WebUri("http://localhost:8080/assets/chart.html")),
              onConsoleMessage: (controller, consoleMessage) {
                print('onConsoleMessage = $consoleMessage');
              },
              onWebViewCreated: (controller) async {
                webViewController = controller;
                controller.addJavaScriptHandler(
                    handlerName: 'initChart',
                    callback: (args) {
                      _initData();
                    });
              },
            ),
          ),
        ]));
  }
}
