import 'package:flutter/material.dart';

mixin BgMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    print('BgMixin initState');
    super.initState();
  }

  @override
  void dispose() {
    print('BgMixin dispose');
    super.dispose();
  }
}
