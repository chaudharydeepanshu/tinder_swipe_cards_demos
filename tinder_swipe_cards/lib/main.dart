import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinder_swipe_cards/state/providers.dart';
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
              ) // Elevated Button // Center

            : Stack(
                children: urlImages
                    .map((urlImage) => TinderCard(
                          urlImage: urlImage,
                          isFront: urlImages.last == urlImage,
                        ))
                    .toList(),
              );
      },
    );
  }
}
