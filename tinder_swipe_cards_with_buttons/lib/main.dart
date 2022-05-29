import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinder_swipe_cards_with_buttons/state/card_provider.dart';
import 'package:tinder_swipe_cards_with_buttons/state/providers.dart';
import 'widget/tinder_card.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tinder Swipe Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: buildCards(),
        ),
      ),
    );
  }

  Widget buildCards() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final provider = ref.watch(cardProvider);
        final urlImages = provider.urlImages;
        return urlImages.isEmpty
            ? Center(
                child: ElevatedButton(
                  child: const Text('Restart'),
                  onPressed: () {
                    provider.resetUsers();
                  },
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: urlImages
                          .map((urlImage) => TinderCard(
                                urlImage: urlImage,
                                isFront: urlImages.last == urlImage,
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  buildButtons(),
                ],
              );
      },
    );
  }

  Widget buildButtons() {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final provider = ref.watch(cardProvider);
        final status = provider.getStatus();
        final isLike = status == CardStatus.like;
        final isDislike = status == CardStatus.dislike;
        final isSuperLike = status == CardStatus.superLike;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(const CircleBorder()),
                foregroundColor: getColor(Colors.red, Colors.white, isDislike),
                backgroundColor: getColor(Colors.white, Colors.red, isDislike),
                side: getBorder(Colors.red, Colors.white, isDislike),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.clear, size: 46),
              ),
              onPressed: () {
                provider.dislike();
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(const CircleBorder()),
                foregroundColor:
                    getColor(Colors.blue, Colors.white, isSuperLike),
                backgroundColor:
                    getColor(Colors.white, Colors.blue, isSuperLike),
                side: getBorder(Colors.blue, Colors.white, isSuperLike),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.star, size: 46),
              ),
              onPressed: () {
                provider.superLike();
              },
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(const CircleBorder()),
                foregroundColor: getColor(Colors.teal, Colors.white, isLike),
                backgroundColor: getColor(Colors.white, Colors.teal, isLike),
                side: getBorder(Colors.teal, Colors.white, isLike),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.favorite, size: 46),
              ),
              onPressed: () {
                provider.like();
              },
            ),
          ],
        );
      },
    );
  }

  MaterialStateProperty<Color> getColor(
      Color color, Color colorPressed, bool force) {
    getColor(Set<MaterialState> states) {
      if (force || states.contains(MaterialState.pressed)) {
        return colorPressed;
      } else {
        return color;
      }
    }

    return MaterialStateProperty.resolveWith(getColor);
  }

  MaterialStateProperty<BorderSide> getBorder(
      Color color, Color colorPressed, bool force) {
    getBorder(Set<MaterialState> states) {
      if (force || states.contains(MaterialState.pressed)) {
        return const BorderSide(color: Colors.transparent);
      } else {
        return BorderSide(color: color, width: 2);
      }
    }

    return MaterialStateProperty.resolveWith(getBorder);
  }
}
