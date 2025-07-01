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
              ),
              Center(
                child: Card(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.question_mark,
                          size: 50,
                          color: Colors.white,
                        )
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Oops! Page Not Found',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'We couldn\'t find the page you were looking for.',
                        textAlign: TextAlign.center,
                        style: TextStyle( 
                          fontSize: 16,
                          color: Colors.grey[700],
                          
                        ),

                      ),
                    ],),
                ),
              ),
              ]
              ),
        );
      }

}
