import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/card_provider.dart';
import '../state/providers.dart';

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
                  child: Stack(
                    children: [
                      buildCard(),
                      buildStamps(provider: provider),
                    ],
                  ),
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

  Widget buildStamps({required CardProvider provider}) {
    final status = provider.getStatus();
    final opacity = provider.getStatusOpacity();

    switch (status) {
      case CardStatus.like:
        final child = buildStamp(
            angle: -0.5, color: Colors.green, text: 'LIKE', opacity: opacity);
        return Positioned(top: 64, left: 50, child: child);
      case CardStatus.dislike:
        final child = buildStamp(
            angle: 0.5, color: Colors.red, text: 'NOPE', opacity: opacity);
        return Positioned(top: 64, right: 50, child: child);
      case CardStatus.superLike:
        final child = buildStamp(
            color: Colors.blue, text: 'SUPER\nLIKE', opacity: opacity);
        return Positioned(bottom: 128, right: 0, left: 0, child: child);
      default:
        return Container();
    }
  }

  Widget buildStamp({
    double angle = 0,
    required Color color,
    required String text,
    required double opacity,
  }) {
    return Opacity(
      opacity: opacity,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 4),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
