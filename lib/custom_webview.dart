import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_practice/images.dart';
import 'package:share_plus/share_plus.dart';
import 'package:time/time.dart';

class CustomWebView extends StatefulWidget {
  const CustomWebView({super.key, required this.url, this.title = ''});
  final String url;
  final String title;

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  final GlobalKey webViewKey = GlobalKey();
  int progress = 0;
  String title = '';
  InAppWebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    title = widget.title;
  }

  @override
  void dispose() {
    _webViewController?.dispose();
    super.dispose();
  }

  Future<void> _backOrClose() async {
    if (await _webViewController?.canGoBack() ?? false) {
      _webViewController?.goBack();
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _backOrClose();
      },
      child: Scaffold(
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              Container(
                height: 50,
                width: double.infinity,
                color: Colors.white,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        _backOrClose();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 16, top: 16, right: 16, bottom: 8),
                        child: Image.asset(
                          ImageRes.webClose,
                          width: 26,
                          height: 26,
                        ),
                      ),
                    ),
                    Expanded(
                        child: Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 16, bottom: 8),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              title,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color(0xFF333333),
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.41,
                              ),
                            ),
                          ),
                          Positioned(
                              right: 0,
                              child: Container(
                                height: 26,
                                width: 48,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    gradient: LinearGradient(
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                        colors: [
                                          const Color(0xFFFFFFFF),
                                          const Color(0xFFFFFFFF)
                                              .withOpacity(0),
                                        ])),
                              )),
                        ],
                      ),
                    )),
                    GestureDetector(
                      onTap: () {
                        Share.share(widget.url);
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 16, top: 16, right: 16, bottom: 8),
                        child: Image.asset(
                          ImageRes.webShare,
                          width: 26,
                          height: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        isInspectable: false,
                        useShouldOverrideUrlLoading: true,
                      ),
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                      },
                      onTitleChanged: (controller, title) {
                        setState(() {
                          this.title = title ?? '';
                        });
                      },
                      onProgressChanged: (controller, progress) {
                        setState(() {
                          this.progress = progress;
                        });
                      },
                      shouldOverrideUrlLoading:
                          (controller, navigationAction) async {
                        if (kIsWeb || !Platform.isAndroid) {
                          return NavigationActionPolicy.ALLOW;
                        }

                        final schema = navigationAction.request.url?.scheme;
                        if (schema == 'https' || schema == 'http') {
                          return NavigationActionPolicy.ALLOW;
                        }
                        print('schema无法识别: ${navigationAction.request.url}');
                        return NavigationActionPolicy.ALLOW;
                      },
                    ),
                    AnimatedOpacity(
                      opacity: progress >= 100 ? 0 : 1,
                      duration: 200.milliseconds,
                      child: LinearProgressIndicator(
                        color: Colors.blue,
                        value: progress / 100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
