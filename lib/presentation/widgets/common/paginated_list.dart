import 'package:flutter/material.dart';

/// A list view with built-in pagination and loading states
class PaginatedListView<T> extends StatefulWidget {
  /// Items to display
  final List<T> items;

  /// Builder for each item
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Callback when more items should be loaded
  final Future<void> Function()? onLoadMore;

  /// Whether more items are available
  final bool hasMore;

  /// Whether currently loading more items
  final bool isLoadingMore;

  /// Separator between items
  final Widget? separator;

  /// Widget to show when list is empty
  final Widget? emptyWidget;

  /// Widget to show at the bottom while loading more
  final Widget? loadingWidget;

  /// Padding for the list
  final EdgeInsetsGeometry? padding;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Shrink wrap
  final bool shrinkWrap;

  /// How close to the bottom to trigger load more (0.0 - 1.0)
  final double loadMoreThreshold;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.separator,
    this.emptyWidget,
    this.loadingWidget,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.loadMoreThreshold = 0.8,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingTriggered = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore || _isLoadingTriggered) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * widget.loadMoreThreshold;

    if (currentScroll >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (widget.onLoadMore == null) return;

    setState(() => _isLoadingTriggered = true);

    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) {
        setState(() => _isLoadingTriggered = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the bottom
        if (index == widget.items.length) {
          return widget.loadingWidget ??
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
        }

        final item = widget.items[index];

        // Item with optional separator
        if (widget.separator != null && index < widget.items.length - 1) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.itemBuilder(context, item, index),
              widget.separator!,
            ],
          );
        }

        return widget.itemBuilder(context, item, index);
      },
    );
  }
}

/// A sliver version of paginated list for use in CustomScrollView
class PaginatedSliverList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final Widget? loadingWidget;
  final double loadMoreThreshold;

  const PaginatedSliverList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadingWidget,
    this.loadMoreThreshold = 0.8,
  });

  @override
  State<PaginatedSliverList<T>> createState() => _PaginatedSliverListState<T>();
}

class _PaginatedSliverListState<T> extends State<PaginatedSliverList<T>> {
  bool _isLoadingTriggered = false;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!widget.hasMore || widget.isLoadingMore || _isLoadingTriggered) {
          return false;
        }

        final maxScroll = notification.metrics.maxScrollExtent;
        final currentScroll = notification.metrics.pixels;
        final threshold = maxScroll * widget.loadMoreThreshold;

        if (currentScroll >= threshold) {
          _loadMore();
        }

        return false;
      },
      child: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == widget.items.length) {
              return widget.loadingWidget ??
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
            }

            return widget.itemBuilder(context, widget.items[index], index);
          },
          childCount: widget.items.length + (widget.hasMore ? 1 : 0),
        ),
      ),
    );
  }

  Future<void> _loadMore() async {
    if (widget.onLoadMore == null) return;

    setState(() => _isLoadingTriggered = true);

    try {
      await widget.onLoadMore!();
    } finally {
      if (mounted) {
        setState(() => _isLoadingTriggered = false);
      }
    }
  }
}

/// Pull to refresh wrapper
class RefreshableList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final Widget? emptyWidget;
  final Widget? separator;
  final EdgeInsetsGeometry? padding;

  const RefreshableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.emptyWidget,
    this.separator,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: PaginatedListView<T>(
        items: items,
        itemBuilder: itemBuilder,
        onLoadMore: onLoadMore,
        hasMore: hasMore,
        isLoadingMore: isLoadingMore,
        emptyWidget: emptyWidget,
        separator: separator,
        padding: padding,
        physics: const AlwaysScrollableScrollPhysics(),
      ),
    );
  }
}
