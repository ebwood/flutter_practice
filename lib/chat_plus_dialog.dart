import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_practice/colors.dart';
import 'package:flutter_practice/extension.dart';
import 'package:flutter_practice/images.dart';
import 'package:collection/collection.dart';
import 'package:time/time.dart';

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
  late AnimationController _reverseController;

  AnimationController get controller =>
      _backPress ? _reverseController : _controller;

  VoidCallback? _callback;

  bool _backPress = false;

  final List<String> _bgCircleImages = [
    ImageRes.chatPlusCircle1,
    ImageRes.chatPlusCircle2,
    ImageRes.chatPlusCircle3
  ];

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

  late Animation<double> _bgRedScaleAnimation;
  late Animation<double> _bgRedScaleReverseAnimation;
  Animation<double> get bgRedScaleAnimation =>
      _backPress ? _bgRedScaleReverseAnimation : _bgRedScaleAnimation;

  late List<Animation<double>> _bgCircleAnimations;
  late List<Animation<double>> _bgCircleReverseAnimations;
  List<Animation<double>> get bgCircleAnimations =>
      _backPress ? _bgCircleReverseAnimations : _bgCircleAnimations;

  late Animation<double> _moreIconScaleAnimation;
  late Animation<double> _moreIconScaleReverseAnimation;
  Animation<double> get moreIconScaleAnimation =>
      _backPress ? _moreIconScaleReverseAnimation : _moreIconScaleAnimation;

  late Animation<double> _moreIconRotateAnimation;
  late Animation<double> _moreIconRotateReverseAnimation;
  Animation<double> get moreIconRotateAnimation =>
      _backPress ? _moreIconRotateReverseAnimation : _moreIconRotateAnimation;

  late Animation<double> _spreadOpacityAnimation;
  late Animation<double> _spreadOpacityReverseAnimation;
  Animation<double> get spreadOpacityAnimation =>
      _backPress ? _spreadOpacityReverseAnimation : _spreadOpacityAnimation;

  late Animation<double> _spreadSizeAnimation;
  late Animation<double> _spreadSizeReverseAnimation;
  Animation<double> get spreadSizeAnimation =>
      _backPress ? _spreadSizeReverseAnimation : _spreadSizeAnimation;

  late List<Animation<double>> _itemScaleAnimations;
  late List<Animation<double>> _itemScaleReverseAnimations;
  List<Animation<double>> get itemScaleAnimations =>
      _backPress ? _itemScaleReverseAnimations : _itemScaleAnimations;

  late List<Animation<double>> _itemTransitionAnimations;
  late List<Animation<double>> _itemTransitionReverseAnimations;
  List<Animation<double>> get itemTransitionAnimations =>
      _backPress ? _itemTransitionReverseAnimations : _itemTransitionAnimations;

  late List<Animation<double>> _itemRotateAnimations;
  late List<Animation<double>> _itemRotateReverseAnimations;
  List<Animation<double>> get itemRotateAnimations =>
      _backPress ? _itemRotateReverseAnimations : _itemRotateAnimations;

  int rotateDuration(bool reverse) => reverse ? 920 : 500;
  int totalDuration(bool reverse) => reverse ? 1450 : 1000;
  // 获取屏幕对角线长度
  double get diagonal => sqrt(pow(MediaQuery.of(context).size.width, 2) +
      pow(MediaQuery.of(context).size.height, 2));
  double get bgWidth => 638.e;
  double get _itemContainerWidth => 544.e;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: totalDuration(false).milliseconds);
    initAnimations(_controller,
        rotateDuration: rotateDuration(false),
        totalDuration: totalDuration(false));

    _reverseController = AnimationController(
        vsync: this, duration: totalDuration(true).milliseconds);
    _reverseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
        _callback?.call();
      }
    });
    initReverseAnimations(_reverseController,
        rotateDuration: rotateDuration(true),
        totalDuration: totalDuration(true));

    _controller.forward();
  }

  @override
  void dispose() {
    timeDilation = 1.0;
    _controller.dispose();
    _reverseController.dispose();
    super.dispose();
  }

  void initAnimations(AnimationController controller,
      {required int rotateDuration, required int totalDuration}) {
    // 红色背景动画
    _bgRedScaleAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: controller,
        curve: const Interval(0, 5 / 12, curve: Curves.ease)));

    // 圆形背景动画
    _bgCircleAnimations = [
      Tween(begin: pi / 2, end: .0).animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(6 / 12, 9 / 12, curve: Curves.ease))),
      Tween(begin: -pi / 2, end: .0).animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(3 / 12, 9 / 12, curve: Curves.ease))),
      Tween(begin: 7 * pi / 8, end: 3 * pi / 8).animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(0, 6 / 12, curve: Curves.ease))),
    ];

    // 加号按钮缩放动画
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
        parent: controller,
        curve: Interval(0.0, rotateDuration / totalDuration)));

    // 加号按钮旋转动画
    _moreIconRotateAnimation = Tween(begin: 0.0, end: pi / 4)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(CurvedAnimation(
            parent: controller,
            curve: Interval(15 / 110 * rotateDuration / totalDuration,
                (15 + 45 + 40) / 110 * rotateDuration / totalDuration)));

    // 扩散透明度动画
    _spreadOpacityAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.0)
              .chain(CurveTween(curve: Curves.linear)),
          weight: (15 + 45) / 110 * rotateDuration / totalDuration),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1 - (15 + 45) / 110 * rotateDuration / totalDuration),
    ]).animate(controller);

    // 扩散大小动画
    _spreadSizeAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 1.3)
              .chain(CurveTween(curve: Curves.linear)),
          weight: (15 + 45) / 110 * rotateDuration / totalDuration),
      TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 2.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1 - (15 + 45) / 110 * rotateDuration / totalDuration),
    ]).animate(controller);

    // 图标缩放动画
    final itemScaleTween = Tween<double>(begin: 0, end: 1.0);
    _itemScaleAnimations = [
      itemScaleTween.animate(CurvedAnimation(
        parent: controller,
        curve: const Interval(3 / 12, 7 / 12, curve: Curves.ease),
      )),
      itemScaleTween.animate(CurvedAnimation(
        parent: controller,
        curve: const Interval(4 / 12, 8 / 12, curve: Curves.ease),
      )),
      itemScaleTween.animate(CurvedAnimation(
        parent: controller,
        curve: const Interval(5 / 12, 9 / 12, curve: Curves.ease),
      )),
      itemScaleTween.animate(CurvedAnimation(
        parent: controller,
        curve: const Interval(6 / 12, 10 / 12, curve: Curves.ease),
      )),
    ];

    // 图标移动动画
    final itemTransitionTween =
        Tween(begin: 0.e, end: -(_itemContainerWidth / 2 - 60.e - 36.e));
    _itemTransitionAnimations = [
      itemTransitionTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(3 / 12, 12 / 12, curve: Curves.ease))),
      itemTransitionTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(4 / 12, 12 / 12, curve: Curves.easeOutBack))),
      itemTransitionTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(5 / 12, 12 / 12, curve: Curves.bounceOut))),
      itemTransitionTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(6 / 12, 12 / 12, curve: Curves.elasticOut))),
    ];

    const rotateTotalAngle = 15 + 10 + 15 + 5;
    final rotateSequence = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: -15 / 360 * 2 * pi, end: 10 / 360 * 2 * pi)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 25 / rotateTotalAngle),
      TweenSequenceItem(
          tween: Tween(begin: 10 / 360 * 2 * pi, end: -5 / 360 * 2 * pi)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 15 / rotateTotalAngle),
      TweenSequenceItem(
          tween: Tween(begin: -5 / 360 * 2 * pi, end: 0 / 360 * 2 * pi)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 5 / rotateTotalAngle),
    ]);

    // 图标旋转动画
    _itemRotateAnimations = [
      rotateSequence.animate(CurvedAnimation(
          parent: controller, curve: const Interval(7 / 12, 12 / 12))),
      rotateSequence.animate(CurvedAnimation(
          parent: controller, curve: const Interval(8 / 12, 12 / 12))),
      rotateSequence.animate(CurvedAnimation(
          parent: controller, curve: const Interval(9 / 12, 12 / 12))),
      rotateSequence.animate(CurvedAnimation(
          parent: controller, curve: const Interval(10 / 12, 12 / 12))),
    ];
  }

  void initReverseAnimations(AnimationController controller,
      {required int rotateDuration, required int totalDuration}) {
    // 红色背景反向动画
    _bgRedScaleReverseAnimation = Tween(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.ease));

    // 圆形背景反向动画
    _bgCircleReverseAnimations = [
      Tween(begin: .0, end: pi / 2)
          .animate(CurvedAnimation(parent: controller, curve: Curves.ease)),
      Tween(begin: .0, end: -pi / 2)
          .animate(CurvedAnimation(parent: controller, curve: Curves.ease)),
      Tween(begin: 3 * pi / 8, end: 7 * pi / 8)
          .animate(CurvedAnimation(parent: controller, curve: Curves.ease)),
    ];

    // 加号按钮反向动画
    _moreIconScaleReverseAnimation =
        TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.3)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30 / 80),
      TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 0.9)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40 / 80),
      TweenSequenceItem(
          tween: Tween(begin: 0.9, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 10 / 80),
    ]).animate(CurvedAnimation(
            parent: controller,
            curve: Interval(0.0, rotateDuration / totalDuration)));

    // 加号按钮旋转反向动画
    _moreIconRotateReverseAnimation = Tween(begin: pi / 4, end: .0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(CurvedAnimation(
            parent: controller,
            curve: Interval(30 / 80 * rotateDuration / totalDuration,
                rotateDuration / totalDuration)));

    // 扩散透明度反向动画
    _spreadOpacityReverseAnimation =
        TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.0)
              .chain(CurveTween(curve: Curves.linear)),
          weight: (30 + 40) / 80 * rotateDuration / totalDuration),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1 - (30 + 40) / 80 * rotateDuration / totalDuration),
    ]).animate(controller);

    // 扩散大小反向动画
    _spreadSizeReverseAnimation =
        TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem(
          tween: Tween(begin: 0.9, end: 0.9)
              .chain(CurveTween(curve: Curves.linear)),
          weight: (30 + 40) / 80 * rotateDuration / totalDuration),
      TweenSequenceItem(
          tween: Tween(begin: 0.9, end: 2.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1 - (30 + 40) / 80 * rotateDuration / totalDuration),
    ]).animate(controller);

    // 图标缩放反向动画
    final itemScaleTween = Tween<double>(begin: 1.0, end: 0.0);
    _itemScaleReverseAnimations = [
      itemScaleTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(6 / 12, 12 / 12, curve: Curves.ease))),
      itemScaleTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(5 / 12, 11 / 12, curve: Curves.ease))),
      itemScaleTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(4 / 12, 10 / 12, curve: Curves.ease))),
      itemScaleTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(3 / 12, 9 / 12, curve: Curves.ease))),
    ];

    // 图标位移反向动画
    final itemTransitionTween =
        Tween(begin: -(_itemContainerWidth / 2 - 60.e - 36.e), end: .0);
    _itemTransitionReverseAnimations = [
      itemTransitionTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(6 / 12, 12 / 12, curve: Curves.ease))),
      itemTransitionTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(5 / 12, 11 / 12, curve: Curves.ease))),
      itemTransitionTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(4 / 12, 10 / 12, curve: Curves.ease))),
      itemTransitionTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(3 / 12, 9 / 12, curve: Curves.ease))),
    ];

    // 图标旋转反向动画
    final itemRotateTween = Tween(begin: .0, end: -15 / 360 * 2 * pi);
    _itemRotateReverseAnimations = [
      itemRotateTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(3 / 12, 6 / 12, curve: Curves.ease))),
      itemRotateTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(2 / 12, 5 / 12, curve: Curves.ease))),
      itemRotateTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(1 / 12, 4 / 12, curve: Curves.ease))),
      itemRotateTween.animate(CurvedAnimation(
          parent: controller,
          curve: const Interval(.0, 3 / 12, curve: Curves.ease))),
    ];
  }

  void _onTapItem(ToolboxType type) {
    _callback = () => widget.onTap?.call(type);
    _onBack();
  }

  void _onBack() {
    setState(() {
      _backPress = true;
      _reverseController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0;
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            _onBack();
          },
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) => ClipPath(
              clipper: RightBottomCircleClipper(
                radius: (_backPress ? 1 - controller.value : controller.value) *
                    diagonal,
              ),
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.e, sigmaY: 10.e),
                  child: Container(
                      color: const Color(0xFFF3EFEB).withOpacity(0.3))),
            ),
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
                    animation: controller,
                    builder: (_, __) => Transform.scale(
                      scale: bgRedScaleAnimation.value,
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
                            animation: controller,
                            builder: (context, child) => Transform.rotate(
                                  angle: bgCircleAnimations[index].value,
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
                        animation: controller,
                        builder: (_, __) => Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.rotate(
                                angle: moreIconRotateAnimation.value,
                                child: Image.asset(ImageRes.chatInputMore,
                                    width: 28.e * moreIconScaleAnimation.value,
                                    height:
                                        28.e * moreIconScaleAnimation.value)),
                            Opacity(
                              opacity: spreadOpacityAnimation.value,
                              child: Transform.scale(
                                scale: spreadSizeAnimation.value,
                                child: Container(
                                  width: 28.e,
                                  height: 28.e,
                                  decoration: BoxDecoration(
                                      color: ColorRes.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: ColorRes.black.withOpacity(0.3),
                                        width:
                                            2.e * spreadOpacityAnimation.value,
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
      animation: controller,
      builder: (context, child) => Transform.rotate(
        angle: _itemAngles[index],
        child: SizedBox(
          width: _itemContainerWidth,
          height: _itemContainerWidth,
          child: Center(
            child: Transform.translate(
              offset: Offset(itemTransitionAnimations[index].value, 0),
              child: GestureDetectorWithSound(
                onTap: onTap,
                child: Transform.rotate(
                    angle:
                        -_itemAngles[index] + itemRotateAnimations[index].value,
                    child: Transform.scale(
                        scale: itemScaleAnimations[index].value,
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
  const RightBottomCircleClipper({required this.radius});
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
