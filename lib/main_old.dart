import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_practice/model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'state_mixin.dart';

void main() {
  Model model = const Model(name: 'wood', age: 18);
  print(model);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with BgMixin<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppBar')),
      body: Center(
          child: Linkify(
        onOpen: (link) async {
          print('Clicked: ${link.url}');
          if (!await launchUrl(Uri.parse(link.url))) {
            print('Could not launch ${link.url}');
          }
        },
        text: 'Made by https://cretezy.com, another link https://google.com',
        linkStyle: TextStyle(
          color: Color(0xEF7663),
          decoration: TextDecoration.underline,
          decorationColor: Colors.blue,
        ),
        options: const LinkifyOptions(humanize: false),
      )),
      drawer:
          Drawer(child: Container(width: 200, height: 200, color: Colors.red)),
      endDrawer: Drawer(
          child: Container(width: 200, height: 200, color: Colors.green)),
    );
  }
}
