import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_practice/colors.dart';
import 'package:flutter_practice/extension.dart';
import 'package:flutter_practice/images.dart';
import 'package:collection/collection.dart';

class ChatPlusDialog extends StatefulWidget {
  const ChatPlusDialog({super.key, this.onTap});

  final Function(ToolboxType type)? onTap;

  static void show(BuildContext context, Function(ToolboxType type) onTap) {
    showDialog(
        context: context,
        barrierColor: ColorRes.transparent,
        barrierDismissible: false,
        useSafeArea: false,
        builder: (context) => Dialog(
            backgroundColor: ColorRes.transparent,
            insetPadding: EdgeInsets.zero,
            child: ChatPlusDialog(onTap: onTap)));
  }

  @override
  State<ChatPlusDialog> createState() => _ChatPlusDialogState();
}

class _ChatPlusDialogState extends State<ChatPlusDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  VoidCallback? _callback;

  bool _backPress = false;

  final int rotateDuration = 920;
  final int totalDuration = 1420;

  late Animation<double> _bgRedScaleAnimation;
  late List<Animation<double>> _bgCircleAnimations;
  final List<String> _bgCircleImages = [
    ImageRes.chatPlusCircle1,
    ImageRes.chatPlusCircle2,
    ImageRes.chatPlusCircle3
  ];
  late Animation<double> _moreIconScaleAnimation;
  late Animation<double> _moreIconRotateAnimation;
  late Animation<double> _spreadOpacityAnimation;
  late Animation<double> _spreadSizeAnimation;
  late List<Animation<double>> _itemScaleAnimations;
  late List<Animation<double>> _itemTransitionAnimations;
  late List<Animation<double>> _itemRotateAnimations;
  final List<double> _itemAngles = [
    0,
    1 / 12 * pi * 2,
    2 / 12 * pi * 2,
    3 / 12 * pi * 2
  ];

  final List<(ToolboxType type, String image)> _typeAndImages = [
    (ToolboxType.album, ImageRes.chatPlusImage),
    (ToolboxType.voice, ImageRes.chatPlusVoice),
    (ToolboxType.video, ImageRes.chatPlusVideo),
    (ToolboxType.gift, ImageRes.chatPlusGift)
  ];

  @override
  void initState() {
    super.initState();
    timeDilation = 10;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDuration),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        Navigator.pop(context);
        _callback?.call();
      }
    });

    _bgRedScaleAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 5 / 12, curve: Curves.ease)));

    _bgCircleAnimations = [
      Tween(begin: pi / 2, end: .0).animate(CurvedAnimation(
          parent: _controller,
          curve: const Interval(6 / 12, 9 / 12, curve: Curves.ease))),
      Tween(begin: -pi / 2, end: .0).animate(CurvedAnimation(
          parent: _controller,
          curve: const Interval(3 / 12, 9 / 12, curve: Curves.ease))),
      Tween(begin: pi / 2, end: .0).animate(CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 6 / 12, curve: Curves.ease))),
    ];

    _moreIconScaleAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.85)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 15 / 110),
      TweenSequenceItem(
          tween: Tween(begin: 0.85, end: 1.3)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 45 / 110),
      TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 0.9)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 40 / 110),
      TweenSequenceItem(
          tween: Tween(begin: 0.9, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 10 / 110),
    ]).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, rotateDuration / totalDuration)));

    _moreIconRotateAnimation = Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(6 / 30 * rotateDuration / totalDuration,
                (6 + 10 + 9) / 30 * rotateDuration / totalDuration)));

    _spreadOpacityAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.0)
              .chain(CurveTween(curve: Curves.linear)),
          weight: (6 + 10) / 30 * rotateDuration / totalDuration),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1 - (6 + 10) / 30 * rotateDuration / totalDuration),
    ]).animate(_controller);

    _spreadSizeAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 1.3)
              .chain(CurveTween(curve: Curves.linear)),
          weight: 60 / 110 * rotateDuration / totalDuration),
      TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 2.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1 - 60 / 110 * rotateDuration / totalDuration),
    ]).animate(_controller);

    _itemScaleAnimations = [
      Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 4 / 12, curve: Curves.ease),
      )),
      Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(1 / 12, 5 / 12, curve: Curves.ease),
      )),
      Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(2 / 12, 6 / 12, curve: Curves.ease),
      )),
      Tween<double>(begin: 0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(3 / 12, 7 / 12, curve: Curves.ease),
      )),
    ];

    _itemTransitionAnimations = [
      Tween(begin: 0.e, end: -(_itemContainerWidth / 2 - 60.e - 36.e)).animate(
          CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 6 / 12, curve: Curves.ease))),
      Tween(begin: 0.e, end: -(_itemContainerWidth / 2 - 60.e - 36.e)).animate(
          CurvedAnimation(
              parent: _controller,
              curve: const Interval(1 / 12, 7 / 12, curve: Curves.ease))),
      Tween(begin: 0.e, end: -(_itemContainerWidth / 2 - 60.e - 36.e)).animate(
          CurvedAnimation(
              parent: _controller,
              curve: const Interval(2 / 12, 8 / 12, curve: Curves.ease))),
      Tween(begin: 0.e, end: -(_itemContainerWidth / 2 - 60.e - 36.e)).animate(
          CurvedAnimation(
              parent: _controller,
              curve: const Interval(3 / 12, 9 / 12, curve: Curves.ease))),
    ];

    final rotateSequence = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: -15 / 360 * 2 * pi, end: 10 / 360 * 2 * pi)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 25 / (15 + 10 + 15 + 5)),
      TweenSequenceItem(
          tween: Tween(begin: 10 / 360 * 2 * pi, end: -5 / 360 * 2 * pi)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 15 / (15 + 10 + 15 + 5)),
      TweenSequenceItem(
          tween: Tween(begin: -5 / 360 * 2 * pi, end: 0 / 360 * 2 * pi)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 5 / (15 + 10 + 15 + 5)),
    ]);

    _itemRotateAnimations = [
      rotateSequence.animate(CurvedAnimation(
          parent: _controller, curve: const Interval(4 / 12, 9 / 12))),
      rotateSequence.animate(CurvedAnimation(
          parent: _controller, curve: const Interval(5 / 12, 10 / 12))),
      rotateSequence.animate(CurvedAnimation(
          parent: _controller, curve: const Interval(6 / 12, 11 / 12))),
      rotateSequence.animate(CurvedAnimation(
          parent: _controller, curve: const Interval(7 / 12, 12 / 12))),
    ];
    _controller.forward();
  }

  @override
  void dispose() {
    timeDilation = 1.0;
    _controller.dispose();
    super.dispose();
  }

  void _onTapItem(ToolboxType type) {
    _callback = () => widget.onTap?.call(type);
    _onBack();
  }

  void _onBack() {
    setState(() {
      _backPress = true;
      // _controller.duration = const Duration(milliseconds: 300);
      _controller.reverse();
    });
  }

  // 获取屏幕对角线长度
  // double diagonal = sqrt(pow(1.sw, 2) + pow(1.sh, 2));
  double bgWidth = 638.e;
  final double _itemContainerWidth = 544.e;
  @override
  Widget build(BuildContext context) {
    // timeDilation = 10.0;
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            _onBack();
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.e, sigmaY: 10.e),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                        ColorRes.black.withOpacity(0.1),
                        const Color(0xFFF3EFEB)
                      ])),
                )),
          ),
        ),
        Positioned(
          // right: -bgWidth / 2 + 14.e + 16.e,
          // bottom: -bgWidth / 2 + 14.e + 16.e + ScreenUtil().bottomBarHeight,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: bgWidth,
              height: bgWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(bgWidth),
                color: ColorRes.transparent,
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) => Transform.scale(
                      scale: _bgRedScaleAnimation.value,
                      child: Container(
                        width: bgWidth,
                        height: bgWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(bgWidth),
                          color: ColorRes.transparent,
                        ),
                        child: Image.asset(ImageRes.chatPlusBg,
                            width: bgWidth, height: bgWidth),
                      ),
                    ),
                  ),
                  ..._bgCircleImages.mapIndexed((index, e) => Center(
                        child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) => Transform.rotate(
                                  angle: _bgCircleAnimations[index].value,
                                  child: Image.asset(e,
                                      width: bgWidth, height: bgWidth),
                                )),
                      )),
                  Center(
                      child: GestureDetectorWithSound(
                    onTap: () {
                      _onBack();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8.e),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (_, __) => Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                                angle: pi / 4 * _moreIconRotateAnimation.value,
                                child: Image.asset(ImageRes.chatInputMore,
                                    width: 28.e * _moreIconScaleAnimation.value,
                                    height:
                                        28.e * _moreIconScaleAnimation.value)),
                            Opacity(
                              opacity: _spreadOpacityAnimation.value,
                              child: Transform.scale(
                                scale: _spreadSizeAnimation.value,
                                child: Container(
                                  width: 28.e,
                                  height: 28.e,
                                  decoration: BoxDecoration(
                                      color: ColorRes.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: ColorRes.black.withOpacity(0.3),
                                        width: 10.e *
                                            max(0,
                                                1 - _spreadSizeAnimation.value),
                                      )),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
                  Center(
                    child: Center(
                      child: Stack(children: [
                        ..._typeAndImages.mapIndexed((index, item) => iconItem(
                            index: index,
                            assetImage: item.$2,
                            onTap: () {
                              _onTapItem(item.$1);
                            }))
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget iconItem(
      {required int index, required String assetImage, VoidCallback? onTap}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.rotate(
        angle: _itemAngles[index],
        child: SizedBox(
          width: _itemContainerWidth,
          height: _itemContainerWidth,
          child: Center(
            child: Transform.translate(
              offset: Offset(_itemTransitionAnimations[index].value, 0),
              child: GestureDetectorWithSound(
                onTap: onTap,
                child: Transform.rotate(
                    angle: -_itemAngles[index] +
                        _itemRotateAnimations[index].value,
                    child: Transform.scale(
                        scale: _itemScaleAnimations[index].value,
                        child: Image.asset(
                          assetImage,
                          width: 36.e,
                          height: 36.e,
                          fit: BoxFit.cover,
                        ))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RightBottomCircleClipper extends CustomClipper<Path> {
  const RightBottomCircleClipper(this.radius);
  final double radius;
  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width, size.height);
    path.addOval(Rect.fromCircle(center: center, radius: radius));

    path.addRect(Rect.fromLTRB(0, 0, size.width, size.height));
    path.fillType = PathFillType.evenOdd;

    return path;
  }

  @override
  bool shouldReclip(RightBottomCircleClipper oldClipper) {
    return oldClipper.radius != radius;
  }
}
