import 'dart:ui';

import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e, scale) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    constraints: const BoxConstraints(minWidth: 48),
                    height: scale * 48,
                    width: scale * 48,
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors
                          .primaries[e.hashCode % Colors.primaries.length],
                    ),
                    child: Center(
                      child: Icon(e, color: Colors.white, size: scale * 24.0),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({super.key, this.items = const [], required this.builder});

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T item, double scale) builder;
  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();
  int? _hoveredIndex;
  int? _draggingIndex;
  int? _hoverTargetIndex;

  double calculatedItemValue({
    required int index,
    required double initVal,
    required double maxVal,
    required double nonHoverMaxVal,
  }) {
    if (_hoveredIndex == null) {
      return initVal;
    }
    final distance = (_hoveredIndex! - index).abs();

    if (distance == 0) {
      return maxVal;
    } else if (distance == 1) {
      return lerpDouble(initVal, maxVal, 0.75)!;
    } else if (distance == 2) {
      return lerpDouble(initVal, maxVal, 0.5)!;
    } else if (distance == 3) {
      return lerpDouble(initVal, nonHoverMaxVal, 0.25)!;
    }
    return initVal;
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _items.removeAt(oldIndex);
      if (newIndex >= _items.length) {
        _items.add(item);
      } else {
        _items.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
      }
    });
  }

  double? scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: EdgeInsets.fromLTRB(8, 2, 8, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_items.length, (index) {
          final item = _items[index];

          return DragTarget<int>(
            onWillAccept: (fromIndex) => fromIndex != index,
            onAccept: (fromIndex) {
              _onReorder(fromIndex, index);
            },
            builder: (context, candidateData, rejectedData) {
              return Draggable<int>(
                data: index,
                onDragStarted: () {
                  setState(() => _draggingIndex = index);
                },
                onDraggableCanceled: (_, __) {
                  setState(() => _draggingIndex = null);
                },
                onDragEnd: (_) {
                  setState(() => _draggingIndex = null);
                },
                feedback: Material(
                  color: Colors.transparent,
                  child: Opacity(
                    opacity: 0.95,                  
                    child: widget.builder(item, 1.25),
                  ),
                ),
                childWhenDragging: const SizedBox(width: 48, height: 48),
                child: MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _hoveredIndex = index;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      if (_hoveredIndex == index) {
                        _hoveredIndex = null;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    child: widget.builder(
                      _items[index],
                      calculatedItemValue(
                        index: index,
                        initVal: 1,
                        maxVal: 1.25,
                        nonHoverMaxVal: 1.1,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
