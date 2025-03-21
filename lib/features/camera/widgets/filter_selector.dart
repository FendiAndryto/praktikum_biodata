import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:saturday_firebase_project/features/camera/widgets/carousel_flow_delegate.dart';
import 'package:saturday_firebase_project/features/camera/widgets/filter_item.dart';

class FilterSelector extends StatefulWidget {
  final List<Color> filters;
  final void Function(Color selectedColor) onFilterChanged;
  final VoidCallback? onFilterTap;
  final EdgeInsets padding;

  const FilterSelector({
    super.key,
    required this.filters,
    required this.onFilterChanged,
    this.onFilterTap,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
  });

  @override
  State<FilterSelector> createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  static const _filtersPerScreen = 5;
  static const _viewportFractionPerItem = 1.0 / _filtersPerScreen;

  late final PageController _controller;
  late int _page;

  int get filterCount => widget.filters.length;

  Color itemColor(int index) => widget.filters[index % filterCount];

  void _onPageChanged() {
    final page = (_controller.page ?? 0).round();
    if (page != _page) {
      _page = page;
      widget.onFilterChanged(widget.filters[page]);
    }
  }

  void _onFilterTapped(int index) {
    if (index == _page) {
      // If tapping current filter, capture photo
      widget.onFilterTap?.call();
    } else {
      // Otherwise, switch to that filter
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 450),
        curve: Curves.ease,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _page = 0;
    _controller = PageController(
      initialPage: _page,
      viewportFraction: _viewportFractionPerItem,
    );
    _controller.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCaptureHint(),
        SizedBox(
          height: 100,
          child: Scrollable(
            controller: _controller,
            axisDirection: AxisDirection.right,
            physics: const PageScrollPhysics(),
            viewportBuilder: (context, viewportOffset) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final itemSize =
                      constraints.maxWidth * _viewportFractionPerItem;
                  viewportOffset
                    ..applyViewportDimension(constraints.maxWidth)
                    ..applyContentDimensions(0.0, itemSize * (filterCount - 1));

                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      _buildShadowGradient(itemSize),
                      _buildCarousel(
                        viewportOffset: viewportOffset,
                        itemSize: itemSize,
                      ),
                      _buildSelectionRing(itemSize),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "Pilih filter dan ketuk untuk ambil foto",
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildShadowGradient(double itemSize) {
    return SizedBox(
      height: itemSize * 2 + widget.padding.vertical,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black45,
            ],
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }

  Widget _buildCarousel({
    required ViewportOffset viewportOffset,
    required double itemSize,
  }) {
    return Container(
      height: itemSize,
      margin: widget.padding,
      child: Flow(
        delegate: CarouselFlowDelegate(
          viewportOffset: viewportOffset,
          filtersPerScreen: _filtersPerScreen,
        ),
        children: [
          for (int i = 0; i < filterCount; i++)
            FilterItem(
              onFilterSelected: () => _onFilterTapped(i),
              color: itemColor(i),
              isSelected: i == _page,
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionRing(double itemSize) {
    return IgnorePointer(
      child: Padding(
        padding: widget.padding,
        child: SizedBox(
          width: itemSize,
          height: itemSize,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(width: 6, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
