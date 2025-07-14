import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class DropZone extends StatefulWidget {
  final ValueNotifier<Uint8List?> imageNotifier;
  final VoidCallback onImageDropped;
  const DropZone({
    super.key,
    required this.imageNotifier,
    required this.onImageDropped,
  });

  @override
  State<StatefulWidget> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DropRegion(
        formats: const [...Formats.standardFormats],
        hitTestBehavior: HitTestBehavior.opaque,
        onDropOver: _onDropOver,
        onPerformDrop: _onPerformDrop,
        onDropLeave: _onDropLeave,
        child: Stack(
          children: [
            Positioned.fill(child: _content),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _isDragOver ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _preview,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropOperation _onDropOver(DropOverEvent event) {
    setState(() {
      _isDragOver = true;
      _preview = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: Colors.black.withValues(alpha: 0.2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Center(
            child: DottedBorder(
              color: Colors.lightBlueAccent,
              strokeWidth: 2,
              borderType: BorderType.RRect,
              dashPattern: [8, 4],
              child: Container(
                width: 180,
                height: 120,
                alignment: Alignment.center,
                color: const Color.fromRGBO(
                  30,
                  32,
                  36,
                  0.92,
                ), // dark background with some opacity
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.paste, size: 40, color: Colors.lightBlueAccent),
                    SizedBox(height: 8),
                    Text(
                      'Drop here',
                      style: TextStyle(
                        color: Colors.lightBlueAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
    return event.session.allowedOperations.firstOrNull ?? DropOperation.none;
  }

  Future<void> _onPerformDrop(PerformDropEvent event) async {
    final item = event.session.items.first;
    final reader = item.dataReader!;

    if (reader.canProvide(Formats.png)) {
      reader.getFile(Formats.png, (file) async {
        final data = await file.readAll();
        widget.imageNotifier.value = data;
        widget.onImageDropped();
      }, onError: (error) {});
    }
  }

  void _onDropLeave(DropEvent event) {
    setState(() {
      _isDragOver = false;
    });
  }

  bool _isDragOver = false;

  Widget _preview = const SizedBox();
  final Widget _content = const Center(
    child: Text(
      'Drop here',
      style: TextStyle(color: Colors.grey, fontSize: 16),
    ),
  );
}
