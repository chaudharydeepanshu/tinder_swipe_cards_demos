import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinder_swipe_cards/state/providers.dart';

class TinderCard extends ConsumerStatefulWidget {
  const TinderCard({Key? key, required this.urlImage, required this.isFront})
      : super(key: key);

  final bool isFront;
  final String urlImage;

  @override
  ConsumerState<TinderCard> createState() => _TinderCardState();
}

class _TinderCardState extends ConsumerState<TinderCard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;

      final provider = ref.read(cardProvider);
      provider.setScreenSize(size);
    });
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: widget.isFront ? buildFrontCard() : buildCard(),
      );

  Widget buildFrontCard() => Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final provider = ref.watch(cardProvider);

          return GestureDetector(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final position = provider.position;
                final milliseconds = provider.isDragging ? 0 : 400;

                final center = constraints.smallest.center(Offset.zero);
                final angle = provider.angle * pi / 180;
                final rotatedMatrix = Matrix4.identity()
                  ..translate(center.dx, center.dy)
                  ..rotateZ(angle)
                  ..translate(-center.dx, -center.dy);

                return AnimatedContainer(
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: milliseconds),
                  transform: rotatedMatrix..translate(position.dx, position.dy),
                  child: buildCard(),
                );
              },
            ),
            onPanStart: (details) {
              provider.startPosition(details);
            },
            onPanUpdate: (details) {
              provider.updatePosition(details);
            },
            onPanEnd: (details) {
              provider.endPosition();
            },
          );
        },
      );
  Widget buildCard() => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.urlImage),
              fit: BoxFit.cover,
              alignment: const Alignment(-0.3, 0),
            ),
          ),
        ),
      );
}
