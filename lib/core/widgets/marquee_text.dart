import 'package:flutter/material.dart';

/// A widget that automatically scrolls text horizontally if it overflows its container.
/// Provides a premium "marquee" effect for long track titles.
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  late ScrollController _scrollController;
  bool _needsScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndScroll());
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _scrollController.jumpTo(0);
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndScroll());
    }
  }

  void _checkAndScroll() async {
    if (!mounted || !_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll > 0) {
      setState(() => _needsScroll = true);
      _scrollLoop();
    } else {
      setState(() => _needsScroll = false);
    }
  }

  void _scrollLoop() async {
    if (!mounted || !_needsScroll || !_scrollController.hasClients) return;

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted || !_needsScroll || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;

    await _scrollController.animateTo(
      maxScroll,
      // 30ms per pixel for smooth consistent speed
      duration: Duration(milliseconds: (maxScroll * 30).toInt()),
      curve: Curves.linear,
    );

    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    _scrollController.jumpTo(0);
    _scrollLoop();
  }

  @override
  void dispose() {
    _needsScroll = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        widget.text,
        style: widget.style,
      ),
    );
  }
}
