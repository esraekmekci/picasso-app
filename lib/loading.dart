import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class LoadingGif extends StatelessWidget {
  const LoadingGif({super.key});

  Future<Widget> _loadGif() async {
    final ByteData data = await rootBundle.load("assets/picaßo.gif");
    final Uint8List bytes = data.buffer.asUint8List();

    return kIsWeb
        ? Image.memory(bytes)
        : Image.asset("assets/picaßo.gif");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _loadGif(),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox(
            width: 100, // Set the desired width
            height: 100, // Set the desired height
            child: snapshot.data!,
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
