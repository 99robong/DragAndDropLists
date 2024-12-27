// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

class DragAndDropItemTarget extends StatefulWidget {
  final Widget child;
  final DragAndDropListInterface? parent;
  final DragAndDropBuilderParameters parameters;
  final OnItemDropOnLastTarget onReorderOrAdd;
  final bool showDragHandle; // 추가된 속성
  final Positioned? positionedItem;

  const DragAndDropItemTarget({
    Key? key,
    required this.child,
    this.parent,
    required this.parameters,
    required this.onReorderOrAdd,
    required this.showDragHandle,
    required this.positionedItem,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DragAndDropItemTarget();
}

class _DragAndDropItemTarget extends State<DragAndDropItemTarget>
    with TickerProviderStateMixin {
  DragAndDropItem? _hoveredDraggable;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: widget.parameters.verticalAlignment,
          children: <Widget>[
            AnimatedSize(
              duration: Duration(
                  milliseconds: widget.parameters.itemSizeAnimationDuration),
              alignment: Alignment.bottomCenter,
              child: _hoveredDraggable != null
                  ? Opacity(
                      opacity: widget.parameters.itemGhostOpacity,
                      child: widget.parameters.itemGhost ??
                          _hoveredDraggable!.child,
                    )
                  : Container(),
            ),
            widget.child,
          ],
        ),
        // 조건에 따라 드래그 핸들 아이콘을 표시
        if (widget.showDragHandle && widget.positionedItem != null)
          widget.positionedItem as Widget,
        Positioned.fill(
          child: DragTarget<DragAndDropItem>(
            builder: (context, candidateData, rejectedData) {
              if (candidateData.isNotEmpty) {}
              return Container();
            },
            onWillAcceptWithDetails: (details) {
              bool accept = true;
              if (widget.parameters.itemTargetOnWillAccept != null) {
                accept = widget.parameters.itemTargetOnWillAccept!(
                    details.data, widget);
              }
              if (accept && mounted) {
                setState(() {
                  _hoveredDraggable = details.data;
                });
              }
              return accept;
            },
            onLeave: (data) {
              if (mounted) {
                setState(() {
                  _hoveredDraggable = null;
                });
              }
            },
            onAcceptWithDetails: (details) {
              if (mounted) {
                setState(() {
                  widget.onReorderOrAdd(details.data, widget.parent!, widget);
                  _hoveredDraggable = null;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
