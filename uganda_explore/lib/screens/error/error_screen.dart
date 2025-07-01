import 'package:flutter/material.dart';

class PageNotFoundScreen extends StatelessWidget {
  const PageNotFoundScreen({super.key});
      @override
      Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ) ,
          ),
          body: Stack(
            children: [
              Container(
                color: Colors.green,
                child: Center(
                  child: Icon(
                    Icons.signal_wifi_off,
                    size: 100,
                    color: Colors.black,
                  ),
                ),
              )
              ]
              ),
        );
      }

}
